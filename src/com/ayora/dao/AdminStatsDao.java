package com.ayora.dao;

import java.util.List;
import java.util.Map;

/** DAO des requetes transverses du back-office admin (timeline, analytics, actions). */
public interface AdminStatsDao {

	public int countQuestionnaireByUser(int userId);
	public int countPicksByUser(int userId);
	public int countRecommendationsByVendor(int vendorId);
	public int countPicksByVendor(int vendorId);
	public boolean syncSubscriptionPlan(int userId, String plan);

	public List<Map<String, Object>> recentUsers(int limit);
	public List<Map<String, Object>> recentDevis(int limit);
	public List<Map<String, Object>> recentRdv(int limit);
	public List<Map<String, Object>> recentQuestionnaires(int limit);

	public List<Map<String, Object>> pendingDevis(int limit);
	public List<Map<String, Object>> pendingRdv(int limit);
	public List<Map<String, Object>> incompleteVendors(int limit);
	public List<Map<String, Object>> clientsWithoutQuestionnaire(int limit);

	public List<Map<String, Object>> signupsByMonth();
	public List<Map<String, Object>> plansDistribution();
	public List<Map<String, Object>> devisByStatus();
}
