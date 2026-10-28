package com.ayora.servlet;

import java.io.IOException;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebFilter("/*")
public class CorsFilter implements Filter {

	@Override
	public void init(FilterConfig filterConfig) throws ServletException {
	}

	@Override
	public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) throws IOException, ServletException {
		HttpServletResponse response = (HttpServletResponse) res;
		HttpServletRequest request = (HttpServletRequest) req;

		// CORS correct : on ne renvoie JAMAIS '*' avec credentials (combinaison
		// invalide). On reflete l'origine uniquement si elle est sur liste blanche.
		// L'app etant servie par le meme Tomcat, les requetes same-origin n'ont
		// pas d'en-tete Origin et n'ont donc besoin d'aucun en-tete CORS.
		String origin = request.getHeader("Origin");
		if (origin != null && (origin.equals("http://localhost:8080")
				|| origin.equals("http://127.0.0.1:8080"))) {
			response.setHeader("Access-Control-Allow-Origin", origin);
			response.setHeader("Access-Control-Allow-Credentials", "true");
			response.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
			response.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
			response.setHeader("Vary", "Origin");
		}

		// FORCE no-cache sur HTML/JS/CSS pour eviter que le navigateur garde
		// d'anciennes versions de l'UI (cause majeure des "changements pas
		// visibles" pendant le developpement). En production on retirera ces
		// headers pour activer le cache classique.
		String uri = request.getRequestURI();
		if (uri != null && (uri.endsWith(".html") || uri.endsWith(".js") || uri.endsWith(".css") || uri.endsWith("/"))) {
			response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
			response.setHeader("Pragma", "no-cache");
			response.setHeader("Expires", "0");
		}

		if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
			response.setStatus(HttpServletResponse.SC_OK);
			return;
		}

		chain.doFilter(req, res);
	}

	@Override
	public void destroy() {
	}
}
