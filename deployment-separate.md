# Déploiement Séparé DONS

## 🎯 Stratégie de déploiement

### Backend (Laravel + API + Base de données)
- **URL** : `https://adm.pront-ix.com/`
- **Configuration** : `nixpacks.toml` (racine)
- **Fonctionnalités** :
  - API Laravel
  - Base de données PostgreSQL
  - Fichiers PHP (BPay, paiements)
  - Router intelligent

### Frontend (Flutter Web)
- **URL** : `https://app.adm.pront-ix.com/` (nouveau domaine)
- **Configuration** : `frontend/nixpacks.toml`
- **Fonctionnalités** :
  - Interface utilisateur Flutter
  - Connexion à l'API backend
  - Gestion des cotisations
  - Dashboard admin

## 📋 Configuration Backend

```
Build Type: Nixpacks
Build Path: /
Container Port: 80
Domain: adm.pront-ix.com
Environment Variables:
- APP_KEY=base64:ypu9/6rjhvrvSSPna9qtpww32pU/zdA9NJTdvjeqgfo=
- DB_HOST=dons-database-dgzain
- DB_DATABASE=postgres
- DB_USERNAME=postgres
- DB_PASSWORD=dzjgy8g9hnrausia
```

## 📋 Configuration Frontend

```
Build Type: Nixpacks
Build Path: frontend/
Container Port: 80
Domain: app.adm.pront-ix.com
Environment Variables:
- API_BASE_URL=https://adm.pront-ix.com/api
```

## 🚀 Étapes de déploiement

### 1. Backend (déjà fait)
- ✅ Configuration backend simple
- ✅ Base de données connectée
- ✅ API fonctionnelle

### 2. Frontend (nouveau projet)
1. Créer nouveau projet dans Dokploy
2. Connecter le repository GitHub
3. Configurer le domaine `app.adm.pront-ix.com`
4. Déployer avec `frontend/nixpacks.toml`

## 🔗 Communication Backend-Frontend

Le frontend communiquera avec le backend via :
- **API Base** : `https://adm.pront-ix.com/api`
- **Endpoints** :
  - `/api/campaigns` - Gestion des campagnes
  - `/api/payments` - Gestion des paiements
  - `/api/users` - Gestion des utilisateurs
  - `/api/groups` - Gestion des groupes
