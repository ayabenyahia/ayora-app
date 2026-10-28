package com.ayora.dao.jdbc;
import com.ayora.util.Log;

import java.sql.Connection;
import java.sql.DriverManager;

public class DataSource {
	private static final Log log = Log.of(DataSource.class);
	private String driver;
	private String url;
	private String username;
	private String password;

	public DataSource() {

	}

	public DataSource(String driver, String url, String username, String password) {
		super();
		this.driver = driver;
		this.url = url;
		this.username = username;
		this.password = password;
	}

	public String getDriver() {
		return driver;
	}

	public void setDriver(String driver) {
		this.driver = driver;
	}

	public String getUrl() {
		return url;
	}

	public void setUrl(String url) {
		this.url = url;
	}

	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public Connection getConnection() {
		try {
			// 1. Chargement du driver :
			Class.forName(driver);
			// 2. Connexion :
			Connection db = DriverManager.getConnection(url, username, password);
			log.debug("Connection established successfully");
			return db;
		} catch (Exception e) {
			log.warn("Connection failed : " + e.getMessage());
			return null;
		}
	}
}
