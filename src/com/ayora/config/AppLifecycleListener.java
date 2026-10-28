package com.ayora.config;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

/**
 * Ferme le pool de connexions a l'arret (ou au redeploiement) de l'application.
 *
 * Sans ca, chaque redeploiement laisserait les connexions du pool ouvertes
 * cote MySQL jusqu'au timeout serveur. Le listener garantit une liberation
 * propre des ressources.
 */
@WebListener
public class AppLifecycleListener implements ServletContextListener {

	@Override
	public void contextInitialized(ServletContextEvent sce) {
		// Base en ligne vide au premier demarrage : import automatique.
		DbBootstrap.run(sce.getServletContext());
	}

	@Override
	public void contextDestroyed(ServletContextEvent sce) {
		AppWiring.getDatabase().shutdown();
	}
}
