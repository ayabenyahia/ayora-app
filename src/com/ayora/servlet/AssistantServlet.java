package com.ayora.servlet;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.ayora.assistant.AssistantOrchestrator;
import com.ayora.assistant.AssistantOrchestrator.AssistantResult;
import com.ayora.assistant.LlmProviderFactory;
import com.ayora.config.AppWiring;
import com.ayora.business.AssistantService;
import com.ayora.business.AyoraService;
import com.ayora.models.QuestionnaireAnswer;
import com.ayora.models.UserProfile;
import com.ayora.util.JsonUtil;

/**
 * AssistantServlet — HTTP boundary for the AYORA conversational assistant.
 *
 * <ul>
 *   <li>{@code POST /api/assistant/chat}       — single user turn, returns structured reply
 *   <li>{@code POST /api/assistant/reset}      — clear the in-session conversation history
 *   <li>{@code GET  /api/assistant/suggestion} — deterministic dashboard hero line
 *   <li>{@code GET  /api/assistant/health}     — which provider is active right now
 * </ul>
 *
 * <p>All routes require an authenticated session. The user id is read from
 * {@code session.userId} only — the front-end cannot impersonate another user
 * by passing an id in the body.
 */
@WebServlet("/api/assistant/*")
public class AssistantServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	private AyoraService metier;
	private AssistantService assistant;
	private AssistantOrchestrator orchestrator;
	private LlmProviderFactory providerFactory;

	@Override
	public void init() throws ServletException {
		this.metier         = AppWiring.getMetier();
		this.assistant      = AppWiring.getAssistant();
		this.orchestrator   = AppWiring.getAssistantOrchestrator();
		this.providerFactory = AppWiring.getLlmProviderFactory();
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String path = request.getPathInfo();
		if ("/chat".equals(path))       handleChat(request, response);
		else if ("/reset".equals(path)) handleReset(request, response);
		else                            JsonUtil.sendError(response, 404, "Route non trouvee");
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String path = request.getPathInfo();
		if ("/suggestion".equals(path)) handleSuggestion(request, response);
		else if ("/health".equals(path)) handleHealth(response);
		else                            JsonUtil.sendError(response, 404, "Route non trouvee");
	}

	// =====================================================================
	// Handlers
	// =====================================================================

	private void handleChat(HttpServletRequest request, HttpServletResponse response) throws IOException {
		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("userId") == null) {
			JsonUtil.sendError(response, 401, "Non authentifie"); return;
		}
		int userId = (int) session.getAttribute("userId");

		String body = JsonUtil.readRequestBody(request);
		String message = JsonUtil.getStringValue(body, "message");
		if (message == null || message.trim().isEmpty()) {
			JsonUtil.sendError(response, 400, "Message vide"); return;
		}
		String currentPage = JsonUtil.getStringValue(body, "currentPage");

		AssistantResult result = orchestrator.handle(session, userId, message, currentPage);
		JsonUtil.sendJson(response, toJson(result));
	}

	private void handleReset(HttpServletRequest request, HttpServletResponse response) throws IOException {
		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("userId") == null) {
			JsonUtil.sendError(response, 401, "Non authentifie"); return;
		}
		orchestrator.resetConversation(session);
		JsonUtil.sendJson(response, "{\"success\":true}");
	}

	private void handleSuggestion(HttpServletRequest request, HttpServletResponse response) throws IOException {
		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("userId") == null) {
			JsonUtil.sendError(response, 401, "Non authentifie"); return;
		}
		int userId = (int) session.getAttribute("userId");
		QuestionnaireAnswer qa = metier.getQuestionnaire(userId);
		UserProfile profile = qa != null ? metier.buildUserProfile(qa) : null;
		String suggestion = assistant.suggestionOfTheDay(profile, qa);
		String json = "{\"suggestion\":\"" + JsonUtil.escapeJson(suggestion) + "\"}";
		JsonUtil.sendJson(response, json);
	}

	private void handleHealth(HttpServletResponse response) throws IOException {
		String desc = providerFactory.describe();
		boolean fallbackMode = "offline-fallback".equals(providerFactory.primary().getProviderName());
		String json = "{\"status\":\"ok\""
			+ ",\"providers\":\"" + JsonUtil.escapeJson(desc) + "\""
			+ ",\"fallbackMode\":" + fallbackMode + "}";
		JsonUtil.sendJson(response, json);
	}

	// =====================================================================
	// JSON serialisation of the assistant result
	// =====================================================================

	private String toJson(AssistantResult r) {
		StringBuilder sb = new StringBuilder();
		sb.append("{");
		sb.append("\"answer\":\"").append(JsonUtil.escapeJson(r.answer)).append("\"");
		sb.append(",\"languageStyle\":\"").append(r.languageStyle).append("\"");
		sb.append(",\"grounded\":").append(r.grounded);
		sb.append(",\"requiresConfirmation\":").append(r.requiresConfirmation);
		sb.append(",\"providerName\":\"").append(JsonUtil.escapeJson(r.providerName == null ? "" : r.providerName)).append("\"");
		sb.append(",\"fallback\":").append(r.fallback);
		if (r.violationCode != null) {
			sb.append(",\"safetyRewriteCode\":\"").append(JsonUtil.escapeJson(r.violationCode)).append("\"");
		}
		if (r.proposedAction != null) {
			sb.append(",\"proposedAction\":{");
			sb.append("\"type\":\"").append(JsonUtil.escapeJson(r.proposedAction.type)).append("\"");
			sb.append(",\"payload\":").append(r.proposedAction.payloadJson == null ? "{}" : r.proposedAction.payloadJson);
			sb.append("}");
		}
		sb.append(",\"suggestedPrompts\":[");
		if (r.suggestedPrompts != null) {
			for (int i = 0; i < r.suggestedPrompts.size(); i++) {
				if (i > 0) sb.append(",");
				sb.append("\"").append(JsonUtil.escapeJson(r.suggestedPrompts.get(i))).append("\"");
			}
		}
		sb.append("]}");
		return sb.toString();
	}
}
