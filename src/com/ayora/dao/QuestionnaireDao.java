package com.ayora.dao;

import com.ayora.models.QuestionnaireAnswer;

/** DAO de l'entite QuestionnaireAnswer. */
public interface QuestionnaireDao {

	public QuestionnaireAnswer findByUserId(int userId);
	public boolean create(QuestionnaireAnswer a);
	public boolean update(QuestionnaireAnswer a);
}
