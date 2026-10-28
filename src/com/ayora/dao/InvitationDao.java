package com.ayora.dao;

import java.util.List;

import com.ayora.models.Invitation;

/** DAO de l'entite Invitation. */
public interface InvitationDao {

	public List<Invitation> findByUserId(int userId);
	public int create(Invitation inv);
	public boolean updateStatut(int id, String statut);
	public boolean delete(int id);
}
