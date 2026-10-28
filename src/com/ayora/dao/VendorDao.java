package com.ayora.dao;

import java.util.List;
import java.util.Map;

import com.ayora.models.Vendor;
import com.ayora.models.VendorCategory;

/** DAO de l'entite Vendor. */
public interface VendorDao {

	public Vendor findById(int id);
	public int create(Vendor v);
	public List<Vendor> findAll();
	public List<Vendor> findByCategory(int categoryId);
	public List<Vendor> findByGamme(String gamme);
	public List<Vendor> search(String keyword);
	public List<VendorCategory> findAllCategories();
	public List<Vendor> searchAll(String keyword, Integer categoryId, String city, String gamme,
			Boolean active, int offset, int limit);
	public int countSearch(String keyword, Integer categoryId, String city, String gamme, Boolean active);
	public int countAll();
	public int countActive(boolean active);
	public int countIncomplete();
	public boolean update(int id, String name, String city, String description, Double prixMin, Double prixMax,
			String gamme, String phone, String email, String instagram, String address, String tags);
	public boolean updateActive(int id, boolean active);
	public boolean delete(int id);
	public Map<String, Integer> countByCategory();
}
