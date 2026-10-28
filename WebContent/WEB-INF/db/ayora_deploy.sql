-- Ayora : base de deploiement (generee depuis la base locale ; comptes personnels retires)
-- Importee automatiquement au premier demarrage par com.ayora.config.DbBootstrap
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

CREATE TABLE IF NOT EXISTS `contact_clicks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int DEFAULT NULL,
  `vendor_id` int NOT NULL,
  `channel` varchar(20) NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_cc_vendor` (`vendor_id`),
  KEY `idx_cc_client` (`client_id`),
  KEY `idx_cc_created` (`created_at`),
  KEY `idx_cc_channel` (`channel`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci AUTO_INCREMENT=2;

CREATE TABLE IF NOT EXISTS `demandes_devis` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL,
  `vendor_id` int NOT NULL,
  `budget_min` decimal(10,2) DEFAULT NULL,
  `budget_max` decimal(10,2) DEFAULT NULL,
  `message` text COLLATE utf8mb4_unicode_ci,
  `date_mariage` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nb_invites` int DEFAULT '0',
  `statut` enum('EN_ATTENTE','ACCEPTE','REFUSE') COLLATE utf8mb4_unicode_ci DEFAULT 'EN_ATTENTE',
  `reponse_prestataire` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `client_id` (`client_id`),
  KEY `vendor_id` (`vendor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=2;

CREATE TABLE IF NOT EXISTS `guests` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `first_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `groupe` enum('FAMILLE_MARIEE','FAMILLE_MARIE','AMIS_MARIEE','AMIS_MARIE','COLLEGUES','AUTRES') COLLATE utf8mb4_unicode_ci DEFAULT 'AUTRES',
  `nb_personnes` int DEFAULT '1',
  `note` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=8;

CREATE TABLE IF NOT EXISTS `invitations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `guest_id` int NOT NULL,
  `user_id` int NOT NULL,
  `statut` enum('EN_ATTENTE','ENVOYEE','CONFIRMEE','DECLINEE') COLLATE utf8mb4_unicode_ci DEFAULT 'EN_ATTENTE',
  `template_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT 'classique',
  `date_envoi` timestamp NULL DEFAULT NULL,
  `date_reponse` timestamp NULL DEFAULT NULL,
  `message_perso` text COLLATE utf8mb4_unicode_ci,
  `video_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `guest_id` (`guest_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=19;

CREATE TABLE IF NOT EXISTS `questionnaire_answers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `budget_total` decimal(12,2) DEFAULT NULL,
  `budget_flexibility` enum('STRICT','FLEXIBLE','TRES_FLEXIBLE') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nb_invites` int DEFAULT NULL,
  `nb_invites_femmes` int DEFAULT NULL,
  `nb_invites_hommes` int DEFAULT NULL,
  `date_mariage` date DEFAULT NULL,
  `saison_preferee` enum('PRINTEMPS','ETE','AUTOMNE','HIVER') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lieu_ceremonie` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `style_mariage` enum('TRADITIONNEL','MODERNE','MIXTE','LUXE','SIMPLE','INTIME') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ambiance` enum('FESTIVE','INTIME','GRANDIOSE','ROMANTIQUE','FAMILIALE','LUXUEUSE','TRADITIONNELLE') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `theme_couleur` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `niveau_luxe` enum('ECONOMIQUE','MOYEN','PREMIUM','ULTRA_LUXE','LUXE') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `priorite_salle` int DEFAULT '3',
  `priorite_traiteur` int DEFAULT '3',
  `priorite_photo` int DEFAULT '3',
  `priorite_musique` int DEFAULT '3',
  `priorite_decoration` int DEFAULT '3',
  `priorite_neggafa` int DEFAULT '3',
  `priorite_makeup` int DEFAULT '3',
  `type_cuisine` enum('MAROCAINE','INTERNATIONALE','MIXTE') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `type_musique` enum('TRADITIONNELLE','MODERNE','DJ','ORCHESTRE','ISSAWA','MIXTE') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pref_photo` enum('CLASSIQUE','ARTISTIQUE','REPORTAGE','DRONE') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pref_decoration` enum('TRADITIONNELLE','MODERNE','FLORALE','MINIMALISTE','LUXUEUSE') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nb_tenues_neggafa` int DEFAULT '3',
  `style_neggafa` enum('TRADITIONNEL','MODERNE','MIXTE') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `postes_economie` text COLLATE utf8mb4_unicode_ci,
  `notes_speciales` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=13;

INSERT INTO `questionnaire_answers` (`id`, `user_id`, `budget_total`, `budget_flexibility`, `nb_invites`, `nb_invites_femmes`, `nb_invites_hommes`, `date_mariage`, `saison_preferee`, `lieu_ceremonie`, `style_mariage`, `ambiance`, `theme_couleur`, `niveau_luxe`, `priorite_salle`, `priorite_traiteur`, `priorite_photo`, `priorite_musique`, `priorite_decoration`, `priorite_neggafa`, `priorite_makeup`, `type_cuisine`, `type_musique`, `pref_photo`, `pref_decoration`, `nb_tenues_neggafa`, `style_neggafa`, `postes_economie`, `notes_speciales`, `created_at`, `updated_at`) VALUES
(12, 2, 500000.00, 'FLEXIBLE', 500, 250, 250, '2026-12-19', 'HIVER', 'Fès', 'MODERNE', 'GRANDIOSE', 'blanc-or', 'PREMIUM', 1, 2, 3, 4, 2, 3, 4, 'MIXTE', 'MIXTE', 'REPORTAGE', 'MODERNE', 5, 'MODERNE', NULL, 'Profil de demonstration: Hind Fes 500 invites Moderne', '2026-05-24 11:51:01', '2026-05-24 11:51:01');

CREATE TABLE IF NOT EXISTS `recommendations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `vendor_id` int NOT NULL,
  `score` decimal(5,2) DEFAULT '0.00',
  `raison` text COLLATE utf8mb4_unicode_ci,
  `is_viewed` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `vendor_id` (`vendor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=2184;

CREATE TABLE IF NOT EXISTS `rendez_vous` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL,
  `vendor_id` int NOT NULL,
  `date_rdv` date NOT NULL,
  `heure_rdv` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lieu` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT 'A definir',
  `note` text COLLATE utf8mb4_unicode_ci,
  `statut` enum('EN_ATTENTE','CONFIRME','ANNULE') COLLATE utf8mb4_unicode_ci DEFAULT 'EN_ATTENTE',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `client_id` (`client_id`),
  KEY `vendor_id` (`vendor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `subscriptions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `plan` enum('FREE','PRO','PREMIUM') COLLATE utf8mb4_unicode_ci DEFAULT 'FREE',
  `invitations_sent` int DEFAULT '0',
  `max_invitations_free` int DEFAULT '10',
  `start_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `end_date` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=19;

INSERT INTO `subscriptions` (`id`, `user_id`, `plan`, `invitations_sent`, `max_invitations_free`, `start_date`, `end_date`) VALUES
(1, 1, 'PREMIUM', 0, 10, '2026-04-28 23:44:38', NULL),
(2, 2, 'PREMIUM', 0, 10, '2026-04-28 23:44:38', NULL),
(5, 5, 'PREMIUM', 0, 10, '2026-04-29 23:16:29', NULL);

CREATE TABLE IF NOT EXISTS `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `first_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `city` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT 'Fes',
  `subscription_type` enum('FREE','PRO','PREMIUM') COLLATE utf8mb4_unicode_ci DEFAULT 'FREE',
  `questionnaire_completed` tinyint(1) DEFAULT '0',
  `role` enum('CLIENT','ADMIN','PRESTATAIRE') COLLATE utf8mb4_unicode_ci DEFAULT 'CLIENT',
  `vendor_id` int DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `fk_users_vendor` (`vendor_id`),
  KEY `idx_users_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=18;

INSERT INTO `users` (`id`, `email`, `password`, `password_hash`, `first_name`, `last_name`, `phone`, `city`, `subscription_type`, `questionnaire_completed`, `role`, `vendor_id`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'admin@ayora.ma', NULL, NULL, 'Admin', 'Ayora', '0600-000000', 'Fes', 'PREMIUM', 0, 'ADMIN', NULL, 1, '2026-04-28 23:44:38', '2026-04-28 23:44:38'),
(2, 'test@ayora.ma', 'test123', NULL, 'Salma', 'Bennani', '0661-000000', 'Fes', 'PREMIUM', 1, 'CLIENT', NULL, 1, '2026-04-28 23:44:38', '2026-05-24 11:51:01'),
(5, 'pro@ayora.ma', 'pro123', NULL, 'Yasmine', 'Pro', '0600-111111', 'Fes', 'PREMIUM', 0, 'CLIENT', NULL, 1, '2026-04-29 23:16:29', '2026-05-09 12:08:47');

CREATE TABLE IF NOT EXISTS `user_picks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `vendor_id` int NOT NULL,
  `category_id` int NOT NULL,
  `picked_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_category` (`user_id`,`category_id`),
  KEY `vendor_id` (`vendor_id`),
  KEY `category_id` (`category_id`),
  KEY `idx_user_picks_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=56;

CREATE TABLE IF NOT EXISTS `vendors` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category_id` int NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `city` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT 'Fes',
  `description` text COLLATE utf8mb4_unicode_ci,
  `prix_min` decimal(10,2) DEFAULT NULL,
  `prix_max` decimal(10,2) DEFAULT NULL,
  `gamme` enum('ECONOMIQUE','MOYEN','PREMIUM') COLLATE utf8mb4_unicode_ci DEFAULT 'MOYEN',
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `instagram` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `photo_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gallery_urls` text COLLATE utf8mb4_unicode_ci,
  `reel_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tags` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rating` decimal(3,2) DEFAULT '0.00',
  `nb_avis` int DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `venue_type` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_vendors_name` (`name`),
  KEY `idx_vendors_venue_type` (`category_id`,`venue_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=105;

INSERT INTO `vendors` (`id`, `category_id`, `name`, `city`, `description`, `prix_min`, `prix_max`, `gamme`, `phone`, `email`, `instagram`, `photo_url`, `gallery_urls`, `reel_url`, `address`, `tags`, `rating`, `nb_avis`, `is_active`, `created_at`, `venue_type`) VALUES
(1, 1, 'Neggafa El Farssi', 'Fes', 'Neggafa El Farssi accompagne la mariee avec une approche classique et elegante, centree sur les tenues marocaines, les accessoires et la coordination des passages. Une option adaptee aux familles qui veulent une ceremonie structuree et respectueuse des traditions. Deplacement possible partout au Maroc.', 6000.00, 50000.00, 'MOYEN', '0661-22-33-44', NULL, '@elfarssi_neggafa', '/ayora/images/vendors/neggafa-el-farssi.png', '/ayora/images/vendors/neggafa-el-farssi.png', NULL, 'Fes Medina', 'neggafa,caftan,takchita,mariee,amariya,accessoires,tradition,habillage,ceremonie,defile', 4.90, 187, 1, '2026-04-28 23:44:38', NULL),
(2, 1, 'Dar Benjelloun Neggafa', 'Casablanca', 'Maison de prestige pour la neggafa a Casablanca. Tenues royales, caftans haute couture, savoir-faire traditionnel.', 30000.00, 60000.00, 'PREMIUM', '0662-33-44-55', NULL, '@dar_benjelloun_neggafa', '/ayora/images/vendors/negafa-dar-benjelloun.png', '/ayora/images/vendors/negafa-dar-benjelloun.png', NULL, 'Casablanca - Anfa', 'neggafa,tenues,caftan,amariya,mise-en-scene,mariee,tradition,ceremonie,accessoires,defile', 4.95, 203, 1, '2026-04-28 23:44:38', NULL),
(3, 1, 'Haja Zakia Neggafa', 'Fes', 'Haja Zakia Neggafa accompagne la mariee avec une approche traditionnelle et rassurante, centree sur les tenues, les accessoires et le bon deroulement des passages. Une prestation adaptee aux familles qui veulent garder une ceremonie marocaine classique et bien maitrisee. Deplacement possible partout au Maroc.', 5000.00, 35000.00, 'MOYEN', '0664-55-66-77', NULL, '@haja_zakia_neggafa', '/ayora/images/vendors/haja-zakia.png', '/ayora/images/vendors/haja-zakia.png', NULL, 'Fes El Bali', 'neggafa,tenues-marocaines,caftan,takchita,amariya,mariee,accessoires,tradition,ceremonie,habillage', 4.80, 241, 1, '2026-04-28 23:44:38', NULL),
(4, 2, 'Nadia El Guerch', 'Fes', 'Nadia El Guerch propose une mise en beaute soignee pour les mariees, avec un travail oriente elegance, teint lumineux et coiffure harmonieuse. Une prestation adaptee aux differentes tenues de la soiree et aux exigences des photos de mariage. Deplacement possible partout au Maroc.', 4000.00, 8000.00, 'PREMIUM', '0668-11-22-33', NULL, '@nadia_elguerch', '/ayora/images/vendors/nadia-el-guerch.png', '/ayora/images/vendors/nadia-el-guerch.png', NULL, 'Ville Nouvelle, Fes', 'maquillage,coiffure,makeup,hairstyle,bride,teint,glamour,preparation,caftan,photos', 4.90, 298, 1, '2026-04-28 23:44:38', NULL),
(5, 2, 'Makeup by Hala', 'Fes', 'Makeup by Hala accompagne les mariees avec une mise en beaute raffinee, pensee pour les photos, la lumiere et les longues soirees. Le resultat vise un equilibre entre glamour, douceur et tenue impeccable jusqu\'a la fin de l\'evenement. Deplacement possible partout au Maroc.', 4000.00, 10.00, 'PREMIUM', '0669-22-33-44', NULL, '@makeupbyhala_fes', '/ayora/images/vendors/makeup-by-hala.png', '/ayora/images/vendors/makeup-by-hala.png', NULL, 'Fes', 'maquillage,coiffure,glamour,bride,beauty,makeup-longue-tenue,photos,hairstyle,preparation,evenement', 4.85, 216, 1, '2026-04-28 23:44:38', NULL),
(10, 8, 'Orchestre Mohamed Laasry', 'Fes', 'Orchestre Mohamed Laasry apporte une animation musicale hautement presente, pensee pour les grandes soirees de mariage. La prestation convient aux couples qui veulent un orchestre capable de porter l\'ambiance, les entrees et les moments dansants. Deplacement possible partout au Maroc.', 30000.00, 40000.00, 'PREMIUM', '06 61 69 67 17', NULL, '@asri_simohamed_officiel', '/ayora/images/vendors/mohamed-laasry.png', '/ayora/images/vendors/mohamed-laasry.png', NULL, 'Fes', 'orchestre,animation-live,chant,scene,soiree,danses,ambiance-festive,entree,mariage,musique', 4.95, 312, 1, '2026-04-28 23:44:38', NULL),
(11, 8, 'Orchestre Marouane Lebbar', 'Fes', 'Orchestre marocain professionnel base a Fes. Repertoire chaabi, andalou et mariage. Formation 6 a 10 musiciens, chanteur principal et chanteuses choeurs. Soiree complete (4-6h).', 10000.00, 40000.00, 'PREMIUM', '0610000011', NULL, '@orchestre_marouane_lebbar', '/ayora/images/vendors/marouane-lebbar.png', '/ayora/images/vendors/marouane-lebbar.png', NULL, 'Fes (deplacement Maroc entier)', 'orchestre,musique-live,animation,scene,chant,soiree,danse,ambiance,entree,mariage', 4.90, 287, 1, '2026-04-28 23:44:38', NULL),
(13, 9, 'Jad maison des fleurs', 'Fes', 'Jad Maison des Fleurs cree des compositions florales pensees pour donner de la douceur et de l\'elegance aux espaces de mariage. Bouquets, centres de table et decorations florales apportent une touche romantique, fraiche et harmonieuse a la celebration. Deplacement possible partout au Maroc.', 5000.00, 20000.00, 'PREMIUM', '0661363032', NULL, '@ jad_luxury_events', '/ayora/images/vendors/jad-maison-fleurs.png', '/ayora/images/vendors/jad-maison-fleurs.png', NULL, 'Hay Azhar Fès', 'fleurs,decoration-florale,bouquet,centre-de-table,arche,romantique,composition,ceremonie,reception,mariage', 4.80, 134, 1, '2026-04-28 23:44:38', NULL),
(14, 11, 'Palais Faraj Fes', 'Fes', 'Palais historique en medina de Fes. Capacite 500 personnes. Deplacement possible partout au Maroc.', 20000.00, 80000.00, 'PREMIUM', '', NULL, '@palais_faraj_fes', '/ayora/images/vendors/palais-faraj.png', '/ayora/images/vendors/palais-faraj.png', NULL, 'Bab Ziat, Fes Medina', 'palais,medina,500-personnes', 4.95, 203, 1, '2026-04-28 23:44:38', 'PALAIS'),
(17, 12, 'Traiteur Al Jawda', 'Fes', 'Traiteur Al Jawda propose un service de restauration pense pour les receptions marocaines, avec des plats genereux et une organisation adaptee aux familles. Une option solide pour les mariages qui veulent un repas simple, efficace et bien servi. Deplacement possible partout au Maroc.', 600.00, 1200.00, 'PREMIUM', '0535197683', NULL, '@traiteur_aljawda_anass', '/ayora/images/vendors/traiteur-aljawda.png', NULL, NULL, 'Avenue Ibn Khatib, Hay Azhar, Fes', 'traiteur,repas,cuisine-marocaine,buffet,service,diner,menu,plats,reception,mariage', 4.80, 198, 1, '2026-04-28 23:44:38', NULL),
(21, 12, 'Doreve Traiteur - Karima Riffi', 'Fes', 'Doreve Traiteur signe une cuisine de reception soignee, pensee pour les mariages ou le service, la presentation et le gout doivent rester equilibres. Une adresse adaptee aux couples qui veulent un repas genereux, elegant et bien organise. Deplacement possible partout au Maroc.', 300.00, 1500.00, 'MOYEN', '0657073073', NULL, '@doreve_traiteur', '/ayora/images/vendors/doreve-traiteur.png', '/ayora/images/vendors/doreve-traiteur.png', NULL, 'Ville Nouvelle, 2e etage cafe Cafemaroccinofes, Fes', 'traiteur,repas-mariage,cuisine-marocaine,buffet,service,plats,menu,reception,diner,presentation', 4.85, 165, 1, '2026-04-30 11:44:23', NULL),
(23, 12, 'Traiteur El Kortbi', 'Fes', 'Traiteur El Kortbi propose des prestations culinaires adaptees aux evenements de mariage, avec une attention portee au service et a la presentation des plats. Une solution pratique pour organiser un diner fluide et genereux. Deplacement possible partout au Maroc.', 380.00, 950.00, 'MOYEN', '0535550628', NULL, '@traiteurelkortbi', '/ayora/images/vendors/traiteur-elkortbi.png', NULL, NULL, 'Ville Nouvelle, Fes', 'traiteur,cuisine-marocaine,repas,plats,buffet,service,menu,diner,reception,evenement', 4.75, 178, 1, '2026-04-30 11:44:23', NULL),
(24, 12, 'Sekkate Traiteur', 'Fes', 'Sekkate Traiteur propose une cuisine de mariage genereuse, pensee pour les grands services et les repas familiaux. La prestation convient aux couples qui veulent un menu efficace, une organisation claire et une table bien servie. Deplacement possible partout au Maroc.', 600.00, 1000.00, 'PREMIUM', '0661609217', NULL, '@sekkate_traiteur', '/ayora/images/vendors/sekkate-traiteur.png', NULL, NULL, 'Fes', 'traiteur,cuisine-marocaine,repas,buffet,service,diner,menu,reception,plats,mariage', 4.78, 156, 1, '2026-04-30 11:44:23', NULL),
(25, 12, 'Traiteur El Amane', 'Fes', 'Traiteur El Amane accompagne les mariages avec une cuisine conviviale et un service oriente reception familiale. La prestation convient aux couples qui cherchent un traiteur accessible, organise et capable d\'assurer les moments essentiels du repas. Deplacement possible partout au Maroc.', 350.00, 900.00, 'MOYEN', '0661491997', NULL, '@elamanetraiteur', '/ayora/images/vendors/traiteur-elamane.png', NULL, NULL, '14 lot Amal Marocain n.4, Ville Nouvelle, Fes', 'traiteur,service,repas,cuisine,menu,diner,buffet,plats,reception,mariage', 4.70, 134, 1, '2026-04-30 11:44:23', NULL),
(26, 12, 'Sahel Traiteur Events', 'Fes', 'Sahel Traiteur Events accompagne les mariages avec une cuisine de reception pratique, conviviale et adaptee aux grands services. La prestation convient aux familles qui veulent un repas bien organise, des plats genereux et un deroulement simple. Deplacement possible partout au Maroc.', 400.00, 1100.00, 'MOYEN', '0661704881', NULL, '@sahel_traiteur', '/ayora/images/vendors/sahel-traiteur.png', NULL, NULL, '18 lotissement Riad al Yassamine, route Ain Chkaf, Fes', 'traiteur,repas,reception,buffet,cuisine-marocaine,service,menu,diner,evenement,mariage', 4.80, 145, 1, '2026-04-30 11:44:23', NULL),
(28, 11, 'Salle de fete El Ouazzani', 'Fes', 'Salle de fete familiale a Fes. Capacite moyenne (jusqu\'a 250 invites), prestation simple et chaleureuse. Ideale pour mariages traditionnels avec budget maitrise. Possibilite traiteur partenaire.', 6000.00, 18000.00, 'ECONOMIQUE', '0666075536', NULL, '@salle_de_fete_el_ouazzani_m', '/ayora/images/vendors/salle-elouazzani.png', NULL, NULL, 'Avenue Panama, Route Imouzzar n.2, Fes', 'salle-reception,mariage-familial,diner,ceremonie,espace-evenement,organisation,decoration,invites,ambiance,reception', 4.72, 145, 1, '2026-04-30 11:44:23', 'SALLE'),
(29, 11, 'Salle des Fetes Dar Hajji', 'Fes', 'Salle des Fetes Dar Hajji — espace evenementiel polyvalent a Fes. Salon traditionnel avec tapis et banquettes, scene pour orchestre. Tarifs accessibles pour les mariages a budget moyen.', 4500.00, 18000.00, 'ECONOMIQUE', '0661654212', NULL, '@darhajji_officiel', '/ayora/images/vendors/dar-hajji.png', NULL, NULL, 'Fes', 'salle-reception,evenement,ceremonie,diner,mariage-familial,organisation,decoration,ambiance,service,invites', 4.70, 128, 1, '2026-04-30 11:44:23', 'SALLE'),
(30, 11, 'Palais Alyakout', 'Fes', 'Palais d\'evenements traditionnel a Fes. Salle decoree avec elements fassi (zellige, lustres), capacite moyenne a grande. Bon rapport qualite-prix dans la categorie palais sans atteindre le tarif des references comme Benjelloun ou Faraj.', 18000.00, 35000.00, 'PREMIUM', '02165636763', NULL, '@palaisalyakout', '/ayora/images/vendors/palais-alyakout.png', '/ayora/images/vendors/palais-alyakout.png', NULL, 'Route Aeroport Fes Saiss, Fes', 'palais,piscine,garden-wedding,prestige,saiss,aeroport', 4.92, 189, 1, '2026-04-30 11:44:23', 'PALAIS'),
(31, 11, 'Palais Benjelloun', 'Fes', 'Le lieu ideal pour vos evenements a la hauteur de vos envies. Palais de prestige fassi. Deplacement possible partout au Maroc.', 35000.00, 80000.00, 'PREMIUM', '0659970157', NULL, '@palaisbenjelloun', '/ayora/images/vendors/palais-benjelloun.png', '/ayora/images/vendors/palais-benjelloun.png', NULL, 'Fes', 'palais,prestige,benjelloun,fassi,reception-luxe', 4.88, 174, 1, '2026-04-30 11:44:23', 'PALAIS'),
(33, 8, 'Marouane Hajji', 'Fes', 'Marouane Hajji propose une animation orchestrale forte pour les mariages qui veulent une grande presence musicale. Sa prestation convient aux soirees ou la musique live doit porter les entrees, les danses et les moments festifs importants. Deplacement possible partout au Maroc.', 45000.00, 150000.00, 'PREMIUM', '', NULL, '@marouanehajjiofficial', '/ayora/images/vendors/marouane-hajji.png', '/ayora/images/vendors/marouane-hajji.png', NULL, 'Fes', 'orchestre,musique-live,animation,chant,soiree,danse,entree,ambiance,scene,mariage', 4.95, 312, 1, '2026-04-30 11:44:23', NULL),
(34, 8, 'Younes Rbati', 'Rabat', 'Younes Rbati apporte une animation orchestrale forte, adaptee aux grandes receptions et aux soirees de mariage tres vivantes. Sa prestation convient aux couples qui veulent une ambiance musicale marquee, festive et capable de porter toute la soiree. Deplacement possible partout au Maroc.', 30000.00, 35000.00, 'PREMIUM', '', NULL, '@younes_rbati', '/ayora/images/vendors/younes-rbati.png', NULL, NULL, 'Rabat (deplacement Maroc)', 'orchestre,musique-live,animation,chant,scene,soiree,danses,ambiance-festive,mariage,entree', 4.78, 156, 1, '2026-04-30 11:44:23', NULL),
(35, 8, 'Youssef Wahbi', 'Casablanca', 'Artiste chanteur populaire base a Casablanca. Animations de mariages et soirees festives partout au Maroc. Repertoire eclectique chaabi et oriental.', 40000.00, 80000.00, 'PREMIUM', '0661383279', NULL, '@youssef_wahbi', '/ayora/images/vendors/youssef-wahbi.png', NULL, NULL, 'Casablanca (deplacement partout au Maroc)', 'orchestre,animation,musique-live,chant,soiree,scene,danse,ambiance,entree,mariage', 4.82, 198, 1, '2026-04-30 11:44:23', NULL),
(36, 7, 'Issawa Zakaria Faida', 'Casablanca', 'Issawa Zakaria Faida propose une ambiance marocaine intense, portee par les chants, les rythmes et la participation des invites. Une prestation adaptee aux mariages qui veulent un moment traditionnel vivant et memorable. Deplacement possible partout au Maroc.', 8000.00, 18000.00, 'PREMIUM', '0212610149434', NULL, '@issawa_zakaria_faida', '/ayora/images/vendors/issawa-zakaria.png', '/ayora/images/vendors/issawa-zakaria.png', NULL, 'Casablanca (deplacement Maroc entier)', 'issawa,animation,chant-collectif,rythme,tradition-marocaine,percussions,soiree,ceremonie,ambiance,mariage', 4.88, 198, 1, '2026-04-30 11:44:23', NULL),
(37, 7, 'Issawa Salim - Ahmed Salim', 'Fes', 'Issawa Salim accompagne les mariages avec une prestation traditionnelle structuree, ideale pour les familles qui veulent une ambiance spirituelle et festive a la fois. La presence du groupe donne du relief aux entrees, au henne et aux moments de celebration collective. Deplacement possible partout au Maroc.', 7000.00, 12000.00, 'PREMIUM', '0661996543', NULL, '@issawa_salim', '/ayora/images/vendors/issawa-salim.png', '/ayora/images/vendors/issawa-salim.png', NULL, 'Fes', 'issawa,tradition,chant,percussions,ambiance,henna,entree,ceremonie,benediction,mariage', 4.80, 167, 1, '2026-04-30 11:44:23', NULL),
(40, 1, 'Negafa Majda Benjelloun - Tenguif de Luxe', 'Fes', 'Negafa Majda Benjelloun — Tenguif de Luxe. Atelier neggafa specialise tenues fassi traditionnelles : caftan, takchita, lebssa fassia ancestrale. Showroom a Fes avec collection exclusive.', 30000.00, 45000.00, 'PREMIUM', '0615855411', NULL, '@negafa_majda_benjelloun', '/ayora/images/vendors/majda-benjelloun.png', '/ayora/images/vendors/majda-benjelloun.png', NULL, 'Fes & Casablanca', 'neggafa,tenguif,caftan,takchita,amariya,mariee,accessoires,ceremonie,tradition,defile', 4.92, 187, 1, '2026-04-30 11:44:23', NULL),
(41, 4, 'Photo Tazi', 'Rabat', 'Photographe & cineaste mariage reconnu - Rabat-Sale, Maroc. Studio LaboPhotoTazi, prestation prestige. Deplacement possible partout au Maroc.', 8000.00, 25000.00, 'PREMIUM', '0212661113534', NULL, '@phototazi', '/ayora/images/vendors/photo-tazi.png', '/ayora/images/vendors/photo-tazi.png', NULL, 'Rabat / Sale, Maroc', 'photographe,cineaste,prestige,rabat,sale,studio,labophototazi', 4.92, 234, 1, '2026-04-30 11:44:23', NULL),
(42, 4, 'Prestige Camera - Hamza', 'Fes', 'Photographie & videographie mariages, evenements, produits. Disponible partout au Maroc. Reservations rapides via WhatsApp.', 7000.00, 22000.00, 'PREMIUM', '0663807685', NULL, '@prestige_camera', '/ayora/images/vendors/prestige-camera.png', '/ayora/images/vendors/prestige-camera.png', NULL, 'Fes Hay Bader (deplacement Maroc entier)', 'photo-video,mariage,evenements,prestige-camera,hamza,partout-maroc', 4.88, 198, 1, '2026-04-30 11:44:23', NULL),
(43, 4, 'Khalid El Achouri Photographe', 'Fes', 'Khalid El Achouri Photographe capture les moments du mariage avec une approche orientee emotion, details et souvenirs durables. Sa prestation convient aux couples qui veulent garder des images naturelles, elegantes et representatives de chaque etape de la journee. Deplacement possible partout au Maroc.', 6500.00, 20000.00, 'PREMIUM', '0675897941', NULL, '@elachouri_photographe_officiel', '/ayora/images/vendors/elachouri.png', '/ayora/images/vendors/elachouri.png', NULL, 'Fes', 'photographe,video,shooting,couple,reportage-mariage,emotion,souvenirs,preparatifs,ceremonie,album', 4.90, 175, 1, '2026-04-30 11:44:23', NULL),
(45, 2, 'Make Me Fab', 'Maroc / International', 'Make Me Fab propose une mise en beaute complete pour les mariees qui veulent un rendu professionnel, lumineux et photo-friendly. Le style s\'adapte aux ceremonies modernes comme traditionnelles, avec une attention portee au teint, aux details et a la tenue du maquillage. Deplacement possible partout au Maroc.', 10000.00, 12000.00, 'PREMIUM', '', NULL, '@makemefab_maroc', '/ayora/images/vendors/make-me-fab.png', '/ayora/images/vendors/make-me-fab.png', NULL, 'Maroc / Worldwide', 'maquillage,coiffure,makeup,hairstyle,bride,beauty,glow,preparation,shooting,caftan', 4.95, 245, 1, '2026-04-30 11:44:23', NULL),
(46, 2, 'Salamoun Makeup Artist - Salma Hammioui', 'Fes', 'Salamoun Makeup Artist propose une mise en beaute elegante pour les mariees qui veulent un resultat travaille, moderne et lumineux. La prestation valorise le visage, les coiffures et l\'harmonie avec les tenues de mariage. Deplacement possible partout au Maroc.', 3500.00, 10000.00, 'MOYEN', '0653555244', NULL, '@salamounmakeup', '/ayora/images/vendors/salamoun-makeup.png', NULL, NULL, 'Fes', 'maquillage,coiffure,makeup,beauty,bride,glamour,hairstyle,preparation,photos,caftan', 4.92, 220, 1, '2026-04-30 11:44:23', NULL),
(47, 2, 'Yassine Makeup & Hair', 'Fes', 'Yassine Makeup & Hair propose une mise en beaute complete, avec maquillage et coiffure adaptes aux mariees qui veulent un rendu structure, net et photographique. La prestation convient aux ceremonies modernes comme aux soirees traditionnelles. Deplacement possible partout au Maroc.', 2500.00, 7000.00, 'PREMIUM', '0618231756', NULL, '@makeup_and_hair_by_yassine', '/ayora/images/vendors/yassine-makeup.png', NULL, NULL, 'Fes / Casablanca (deplacement)', 'maquillage,coiffure,makeup,hair,bride,beauty,shooting,preparation,glamour,caftan', 4.80, 167, 1, '2026-04-30 11:44:23', NULL),
(48, 13, 'Emeraude by Malika Alaoui', 'Fes', 'Emeraude by Malika Alaoui met en valeur les cadeaux et presentations de mariage avec une touche delicate et feminine. Ses creations conviennent aux ceremonies ou les tyafer, les douceurs et les details visuels doivent avoir une vraie presence. Deplacement possible partout au Maroc.', 3000.00, 12000.00, 'MOYEN', '0661520516', NULL, '@emraude_by_malika', '/ayora/images/vendors/emeraude-malika.png', '/ayora/images/vendors/emeraude-malika.png', NULL, 'Fes', 'tyafer,myadi,presentation-cadeaux,offrandes,douceurs,ceremonie,detail,raffinement,mariage,tradition,myadi,tyafer,traditionnel', 4.90, 154, 1, '2026-04-30 11:44:23', NULL),
(49, 13, 'Chocolat de Joie', 'Fes', 'Chocolat de Joie propose des presentations raffinees pour les moments d\'offrande et de reception, avec une attention particuliere aux details, aux emballages et a l\'harmonie visuelle. Une belle option pour accompagner les tyafer, les cadeaux invites ou les tables d\'accueil avec une touche douce et soignee. Deplacement possible partout au Maroc.', 4000.00, 7000.00, 'PREMIUM', '0661978478', NULL, '@chocolat_de_joie', '/ayora/images/vendors/chocolat-joie.png', '/ayora/images/vendors/chocolat-joie.png', NULL, 'Fes', 'chocolat,presentation,cadeaux-invites,dragees,table-daccueil,offrandes,mariage,raffine,emballage,ceremonie,myadi,tyafer,traditionnel', 4.78, 134, 1, '2026-04-30 11:44:23', NULL),
(50, 6, 'Cake Ahlame - Ahlam Zayyoun', 'Fes', 'Cake Ahlame propose des gâteaux de mariage sur commande avec un style travaillé, décoratif et adapté aux grandes célébrations. Idéal pour les mariées qui cherchent un gâteau élégant, livré avec soin, pour accompagner la découpe et les photos de fin de soirée Deplacement possible partout au Maroc.', 1200.00, 5000.00, 'PREMIUM', '0665221142', NULL, '@cake_ahlame', '/ayora/images/vendors/cake-ahlame.png', '/ayora/images/vendors/cake-ahlame.png', NULL, 'Fes Hay Tarik 1', 'cake-designer,gateau-mariage,sur-commande,livraison,fes,dessert,decoration,sucre,patisserie', 4.82, 142, 1, '2026-04-30 11:44:23', NULL),
(51, 1, 'Mounia Ramsis Tounsi - Neggafa', 'Rabat', 'Mounia Ramsis Tounsi - Neggafa premium et caftan designer. Reference du mariage marocain. Service complet sur Rabat, Sale, Temara et Kenitra. Plus d\'un million d\'abonnes sur Instagram.', 25000.00, 45000.00, 'PREMIUM', '0661-81-81-82', NULL, '@mounia_ramsis', '/ayora/images/vendors/mounia-ramsis.png', '/ayora/images/vendors/mounia-ramsis.png', NULL, 'Rabat - Sale - Temara - Kenitra', 'neggafa,premium,caftan,royal,fassi,mounia-ramsis,rabat,sale', 4.95, 312, 1, '2026-04-30 11:44:23', NULL),
(53, 12, 'Festin Traiteur', 'Fes', 'FESTIN propose une offre de traiteur complete, originale et raffinee. Au plaisir de vous servir partout au Maroc.', 450.00, 850.00, 'PREMIUM', '0661420546', NULL, '@festin_traiteur', '/ayora/images/vendors/festin-traiteur.png', '/ayora/images/vendors/festin-traiteur.png', NULL, 'Fes', 'traiteur,service-table,repas,menu-marocain,buffet,diner,vaisselle,reception,cuisine,evenement', 4.90, 234, 1, '2026-04-30 11:59:53', NULL),
(54, 6, 'My Kiko Cake ', 'Fes', 'My Kiko Cake realise des creations sucrees personnalisees pour les mariages et evenements familiaux. Ses gateaux conviennent aux couples qui veulent une piece visuelle agreable, adaptee a la decoupe, aux photos et a l\'ambiance de la soiree. Deplacement possible partout au Maroc.', 900.00, 4500.00, 'MOYEN', '0648238761', NULL, '@my_kiko_cake', '/ayora/images/vendors/my-kiko-cake.png', '/ayora/images/vendors/my-kiko-cake.png', NULL, 'Fes', 'cake-design,gateau,table-sucree,patisserie,dessert,personnalise,decoration,douceurs,mariage,evenement', 4.85, 145, 1, '2026-04-30 13:19:51', NULL),
(55, 6, 'The Cake House by Chaym', 'Fes', 'Cake designer - Homemade with love. Wedding cakes, fiancailles, Tyaffer. Deplacement partout au Maroc.', 1200.00, 5500.00, 'MOYEN', '0615070330', NULL, '@thecakehousebychaym', '/ayora/images/vendors/cake-house-chaym.png', NULL, NULL, 'Fes, Maroc', 'cake-design,gateau,dessert,patisserie,table-sucree,decoration,douceurs,personnalise,mariage,ceremonie', 4.88, 178, 1, '2026-04-30 13:19:51', NULL),
(56, 16, 'Hnaya Fati Fes', 'Fes', 'Specialiste henna pour mariees fassies - artiste reconnu. Deplacement partout au Maroc.', 800.00, 2800.00, 'MOYEN', '0676130037', NULL, '@hnaya_fati_fes_officiel', '/ayora/images/vendors/hennaya-fati.png', '/ayora/images/vendors/hennaya-fati.png', NULL, 'Fes', 'henna,hennaya,ceremonie-henne,dessin-henne,tradition,mariee,famille,benediction,soiree-henne,rituel', 4.85, 165, 1, '2026-04-30 13:19:51', NULL),
(57, 8, 'Adil Otmani - Artiste & Compositeur', 'Fes', 'Artiste chanteur compositeur. Reservations TikTok @adilotmani7 et Facebook Adil Otmani. Deplacement partout au Maroc.', 9000.00, 45000.00, 'MOYEN', '0212631374578', NULL, '@adil_otmani', '/ayora/images/vendors/adil-otmani.png', '/ayora/images/vendors/adil-otmani.png', NULL, 'Fes - Maroc', 'artiste,chanteur,compositeu,tarab-al-andaloussi', 4.85, 198, 1, '2026-04-30 13:19:51', NULL),
(58, 7, 'Haj Said Berrada', 'Fes', 'Groupe issawa renomme dirige par Haj Said Berrada. Specialise dans l\'entree de la mariee (zaffa) et les ceremonies traditionnelles fassia. Prestation premium avec tenues d\'epoque, percussions et chants liturgiques.', 10000.00, 25000.00, 'PREMIUM', '', NULL, '@hajsaidberrada', '/ayora/images/vendors/haj-said-berrada.png', '/ayora/images/vendors/haj-said-berrada.png', NULL, 'Fes (deplacement partout au Maroc)', 'issawa,chant-traditionnel,rythmes,spirituel,benediction,henna,entree-mariee,ceremonie,folklore,ambiance,issawa,soufi,traditionnel,fassi', 4.92, 245, 1, '2026-04-30 13:19:51', NULL),
(59, 8, 'Omar Hanoun', 'Fes', 'Chanteur fassi reconnu. Reservations directes. Repertoire varie pour mariages et soirees. Deplacement partout au Maroc.', 10000.00, 25000.00, 'MOYEN', '0666059905', NULL, '@omar_hanoun_artiste', '/ayora/images/vendors/omar-hanoun.png', '/ayora/images/vendors/omar-hanoun.png', NULL, 'Fes', 'orchestre,musique-live,animation,chant,soiree,danses,ambiance,entree,mariage,scene', 4.80, 178, 1, '2026-04-30 13:19:51', NULL),
(60, 8, 'Mehdi Artiste Orchestre', 'Fes', 'Chef orchestre et chanteur professionnel. Repertoire varie : chaabi, oriental, festif. Deplacement partout au Maroc.', 10000.00, 35000.00, 'MOYEN', '0212661364068', NULL, '@artiste_mehdi', '/ayora/images/vendors/artiste-mehdi.png', '/ayora/images/vendors/artiste-mehdi.png', NULL, 'Maroc - Fes', 'orchestre,artiste,chanteur,musique-live,animation,danse,soiree,ambiance,entree,mariage', 4.85, 167, 1, '2026-04-30 13:19:51', NULL),
(61, 14, 'DJ Kacem - Kacem Mghabbar', 'Fes', 'Chanteur et DJ professionnel pour tout genre evenements. Animations mariages, soirees prive. Deplacement partout au Maroc.', 1500.00, 12000.00, 'ECONOMIQUE', '0661693051', NULL, '@dj__kacem', '/ayora/images/vendors/dj-kacem.png', '/ayora/images/vendors/dj-kacem.png', NULL, 'Fes', 'dj,animation-musicale,playlist,danse,soiree,ambiance,sonorisation,mariage,rythme,piste', 4.82, 156, 1, '2026-04-30 13:19:51', NULL),
(62, 14, 'DJ Mehdi Bouchal', 'Fes', 'DJ Professionnel specialise dans les Mariages et Soirees. Transforme vos vibes en experience unique. Deplacement partout au Maroc.', 2000.00, 10000.00, 'MOYEN', '+212649937147', NULL, '@dj_mehdi_b', '/ayora/images/vendors/dj-mehdi.png', '/ayora/images/vendors/dj-mehdi.png', NULL, 'Fes', 'dj,musique,animation,soiree-dansante,son,playlist,ambiance-festive,entree,danse,mariage', 4.75, 132, 1, '2026-04-30 13:19:51', NULL),
(63, 7, 'Issawa Moustafa Meseyah - Bola Bola de Luxe', 'Fes', 'Issawa Bola Bola de Luxe - reservation pour mariages partout au Maroc. Repertoire issawa et folklore prestige.', 1500.00, 14000.00, 'MOYEN', '0212661361956', NULL, '@issawa_moustafa', '/ayora/images/vendors/issawa-moustapha.png', '/ayora/images/vendors/issawa-moustapha.png', NULL, 'Fes (deplacement Maroc)', 'issawa,bola-bola,animation-traditionnelle,rythme,ambiance-populaire,chant,percussions,ceremonie,entree,mariage', 4.88, 187, 1, '2026-04-30 13:19:51', NULL),
(64, 11, 'Le Pavillon Dor', 'Fes', 'Weddings & Luxury Events - Salle des fetes et de spectacles, maison d hotes. Cadre prestigieux pour evenements haut de gamme.', 18000.00, 40000.00, 'PREMIUM', '0212661365449', NULL, '@lepavillon_dor', '/ayora/images/vendors/pavillon-dor.png', '/ayora/images/vendors/pavillon-dor.png', NULL, 'Fes', 'salle-reception,espace-mariage,diner,ceremonie,grande-capacite,decoration,organisation,ambiance,soiree,reception', 4.88, 178, 1, '2026-04-30 13:19:51', 'PALAIS'),
(65, 11, 'Salle The Queen', 'Fes', 'Salle The Queen propose un espace de reception elegant pour les mariages qui recherchent une atmosphere soignee et une presentation valorisante. Le lieu convient aux soirees avec diner, animation et mise en scene des moments importants. Deplacement possible partout au Maroc.', 12000.00, 40000.00, 'MOYEN', '', NULL, '@salle_polyvalente_the_queen', '/ayora/images/vendors/the-queen.png', NULL, NULL, 'Complexe La Perla, Km 10, Route de Meknes, Fes', 'salle-reception,espace-mariage,decoration,diner,ceremonie,ambiance,organisation,soiree,reception,invites', 4.60, 143, 1, '2026-05-09 12:05:56', 'SALLE'),
(66, 11, 'Palais D\'or Fes', 'Fes', 'Palais d\'evenements luxe situe a Ain Chqef, Fes. \"Luxury Weddings & Events\" : scenographie tres riche, mises en lumiere premium, allee VIP, palanquin amariya integre. Parfait pour mariages royaux et grandes ceremonies (250-500 invites). Cafe palais disponible pour les invites. Deplacement possible partout au Maroc.', 8000.00, 40000.00, 'MOYEN', '0663572605', NULL, '@palaisdorfes', '/ayora/images/vendors/palais-dor.png', '/ayora/images/vendors/palais-dor.png', NULL, 'Palais d\'or, Ain Chqef, Fes', 'palais,royal,luxe,premium,grand,prestige,or,scenographie,fes,haut-gamme,amariya,vip', 4.70, 68, 1, '2026-05-09 12:05:56', 'PALAIS'),
(67, 11, 'Riad Arabesque', 'Fes', 'Riad de charme situe au coeur de la medina ancienne de Fes. Architecture traditionnelle fassie authentique : zellige multicolore, plafonds en bois sculpte, patio central avec fontaine. Capacite intime (60-120 invites), ambiance heritage andalous incomparable. Possibilite restauration sur place. Deplacement possible partout au Maroc.', 20000.00, 50000.00, 'PREMIUM', '0703191113', NULL, '@riadarabesque', '/ayora/images/vendors/riad-arabesque.png', '/ayora/images/vendors/riad-arabesque.png', NULL, 'Medina ancienne, Fes', 'riad,medina,fassi,authentique,intime,heritage,zellige,oriental,charme,traditionnel,andalous,patio', 4.80, 91, 1, '2026-05-09 12:05:56', 'RIAD'),
(68, 11, 'Riad Salam Fes', 'Fes', 'Riad Salam Fes propose un cadre marocain elegant pour une reception de mariage au style traditionnel et intimiste. Le lieu convient aux couples qui veulent une atmosphere de riad, une architecture de caractere et un decor naturellement photogenique. Deplacement possible partout au Maroc.', 20000.00, 50000.00, 'PREMIUM', '', NULL, '@riad_salam_fes', '/ayora/images/vendors/riad-salam-fes.png', NULL, NULL, 'Fes', 'riad,reception,architecture-marocaine,patio,ceremonie,intimiste,decoration,photos,diner,mariage', 4.50, 39, 1, '2026-05-09 12:05:56', 'RIAD'),
(69, 11, 'Palais Laraki', 'Meknes', 'Palais Laraki - institution evenementielle a Meknes, region Fes-Meknes. Salle prestigieuse pour mariages traditionnels et ceremonies marocaines avec option traiteur integre. Equipe coordination experimentee (37K abonnes IG, +1200 publications mariage). Tres demande dans la region pour les mariages dits \"royaux\". Deplacement possible partout au Maroc.', 22000.00, 45000.00, 'PREMIUM', '0661807893', NULL, '@palais_laraki', '/ayora/images/vendors/palais-laraki.png', '/ayora/images/vendors/palais-laraki.png', NULL, 'Meknes', 'palais,royal,prestige,grand,traiteur,traditionnel,fassi,heritage,meknes,coordination,renomme', 4.70, 200, 1, '2026-05-09 12:05:56', 'PALAIS'),
(70, 11, 'Salle Billionaire Fes', 'Fes', 'Salle Billionaire Fes offre un espace de reception adapte aux mariages elegants, avec une organisation pensee pour les grandes soirees. La salle convient aux couples qui veulent un cadre moderne, une ambiance structuree et une reception facile a mettre en scene. Deplacement possible partout au Maroc.', 12000.00, 40000.00, 'MOYEN', '0661060039', NULL, '@salle_des_fete_billionaire', '/ayora/images/vendors/salle-billionaire.png', NULL, NULL, 'Route Immouzer avant Golf Royal, Medina, Fes', 'salle-reception,espace-evenement,decoration,ceremonie,diner,grande-capacite,ambiance,organisation,soiree,mariage', 4.50, 100, 1, '2026-05-09 12:05:56', 'PALAIS'),
(71, 13, 'La Dragee d\'Or Fes', 'Fes', 'La Dragee d\'Or propose des douceurs et presentations adaptees aux cadeaux invites, aux tyafer et aux tables de mariage. Son univers convient aux mariages qui veulent une touche sucree classique, bien presentee et facile a integrer dans la decoration. Deplacement possible partout au Maroc.', 1500.00, 5000.00, 'MOYEN', '0661437950', NULL, '@la_dragee_dor_fes', '/ayora/images/vendors/ladragee-dor.png', '/ayora/images/vendors/ladragee-dor.png', NULL, '8 Avenue Roi Hussein, Route d\'Immouzer, Fes', 'dragees,chocolat,cadeaux-invites,douceurs,presentation,tyafer,table-sucree,emballage,ceremonie,mariage', 4.70, 500, 1, '2026-05-09 12:05:56', NULL),
(72, 13, 'Le Cacaochi', 'Fes', 'Le Cacaouchi propose des creations gourmandes et presentations sucrees adaptees aux evenements familiaux et aux mariages. Une option pratique pour enrichir les tables de reception, les cadeaux invites ou les moments d\'accueil avec une touche artisanale. Deplacement possible partout au Maroc.', 2000.00, 7000.00, 'MOYEN', '', NULL, '@le_cacaochi_chocolatier', '/ayora/images/vendors/le-cacaochi.png', '/ayora/images/vendors/le-cacaochi.png', NULL, 'Route Ain Chkef, Fes', 'gateaux,douceurs,table-sucree,patisserie,confiserie,cadeaux-invites,reception,gourmandise,tradition,evenement', 4.60, 224, 1, '2026-05-09 12:05:56', NULL),
(73, 13, 'Jeff de Bruges Fes', 'Fes', 'Jeff de Bruges Fes apporte une touche gourmande et elegante aux cadeaux d\'invites, aux tyafer et aux tables de reception. Les chocolats et presentations conviennent aux mariages qui veulent offrir un detail raffine et facilement appreciable par les invites. Deplacement possible partout au Maroc.', 5000.00, 8000.00, 'PREMIUM', '0535606646', NULL, '@jeffdebrugesfes', '/ayora/images/vendors/jeff-de-bruges.png', '/ayora/images/vendors/jeff-de-bruges.png', NULL, 'Fes', 'chocolat,confiserie,cadeaux-invites,dragees,tyafer,gourmandise,presentation,table-sucree,offrandes,mariage', 4.80, 1313, 1, '2026-05-09 12:05:56', NULL),
(74, 13, 'Filali Tyafer', 'Fes', 'Filali Tyafer valorise les moments de presentation avec des tyafer elegants, adaptes aux ceremonies de mariage marocain. Le rendu met l\'accent sur l\'ordre, la brillance et la mise en scene des cadeaux pour creer un moment fort devant les invites. Deplacement possible partout au Maroc.', 8000.00, 25000.00, 'PREMIUM', '0600185698', NULL, '@filali_tyafer', '/ayora/images/vendors/filali-tyafer.png', '/ayora/images/vendors/filali-tyafer.png', NULL, 'Fes, Maroc', 'tyafer,myadi,dfoua,presentation-cadeaux,ceremonie,tradition,offrandes,mariage,plateaux,detail', 4.90, 2681, 1, '2026-05-09 12:05:56', NULL),
(75, 13, 'Aziz Iyachi Tyafer', 'Casablanca', 'Aziz Iyachi Tyafer sublime la présentation du dfoua et des cadeaux de mariage avec une mise en scène soignée, raffinée et luxueuse. Ses tyafer sont pensés pour donner de la valeur au moment de l’offrande et créer un effet visuel marquant pendant les cérémonies marocaines Deplacement possible partout au Maroc.', 5000.00, 30000.00, 'PREMIUM', '0661979016', NULL, '@tyafer_aziz_iyachi', '/ayora/images/vendors/aziz-iyachi.png', '/ayora/images/vendors/aziz-iyachi.png', NULL, 'Bd Al Qods, Casablanca', 'tyafer,luxe,prestige,heritage,exclusif,sur-mesure,mille-et-une-nuits', 4.80, 323, 1, '2026-05-09 12:05:56', NULL),
(76, 1, 'Maison Mariee Soltana', 'Casablanca', 'Maison Mariee Soltana accompagne la mariee dans ses changements de tenues avec une selection de caftans, accessoires et mises en scene traditionnelles. La prestation convient aux mariages qui veulent une presence feminine, royale et soigneusement orchestree. Deplacement possible partout au Maroc.', 18000.00, 50000.00, 'PREMIUM', '0661088151', NULL, '@negafa_soltana', '/ayora/images/vendors/neggafa-soltana.png', '/ayora/images/vendors/neggafa-soltana.png', NULL, 'Casablanca, Maarif, Maroc', 'neggafa,caftan,takchita,tenues,mariee,amariya,accessoires,defile,habillage,ceremonie', 4.80, 735, 1, '2026-05-09 12:05:56', NULL),
(77, 2, 'Glamsmakeup by Ghita', 'Fes', 'Glamsmakeup by Ghita propose une mise en beaute douce et travaillee pour les mariees qui veulent un resultat lumineux sans surcharge. Le style convient aux caftans, aux photos et aux changements de tenues avec une finition feminine et moderne. Deplacement possible partout au Maroc.', 2000.00, 5000.00, 'MOYEN', '0606440302', NULL, '@glam_smakeup_by_ghita', '/ayora/images/vendors/glamsmakeup-ghita.png', '/ayora/images/vendors/glamsmakeup-ghita.png', NULL, 'Fes (deplacement partout au Maroc)', 'maquillage,coiffure,beauty,bride,makeup,hairstyle,glamour,caftan,photos,preparation', 4.80, 341, 1, '2026-05-09 12:05:56', NULL),
(78, 2, 'Makeup by Ghita (GhB)', 'Fes', 'Makeup by Ghita offre un style de maquillage doux, propre et adapte aux mariees qui veulent rester elegantes sans exces. La prestation met l\'accent sur l\'harmonie du visage, la coiffure et la coherence avec les tenues de la soiree. Deplacement possible partout au Maroc.', 1000.00, 4000.00, 'ECONOMIQUE', '0668570987', NULL, '@ghita_beauty_1', '/ayora/images/vendors/ghita-beauty.png', '/ayora/images/vendors/ghita-beauty.png', NULL, 'Fes', 'maquillage,coiffure,makeup,beauty,naturel,elegant,mariee,hairstyle,preparation,caftan', 4.50, 104, 1, '2026-05-09 12:05:56', NULL),
(79, 2, 'Beauty by Saoussane', 'Fes', 'Beauty by Saoussane accompagne la mariée avec un maquillage professionnel et une coiffure élégante, pensés pour révéler sa beauté sans la transformer. Le style est féminin, travaillé et adapté aux caftans, aux changements de tenues et aux photos de mariage Deplacement possible partout au Maroc.', 1500.00, 5000.00, 'ECONOMIQUE', '0664193381', NULL, '@makeup_by_saoussane', '/ayora/images/vendors/beauty-saoussane.png', '/ayora/images/vendors/beauty-saoussane.png', NULL, 'Champs de Cours, Fes', 'maquillage,coiffure,bridal,mariee,beauty,makeup,hair', 4.70, 432, 1, '2026-05-09 12:05:56', NULL),
(80, 2, 'Souma Makeup', 'Casablanca', 'Souma Makeup accompagne la mariee avec une mise en beaute sophistiquee, pensee pour les photos, la lumiere et les changements de tenues. Le style met l\'accent sur un rendu elegant, feminin et durable tout au long de la soiree. Deplacement possible partout au Maroc.', 6000.00, 10000.00, 'PREMIUM', '0644931869', NULL, '@souma__makeup', '/ayora/images/vendors/souma-makeup.png', NULL, NULL, 'Casablanca', 'maquillage,coiffure,makeup,beauty,bride,glamour,teint,hairstyle,photos,preparation', 4.90, 1571, 1, '2026-05-09 12:05:56', NULL),
(81, 11, 'Crystal Salle des Fetes', 'Fes', 'Crystal Salle des Fetes offre un cadre elegant pour organiser une reception structuree, confortable et adaptee aux grands rassemblements familiaux. Son espace convient aux mariages qui recherchent une salle claire, bien organisee et facile a amenager selon le theme choisi. Deplacement possible partout au Maroc.', 18000.00, 40000.00, 'PREMIUM', '', NULL, '@crysta_fes', '/ayora/images/vendors/salle-crystal.png', '/ayora/images/vendors/salle-crystal.png', NULL, 'Fes', 'salle-reception,espace-evenement,grande-capacite,decoration,ceremonie,diner,mariage-familial,organisation,ambiance', 4.60, 80, 1, '2026-05-09 14:11:30', 'PALAIS'),
(82, 8, 'Orchestre Tamouh', 'Fes', 'Orchestre Tamouh, Fes  Deplacement possible partout au Maroc.', 10000.00, 25000.00, 'MOYEN', '', NULL, '@orchestretamouhahmed', '/ayora/images/vendors/orchestre-tamouh.png', '/ayora/images/vendors/orchestre-tamouh.png', NULL, 'Fes', 'orchestre,marocain,chaabi,andalou,mariage,fes,professionnel,polyvalent', 4.50, 60, 1, '2026-05-09 14:11:30', NULL),
(83, 8, 'Orchestre Tahour', 'Fes', 'Orchestre Tahour propose une prestation musicale genereuse pour les mariages qui veulent une soiree vivante, festive et marquee par la musique live. L\'orchestre convient aux grandes receptions avec un public familial et varie. Deplacement possible partout au Maroc.', 60000.00, 120000.00, 'PREMIUM', '0661213443', NULL, '@tahourofficial', '/ayora/images/vendors/orchestre-tahour.png', '/ayora/images/vendors/orchestre-tahour.png', NULL, 'Fes', 'orchestre,musique-live,animation,chant,percussion,soiree,ambiance,danse,scene,mariage', 4.90, 200, 1, '2026-05-09 14:11:30', NULL),
(84, 6, 'Nisrine Benkirane', 'Fes', 'Nisrine Benkirane propose des gateaux et douceurs de mariage avec un style delicat, adapte aux tables sucrees et aux moments de decoupe. Ses creations conviennent aux evenements qui recherchent une presentation propre, feminine et gourmande. Deplacement possible partout au Maroc.', 2500.00, 8000.00, 'PREMIUM', '0665410197', NULL, '@nisrinebenkirane_', '/ayora/images/vendors/nisrine-benkirane.png', NULL, NULL, 'Avenue Mohamed Zerktouni, Atlas, Fes', 'cake-design,gateau-mariage,douceurs,patisserie,table-sucree,dessert,decoration,personnalise,ceremonie,mariage', 4.85, 187, 1, '2026-05-14 23:01:28', NULL),
(85, 6, 'Bloom by Amal', 'Fes', 'Bloom by Amal réalise des créations sucrées délicates pour les événements de mariage : gâteaux, douceurs et présentations soignées. Une adresse adaptée aux mariées qui veulent une table élégante, douce et féminine, avec une touche artisanale et personnalisée Deplacement possible partout au Maroc.', 1500.00, 10.00, 'PREMIUM', '0661255210', NULL, '@bloomette_maroc', '/ayora/images/vendors/bloom-by-amal.png', NULL, NULL, 'Fes', 'cake,cake-design,gateau,douceurs,sucre,mariage,fes,anniversaire,table-sucree,personnalise', 4.70, 142, 1, '2026-05-14 23:01:28', NULL),
(86, 4, 'Camera Youness', 'Fes', 'Camera Youness capture les moments essentiels du mariage avec une approche simple, vivante et orientée souvenir. Des préparatifs jusqu’à la soirée, la prestation met en valeur les émotions, les détails, les familles et les instants forts du couple Deplacement possible partout au Maroc.', 2500.00, 7000.00, 'MOYEN', '0661113691', NULL, '@camera_youness', '/ayora/images/vendors/camera-youness.png', NULL, NULL, 'Fes', 'photographe,videaste,photo,video,mariage,fes,couple,evenement,souvenir,shooting', 4.70, 134, 1, '2026-05-14 23:01:28', NULL),
(87, 7, 'Noujoum Fes Bola Bola', 'Fes', 'Noujoum Fes Bola Bola apporte une animation Issawa tres rythmee, ideale pour donner une energie populaire et traditionnelle a la soiree. La prestation convient aux mariages qui veulent un moment fort, participatif et marque par les percussions. Deplacement possible partout au Maroc.', 8000.00, 20000.00, 'PREMIUM', '0663195025', NULL, '@noujoum_fes_bola_bola', '/ayora/images/vendors/noujoum-bola-bola.png', NULL, NULL, 'Fes (deplacement partout au Maroc)', 'issawa,bola-bola,animation,percussions,chant,tradition,ambiance-populaire,entree,ceremonie,mariage', 4.75, 156, 1, '2026-05-14 23:01:28', NULL),
(88, 7, 'Adnane Nafie', 'Fes', 'Adnane Nafie propose une prestation Issawa vivante et puissante, pensée pour les mariages qui veulent garder une vraie touche traditionnelle. Son style convient parfaitement aux entrées marocaines, aux moments de bénédiction et aux ambiances populaires de fin de soirée Deplacement possible partout au Maroc.', 6000.00, 15000.00, 'MOYEN', '0661609964', NULL, '@adnane_nafie_officiel', '/ayora/images/vendors/adnane-nafie.png', NULL, NULL, 'Fes', 'issawa,traditionnel,fassi,ceremonie,fes,authentique,henna,mariage,energique', 4.78, 128, 1, '2026-05-14 23:01:28', NULL),
(89, 13, 'Faly Events', 'Fes', 'Faly Events propose des presentations de mariage elegantes autour des cadeaux, douceurs et mises en scene de reception. Le style convient aux familles qui veulent un rendu propre, harmonieux et valorisant pour les moments d\'entree et d\'offrande. Deplacement possible partout au Maroc.', 3500.00, 12000.00, 'PREMIUM', '0641516348', NULL, '@falyfes_events', '/ayora/images/vendors/faly-events.png', NULL, NULL, 'Fes', 'myadi,tyafer,evenementiel,presentation,offrandes,cadeaux,ceremonie,organisation,decoration,mariage', 4.80, 215, 1, '2026-05-14 23:01:39', NULL),
(90, 7, 'Abdellah El Yaakoubi', 'Fes', 'Groupe Issawa traditionnel porté par Abdellah El Yaakoubi, idéal pour créer une ambiance spirituelle, festive et profondément marocaine. Une animation authentique pour l’entrée de la mariée, la soirée du henné ou les grands moments de célébration familiale. Deplacement possible partout au Maroc.', 5000.00, 10000.00, 'MOYEN', '0661722005', NULL, '@yaakoubichrif', '/ayora/images/vendors/abdellah-yaakoubi.png', NULL, NULL, 'Fes', 'issawa,traditionnel,fassi,fes,authentique,henna,zaffa,ceremonie,premium,mariage,chants,percussions', 4.85, 198, 1, '2026-05-14 23:01:39', NULL),
(91, 11, 'Dar Ba Sidi', 'Fes', 'Dar Ba Sidi met en avant une atmosphere marocaine chaleureuse, parfaite pour une reception traditionnelle avec du caractere. Le lieu convient aux mariages qui veulent une ambiance conviviale, authentique et proche de l\'esprit des grandes maisons marocaines. Deplacement possible partout au Maroc.', 12000.00, 28000.00, 'PREMIUM', '0660088995', NULL, '@dar_ba_sidi', '/ayora/images/vendors/dar-ba-sidi.png', NULL, NULL, 'Fes', 'maison-traditionnelle,reception,ambiance-marocaine,patrimoine,ceremonie,diner-familial,authentique,decoration,mariage', 4.70, 167, 1, '2026-05-14 23:01:39', 'RIAD'),
(92, 11, 'Moktaka Alossar', 'Fes', 'Moktaka Alossar propose un espace de reception simple et fonctionnel pour les mariages familiaux. Le lieu convient aux couples qui cherchent une salle accessible, adaptable et capable d\'accueillir les principaux moments de la ceremonie. Deplacement possible partout au Maroc.', 10000.00, 22000.00, 'MOYEN', '0668199758', NULL, '@moltalalossar', '/ayora/images/vendors/moktaka-alossar.png', NULL, NULL, 'Fes', 'salle-reception,mariage-familial,espace-evenement,diner,ceremonie,organisation,decoration,ambiance,reception,invites', 4.60, 124, 1, '2026-05-14 23:01:39', 'SALLE'),
(94, 6, 'My Kiko Cake - Yassmine Guennoun', 'Fes', 'Chef cuisinier a domicile. Birthday cakes, Wedding cakes, cakes for all occasions. Deplacement partout au Maroc.', 900.00, 4500.00, 'MOYEN', '0648238761', NULL, '@my_kiko_cookies', NULL, NULL, NULL, 'Fes', 'wedding-cake,birthday,domicile,my-kiko,yassmine-guennoun', 4.85, 145, 1, '2026-05-23 14:28:00', NULL);

CREATE TABLE IF NOT EXISTS `vendor_categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name_fr` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `icon` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=18;

INSERT INTO `vendor_categories` (`id`, `name`, `name_fr`, `description`, `icon`) VALUES
(1, 'NEGGAFA', 'Neggafa', 'Habilleuse traditionnelle de la mariee', 'neggafa'),
(2, 'MAKEUP', 'Maquillage & Coiffure', 'Artiste maquilleur(se) et coiffeur(se) specialise(e) mariage', 'makeup'),
(3, 'COIFFURE', '[Obsolete] Coiffure (fusionnee)', 'Categorie fusionnee dans Maquillage & Coiffure', 'coiffure'),
(4, 'PHOTOGRAPHE', 'Photographe & Videaste', 'Photographe et videaste de mariage professionnel', 'photo'),
(5, 'VIDEASTE', '[Obsolete] Videaste (fusionnee)', 'Categorie fusionnee dans Photographe & Videaste', 'video'),
(6, 'CAKE_DESIGNER', 'Cake Designer', 'Patissier specialise gateaux de mariage', 'cake'),
(7, 'ISSAWA', 'Issawa', 'Groupe de musique traditionnelle Issawa', 'issawa'),
(8, 'ORCHESTRE', 'Orchestre', 'Orchestre et groupe musical', 'orchestre'),
(9, 'DECORATION', 'Decoration & Fleuriste', 'Decorateur de mariage et compositions florales', 'decoration'),
(10, 'FLEURISTE', '[Obsolete] Fleuriste (fusionnee)', 'Categorie fusionnee dans Decoration & Fleuriste', 'fleuriste'),
(11, 'SALLE', 'Salle de fete', 'Salle de reception et de mariage', 'salle'),
(12, 'TRAITEUR', 'Traiteur', 'Service traiteur pour mariage', 'traiteur'),
(13, 'MYADI', 'Myadi / Tyafr', 'Service Myadi et Tyafr traditionnel', 'myadi'),
(14, 'DJ', 'DJ', 'DJ professionnel pour soiree', 'dj'),
(15, 'TRANSPORT', '[Supprime] Transport', 'Service non offert par Ayora', 'transport'),
(16, 'HENNAYA', 'Hennaya', 'Artiste de henne traditionnel', 'hennaya'),
(17, 'WEDDING_PLANNER', '[Supprime] Wedding Planner', 'Service non offert par Ayora', 'planner');

CREATE TABLE IF NOT EXISTS `_migrations` (
  `filename` varchar(190) COLLATE utf8mb4_unicode_ci NOT NULL,
  `applied_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `checksum` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`filename`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE `contact_clicks`
  ADD CONSTRAINT `fk_cc_client` FOREIGN KEY (`client_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_cc_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE;

ALTER TABLE `demandes_devis`
  ADD CONSTRAINT `demandes_devis_ibfk_1` FOREIGN KEY (`client_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `demandes_devis_ibfk_2` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE;

ALTER TABLE `guests`
  ADD CONSTRAINT `guests_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

ALTER TABLE `invitations`
  ADD CONSTRAINT `invitations_ibfk_1` FOREIGN KEY (`guest_id`) REFERENCES `guests` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `invitations_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

ALTER TABLE `questionnaire_answers`
  ADD CONSTRAINT `questionnaire_answers_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

ALTER TABLE `recommendations`
  ADD CONSTRAINT `recommendations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `recommendations_ibfk_2` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE;

ALTER TABLE `rendez_vous`
  ADD CONSTRAINT `rendez_vous_ibfk_1` FOREIGN KEY (`client_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `rendez_vous_ibfk_2` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE;

ALTER TABLE `subscriptions`
  ADD CONSTRAINT `subscriptions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

ALTER TABLE `users`
  ADD CONSTRAINT `fk_users_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE SET NULL;

ALTER TABLE `user_picks`
  ADD CONSTRAINT `user_picks_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_picks_ibfk_2` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_picks_ibfk_3` FOREIGN KEY (`category_id`) REFERENCES `vendor_categories` (`id`);

ALTER TABLE `vendors`
  ADD CONSTRAINT `vendors_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `vendor_categories` (`id`);
COMMIT;
