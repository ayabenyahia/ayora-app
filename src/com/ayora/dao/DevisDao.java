package com.ayora.dao;

import java.util.List;

import com.ayora.models.Devis;

/** DAO de l'entite Devis (table demandes_devis). */
public interface DevisDao {

	public List<Devis> findByClient(int clientId);
	public List<Devis> findByVendor(int vendorId);
	public List<Devis> findAll();
	public List<Devis> findAll(String statutFilter);
	public int create(Devis d);
	public boolean updateStatutAndReponse(int id, String statut, String reponse);
	public boolean updateStatut(int id, String statut);
	public int countAll();
	public int countByStatut(String statut);
	public int countByClient(int clientId);
	public int countByVendor(int vendorId);
}
