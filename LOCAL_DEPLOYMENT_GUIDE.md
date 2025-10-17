# 🏠 Déploiement Local - Système DONS

## 🚀 Scripts de démarrage local

### 📋 **Scripts disponibles :**

1. **`start-local-backend.bat`** - Backend Laravel uniquement
2. **`start-local-frontend.bat`** - Frontend Flutter uniquement  
3. **`start-local-bpay.bat`** - BPay SDK uniquement
4. **`start-local-complete.bat`** - Système complet

## 🎯 **Démarrage rapide :**

### Option 1: Système complet (Recommandé)
```bash
# Double-clic sur le fichier ou en ligne de commande :
start-local-complete.bat
```

### Option 2: Composants séparés
```bash
# Backend Laravel
start-local-backend.bat

# Frontend Flutter (dans un autre terminal)
start-local-frontend.bat

# BPay SDK (dans un autre terminal)
start-local-bpay.bat
```

## 🔧 **Prérequis :**

### Logiciels requis :
- ✅ **PHP 8.1+** avec extensions
- ✅ **Composer** (gestionnaire de dépendances PHP)
- ✅ **Flutter SDK** (pour le frontend)
- ✅ **Python 3** (serveur statique)
- ✅ **PostgreSQL** (base de données)

### Extensions PHP requises :
- `pdo_pgsql` (PostgreSQL)
- `curl` (API calls)
- `json` (JSON handling)
- `mbstring` (Multibyte strings)

## 📊 **URLs locales :**

### Backend Laravel
- **URL principale** : http://localhost:8000
- **API Dons** : http://localhost:8000/api/dons
- **API Paiements** : http://localhost:8000/api/payments
- **API Statistiques** : http://localhost:8000/api/statistics

### Frontend Flutter
- **URL principale** : http://localhost:3000
- **Dashboard** : http://localhost:3000/dashboard.html
- **Login** : http://localhost:3000/login.html
- **Admin Groups** : http://localhost:3000/admin_groups.html

### BPay SDK
- **URL principale** : http://localhost:8080
- **Test BPay** : http://localhost:8080/test_barapay_integration.php
- **Intégration** : http://localhost:8080/barapay_payment_integration.php

## 🔧 **Configuration :**

### Base de données PostgreSQL
```sql
-- Créer la base de données
CREATE DATABASE dons_local;

-- Utiliser le script de création des tables
\i script-complet-dons.sql
```

### Variables d'environnement (backend/.env)
```env
APP_NAME=DONS
APP_ENV=local
APP_KEY=base64:your-key-here
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=pgsql
DB_HOST=localhost
DB_PORT=5432
DB_DATABASE=dons_local
DB_USERNAME=your_username
DB_PASSWORD=your_password
```

## 🧪 **Tests de fonctionnement :**

### 1. Test Backend
```bash
# Test API
curl http://localhost:8000/api/dons

# Test BPay
curl http://localhost:8000/barapay_payment_integration.php
```

### 2. Test Frontend
- Ouvrir http://localhost:3000
- Vérifier que l'interface se charge
- Tester la navigation

### 3. Test BPay SDK
- Ouvrir http://localhost:8080
- Tester l'intégration de paiement

## 🚨 **Dépannage :**

### Erreurs communes :

#### Backend ne démarre pas
- Vérifier que PHP est installé
- Vérifier que Composer est installé
- Vérifier la configuration de la base de données

#### Frontend ne se charge pas
- Vérifier que Flutter est installé
- Vérifier que Python est installé
- Vérifier que le build s'est bien passé

#### BPay SDK ne fonctionne pas
- Vérifier que les fichiers sont copiés
- Vérifier que Composer a installé les dépendances
- Vérifier la configuration BPay

### Logs à vérifier :
- Logs PHP : `backend/storage/logs/`
- Logs Flutter : Console du navigateur
- Logs BPay : Console du serveur

## 🔄 **Workflow de développement :**

1. **Démarrer la base de données** PostgreSQL
2. **Démarrer le backend** : `start-local-backend.bat`
3. **Démarrer le frontend** : `start-local-frontend.bat`
4. **Démarrer BPay** : `start-local-bpay.bat`
5. **Tester les connexions** entre composants

## 📝 **Notes importantes :**

- **Ports utilisés** : 8000 (Backend), 3000 (Frontend), 8080 (BPay)
- **Base de données** : PostgreSQL locale
- **Environnement** : Développement local
- **Sécurité** : Configuration de développement uniquement

---

**Note** : Ces scripts sont optimisés pour le développement local. Pour la production, utilisez les configurations de déploiement Dokploy.
