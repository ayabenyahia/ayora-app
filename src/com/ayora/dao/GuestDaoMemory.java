package com.ayora.dao;

import java.util.List;
import java.util.Vector;

import com.ayora.models.Guest;

/**
 * Implementation EN MEMOIRE de GuestDao (sans base de donnees).
 *
 * Demontre l'inversion de dependance : le metier depend de l'interface
 * GuestDao, pas d'une implementation. On peut brancher cette version
 * memoire a la place de GuestDaoJdbc dans AppWiring sans rien changer au
 * metier. Meme principe que AuthorRepositoryMemory du cours.
 */
public class GuestDaoMemory implements GuestDao {

	private final List<Guest> guests = new Vector<Guest>();
	private int sequence = 0;

	@Override
	public List<Guest> findByUserId(int userId) {
		List<Guest> out = new Vector<Guest>();
		for (Guest g : guests) {
			if (g.getUserId() == userId) out.add(g);
		}
		return out;
	}

	@Override
	public Guest findById(int id) {
		for (Guest g : guests) {
			if (g.getId() == id) return g;
		}
		return null;
	}

	@Override
	public int create(Guest g) {
		g.setId(++sequence);
		guests.add(g);
		return g.getId();
	}

	@Override
	public boolean update(Guest g) {
		for (int i = 0; i < guests.size(); i++) {
			if (guests.get(i).getId() == g.getId()) {
				guests.set(i, g);
				return true;
			}
		}
		return false;
	}

	@Override
	public boolean delete(int id) {
		for (int i = 0; i < guests.size(); i++) {
			if (guests.get(i).getId() == id) {
				guests.remove(i);
				return true;
			}
		}
		return false;
	}

	@Override
	public int countByUserId(int userId) {
		int n = 0;
		for (Guest g : guests) {
			if (g.getUserId() == userId) n++;
		}
		return n;
	}
}
