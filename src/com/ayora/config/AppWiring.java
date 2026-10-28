package com.ayora.config;

import com.ayora.dao.AdminStatsDao;
import com.ayora.dao.AdminStatsDaoJdbc;
import com.ayora.dao.DevisDao;
import com.ayora.dao.DevisDaoJdbc;
import com.ayora.dao.GuestDao;
import com.ayora.dao.GuestDaoJdbc;
import com.ayora.dao.InvitationDao;
import com.ayora.dao.InvitationDaoJdbc;
import com.ayora.dao.QuestionnaireDao;
import com.ayora.dao.QuestionnaireDaoJdbc;
import com.ayora.dao.RecommendationDao;
import com.ayora.dao.RecommendationDaoJdbc;
import com.ayora.dao.RendezVousDao;
import com.ayora.dao.RendezVousDaoJdbc;
import com.ayora.dao.SubscriptionDao;
import com.ayora.dao.SubscriptionDaoJdbc;
import com.ayora.dao.UserDao;
import com.ayora.dao.UserDaoJdbc;
import com.ayora.dao.UserPickDao;
import com.ayora.dao.UserPickDaoJdbc;
import com.ayora.dao.VendorDao;
import com.ayora.dao.VendorDaoJdbc;
import com.ayora.assistant.AssistantContextBuilder;
import com.ayora.assistant.AssistantConversationStore;
import com.ayora.assistant.AssistantOrchestrator;
import com.ayora.assistant.AssistantPromptBuilder;
import com.ayora.assistant.AssistantSafetyGuard;
import com.ayora.assistant.LlmProviderFactory;
import com.ayora.business.AssistantService;
import com.ayora.business.AyoraServiceDefault;
import com.ayora.business.AyoraService;
import com.ayora.dao.jdbc.Database;
import com.ayora.dao.jdbc.MySQLDataSource;

/**
 * Wiring centralise de l'application Ayora.
 *
 * Une seule instance est creee au demarrage pour :
 *   - la DataSource
 *   - la Database
 *   - chacun des 11 DAO
 *   - le metier (AyoraServiceDefault)
 *
 * Les Servlets recuperent la meme instance metier via getMetier().
 */
public final class AppWiring {

	// === 1. Configuration de la base de donnees ===
	// Externalisee : surchargeable par variables d'environnement (ou -D),
	// avec valeurs par defaut pour le developpement local (XAMPP).
	private static final String DB_NAME     = env("AYORA_DB_NAME", "ayora_db");
	private static final String DB_USER     = env("AYORA_DB_USER", "root");
	private static final String DB_PASSWORD = env("AYORA_DB_PASSWORD", "");
	// Hebergement en ligne (ex : Aiven) : la base n'est plus sur "localhost".
	private static final String DB_HOST     = env("AYORA_DB_HOST", "localhost");
	private static final String DB_PORT     = env("AYORA_DB_PORT", "");
	private static final boolean DB_SSL     = Boolean.parseBoolean(env("AYORA_DB_SSL", "false"));

	/** Lit une variable d'environnement (sinon une propriete systeme, sinon la valeur par defaut). */
	private static String env(String key, String defaultValue) {
		String v = System.getenv(key);
		if (v == null) v = System.getProperty(key);
		return (v == null || v.isEmpty()) ? defaultValue : v;
	}

	// === 2. DataSource + Database (instances uniques) ===
	// En local : jdbc:mysql://localhost/ayora_db (comportement inchange).
	// En ligne : jdbc:mysql://<hote>:<port>/<base>?sslMode=REQUIRED
	private static final MySQLDataSource DATA_SOURCE =
		new MySQLDataSource(dbAddress(), DB_NAME + dbOptions(), DB_USER, DB_PASSWORD);

	/** "hote" ou "hote:port". */
	private static String dbAddress() {
		return DB_PORT.isEmpty() ? DB_HOST : DB_HOST + ":" + DB_PORT;
	}

	/** Options JDBC : SSL obligatoire chez les hebergeurs MySQL (Aiven, etc.). */
	private static String dbOptions() {
		return DB_SSL ? "?sslMode=REQUIRED" : "";
	}
	private static final Database DATABASE = new Database(DATA_SOURCE);

	// === 3. DAOs (instances uniques) ===
	private static final UserDao           USER_DAO          = new UserDaoJdbc(DATABASE);
	private static final VendorDao         VENDOR_DAO        = new VendorDaoJdbc(DATABASE);
	// Inversion de dependance (cf. cours) : GuestDao a deux implementations.
	// Pour basculer en memoire (sans base), commenter la ligne JDBC et activer l'autre.
	// private static final GuestDao       GUEST_DAO         = new GuestDaoMemory();
	private static final GuestDao          GUEST_DAO         = new GuestDaoJdbc(DATABASE);
	private static final InvitationDao     INVITATION_DAO    = new InvitationDaoJdbc(DATABASE);
	private static final QuestionnaireDao  QUESTIONNAIRE_DAO = new QuestionnaireDaoJdbc(DATABASE);
	private static final RecommendationDao RECOMMENDATION_DAO= new RecommendationDaoJdbc(DATABASE);
	private static final SubscriptionDao   SUBSCRIPTION_DAO  = new SubscriptionDaoJdbc(DATABASE);
	private static final UserPickDao       USER_PICK_DAO     = new UserPickDaoJdbc(DATABASE);
	private static final DevisDao          DEVIS_DAO         = new DevisDaoJdbc(DATABASE);
	private static final RendezVousDao     RDV_DAO           = new RendezVousDaoJdbc(DATABASE);
	private static final AdminStatsDao     ADMIN_STATS_DAO   = new AdminStatsDaoJdbc(DATABASE);

	// === 4. Metier (instance unique) ===
	private static final AyoraService METIER = new AyoraServiceDefault(
		USER_DAO, VENDOR_DAO, GUEST_DAO, INVITATION_DAO,
		QUESTIONNAIRE_DAO, RECOMMENDATION_DAO, SUBSCRIPTION_DAO, USER_PICK_DAO,
		DEVIS_DAO, RDV_DAO, ADMIN_STATS_DAO);

	// === 5. AYORA Assistant pipeline ============================================
	// Real-LLM-backed assistant. The provider used at runtime is picked from
	// AYORA_AI_PROVIDER / AYORA_MODEL_ENDPOINT / AYORA_CLOUD_API_KEY env vars
	// (see com.ayora.assistant.LlmProviderFactory). When no provider is
	// configured the pipeline degrades to com.ayora.assistant.FallbackProvider,
	// which clearly tells the user it cannot give personalised advice.
	private static final LlmProviderFactory       LLM_FACTORY      = new LlmProviderFactory();
	private static final AssistantContextBuilder  CONTEXT_BUILDER  = new AssistantContextBuilder(METIER);
	private static final AssistantConversationStore CONV_STORE     = new AssistantConversationStore();
	private static final AssistantSafetyGuard     SAFETY_GUARD     = new AssistantSafetyGuard();
	private static final AssistantPromptBuilder   PROMPT_BUILDER   = new AssistantPromptBuilder();
	private static final AssistantOrchestrator    ORCHESTRATOR     = new AssistantOrchestrator(
		LLM_FACTORY, CONTEXT_BUILDER, CONV_STORE, SAFETY_GUARD, PROMPT_BUILDER);
	private static final AssistantService         ASSISTANT        = new AssistantService(ORCHESTRATOR);

	private AppWiring() {
		// utility class : pas d'instance
	}

	// === API publique ===

	/** Point d'entree principal : utilise par tous les Servlets. */
	public static AyoraService getMetier() { return METIER; }

	/** AYORA conversational assistant facade. */
	public static AssistantService getAssistant() { return ASSISTANT; }

	/** Orchestrator handle (servlet uses this for chat + reset endpoints). */
	public static AssistantOrchestrator getAssistantOrchestrator() { return ORCHESTRATOR; }

	/** Provider chain inspector — surfaced by /api/assistant/health. */
	public static LlmProviderFactory getLlmProviderFactory() { return LLM_FACTORY; }

	/** Conversation store handle for reset / inspection. */
	public static AssistantConversationStore getConversationStore() { return CONV_STORE; }

	/** Database brut (utile pour Examples.java en CLI). */
	public static Database getDatabase() { return DATABASE; }
}
