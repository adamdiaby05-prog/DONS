# 🚀 Intégration Barapay dans DONS

## 📋 Vue d'ensemble

L'intégration Barapay permet aux utilisateurs de faire des paiements sécurisés directement depuis l'application Flutter DONS. Le système utilise un backend PHP pour communiquer avec l'API Barapay.

## 🏗️ Architecture

```
[App Flutter] → [Backend PHP] → [API Barapay]
                      ↓
              (renvoie checkout_url)
                      ↓
[App Flutter] → (ouvre page de paiement)
```

## 📁 Fichiers créés/modifiés

### Nouveaux fichiers
- `frontend/lib/services/barapay_service.dart` - Service principal Barapay
- `frontend/lib/models/barapay_payment.dart` - Modèle de données
- `frontend/lib/screens/client/barapay_payment_screen.dart` - Écran de paiement
- `frontend/lib/widgets/client/barapay_button.dart` - Widgets de paiement
- `test_barapay_connection.dart` - Script de test
- `test_barapay_integration.bat` - Script de démarrage

### Fichiers modifiés
- `frontend/lib/screens/client/payment_confirmation_screen.dart` - Intégration Barapay

## 🔧 Configuration

### 1. Identifiants Barapay
Les identifiants sont configurés dans le backend PHP :
```php
define('BARAPAY_CLIENT_ID', 'wjb7lzQVialbcwMNTPD1IojrRzPIIl');
define('BARAPAY_CLIENT_SECRET', 'eXSMVquRfnUi6u5epkKFbxym1bZxSjgfHMxJlGGKq9j1amulx97Cj4QB7vZFzuyRUm4UC9mCHYhfzWn34arIyW4G2EU9vcdcQsb1');
```

### 2. URL du serveur
Dans `barapay_service.dart` :
```dart
static const String _baseUrl = 'http://localhost:8000';
```

## 🚀 Démarrage

### 1. Démarrer le serveur PHP
```bash
cd backend
php -S localhost:8000
```

### 2. Démarrer l'application Flutter
```bash
cd frontend
flutter run -d chrome --web-port 3000
```

### 3. Tester l'intégration
```bash
# Windows
test_barapay_integration.bat

# Ou manuellement
dart test_barapay_connection.dart
```

## 💳 Utilisation

### 1. Dans l'écran de confirmation de paiement
- L'utilisateur peut choisir entre "Barapay (Recommandé)" et "Paiement traditionnel"
- Barapay est sélectionné par défaut si le service est disponible

### 2. Processus de paiement Barapay
1. L'utilisateur clique sur "Payer avec Barapay"
2. L'app crée un paiement via l'API PHP
3. L'app ouvre la page de paiement Barapay dans un WebView
4. L'utilisateur termine le paiement sur la page Barapay

### 3. Widgets disponibles
- `BarapayButton` - Bouton de paiement principal
- `BarapayQuickButton` - Bouton rapide avec montant
- `BarapayCustomButton` - Bouton avec montant personnalisé

## 🔍 Endpoints API

### Backend PHP
- `POST /api_save_payment.php` - Créer un paiement (compatible Flutter)
- `POST /api/barapay/create` - Créer un paiement selon la documentation
- `GET /api/barapay/status` - Vérifier le statut d'un paiement
- `POST /api/barapay/callback` - Callback Barapay (webhook)
- `GET /api/test` - Test de l'API

### Flutter Service
- `BarapayService.createPayment()` - Créer un paiement
- `BarapayService.openPaymentPage()` - Ouvrir la page de paiement
- `BarapayService.checkPaymentStatus()` - Vérifier le statut
- `BarapayService.testConnection()` - Tester la connexion

## 🛡️ Sécurité

- Les clés secrètes Barapay sont stockées uniquement côté serveur
- L'app Flutter ne contient aucune clé sensible
- Communication sécurisée via HTTPS (en production)
- Validation des données côté serveur

## 🧪 Tests

### Test de connexion
```dart
final isConnected = await BarapayService.testConnection();
```

### Test de création de paiement
```dart
final response = await BarapayService.createPayment(
  amount: 5000,
  phoneNumber: '+225123456789',
  description: 'Test de paiement',
);
```

### Test d'ouverture de page
```dart
final success = await BarapayService.openPaymentPage(response.checkoutUrl!);
```

## 🐛 Dépannage

### Problèmes courants

1. **Serveur PHP non accessible**
   - Vérifiez que le serveur PHP est démarré sur le port 8000
   - Testez avec `curl http://localhost:8000/api/test`

2. **Erreur de connexion Barapay**
   - Vérifiez les identifiants dans le backend PHP
   - Testez la connexion avec `BarapayService.testConnection()`

3. **Page de paiement ne s'ouvre pas**
   - Vérifiez que `url_launcher` est installé
   - Testez avec `BarapayService.openPaymentPage()`

### Logs de débogage
```dart
// Activer les logs dans barapay_service.dart
print('🚀 Création paiement Barapay: $requestData');
print('📡 Réponse Barapay: ${response.statusCode} - ${response.body}');
```

## 📱 Interface utilisateur

### Écran de confirmation de paiement
- Sélection du mode de paiement (Barapay/Traditionnel)
- Indicateur de statut de connexion Barapay
- Bouton de paiement adapté au mode sélectionné
- Messages d'information contextuels

### Widgets de paiement
- Boutons avec animations
- Gestion des états de chargement
- Messages d'erreur intégrés
- Design cohérent avec l'app

## 🔄 Flux de données

1. **Création du paiement**
   ```
   Flutter → PHP → Barapay API → PHP → Flutter
   ```

2. **Ouverture de la page**
   ```
   Flutter → WebView → Page Barapay
   ```

3. **Vérification du statut**
   ```
   Flutter → PHP → Barapay API → PHP → Flutter
   ```

## 📈 Améliorations futures

- [ ] Gestion des webhooks Barapay
- [ ] Historique des paiements
- [ ] Notifications push
- [ ] Support multi-devises
- [ ] Analytics des paiements

## 🆘 Support

En cas de problème :
1. Vérifiez les logs de l'application
2. Testez la connexion avec le script de test
3. Vérifiez la configuration du serveur PHP
4. Consultez la documentation Barapay officielle
