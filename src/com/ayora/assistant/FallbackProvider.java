package com.ayora.assistant;

/**
 * Minimal offline fallback.
 *
 * <p>Used only when no real LLM provider is configured or the configured
 * provider fails. The message is intentionally honest about the
 * limitation — the orchestrator must not present this as the
 * "intelligent assistant". Logs show
 * {@code "[AYORA] AI provider unavailable — fallback mode active"}.
 *
 * <p>Per spec section 3 / 15 / 17: the fallback is NOT a hardcoded
 * response library. The full template engine that previously lived in
 * {@code AssistantService} is retired — keeping it would re-create the
 * "smart-looking but actually dumb" experience.
 */
public final class FallbackProvider implements AyoraLlmProvider {

	@Override public String getProviderName() { return "offline-fallback"; }

	@Override public boolean isAvailable() { return true; }

	@Override public AssistantModelResponse generate(AssistantPromptRequest req) {
		String lang = req == null ? "french" : req.languageHint;
		String body;
		switch (lang) {
			case "darija_ar":
				body = "ما قدرتش نحضر ليك جواب شخصي دابا. مازال نقدر نعاونك تشوفي الميزانية، اللائحة ديالك، ولا الموردين المقترحين فالتطبيق. عاودي تجربي دغيا.";
				break;
			case "darija_latin":
				body = "Ma 9dertch n7adro lik jawab chakhsi daba. Mazal n9der n3awnek tchoufi mizania, checklist dyalek, ola moridin l m9traha f l'application. 3awad jarbi dghya.";
				break;
			case "mixed":
				body = "Je rencontre momentanément une difficulté pour préparer un conseil personnalisé. Mazal n9der n3awnek tchoufi ton budget, ta checklist ou tes prestataires dans l'application — réessaie dans un instant.";
				break;
			case "french":
			default:
				body = "Je rencontre momentanément une difficulté pour préparer un conseil personnalisé. Je peux toutefois t'aider à consulter ton budget, ta checklist ou tes recommandations depuis l'application. Réessaie dans un instant.";
		}
		return new AssistantModelResponse(body, getProviderName(), 0, true);
	}
}
