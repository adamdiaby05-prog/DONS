# 🚀 Stratégie de Déploiement DONS

## 📋 Vue d'ensemble

Cette stratégie utilise des déploiements séparés pour optimiser la stabilité et la maintenance.

## 🔧 Configuration Actuelle

### Backend Laravel (Principal)
- **Fichier de config** : `nixpacks.toml`
- **URL** : `https://adm.pront-ix.com/`
- **Fonctionnalités** :
  - API Laravel
  - Base de données PostgreSQL
  - BPay SDK
  - Fichiers de paiement
  - Router intelligent

### Frontend Flutter (Séparé - à venir)
- **Fichier de config** : `nixpacks-frontend.toml`
- **URL** : `https://app.adm.pront-ix.com/` (à configurer)
- **Fonctionnalités** :
  - Interface utilisateur Flutter
  - Connexion au backend via API
  - Assets statiques

## 🎯 Avantages

1. **Stabilité** - Backend et frontend indépendants
2. **Maintenance** - Mise à jour séparée de chaque partie
3. **Performance** - Builds plus rapides et fiables
4. **Scalabilité** - Possibilité de déployer sur différents serveurs

## 📁 Structure des Fichiers

```
DONS/
├── nixpacks.toml              # Backend Laravel
├── nixpacks-backend.toml      # Backend alternatif
├── nixpacks-frontend.toml     # Frontend Flutter
├── backend/                   # Code Laravel
├── frontend/                  # Code Flutter
├── public/index.php           # Router intelligent
└── DEPLOYMENT_STRATEGY.md     # Ce fichier
```

## 🚀 Prochaines Étapes

1. ✅ **Backend déployé** - Fonctionnel sur adm.pront-ix.com
2. 🔄 **Frontend séparé** - Nouveau projet Dokploy
3. 🔗 **Intégration** - Connexion frontend ↔ backend
4. 🧪 **Tests** - Validation complète

## 📞 Support

Pour toute question sur le déploiement, consultez ce fichier ou les logs de déploiement.
