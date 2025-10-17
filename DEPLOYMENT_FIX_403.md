# 🔧 Correction de l'erreur 403 Forbidden

## Problème identifié
L'erreur 403 Forbidden sur https://adm.pront-ix.com/ était causée par :
1. Configuration nginx complexe avec des chemins incorrects
2. Conflit entre nginx et PHP-FPM
3. Structure de fichiers non optimale pour Dokploy

## Solutions appliquées

### 1. Configuration nixpacks simplifiée
- ✅ Supprimé nginx de la configuration
- ✅ Utilisé uniquement le serveur PHP intégré
- ✅ Simplifié la structure de déploiement

### 2. Router PHP amélioré
- ✅ Ajouté une page d'accueil de test
- ✅ Gestion des erreurs améliorée
- ✅ Support des routes API Laravel

### 3. Nouvelles configurations disponibles

#### Option 1: Backend uniquement (recommandé)
```bash
# Utiliser nixpacks-backend-only.toml
# Configuration la plus simple et stable
```

#### Option 2: Configuration complète
```bash
# Utiliser nixpacks-complete.toml (modifié)
# Inclut frontend Flutter si disponible
```

## Instructions de redéploiement

### Étape 1: Choisir la configuration
1. **Pour un déploiement simple (recommandé)** :
   - Renommez `nixpacks-backend-only.toml` en `nixpacks.toml`
   - Supprimez l'ancien `nixpacks.toml`

2. **Pour un déploiement complet** :
   - Renommez `nixpacks-complete.toml` en `nixpacks.toml`

### Étape 2: Redéployer
1. Dans Dokploy, allez dans votre projet "Dons-Backend"
2. Cliquez sur "Deploy" ou utilisez le webhook
3. Attendez la fin du build

### Étape 3: Tester
1. Visitez https://adm.pront-ix.com/
2. Vous devriez voir la page d'accueil DONS
3. Testez les endpoints API :
   - https://adm.pront-ix.com/api/dons
   - https://adm.pront-ix.com/barapay_payment_integration.php

## Commandes de déploiement

```bash
# Option 1: Backend uniquement
cp nixpacks-backend-only.toml nixpacks.toml
git add .
git commit -m "Fix 403 error - use backend-only configuration"
git push

# Option 2: Configuration complète
cp nixpacks-complete.toml nixpacks.toml
git add .
git commit -m "Fix 403 error - use simplified complete configuration"
git push
```

## Vérification du déploiement

### Tests à effectuer :
1. ✅ Page d'accueil accessible
2. ✅ API Laravel fonctionnelle
3. ✅ Routes BPay opérationnelles
4. ✅ Base de données connectée

### URLs de test :
- https://adm.pront-ix.com/ (page d'accueil)
- https://adm.pront-ix.com/api/dons (API dons)
- https://adm.pront-ix.com/barapay_payment_integration.php (Barapay)

## En cas de problème

### Logs à vérifier :
1. Dans Dokploy : Logs de l'application
2. Vérifier les variables d'environnement
3. Tester la connexion à la base de données

### Solutions de dépannage :
1. **Erreur 500** : Vérifier les variables d'environnement
2. **Erreur de base de données** : Vérifier la configuration DB
3. **Erreur de permissions** : Vérifier les permissions des fichiers

## Prochaines étapes

1. **Déployer le frontend Flutter séparément** (recommandé)
2. **Configurer le domaine personnalisé**
3. **Mettre en place SSL/HTTPS**
4. **Optimiser les performances**

---

**Note** : Cette configuration est optimisée pour Dokploy et devrait résoudre l'erreur 403 Forbidden.
