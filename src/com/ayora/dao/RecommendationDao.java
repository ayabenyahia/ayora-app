package com.ayora.dao;

import java.util.List;

import com.ayora.models.Recommendation;

/** DAO de l'entite Recommendation. */
public interface RecommendationDao {

	public List<Recommendation> findByUserId(int userId);
	public List<Recommendation> findByVendorId(int vendorId);
	public boolean create(Recommendation rec);
	public boolean deleteByUserId(int userId);
}
