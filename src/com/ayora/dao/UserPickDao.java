package com.ayora.dao;

import java.util.List;
import java.util.Set;

import com.ayora.models.UserPick;

/** DAO de l'entite UserPick. */
public interface UserPickDao {

	public List<UserPick> findByUserId(int userId);
	public Set<Integer> findPickedVendorIds(int userId);
	public boolean pick(int userId, int vendorId, int categoryId);
	public boolean unpick(int userId, int vendorId);
}
