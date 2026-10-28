package com.ayora.dao;

import com.ayora.models.Subscription;

/** DAO de l'entite Subscription. */
public interface SubscriptionDao {

	public Subscription findByUserId(int userId);
	public boolean create(Subscription sub);
	public boolean updatePlan(int userId, String plan);
	public boolean incrementInvitationsSent(int userId);
}
