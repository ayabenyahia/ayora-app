package com.ayora.dao;

import java.util.List;

import com.ayora.models.Guest;

/** DAO de l'entite Guest. */
public interface GuestDao {

	public List<Guest> findByUserId(int userId);
	public Guest findById(int id);
	public int create(Guest g);
	public boolean update(Guest g);
	public boolean delete(int id);
	public int countByUserId(int userId);
}
