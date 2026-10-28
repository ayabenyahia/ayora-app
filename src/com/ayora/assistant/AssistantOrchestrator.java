package com.ayora.assistant;

import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import jakarta.servlet.http.HttpSession;

/**
 * The pipeline that turns a raw user message into a structured AYORA
 * response.
 *
 * <pre>
 *   user message
 *      ↓
 *   detectLanguage()        ← lightweight heuristic, used to hint reply language
 *   AssistantSafetyGuard.preCheck()  ← detect risky asks, harden system prompt
 *   AssistantContextBuilder.build()  ← trusted profile/budget/vendor block
 *   AssistantConversationStore       ← recent turns
 *   AssistantPromptBuilder           ← persona + rules
 *      ↓
 *   provider chain (Gemma endpoint → Gemini → Fallback)
 *      ↓
 *   parse trailing ```action and ```prompts blocks (if any)
 *   AssistantSafetyGuard.postCheck() ← rewrite if hallucination detected
 *      ↓
 *   AssistantConversationStore.appendUser/Assistant
 *      ↓
 *   AssistantResult
 * </pre>
 */
public final class AssistantOrchestrator {

	private static final Logger LOG = Logger.getLogger(AssistantOrchestrator.class.getName());

	private final LlmProviderFactory providerFactory;
	private final AssistantContextBuilder contextBuilder;
	private final AssistantConversationStore conversationStore;
	private final AssistantSafetyGuard safetyGuard;
	private final AssistantPromptBuilder promptBuilder;

	public AssistantOrchestrator(
		LlmProviderFactory providerFactory,
		AssistantContextBuilder contextBuilder,
		AssistantConversationStore conversationStore,
		AssistantSafetyGuard safetyGuard,
		AssistantPromptBuilder promptBuilder
	) {
		this.providerFactory   = providerFactory;
		this.contextBuilder    = contextBuilder;
		this.conversationStore = conversationStore;
		this.safetyGuard       = safetyGuard;
		this.promptBuilder     = promptBuilder;
	}

	// =====================================================================
	// Result DTO
	// =====================================================================

	public static final class AssistantResult {
		public String answer;
		public String languageStyle;     // "french" / "darija_ar" / "darija_latin" / "mixed"
		public boolean grounded;         // true when we had real trusted context
		public boolean requiresConfirmation; // true when a proposed action exists
		public ProposedAction proposedAction;
		public List<String> suggestedPrompts = new ArrayList<String>();
		public String providerName;
		public boolean fallback;         // came from FallbackProvider
		public String violationCode;     // safety violation rewrite, if any
	}

	public static final class ProposedAction {
		public String type;
		public String payloadJson;       // raw JSON object (we keep it as a string)
		public ProposedAction(String type, String payloadJson) {
			this.type = type;
			this.payloadJson = payloadJson;
		}
	}

	// =====================================================================
	// Public entry points
	// =====================================================================

	public AssistantResult handle(HttpSession session, int userId, String userMessage, String currentPage) {
		AssistantResult out = new AssistantResult();
		String trimmed = userMessage == null ? "" : userMessage.trim();
		String lang = detectLanguage(trimmed);
		out.languageStyle = lang;
		out.grounded = true;

		// 1. Pre-check (does not replace the LLM, only tightens its prompt).
		AssistantSafetyGuard.PreCheckSignals pre = safetyGuard.preCheck(trimmed);

		// 2. Build prompt: system + trusted context (+ safety reminder if any).
		String systemPrompt = promptBuilder.systemPrompt();
		String trusted      = contextBuilder.build(userId, currentPage);
		if (pre.any()) trusted += pre.reminderBlock();

		// 3. Pull recent history.
		List<AssistantPromptRequest.Turn> history = conversationStore.tail(session, AssistantConversationStore.MAX_TURNS);

		// 4. Build request.
		AssistantPromptRequest req = new AssistantPromptRequest(
			systemPrompt, trusted, history, trimmed, lang, 0.7, 600);

		// 5. Try providers in order.
		AssistantModelResponse modelResp = callProviderChain(req, lang);
		out.providerName = modelResp.providerName;
		out.fallback     = modelResp.fallback;

		// 6. Strip and parse trailing ```action / ```prompts blocks.
		String[] parts = splitOutBlocks(modelResp.text);
		String answer  = parts[0];
		String actionBlock  = parts[1];
		String promptsBlock = parts[2];

		// 7. Post-check rewriting (booking / availability / real-price hallucinations).
		AssistantSafetyGuard.PostCheckResult post = safetyGuard.postCheck(answer, lang);
		out.answer        = post.sanitizedText;
		out.violationCode = post.violationCode;
		if (post.violated) {
			// If we rewrote the answer we drop the proposed action and prompts —
			// they may be tied to a hallucination we just removed.
			actionBlock = null;
			promptsBlock = null;
		}

		// 8. Parse the action block (no action execution — that's the front-end's job after confirm).
		out.proposedAction = parseAction(actionBlock);
		out.requiresConfirmation = out.proposedAction != null;

		// 9. Parse the prompt suggestions.
		out.suggestedPrompts = parsePrompts(promptsBlock);

		// 10. Persist this turn in the session history (after possible rewrite).
		if (session != null) {
			conversationStore.appendUser(session, trimmed);
			conversationStore.appendAssistant(session, out.answer);
		}

		return out;
	}

	public void resetConversation(HttpSession session) {
		conversationStore.reset(session);
	}

	// =====================================================================
	// Helpers
	// =====================================================================

	private AssistantModelResponse callProviderChain(AssistantPromptRequest req, String lang) {
		List<AyoraLlmProvider> chain = providerFactory.fallbackChain();
		for (int i = 0; i < chain.size(); i++) {
			AyoraLlmProvider p = chain.get(i);
			try {
				AssistantModelResponse r = p.generate(req);
				if (r != null && r.text != null && !r.text.trim().isEmpty()) return r;
				LOG.log(Level.WARNING, "[AYORA] empty answer from " + p.getProviderName() + ", trying next");
			} catch (Exception e) {
				// Log error type without leaking the prompt content.
				LOG.log(Level.WARNING, "[AYORA] provider " + p.getProviderName()
					+ " failed: " + e.getClass().getSimpleName() + " — falling back");
			}
		}
		// All providers failed — should not happen because FallbackProvider can't fail.
		return new FallbackProvider().generate(new AssistantPromptRequest(
			"", "", new ArrayList<AssistantPromptRequest.Turn>(), "", lang, 0.7, 200));
	}

	/**
	 * Lightweight language detector — same heuristic as the previous
	 * AssistantService, kept here so the orchestrator is self-contained.
	 */
	public static String detectLanguage(String text) {
		if (text == null || text.isEmpty()) return "french";
		int arabic = 0, latin = 0;
		for (int i = 0; i < text.length(); i++) {
			int c = text.charAt(i);
			if (c >= 0x0600 && c <= 0x06FF) arabic++;
			else if ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')) latin++;
		}
		int total = arabic + latin;
		if (total == 0) return "french";
		double ar = arabic / (double) total;
		if (ar > 0.6) return "darija_ar";
		if (ar > 0.15 && latin > 0) return "mixed";
		String lower = text.toLowerCase();
		String[] arabizi = {"bghit","khass","chno","wash","kifach","m3a","dyal","9bel","daba","3la","7it","3andi","fes","ngafa","ana"};
		for (String t : arabizi) if (lower.matches(".*\\b" + t + "\\b.*")) return "darija_latin";
		return "french";
	}

	/**
	 * Split a model output into [main answer, action block, prompts block].
	 * Action and prompts blocks are returned without their ``` fences.
	 */
	static String[] splitOutBlocks(String raw) {
		if (raw == null) return new String[]{ "", null, null };
		String text = raw;
		String action = null, prompts = null;

		int actionStart = text.indexOf("```action");
		if (actionStart >= 0) {
			int contentStart = text.indexOf('\n', actionStart);
			int end = text.indexOf("```", contentStart < 0 ? actionStart + 1 : contentStart);
			if (contentStart > 0 && end > contentStart) {
				action = text.substring(contentStart + 1, end).trim();
				text = (text.substring(0, actionStart) + text.substring(end + 3)).trim();
			}
		}
		int promptsStart = text.indexOf("```prompts");
		if (promptsStart >= 0) {
			int contentStart = text.indexOf('\n', promptsStart);
			int end = text.indexOf("```", contentStart < 0 ? promptsStart + 1 : contentStart);
			if (contentStart > 0 && end > contentStart) {
				prompts = text.substring(contentStart + 1, end).trim();
				text = (text.substring(0, promptsStart) + text.substring(end + 3)).trim();
			}
		}
		return new String[]{ text.trim(), action, prompts };
	}

	static ProposedAction parseAction(String json) {
		if (json == null || json.isEmpty()) return null;
		// Extract "type" value.
		int typeKey = json.indexOf("\"type\"");
		if (typeKey < 0) return null;
		int colon = json.indexOf(':', typeKey);
		int firstQuote = json.indexOf('"', colon + 1);
		int closingQuote = json.indexOf('"', firstQuote + 1);
		if (firstQuote < 0 || closingQuote < 0) return null;
		String type = json.substring(firstQuote + 1, closingQuote);

		// Extract whole "payload" sub-object verbatim if present.
		int payloadKey = json.indexOf("\"payload\"");
		String payloadJson = "{}";
		if (payloadKey >= 0) {
			int openBrace = json.indexOf('{', payloadKey);
			if (openBrace > 0) {
				int depth = 0;
				int i = openBrace;
				for (; i < json.length(); i++) {
					char c = json.charAt(i);
					if (c == '{') depth++;
					else if (c == '}') { depth--; if (depth == 0) { i++; break; } }
				}
				payloadJson = json.substring(openBrace, i);
			}
		}
		return new ProposedAction(type, payloadJson);
	}

	static List<String> parsePrompts(String json) {
		List<String> out = new ArrayList<String>();
		if (json == null) return out;
		int from = 0;
		while (true) {
			int q1 = json.indexOf('"', from);
			if (q1 < 0) break;
			int q2 = json.indexOf('"', q1 + 1);
			if (q2 < 0) break;
			String s = json.substring(q1 + 1, q2);
			// Skip if it's just a list-format artefact like "" or "["
			if (!s.isEmpty() && s.length() < 80) out.add(s);
			from = q2 + 1;
			if (out.size() >= 3) break;
		}
		return out;
	}
}
