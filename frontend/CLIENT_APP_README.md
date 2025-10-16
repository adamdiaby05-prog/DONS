# 🚀 Application Mobile Client - Campagne ADM MELLO

## 📱 Vue d'ensemble

Cette application mobile Flutter est conçue pour la campagne électorale d'**Ahoua Don Mello** pour l'élection présidentielle 2025 en Côte d'Ivoire. Elle permet aux citoyens de découvrir la campagne et de faire des dons via les réseaux de paiement mobile.

## ✨ Fonctionnalités principales

### 🎯 **Campagne électorale**
- **Présentation du candidat** : Biographie, photo et informations
- **Priorités de campagne** : 4 axes principaux avec descriptions détaillées
- **Design moderne** : Interface utilisateur intuitive et responsive

### 💰 **Système de paiement intégré**
- **4 réseaux de paiement** : MTN MoMo, MOOV Money, ORANGE Money, WACE CI
- **Processus simplifié** : Sélection réseau → Numéro → Montant → Confirmation
- **Sécurité** : Validation et confirmation des transactions

### 🔄 **Navigation fluide**
- **Interface à onglets** : Campagne et Paiement
- **Navigation intuitive** : Boutons de retour et progression claire
- **Design cohérent** : Palette de couleurs unifiée

## 🏗️ Architecture technique

### 📁 **Structure des fichiers**
```
lib/
├── models/
│   ├── campaign.dart          # Modèle de campagne
│   └── payment_network.dart   # Modèle de réseau de paiement
├── screens/
│   └── client/
│       ├── campaign_screen.dart           # Écran principal de campagne
│       ├── network_selection_screen.dart  # Sélection du réseau
│       ├── phone_number_screen.dart       # Saisie du numéro
│       ├── amount_screen.dart             # Saisie du montant
│       ├── payment_confirmation_screen.dart # Confirmation
│       └── client_main_screen.dart        # Écran principal
├── services/
│   ├── campaign_service.dart  # API campagne
│   └── payment_service.dart   # API paiements
└── widgets/
    └── client/
        ├── priority_card.dart     # Carte de priorité
        ├── donation_button.dart   # Bouton de don
        ├── network_button.dart    # Bouton réseau
        └── network_display.dart   # Affichage réseau
```

### 🔌 **Intégration API**
- **Base URL** : `http://127.0.0.1:8000/api`
- **Endpoints** :
  - `GET /campaign` - Informations de la campagne
  - `GET /campaign/priorities` - Priorités de la campagne
  - `POST /payments/initiate` - Initier un paiement
  - `GET /payments/{id}/status` - Statut du paiement
  - `POST /payments/{id}/confirm` - Confirmer le paiement

### 🎨 **Design System**
- **Couleurs principales** :
  - Rouge : `#b22222` (ADM MELLO)
  - Bleu : `#1e3a8a` (Côte d'Ivoire)
  - Blanc : `#ffffff`
- **Typographie** : Google Fonts Poppins
- **Style** : Material Design 3 avec personnalisation

## 🚀 Installation et démarrage

### 📋 **Prérequis**
- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / VS Code
- Émulateur Android ou appareil physique

### ⚙️ **Configuration**
1. **Cloner le projet**
   ```bash
   git clone <repository-url>
   cd frontend
   ```

2. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

3. **Configurer l'API**
   - Modifier `baseUrl` dans les services si nécessaire
   - Vérifier que le backend Laravel est en cours d'exécution

4. **Lancer l'application**
   ```bash
   flutter run
   ```

## 📱 Utilisation de l'application

### 🎯 **Découvrir la campagne**
1. **Accueil** : Informations sur le candidat
2. **Priorités** : 4 axes de développement
3. **Biographie** : Parcours et expérience

### 💳 **Faire un don**
1. **Sélection réseau** : Choisir MTN, MOOV, ORANGE ou WACE
2. **Numéro de téléphone** : Saisir le numéro mobile
3. **Montant** : Définir le montant du don
4. **Confirmation** : Vérifier et valider la transaction

## 🔧 Configuration avancée

### 🌐 **Environnements**
- **Développement** : `http://127.0.0.1:8000`
- **Production** : À configurer selon l'hébergement

### 🔐 **Sécurité**
- Validation des entrées utilisateur
- Gestion des erreurs réseau
- Messages d'information clairs

### 📊 **Monitoring**
- Logs de navigation
- Suivi des erreurs
- Métriques de performance

## 🧪 Tests

### 📱 **Tests d'interface**
```bash
flutter test integration_test/
```

### 🔧 **Tests unitaires**
```bash
flutter test test/
```

### 📊 **Tests de performance**
```bash
flutter run --profile
```

## 🚀 Déploiement

### 📱 **Build Android**
```bash
flutter build apk --release
```

### 🍎 **Build iOS**
```bash
flutter build ios --release
```

### 🌐 **Build Web**
```bash
flutter build web --release
```

## 📚 Documentation API

### 🎯 **Campagne**
```json
GET /api/campaign
Response: {
  "data": {
    "id": "1",
    "candidate_name": "Ahoua Don Mello",
    "candidate_photo": "url_photo",
    "biography": "Biographie...",
    "election_year": "2025",
    "slogan": "SOUVERAINETÉ - ÉGALITÉ - JUSTICE",
    "priorities": [...]
  }
}
```

### 💰 **Paiements**
```json
POST /api/payments/initiate
Body: {
  "network_id": "mtn",
  "phone_number": "+2250701234567",
  "amount": 1000.00,
  "currency": "XOF",
  "description": "Don pour la campagne ADM MELLO"
}
```

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature
3. Commit les changements
4. Push vers la branche
5. Ouvrir une Pull Request

## 📞 Support

Pour toute question ou support :
- Créer une issue sur GitHub
- Contacter l'équipe de développement
- Consulter la documentation technique

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

---

**Développé avec ❤️ pour la campagne ADM MELLO 2025**
