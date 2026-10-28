package com.ayora.assistant;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.List;

import com.ayora.util.JsonUtil;

/**
 * Real Google Gemini provider — used at runtime while the fine-tuned
 * Gemma checkpoint is not yet deployed.
 *
 * <p><b>Honesty for the PFA report</b>: this provider is a development
 * convenience. The academic ML deliverable of the project is the
 * fine-tuned Gemma 2 (2B) model and its training pipeline; Gemini is
 * only used at demo time so the assistant feels alive when the local
 * model is not served. The two must never be conflated in the report.
 *
 * <h3>Activation</h3>
 * Environment variables read at {@link #isAvailable()} time:
 * <pre>
 *   AYORA_CLOUD_API_KEY  (required — the Google AI Studio API key)
 *   AYORA_CLOUD_MODEL    (optional, defaults to "gemini-2.5-flash")
 * </pre>
 *
 * <h3>Endpoint</h3>
 * Verified against Google's official docs (May 2026):
 * <pre>POST https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent
 *   Header: x-goog-api-key: {key}
 *   Header: Content-Type: application/json</pre>
 *
 * <h3>Privacy</h3>
 * This provider only receives what {@code AssistantContextBuilder} hands
 * it: first name, wedding preferences, vendor names already displayed to
 * the user, conversation transcript. It never sees passwords, email,
 * phone, or internal database ids.
 *
 * <h3>No external dependencies</h3>
 * Built on {@link HttpClient} (JDK 11+, present in our JDK 17 runtime).
 * No Gson, Jackson, OkHttp, etc. — we hand-build the JSON payload with
 * the same approach the rest of the project uses (see JsonUtil).
 */
public final class GeminiCloudProvider implements AyoraLlmProvider {

	private static final String DEFAULT_MODEL    = "gemini-2.5-flash";
	private static final String ENDPOINT_FORMAT  = "https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent";
	private static final Duration TIMEOUT        = Duration.ofSeconds(20);

	private final HttpClient http;
	private final String apiKey;
	private final String model;

	public GeminiCloudProvider() {
		this.apiKey = readEnv("AYORA_CLOUD_API_KEY");
		String m = readEnv("AYORA_CLOUD_MODEL");
		this.model = (m == null || m.isEmpty()) ? DEFAULT_MODEL : m;
		this.http  = HttpClient.newBuilder()
			.connectTimeout(Duration.ofSeconds(8))
			.build();
	}

	private static String readEnv(String key) {
		String v = System.getenv(key);
		if (v == null) v = System.getProperty(key);
		return v == null ? "" : v.trim();
	}

	@Override public String getProviderName() { return "gemini-cloud:" + model; }

	@Override public boolean isAvailable() {
		return apiKey != null && !apiKey.isEmpty();
	}

	@Override public AssistantModelResponse generate(AssistantPromptRequest request) throws Exception {
		long start = System.currentTimeMillis();
		String body = buildRequestBody(request);

		HttpRequest httpReq = HttpRequest.newBuilder()
			.uri(URI.create(String.format(ENDPOINT_FORMAT, model)))
			.timeout(TIMEOUT)
			.header("Content-Type", "application/json")
			.header("x-goog-api-key", apiKey)
			.POST(HttpRequest.BodyPublishers.ofString(body, java.nio.charset.StandardCharsets.UTF_8))
			.build();

		HttpResponse<String> resp = http.send(httpReq, HttpResponse.BodyHandlers.ofString(java.nio.charset.StandardCharsets.UTF_8));
		long latency = System.currentTimeMillis() - start;

		if (resp.statusCode() < 200 || resp.statusCode() >= 300) {
			throw new RuntimeException("Gemini HTTP " + resp.statusCode() + " — "
				+ truncate(resp.body(), 240));
		}

		String text = extractCandidateText(resp.body());
		if (text == null || text.trim().isEmpty()) {
			throw new RuntimeException("Gemini empty candidate body — " + truncate(resp.body(), 240));
		}
		return new AssistantModelResponse(text.trim(), getProviderName(), latency, false);
	}

	// ---------------------------------------------------------------------
	// Payload construction
	// ---------------------------------------------------------------------

	/**
	 * Build the Gemini generateContent payload by hand. Format:
	 * <pre>
	 * {
	 *   "system_instruction": { "parts": [{"text": "..."}] },
	 *   "contents": [
	 *     { "role": "user",  "parts": [{"text": "..."}] },
	 *     { "role": "model", "parts": [{"text": "..."}] },
	 *     ...
	 *     { "role": "user",  "parts": [{"text": "<latest>"}] }
	 *   ],
	 *   "generationConfig": { "temperature": 0.7, "maxOutputTokens": 600 }
	 * }
	 * </pre>
	 *
	 * The "trusted context block" is prepended to the system instruction
	 * so that injection attempts inside vendor descriptions or user
	 * messages cannot displace the AYORA persona.
	 */
	private String buildRequestBody(AssistantPromptRequest req) {
		StringBuilder sys = new StringBuilder();
		sys.append(req.systemPrompt);
		if (req.trustedContextBlock != null && !req.trustedContextBlock.isEmpty()) {
			sys.append("\n\n").append(req.trustedContextBlock);
		}

		StringBuilder json = new StringBuilder();
		json.append("{");
		json.append("\"system_instruction\":{\"parts\":[{\"text\":\"")
			.append(JsonUtil.escapeJson(sys.toString())).append("\"}]},");

		json.append("\"contents\":[");
		boolean first = true;
		if (req.history != null) {
			for (int i = 0; i < req.history.size(); i++) {
				AssistantPromptRequest.Turn t = req.history.get(i);
				if (t == null || t.text == null || t.text.isEmpty()) continue;
				if (!first) json.append(",");
				String role = "assistant".equalsIgnoreCase(t.role) ? "model" : "user";
				json.append("{\"role\":\"").append(role).append("\",\"parts\":[{\"text\":\"")
					.append(JsonUtil.escapeJson(t.text)).append("\"}]}");
				first = false;
			}
		}
		if (!first) json.append(",");
		json.append("{\"role\":\"user\",\"parts\":[{\"text\":\"")
			.append(JsonUtil.escapeJson(req.userMessage)).append("\"}]}");
		json.append("],");

		json.append("\"generationConfig\":{");
		json.append("\"temperature\":").append(req.temperature);
		json.append(",\"maxOutputTokens\":").append(req.maxOutputTokens);
		json.append(",\"topP\":0.95");
		json.append("}");

		json.append("}");
		return json.toString();
	}

	/**
	 * Pull <code>candidates[0].content.parts[0].text</code> out of the
	 * Gemini response without dragging Gson into the project. The format
	 * is stable enough that a focused string walk is reliable; if Google
	 * ever changes the shape, the orchestrator falls back to the next
	 * provider.
	 */
	private static String extractCandidateText(String json) {
		if (json == null) return null;

		int candIdx = json.indexOf("\"candidates\"");
		if (candIdx < 0) return null;

		int contentIdx = json.indexOf("\"content\"", candIdx);
		if (contentIdx < 0) return null;

		int partsIdx = json.indexOf("\"parts\"", contentIdx);
		if (partsIdx < 0) return null;

		// Concatenate all "text" fields under parts[*] in document order.
		StringBuilder out = new StringBuilder();
		int cursor = partsIdx;
		while (true) {
			int textKey = json.indexOf("\"text\"", cursor);
			if (textKey < 0) break;
			int colon = json.indexOf(":", textKey);
			if (colon < 0) break;
			int firstQuote = json.indexOf('"', colon + 1);
			if (firstQuote < 0) break;
			// Find the closing quote, accounting for backslash escapes.
			int i = firstQuote + 1;
			StringBuilder val = new StringBuilder();
			boolean escape = false;
			while (i < json.length()) {
				char c = json.charAt(i);
				if (escape) {
					switch (c) {
						case '"':  val.append('"'); break;
						case '\\': val.append('\\'); break;
						case 'n':  val.append('\n'); break;
						case 't':  val.append('\t'); break;
						case 'r':  val.append('\r'); break;
						case '/':  val.append('/'); break;
						case 'u':
							if (i + 4 < json.length()) {
								try {
									int cp = Integer.parseInt(json.substring(i + 1, i + 5), 16);
									val.append((char) cp);
									i += 4;
								} catch (NumberFormatException e) { val.append('?'); }
							}
							break;
						default: val.append(c);
					}
					escape = false;
				} else if (c == '\\') {
					escape = true;
				} else if (c == '"') {
					break;
				} else {
					val.append(c);
				}
				i++;
			}
			out.append(val);
			cursor = i + 1;
			// Stop walking once we leave the parts[] array of candidate[0].
			int closingBracket = json.indexOf(']', cursor);
			int nextCandidateContent = json.indexOf("\"content\"", cursor);
			if (closingBracket > 0 && (nextCandidateContent < 0 || closingBracket < nextCandidateContent)) {
				// Look ahead to see if more parts exist before the bracket.
				int nextText = json.indexOf("\"text\"", cursor);
				if (nextText < 0 || nextText > closingBracket) break;
			} else {
				break;
			}
		}
		return out.toString();
	}

	private static String truncate(String s, int n) {
		if (s == null) return "";
		return s.length() <= n ? s : s.substring(0, n) + "…";
	}
}
