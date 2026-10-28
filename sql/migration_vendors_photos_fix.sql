-- ============================================================
-- Migration — Correction et complement des photos prestataires
-- ------------------------------------------------------------
--   1) Corrige les photos croisees (collision de noms partages)
--   2) Rattache les photos "oubliees" a leur prestataire
--   3) Restaure 5 prestataires premium disparus (photos a l'appui)
-- Idempotent : peut etre rejoue sans risque.
-- ============================================================

USE ayora_db;

-- 1) Photos croisees (le moteur de matching avait melange les noms) -----------
UPDATE vendors SET photo_url='/ayora/images/vendors/palais-benjelloun.png'      WHERE name='Palais Benjelloun';
UPDATE vendors SET photo_url='/ayora/images/vendors/negafa-dar-benjelloun.png'  WHERE name='Negafa Dar Benjelloun - Wedding Planner';
UPDATE vendors SET photo_url='/ayora/images/vendors/marouane-hajji.png'         WHERE name='Marouane Hajji';

-- 2) Photos presentes mais non rattachees ------------------------------------
UPDATE vendors SET photo_url='/ayora/images/vendors/elachouri.png'         WHERE name='Khalid El Achouri Photographe';
UPDATE vendors SET photo_url='/ayora/images/vendors/hennaya-fati.png'      WHERE name='Hnaya Fati Fes';
UPDATE vendors SET photo_url='/ayora/images/vendors/issawa-moustapha.png'  WHERE name='Issawa Moustafa Meseyah - Bola Bola de Luxe';
UPDATE vendors SET photo_url='/ayora/images/vendors/palais-dor.png'        WHERE name='Palais D''or Fes';
UPDATE vendors SET photo_url='/ayora/images/vendors/ladragee-dor.png'      WHERE name='La Dragee d''Or Fes';
UPDATE vendors SET photo_url='/ayora/images/vendors/glamsmakeup-ghita.png' WHERE name='Glamsmakeup by Ghita';
UPDATE vendors SET photo_url='/ayora/images/vendors/ghita-beauty.png'      WHERE name='Makeup by Ghita (GhB)';

-- 3) Prestataires premium disparus, restaures avec leurs photos --------------
INSERT INTO vendors (category_id, name, city, description, prix_min, prix_max, gamme, phone, instagram, address, tags, rating, nb_avis, photo_url, venue_type, is_active)
SELECT 1, 'Neggafa El Farssi', 'Fes', 'Institution incontournable de la neggafa a Fes. Tenues royales, caftans de haute couture.', 15000.00, 50000.00, 'PREMIUM', '0661-223344', '@elfarssi_neggafa', 'Fes Medina', 'luxe,fassi,royal,caftan', 4.90, 187, '/ayora/images/vendors/neggafa-el-farssi.png', NULL, 1
FROM dual WHERE NOT EXISTS (SELECT 1 FROM vendors WHERE name='Neggafa El Farssi');

INSERT INTO vendors (category_id, name, city, description, prix_min, prix_max, gamme, phone, instagram, address, tags, rating, nb_avis, photo_url, venue_type, is_active)
SELECT 2, 'Nadia El Guerch', 'Fes', 'Makeup artist de renom a Fes. Style glamour et sophistique.', 3000.00, 8000.00, 'PREMIUM', '0668-112233', '@nadia.elguerch', 'Ville Nouvelle, Fes', 'glamour,HD,sophistique', 4.90, 298, '/ayora/images/vendors/nadia-el-guerch.png', NULL, 1
FROM dual WHERE NOT EXISTS (SELECT 1 FROM vendors WHERE name='Nadia El Guerch');

INSERT INTO vendors (category_id, name, city, description, prix_min, prix_max, gamme, phone, instagram, address, tags, rating, nb_avis, photo_url, venue_type, is_active)
SELECT 2, 'Makeup by Hala', 'Fes', 'Style lumineux et naturel rehausse. Produits premium.', 2500.00, 6000.00, 'PREMIUM', '0669-223344', '@makeupbyhala_fes', 'Fes', 'lumineux,naturel,premium', 4.85, 216, '/ayora/images/vendors/makeup-by-hala.png', NULL, 1
FROM dual WHERE NOT EXISTS (SELECT 1 FROM vendors WHERE name='Makeup by Hala');

INSERT INTO vendors (category_id, name, city, description, prix_min, prix_max, gamme, phone, instagram, address, tags, rating, nb_avis, photo_url, venue_type, is_active)
SELECT 8, 'Orchestre Mohamed Laasry', 'Fes', 'Orchestre de reference a Fes. Chaabi fassi, andalous et variete.', 15000.00, 40000.00, 'PREMIUM', '0688-112233', '@mohamed_laasry_officiel', 'Fes', 'chaabi,andalous,fassi,maestro', 4.95, 312, '/ayora/images/vendors/mohamed-laasry.png', NULL, 1
FROM dual WHERE NOT EXISTS (SELECT 1 FROM vendors WHERE name='Orchestre Mohamed Laasry');

INSERT INTO vendors (category_id, name, city, description, prix_min, prix_max, gamme, phone, instagram, address, tags, rating, nb_avis, photo_url, venue_type, is_active)
SELECT 11, 'Palais Faraj Fes', 'Fes', 'Palais historique en medina de Fes. Capacite 500 personnes.', 50000.00, 150000.00, 'PREMIUM', '0699-223344', '@palais_faraj_fes', 'Bab Ziat, Fes Medina', 'palais,medina,500-personnes', 4.95, 203, '/ayora/images/vendors/palais-faraj.png', 'PALAIS', 1
FROM dual WHERE NOT EXISTS (SELECT 1 FROM vendors WHERE name='Palais Faraj Fes');
