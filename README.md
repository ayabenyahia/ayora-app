# Ayora — Planification de mariage à Fès

Application web de planification de mariage marocain : questionnaire en 6 sections,
**moteur de recommandation** de prestataires (k-NN pondéré : budget, style, ville,
invités, luxe, qualité), **assistant IA** (Gemini), 76 prestataires réels (Fès, Rabat,
Casablanca…), gestion des invités, invitations digitales et abonnements Free / Pro / Premium.

**Démo en ligne : _lien à venir_**

| Compte de démonstration | Email | Mot de passe |
|---|---|---|
| Cliente (Premium) | `test@ayora.ma` | `test123` |
| Cliente (Premium) | `pro@ayora.ma` | `pro123` |

> Hébergement gratuit : au premier chargement, le serveur peut mettre ~1 minute à se réveiller.

## Stack

- **Java 17**, **Jakarta EE** (Servlets, Filters, Listeners) sur **Apache Tomcat 10**
- **MySQL 8** via **JDBC** (DAO + PreparedStatement), mots de passe hashés **PBKDF2**
- **HTML / CSS / JavaScript** (sans framework) côté front, API REST JSON
- **Docker** — déployé sur **Render** (application) + **Aiven** (base MySQL)

## Architecture

```
navigateur ──► Servlets REST (/api/...) ──► AyoraService (métier) ──► DAO JDBC ──► MySQL
                      │
                      └──► Assistant IA : orchestrateur + garde-fous + fournisseur LLM
```

- `src/com/ayora/servlet` : endpoints REST (`/api/vendors`, `/api/auth`, `/api/guests`…)
- `src/com/ayora/business` : logique métier, recommandations
- `src/com/ayora/dao` : accès aux données (JDBC)
- `src/com/ayora/assistant` : assistant IA
- `WebContent/` : pages et ressources du front

Documentation détaillée : [`docs/`](docs/README.md).

## Lancer en local (Eclipse + Tomcat)

1. Importer la base dans MySQL (`sql/ayora_db_full.sql` puis les migrations, voir `docs/LAUNCH.md`).
2. Importer le projet dans Eclipse (Dynamic Web Project), ajouter un serveur **Tomcat 10**.
3. Démarrer le serveur, puis ouvrir `http://localhost:8080/ayora/`.

Sans configuration, l'application se connecte à `localhost`, base `ayora_db`, utilisateur `root`.

## Déploiement (Render + Aiven)

L'image est construite par le [`Dockerfile`](Dockerfile) (Tomcat 10.1 + Java 17). Au premier
démarrage, si la base est vide, l'application importe automatiquement
`WebContent/WEB-INF/db/ayora_deploy.sql` (tables, prestataires, comptes de démonstration).

| Variable | Rôle |
|---|---|
| `AYORA_DB_HOST`, `AYORA_DB_PORT` | adresse de la base MySQL (Aiven) |
| `AYORA_DB_NAME`, `AYORA_DB_USER`, `AYORA_DB_PASSWORD` | base et identifiants |
| `AYORA_DB_SSL` | `true` pour une base hébergée (SSL obligatoire) |
| `AYORA_ADMIN_PASSWORD` | mot de passe du compte `admin@ayora.ma` |
| `AYORA_CLOUD_API_KEY` | clé Gemini pour l'assistant IA (facultatif) |

Le fichier [`render.yaml`](render.yaml) décrit le service Render, et
[`.github/workflows/keep-alive.yml`](.github/workflows/keep-alive.yml) garde le site éveillé.
