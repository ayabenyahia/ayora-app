package com.ayora.dao;

import java.util.List;

import com.ayora.models.RendezVous;

/** DAO de l'entite RendezVous (table rendez_vous). */
public interface RendezVousDao {

	public List<RendezVous> findByClient(int clientId);
	public List<RendezVous> findByVendor(int vendorId);
	public List<RendezVous> findAll();
	public List<RendezVous> findAll(String statutFilter);
	public int create(RendezVous r);
	public boolean updateStatut(int id, String statut);
	public int countAll();
	public int countByStatut(String statut);
	public int countByClient(int clientId);
	public int countByVendor(int vendorId);
}
