# Guide de Déploiement Dokploy - Application DONS

## 🚀 Déploiement de l'Application DONS sur Dokploy

### 📋 Prérequis
- Repository GitHub : `https://github.com/adamdiaby05-prog/DONS.git`
- Compte Dokploy configuré
- Accès SSH aux serveurs

### 🔧 Configuration du Déploiement

#### 1. **Backend PHP (API)**
```yaml
# Configuration Dokploy pour le Backend
name: dons-backend
type: php
repository: https://github.com/adamdiaby05-prog/DONS.git
branch: master
path: /backend
port: 8000
php_version: 8.2
```

**Variables d'environnement :**
```env
DB_HOST=localhost
DB_NAME=dons_db
DB_USER=dons_user
DB_PASSWORD=your_password
BARAPAY_API_KEY=your_barapay_key
BARAPAY_SECRET=your_barapay_secret
```

#### 2. **Frontend Flutter Web**
```yaml
# Configuration Dokploy pour le Frontend
name: dons-frontend
type: static
repository: https://github.com/adamdiaby05-prog/DONS.git
branch: master
path: /frontend
build_command: |
  cd frontend
  flutter pub get
  flutter build web --release
output_directory: frontend/build/web
port: 3000
```

### 🛠️ Étapes de Déploiement

#### **Étape 1 : Backend PHP**
1. Créer une nouvelle application dans Dokploy
2. Type : **PHP**
3. Repository : `https://github.com/adamdiaby05-prog/DONS.git`
4. Chemin : `/backend`
5. Port : `8000`
6. PHP Version : `8.2`

**Script de démarrage :**
```bash
#!/bin/bash
cd /app/backend
php -S 0.0.0.0:8000
```

#### **Étape 2 : Frontend Flutter**
1. Créer une nouvelle application dans Dokploy
2. Type : **Static Site**
3. Repository : `https://github.com/adamdiaby05-prog/DONS.git`
4. Chemin : `/frontend`
5. Build Command :
```bash
cd frontend
flutter pub get
flutter build web --release
```
6. Output Directory : `frontend/build/web`
7. Port : `3000`

### 🔗 Configuration des Domaines

#### **Backend API**
- URL : `https://api.dons.yourdomain.com`
- Port : `8000`
- CORS : Activé pour le frontend

#### **Frontend Web**
- URL : `https://dons.yourdomain.com`
- Port : `3000`
- Proxy vers backend API

### 📊 Configuration de la Base de Données

#### **PostgreSQL (Recommandé)**
```sql
-- Script de création de la base de données
CREATE DATABASE dons_db;
CREATE USER dons_user WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE dons_db TO dons_user;
```

#### **Tables requises :**
```sql
-- Table des paiements
CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    amount DECIMAL(10,2) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    order_no VARCHAR(100) UNIQUE NOT NULL,
    network VARCHAR(50) NOT NULL,
    currency VARCHAR(3) DEFAULT 'XOF',
    barapay_reference VARCHAR(100),
    checkout_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 🔐 Configuration de Sécurité

#### **Variables d'environnement sensibles :**
```env
# Barapay Configuration
BARAPAY_API_KEY=your_api_key_here
BARAPAY_SECRET=your_secret_here
BARAPAY_MERCHANT_ID=your_merchant_id

# Database Configuration
DB_HOST=your_db_host
DB_NAME=dons_db
DB_USER=dons_user
DB_PASSWORD=secure_password

# Security
JWT_SECRET=your_jwt_secret_key
ENCRYPTION_KEY=your_encryption_key
```

### 🚀 Commandes de Déploiement

#### **Backend :**
```bash
# Cloner le repository
git clone https://github.com/adamdiaby05-prog/DONS.git

# Aller dans le dossier backend
cd DONS/backend

# Installer les dépendances PHP
composer install

# Configurer la base de données
php artisan migrate

# Démarrer le serveur
php -S 0.0.0.0:8000
```

#### **Frontend :**
```bash
# Aller dans le dossier frontend
cd DONS/frontend

# Installer les dépendances Flutter
flutter pub get

# Construire pour le web
flutter build web --release

# Servir les fichiers statiques
# (Dokploy s'occupera de servir les fichiers)
```

### 🔍 Vérification du Déploiement

#### **Backend API :**
```bash
curl https://api.dons.yourdomain.com/api_save_payment_simple.php
# Devrait retourner une réponse JSON
```

#### **Frontend :**
```bash
curl https://dons.yourdomain.com
# Devrait retourner la page HTML de l'application
```

### 📱 Configuration des URLs

#### **Environnement de Production :**
```dart
// frontend/lib/config/environment.dart
static const String productionBaseUrl = 'https://api.dons.yourdomain.com';
```

#### **CORS Configuration :**
```php
// backend/index.php
header('Access-Control-Allow-Origin: https://dons.yourdomain.com');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
```

### 🎯 URLs Finales

- **Application Web** : `https://dons.yourdomain.com`
- **API Backend** : `https://api.dons.yourdomain.com`
- **Documentation** : `https://dons.yourdomain.com/docs`

### 🔧 Maintenance

#### **Logs à surveiller :**
- Backend : `/var/log/dons-backend.log`
- Frontend : `/var/log/dons-frontend.log`
- Base de données : `/var/log/postgresql.log`

#### **Commandes de maintenance :**
```bash
# Redémarrer le backend
sudo systemctl restart dons-backend

# Redémarrer le frontend
sudo systemctl restart dons-frontend

# Vérifier les logs
tail -f /var/log/dons-backend.log
```

### ✅ Checklist de Déploiement

- [ ] Repository GitHub accessible
- [ ] Applications créées dans Dokploy
- [ ] Base de données configurée
- [ ] Variables d'environnement définies
- [ ] Domaines configurés
- [ ] CORS configuré
- [ ] SSL/HTTPS activé
- [ ] Tests de fonctionnement effectués
- [ ] Monitoring configuré

### 🆘 Support

En cas de problème :
1. Vérifier les logs Dokploy
2. Tester les endpoints API
3. Vérifier la configuration CORS
4. Contacter l'équipe de développement

---

**🎉 Déploiement réussi ! Votre application DONS est maintenant en ligne !**
