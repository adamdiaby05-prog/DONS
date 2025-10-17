# 🚀 Déploiement Complet du Système DONS

## 📋 Composants à déployer

### 1. 🎯 Frontend Flutter
- **Configuration** : `nixpacks-frontend-flutter.toml`
- **Contenu** : Interface utilisateur Flutter compilée
- **Serveur** : Python HTTP Server
- **URL** : Frontend séparé

### 2. 💳 BPay SDK
- **Configuration** : `nixpacks-bpay-sdk.toml`
- **Contenu** : SDK BPay + intégrations de paiement
- **Serveur** : PHP intégré
- **URL** : API de paiement

### 3. 🔧 Backend Laravel
- **Configuration** : `nixpacks-backend-only.toml` (déjà déployé)
- **Contenu** : API Laravel + base de données
- **URL** : https://adm.pront-ix.com/

### 4. 🌐 Système Complet
- **Configuration** : `nixpacks-complete-system.toml`
- **Contenu** : Frontend + Backend + BPay SDK
- **Serveur** : Nginx + PHP-FPM

## 🚀 Instructions de déploiement

### Option 1: Déploiement séparé (Recommandé)

#### Frontend Flutter
```bash
cp nixpacks-frontend-flutter.toml nixpacks.toml
git add .
git commit -m "Deploy Flutter frontend"
git push
```

#### BPay SDK
```bash
cp nixpacks-bpay-sdk.toml nixpacks.toml
git add .
git commit -m "Deploy BPay SDK"
git push
```

### Option 2: Déploiement complet
```bash
cp nixpacks-complete-system.toml nixpacks.toml
git add .
git commit -m "Deploy complete system"
git push
```

## 📊 Architecture du système

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend       │    │   BPay SDK      │
│   (Flutter)     │◄──►│   (Laravel)     │◄──►│   (PHP)         │
│   Port: 80      │    │   Port: 80      │    │   Port: 80      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   PostgreSQL    │
                    │   Database      │
                    └─────────────────┘
```

## 🔧 Configuration des projets Dokploy

### Projet 1: Frontend Flutter
- **Nom** : Dons-Frontend
- **Configuration** : `nixpacks-frontend-flutter.toml`
- **Domaine** : `frontend.dons.com`

### Projet 2: BPay SDK
- **Nom** : Dons-BPay
- **Configuration** : `nixpacks-bpay-sdk.toml`
- **Domaine** : `bpay.dons.com`

### Projet 3: Backend (déjà déployé)
- **Nom** : Dons-Backend
- **Configuration** : `nixpacks-backend-only.toml`
- **Domaine** : `adm.pront-ix.com`

## 🧪 Tests de déploiement

### Frontend Flutter
- ✅ Interface utilisateur accessible
- ✅ Assets et ressources chargées
- ✅ Connexion API backend

### BPay SDK
- ✅ API de paiement fonctionnelle
- ✅ Intégration BPay opérationnelle
- ✅ Callbacks de paiement

### Backend Laravel
- ✅ API REST fonctionnelle
- ✅ Base de données connectée
- ✅ Authentification

## 📝 URLs de test

### Frontend
- Interface utilisateur : `https://frontend.dons.com/`
- Dashboard : `https://frontend.dons.com/dashboard.html`
- Login : `https://frontend.dons.com/login.html`

### BPay SDK
- API BPay : `https://bpay.dons.com/`
- Test paiement : `https://bpay.dons.com/test_barapay_integration.php`
- Intégration : `https://bpay.dons.com/barapay_payment_integration.php`

### Backend
- API Dons : `https://adm.pront-ix.com/api/dons`
- API Paiements : `https://adm.pront-ix.com/api/payments`
- Statistiques : `https://adm.pront-ix.com/api/statistics`

## 🔄 Workflow de déploiement

1. **Déployer le Backend** (déjà fait)
2. **Déployer le Frontend Flutter**
3. **Déployer le BPay SDK**
4. **Tester les connexions**
5. **Configurer les domaines**

## 🚨 Dépannage

### Erreurs communes
- **403 Forbidden** : Vérifier la configuration nginx
- **500 Internal Error** : Vérifier les variables d'environnement
- **Connexion DB** : Vérifier la configuration PostgreSQL

### Logs à vérifier
- Logs de build dans Dokploy
- Logs d'application
- Logs de base de données

---

**Note** : Chaque composant peut être déployé indépendamment pour une meilleure gestion et maintenance.
