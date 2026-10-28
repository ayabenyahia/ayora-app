package com.ayora.dao;

import java.util.List;

import com.ayora.models.User;

/** DAO de l'entite User. */
public interface UserDao {

	public User findByEmail(String email);
	public User findById(int id);

	@Deprecated
	public User authenticate(String email, String password);

	public int create(User user);
	public boolean updatePasswordHash(int userId, String passwordHash);
	public boolean updateQuestionnaireStatus(int userId, boolean completed);
	public boolean updateSubscription(int userId, String type);
	public List<User> findAll();
	public int countAll();
	public int countByRole(String role);
	public int countByPlan(String plan);
	public int countByQuestionnaire(boolean completed);
	public int countByActive(boolean active);
	public List<User> search(String keyword, String role, String plan, Boolean questionnaireCompleted,
			Boolean active, int offset, int limit);
	public int countSearch(String keyword, String role, String plan, Boolean questionnaireCompleted, Boolean active);
	public boolean update(int id, String firstName, String lastName, String email, String phone, String city);
	public boolean updateRole(int id, String role);
	public boolean updateActive(int id, boolean active);
	public boolean delete(int id);
}
