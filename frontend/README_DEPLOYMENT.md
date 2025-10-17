# 🚀 Déploiement Frontend DONS

## 📋 Configuration Dokploy

### 1. Nouveau Projet
- **Nom** : `DONS-Frontend`
- **Description** : `Interface utilisateur Flutter pour DONS`

### 2. Configuration Build
```
Build Type: Nixpacks
Build Path: frontend/
Publish Directory: (vide)
Container Port: 80
```

### 3. Variables d'environnement
```
APP_NAME=DONS-Frontend
APP_ENV=production
API_URL=https://adm.pront-ix.com/api
```

### 4. Domaine
```
Domain: app.adm.pront-ix.com
(ou frontend.adm.pront-ix.com)
```

## 🔧 Fichiers de Configuration

- `nixpacks.toml` - Configuration Nixpacks
- `static-server.py` - Serveur Python pour Flutter
- `setup-complete.sh` - Script de configuration
- `README_DEPLOYMENT.md` - Ce fichier

## 🎯 Fonctionnalités

### Frontend Flutter
- Interface utilisateur complète
- Navigation et écrans
- Connexion au backend via API

### Fichiers Statiques
- Documentation du projet
- Scripts SQL
- Fichiers de configuration
- Fichiers PHP (pour référence)

## 🚀 Déploiement

1. **Créer le projet** dans Dokploy
2. **Configurer** les paramètres ci-dessus
3. **Déployer** depuis le repository GitHub
4. **Tester** l'URL du domaine

## 🔗 Intégration

Le frontend se connecte au backend via :
- **API URL** : `https://adm.pront-ix.com/api`
- **Endpoints** : `/api/campaign`, `/api/payments`, etc.
- **Authentification** : Via l'API Laravel

## 📞 Support

Pour toute question, consultez les logs de déploiement ou ce fichier.
