package com.ayora.dao.jdbc;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.List;
import java.util.Vector;

import com.ayora.dao.mappers.RowMapper;
import com.ayora.util.Log;

/**
 * Classe Database : centralise les operations JDBC reutilisables.
 *
 * Modele de connexion identique au cours : UNE seule connexion est ouverte
 * une fois (dans le constructeur) puis reutilisee pour toutes les requetes.
 * On n'ouvre donc jamais une connexion par requete.
 *
 * Les methodes template (queryList, queryOne, queryInt, executeUpdate,
 * insertReturningKey) utilisent PreparedStatement (anti-injection) et ferment
 * leurs Statement/ResultSet ; la connexion partagee, elle, reste ouverte toute
 * la duree de vie de l'application (fermee par shutdown()).
 */
public class Database {

	private static final Log log = Log.of(Database.class);

	private final DataSource dataSource;
	private Connection db; // connexion UNIQUE, ouverte une seule fois (comme le cours)
	private long lastUse = System.currentTimeMillis();
	private static final long IDLE_CHECK_MS = 30_000; // verif. apres 30 s d'inactivite

	public Database(DataSource dataSource) {
		this.dataSource = dataSource;
		this.db = dataSource.getConnection(); // ouverture unique au demarrage
	}

	// ============================================================
	// Gestion de connexion : une connexion unique partagee
	// ============================================================

	/**
	 * Retourne la connexion unique. Elle est rouverte UNIQUEMENT si elle a ete
	 * fermee/expiree cote serveur (garde-fou) — on reste sur une seule connexion
	 * vivante a la fois.
	 */
	public Connection getConnection() throws SQLException {
		long now = System.currentTimeMillis();
		// Une base hebergee (Aiven...) coupe les connexions inactives sans
		// prevenir : apres un moment sans requete, on verifie que la connexion
		// repond encore, sinon on en rouvre une (toujours une seule a la fois).
		if (db != null && !db.isClosed() && now - lastUse > IDLE_CHECK_MS && !db.isValid(3)) {
			try { db.close(); } catch (SQLException ignore) { /* deja morte */ }
			db = null;
		}
		if (db == null || db.isClosed()) {
			db = dataSource.getConnection();
		}
		if (db == null) {
			throw new SQLException("## Erreur : connexion impossible a la base de donnees.");
		}
		lastUse = now;
		return db;
	}

	/**
	 * Ferme les ressources jetables (PreparedStatement, ResultSet, ...).
	 * La connexion UNIQUE n'est jamais fermee ici : elle vit toute la duree de
	 * l'application (fermeture via shutdown()).
	 */
	public void close(AutoCloseable... resources) {
		if (resources == null) return;
		for (AutoCloseable r : resources) {
			if (r == null || r instanceof Connection) continue; // ne jamais fermer la connexion partagee
			try { r.close(); }
			catch (Exception e) { log.warn("## Erreur fermeture : " + e.getMessage()); }
		}
	}

	/** Ferme la connexion unique (a appeler a l'arret de l'application). */
	public void shutdown() {
		try { if (db != null && !db.isClosed()) db.close(); }
		catch (SQLException e) { log.warn("## Erreur fermeture connexion : " + e.getMessage()); }
	}

	public DataSource getDataSource() {
		return dataSource;
	}

	// ============================================================
	// Methodes template (le DAO ne s'occupe plus du boilerplate
	// open/finally/close — il decrit juste sa requete + son mapping)
	// ============================================================

	/**
	 * Execute un SELECT et retourne la liste mappee.
	 * Exemple : db.queryList("SELECT * FROM guests WHERE user_id=?", this::mapGuest, userId);
	 */
	public <T> List<T> queryList(String sql, RowMapper<T> mapper, Object... params) {
		List<T> list = new Vector<T>();
		Connection c = null;
		try {
			c = getConnection();
			try (PreparedStatement ps = c.prepareStatement(sql)) {
				bindParams(ps, params);
				try (ResultSet rs = ps.executeQuery()) {
					while (rs.next()) list.add(mapper.map(rs));
				}
			}
		} catch (SQLException e) {
			log.warn("## queryList erreur [" + sql + "] : " + e.getMessage());
		} finally {
			close(c);
		}
		return list;
	}

	/**
	 * Execute un SELECT et retourne le 1er resultat (ou null si vide).
	 * Exemple : db.queryOne("SELECT * FROM users WHERE id=?", this::mapUser, id);
	 */
	public <T> T queryOne(String sql, RowMapper<T> mapper, Object... params) {
		List<T> list = queryList(sql, mapper, params);
		return list.isEmpty() ? null : list.get(0);
	}

	/**
	 * Execute INSERT/UPDATE/DELETE et retourne le nombre de lignes affectees.
	 * Exemple : db.executeUpdate("DELETE FROM guests WHERE id=?", id);
	 */
	public int executeUpdate(String sql, Object... params) {
		Connection c = null;
		try {
			c = getConnection();
			try (PreparedStatement ps = c.prepareStatement(sql)) {
				bindParams(ps, params);
				return ps.executeUpdate();
			}
		} catch (SQLException e) {
			log.warn("## executeUpdate erreur [" + sql + "] : " + e.getMessage());
			return 0;
		} finally {
			close(c);
		}
	}

	/**
	 * Execute un INSERT et retourne la cle generee (ou -1 si erreur).
	 * Exemple : int id = db.insertReturningKey("INSERT INTO users (...) VALUES (?,?)", a, b);
	 */
	public int insertReturningKey(String sql, Object... params) {
		Connection c = null;
		try {
			c = getConnection();
			try (PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
				bindParams(ps, params);
				ps.executeUpdate();
				try (ResultSet keys = ps.getGeneratedKeys()) {
					if (keys.next()) return keys.getInt(1);
				}
			}
			return -1;
		} catch (SQLException e) {
			log.warn("## insert erreur [" + sql + "] : " + e.getMessage());
			return -1;
		} finally {
			close(c);
		}
	}

	/** Compte (renvoie le 1er int d'une requete agregat type SELECT COUNT(*)). */
	public int queryInt(String sql, Object... params) {
		Connection c = null;
		try {
			c = getConnection();
			try (PreparedStatement ps = c.prepareStatement(sql)) {
				bindParams(ps, params);
				try (ResultSet rs = ps.executeQuery()) {
					if (rs.next()) return rs.getInt(1);
				}
			}
		} catch (SQLException e) {
			log.warn("## queryInt erreur [" + sql + "] : " + e.getMessage());
		} finally {
			close(c);
		}
		return 0;
	}

	private void bindParams(PreparedStatement ps, Object... params) throws SQLException {
		if (params == null) return;
		for (int i = 0; i < params.length; i++) {
			Object p = params[i];
			if (p == null)                    ps.setObject(i + 1, null);
			else if (p instanceof Integer)    ps.setInt(i + 1, (Integer) p);
			else if (p instanceof Long)       ps.setLong(i + 1, (Long) p);
			else if (p instanceof Double)     ps.setDouble(i + 1, (Double) p);
			else if (p instanceof Float)      ps.setFloat(i + 1, (Float) p);
			else if (p instanceof Boolean)    ps.setBoolean(i + 1, (Boolean) p);
			else                              ps.setString(i + 1, p.toString());
		}
	}

	// ============================================================
	// Methodes utilitaires simples : SELECT * generique par nom de
	// table. Utilisees par Examples.java en mode CLI ; les DAO passent
	// par les methodes template (queryList, queryOne, ...).
	// ============================================================

	public String[][] executeSelect(String query) {
		Connection c = null;
		try {
			c = getConnection();
			try (Statement sql = c.createStatement(
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_READ_ONLY);
					ResultSet rs = sql.executeQuery(query)) {
				rs.last();
				int rows = rs.getRow();
				rs.beforeFirst();
				ResultSetMetaData rsm = rs.getMetaData();
				int cols = rsm.getColumnCount();
				String[][] data = new String[rows][cols];
				int row = 0;
				while (rs.next()) {
					for (int col = 0; col < cols; col++) data[row][col] = rs.getString(col + 1);
					row++;
				}
				return data;
			}
		} catch (Exception e) {
			log.warn("## executeSelect : " + e.getMessage());
			return null;
		} finally {
			close(c);
		}
	}

	public String[][] selectAll(String tableName) {
		return executeSelect("SELECT * FROM " + tableName);
	}

	// === Methodes legacy SUPPRIMEES en v1.1 (audit securite) =============
	// selectByKeyword(), selectById(), insert(), delete() concatenaient
	// tableName/key/value directement dans la chaine SQL : injection garantie
	// si un input utilisateur les atteignait un jour. Tous les vrais usages
	// passent desormais par les DAO (UserDao, VendorDao, ...) qui utilisent
	// PreparedStatement via db.queryOne/queryList/executeUpdate/insertReturningKey.
	// =====================================================================
}
