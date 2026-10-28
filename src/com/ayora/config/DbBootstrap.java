package com.ayora.config;

import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.ayora.util.Log;
import com.ayora.util.PasswordHasher;

import jakarta.servlet.ServletContext;

/**
 * Initialisation de la base au demarrage (utile pour l'hebergement en ligne).
 *
 * 1) Si la base est vide (pas de table "vendors"), on importe
 *    /WEB-INF/db/ayora_deploy.sql : tables + prestataires + comptes demo.
 *    En local, la base existe deja : rien n'est fait.
 * 2) Si AYORA_ADMIN_PASSWORD est defini, le compte admin@ayora.ma recoit ce
 *    mot de passe (hashe en PBKDF2). Sans cette variable, le compte admin
 *    de la base en ligne n'a aucun mot de passe utilisable.
 *
 * Desactivable avec AYORA_DB_AUTO_INIT=false.
 */
public final class DbBootstrap {

	private static final Log log = Log.of(DbBootstrap.class);
	private static final String SCRIPT = "/WEB-INF/db/ayora_deploy.sql";
	private static final String ADMIN_EMAIL = "admin@ayora.ma";

	private DbBootstrap() { }

	public static void run(ServletContext ctx) {
		if ("false".equalsIgnoreCase(env("AYORA_DB_AUTO_INIT"))) return;
		// Connexion dediee (le script modifie des variables de session SQL :
		// on ne veut pas polluer la connexion partagee de l'application).
		try (Connection c = AppWiring.getDatabase().getDataSource().getConnection()) {
			if (c == null) { log.warn("DbBootstrap : base injoignable, initialisation ignoree."); return; }
			if (!tableExists(c, "vendors")) importScript(ctx, c);
			setAdminPassword(c);
		} catch (Exception e) {
			log.error("DbBootstrap : echec de l'initialisation de la base", e);
		}
	}

	private static boolean tableExists(Connection c, String table) throws Exception {
		try (PreparedStatement ps = c.prepareStatement(
				"SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = ?")) {
			ps.setString(1, table);
			try (ResultSet rs = ps.executeQuery()) { return rs.next() && rs.getInt(1) > 0; }
		}
	}

	private static void importScript(ServletContext ctx, Connection c) throws Exception {
		String sql;
		try (InputStream in = ctx.getResourceAsStream(SCRIPT)) {
			if (in == null) { log.warn("DbBootstrap : {0} introuvable, base laissee vide.", SCRIPT); return; }
			sql = new String(in.readAllBytes(), StandardCharsets.UTF_8);
		}
		List<String> statements = split(sql);
		log.info("DbBootstrap : base vide, import de {0} instructions...", statements.size());
		boolean auto = c.getAutoCommit();
		c.setAutoCommit(true);
		try (Statement st = c.createStatement()) {
			for (String s : statements) st.execute(s);
		} finally {
			c.setAutoCommit(auto);
		}
		log.info("DbBootstrap : import termine.");
	}

	private static void setAdminPassword(Connection c) throws Exception {
		String pwd = env("AYORA_ADMIN_PASSWORD");
		if (pwd == null || pwd.isEmpty()) return;
		String current = null;
		try (PreparedStatement ps = c.prepareStatement("SELECT password_hash FROM users WHERE email = ?")) {
			ps.setString(1, ADMIN_EMAIL);
			try (ResultSet rs = ps.executeQuery()) {
				if (!rs.next()) return;
				current = rs.getString(1);
			}
		}
		if (PasswordHasher.isHashed(current) && PasswordHasher.verify(pwd, current)) return; // deja a jour
		try (PreparedStatement ps = c.prepareStatement(
				"UPDATE users SET password_hash = ?, password = NULL WHERE email = ?")) {
			ps.setString(1, PasswordHasher.hash(pwd));
			ps.setString(2, ADMIN_EMAIL);
			ps.executeUpdate();
		}
		log.info("DbBootstrap : mot de passe admin mis a jour depuis AYORA_ADMIN_PASSWORD.");
	}

	/**
	 * Decoupe un script SQL en instructions (separateur ';'), en ignorant les
	 * ';' places dans des chaines ('...', "...", `...`) ou des commentaires.
	 */
	static List<String> split(String sql) {
		List<String> out = new ArrayList<>();
		StringBuilder cur = new StringBuilder();
		int n = sql.length();
		char quote = 0;
		for (int i = 0; i < n; i++) {
			char ch = sql.charAt(i);
			if (quote != 0) {
				cur.append(ch);
				if (ch == '\\' && quote != '`' && i + 1 < n) { cur.append(sql.charAt(++i)); continue; }
				if (ch == quote) {
					if (i + 1 < n && sql.charAt(i + 1) == quote) { cur.append(sql.charAt(++i)); continue; }
					quote = 0;
				}
				continue;
			}
			if (ch == '\'' || ch == '"' || ch == '`') { quote = ch; cur.append(ch); continue; }
			if (ch == '-' && i + 1 < n && sql.charAt(i + 1) == '-' && (i + 2 >= n || Character.isWhitespace(sql.charAt(i + 2)))) {
				while (i < n && sql.charAt(i) != '\n') i++;
				cur.append('\n');
				continue;
			}
			if (ch == '#') { while (i < n && sql.charAt(i) != '\n') i++; cur.append('\n'); continue; }
			if (ch == '/' && i + 1 < n && sql.charAt(i + 1) == '*' && !(i + 2 < n && sql.charAt(i + 2) == '!')) {
				int end = sql.indexOf("*/", i + 2);
				i = (end < 0) ? n : end + 1;
				continue;
			}
			if (ch == ';') {
				String s = cur.toString().trim();
				if (!s.isEmpty()) out.add(s);
				cur.setLength(0);
				continue;
			}
			cur.append(ch);
		}
		String s = cur.toString().trim();
		if (!s.isEmpty()) out.add(s);
		return out;
	}

	private static String env(String key) {
		String v = System.getenv(key);
		return (v == null) ? System.getProperty(key) : v;
	}
}
