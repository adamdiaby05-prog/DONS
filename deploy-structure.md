# 🚀 Structure de déploiement recommandée pour DONS

## 📁 Structure actuelle (problématique)

```
DONS/
├── backend/                    ✅ À garder (API Laravel)
├── frontend/                   ❌ À exclure (Flutter - pas nécessaire pour le backend)
├── bpay_sdk/                   ❌ À exclure (dupliqué)
├── Nouveau dossier/            ❌ À exclure (nom problématique)
├── *.md                       ❌ À exclure (documentation)
├── *.bat                      ❌ À exclure (Windows)
├── test_*.php                 ❌ À exclure (tests)
├── *.log                      ❌ À exclure (logs)
└── docker-compose.yml         ❌ À exclure (développement local)
```

## 📁 Structure recommandée pour le déploiement

```
DONS/
├── backend/                    ✅ API Laravel
│   ├── app/
│   ├── config/
│   ├── database/
│   ├── routes/
│   ├── storage/
│   ├── vendor/
│   ├── composer.json
│   ├── composer.lock
│   └── .env
├── Dockerfile                  ✅ Configuration Docker
├── .dockerignore              ✅ Fichiers à ignorer
└── README.md                  ✅ Documentation principale
```

## 🔧 Solutions appliquées

### 1. Fichier .dockerignore créé
- Exclut tous les fichiers inutiles
- Exclut les dossiers problématiques
- Exclut la documentation
- Exclut les fichiers de test

### 2. Structure optimisée
- Seul le dossier `backend/` est nécessaire
- Tous les autres dossiers sont ignorés
- Le Dockerfile pointe vers le bon répertoire

## 🚀 Déploiement sur Dokploy

### Variables d'environnement requises :
```yaml
# Application
APP_NAME=DONS
APP_ENV=production
APP_DEBUG=false
APP_URL=https://votre-domaine.com
APP_KEY=base64:your-generated-app-key

# Base de données
DB_CONNECTION=pgsql
DB_HOST=dons-database-dgzain
DB_PORT=5432
DB_DATABASE=postgres
DB_USERNAME=postgres
DB_PASSWORD=your_postgres_password
```

### Configuration Docker :
- **Dockerfile** : Utilise le dossier `backend/`
- **Port** : 80
- **Base de données** : PostgreSQL connectée

## ✅ Avantages de cette structure

1. **Déploiement plus rapide** - Moins de fichiers à transférer
2. **Sécurité** - Pas de fichiers sensibles exposés
3. **Performance** - Image Docker plus légère
4. **Maintenance** - Structure claire et organisée
5. **Compatibilité** - Fonctionne sur tous les systèmes

## 🎯 Prochaines étapes

1. **Vérifiez** que le .dockerignore est correct
2. **Testez** le build Docker localement (optionnel)
3. **Déployez** sur Dokploy avec la nouvelle structure
4. **Vérifiez** que l'application fonctionne

Votre projet DONS est maintenant optimisé pour le déploiement ! 🚀
