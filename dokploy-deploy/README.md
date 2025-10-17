# DONS - Déploiement Dokploy

## 🚀 Structure de Déploiement

Ce dossier contient la structure optimisée pour le déploiement sur Dokploy.

### 📁 Structure des dossiers

```
dokploy-deploy/
├── backend/                 # API Backend PHP
│   ├── *.php               # Fichiers API
│   ├── composer.json       # Dépendances PHP
│   ├── index.php          # Point d'entrée
│   ├── .htaccess          # Configuration Apache
│   ├── start.sh           # Script de démarrage
│   └── Dockerfile         # Configuration Docker
└── README.md              # Ce fichier
```

## 🔧 Configuration Dokploy

### Backend API
- **Type** : PHP
- **Repository** : `https://github.com/adamdiaby05-prog/DONS.git`
- **Chemin** : `/dokploy-deploy/backend`
- **Port** : `8000`
- **Script de démarrage** : `php -S 0.0.0.0:8000`

### Variables d'environnement
```env
DB_HOST=localhost
DB_NAME=dons_db
DB_USER=dons_user
DB_PASSWORD=your_password
BARAPAY_API_KEY=your_barapay_key
BARAPAY_SECRET=your_barapay_secret
```

## 📋 Endpoints API

- `POST /api_save_payment_simple.php` - Créer un paiement
- `GET /api_payments_status.php?payment_id=ID` - Statut du paiement
- `GET /api_payments_history.php` - Historique des paiements

## 🛠️ Commandes de déploiement

```bash
# Cloner le repository
git clone https://github.com/adamdiaby05-prog/DONS.git

# Aller dans le dossier backend
cd DONS/dokploy-deploy/backend

# Installer les dépendances
composer install

# Démarrer le serveur
php -S 0.0.0.0:8000
```

## ✅ Vérification

```bash
# Tester l'API
curl http://localhost:8000

# Tester un endpoint
curl -X POST http://localhost:8000/api_save_payment_simple.php \
  -H "Content-Type: application/json" \
  -d '{"amount": 1000, "phone_number": "1234567890"}'
```
