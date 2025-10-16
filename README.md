# 🚀 DONS - Application de Gestion de Cotisations

## 📋 Vue d'ensemble

DONS est une application complète de gestion de cotisations pour groupes et associations, composée d'un backend Laravel (PHP) et d'un frontend Flutter. L'application intègre le système de paiement Barapay pour des transactions sécurisées.

## 🏗️ Architecture du Projet

```
DONS/
├── backend/          # API Laravel (PHP)
├── frontend/         # Application Flutter
└── README.md         # Ce fichier
```

## 🛠️ Prérequis

### Pour le Backend (Laravel)
- **PHP 8.2+** avec extensions : `curl`, `json`, `mbstring`, `openssl`, `pdo`, `tokenizer`, `xml`
- **Composer** (gestionnaire de dépendances PHP)
- **Base de données** : SQLite (par défaut) ou PostgreSQL
- **Serveur web** : Apache/Nginx (optionnel, Laravel inclut un serveur de développement)

### Pour le Frontend (Flutter)
- **Flutter SDK 3.9.0+**
- **Dart SDK** (inclus avec Flutter)
- **Navigateur web** (pour le développement web)

## 🚀 Installation et Démarrage

### 1. Cloner le Projet

```bash
git clone <url-du-repo>
cd DONS
```

### 2. Configuration du Backend

#### Installation des dépendances
```bash
cd backend
composer install
```

#### Configuration de l'environnement
```bash
# Copier le fichier d'environnement
cp .env.example .env

# Générer la clé d'application
php artisan key:generate

# Créer la base de données SQLite (si elle n'existe pas)
touch database/database.sqlite

# Exécuter les migrations
php artisan migrate
```

#### Démarrage du serveur backend
```bash
# Option 1: Utiliser le script automatique (Windows)
start_backend.bat

# Option 2: Commande manuelle
php artisan serve --host=0.0.0.0 --port=8000
```

Le backend sera accessible sur :
- **Local** : http://localhost:8000
- **Réseau** : http://192.168.100.7:8000

### 3. Configuration du Frontend

#### Installation des dépendances
```bash
cd frontend
flutter pub get
```

#### Démarrage de l'application
```bash
# Option 1: Utiliser le script automatique (Windows)
run_web.bat

# Option 2: Commande manuelle pour le web
flutter run -d web-server --web-port 3000 --web-hostname 0.0.0.0

# Option 3: Pour le développement mobile
flutter run
```

Le frontend sera accessible sur :
- **Local** : http://localhost:3000
- **Réseau** : http://192.168.100.7:3000

## 📱 Scripts de Démarrage Rapide

### Windows

#### Backend
```batch
# Double-clic sur le fichier
backend/start_backend.bat
```

#### Frontend
```batch
# Double-clic sur le fichier
frontend/run_web.bat
```

### Linux/Mac

#### Backend
```bash
cd backend
composer install
php artisan key:generate
php artisan migrate
php artisan serve --host=0.0.0.0 --port=8000
```

#### Frontend
```bash
cd frontend
flutter pub get
flutter run -d web-server --web-port 3000 --web-hostname 0.0.0.0
```

## 🔧 Configuration Avancée

### Base de données PostgreSQL (Optionnel)

Si vous préférez utiliser PostgreSQL au lieu de SQLite :

1. **Installer PostgreSQL** et créer une base de données
2. **Modifier le fichier `.env`** :
```env
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=dons_db
DB_USERNAME=your_username
DB_PASSWORD=your_password
```

3. **Exécuter les migrations** :
```bash
php artisan migrate
```

### Configuration Barapay

Les identifiants Barapay sont déjà configurés dans le backend. Pour les modifier :

1. **Ouvrir** `backend/barapay_*.php`
2. **Modifier** les constantes :
```php
define('BARAPAY_CLIENT_ID', 'votre_client_id');
define('BARAPAY_CLIENT_SECRET', 'votre_client_secret');
```

## 🌐 Accès à l'Application

### Depuis votre ordinateur
- **Backend API** : http://localhost:8000
- **Frontend Web** : http://localhost:3000

### Depuis votre téléphone (même réseau WiFi)
- **Backend API** : http://192.168.100.7:8000
- **Frontend Web** : http://192.168.100.7:3000

## 📊 Endpoints API Principaux

### Backend Laravel
- `GET /api/test` - Test de l'API
- `POST /api/payments/initiate` - Initier un paiement
- `GET /api/payments/{id}` - Récupérer un paiement
- `POST /api/barapay/create` - Créer un paiement Barapay
- `GET /api/barapay/status/{id}` - Statut d'un paiement Barapay

### Test de l'API
```bash
# Test de base
curl http://localhost:8000/api/test

# Test des paiements
curl -X POST http://localhost:8000/api/payments/initiate \
  -H "Content-Type: application/json" \
  -d '{"amount": 5000, "phone": "+225123456789"}'
```

## 🧪 Tests et Débogage

### Test de connexion Barapay
```bash
# Depuis le dossier frontend
dart test_barapay_connection.dart
```

### Logs de débogage
```bash
# Backend Laravel
tail -f backend/storage/logs/laravel.log

# Frontend Flutter
flutter logs
```

## 🛠️ Développement

### Structure du Backend
```
backend/
├── app/
│   ├── Http/Controllers/    # Contrôleurs API
│   └── Models/              # Modèles de données
├── routes/
│   └── api.php             # Routes API
├── database/
│   └── migrations/         # Migrations de base de données
└── barapay_sdk/           # SDK Barapay
```

### Structure du Frontend
```
frontend/
├── lib/
│   ├── screens/           # Écrans de l'application
│   ├── services/          # Services (API, Barapay)
│   ├── models/            # Modèles de données
│   └── widgets/           # Widgets réutilisables
├── assets/
│   ├── images/            # Images
│   └── icons/             # Icônes
└── web/                   # Configuration web
```

## 🚨 Dépannage

### Problèmes courants

#### 1. Erreur "PHP not found"
```bash
# Vérifier l'installation PHP
php --version

# Ajouter PHP au PATH si nécessaire
export PATH="/path/to/php/bin:$PATH"
```

#### 2. Erreur "Composer not found"
```bash
# Installer Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
```

#### 3. Erreur "Flutter not found"
```bash
# Vérifier l'installation Flutter
flutter --version

# Ajouter Flutter au PATH
export PATH="$PATH:/path/to/flutter/bin"
```

#### 4. Erreur de base de données
```bash
# Réinitialiser la base de données
php artisan migrate:fresh
php artisan db:seed
```

#### 5. Problème de CORS
```bash
# Vérifier la configuration CORS dans backend/config/cors.php
# S'assurer que les domaines frontend sont autorisés
```

### Logs utiles
```bash
# Backend Laravel
tail -f backend/storage/logs/laravel.log

# Frontend Flutter
flutter logs --verbose
```

## 📱 Déploiement

### Build de production

#### Frontend
```bash
cd frontend
flutter build web --release
# Les fichiers sont dans build/web/
```

#### Backend
```bash
cd backend
composer install --optimize-autoloader --no-dev
php artisan config:cache
php artisan route:cache
```

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 🆘 Support

En cas de problème :

1. **Vérifiez les logs** : `backend/storage/logs/laravel.log`
2. **Testez la connexion** : `curl http://localhost:8000/api/test`
3. **Vérifiez les dépendances** : `composer install` et `flutter pub get`
4. **Consultez la documentation** : Laravel et Flutter docs

---

**Développé avec ❤️ pour la gestion de cotisations**
