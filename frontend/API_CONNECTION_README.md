# 🔌 Guide de Connexion API - Application DONS

## 📋 **Vue d'ensemble**

Cette application Flutter se connecte à un backend Laravel pour gérer les paiements et les contributions. Le système inclut un diagnostic automatique de connexion et des outils de dépannage.

## ⚙️ **Configuration de l'environnement**

### **1. Fichier de configuration rapide**
Modifiez le fichier `lib/config/quick_config.dart` selon votre environnement :

```dart
void configureEnvironment() {
  // Pour le développement local (votre ordinateur)
  EnvironmentConfig.setEnvironment(Environment.local);
  
  // Pour l'émulateur Android
  // EnvironmentConfig.setEnvironment(Environment.emulator);
  
  // Pour le serveur de production
  // EnvironmentConfig.setEnvironment(Environment.server);
}
```

### **2. Environnements disponibles**

| Environnement | URL | Utilisation |
|---------------|-----|-------------|
| `Environment.local` | `http://localhost:8000` | Développement sur votre ordinateur |
| `Environment.emulator` | `http://10.0.2.2:8000` | Émulateur Android |
| `Environment.server` | `http://votre-serveur.com:8000` | Serveur de production |

## 🚀 **Démarrage du backend**

### **1. Démarrer le serveur Laravel**
```bash
cd backend
php artisan serve
```

Le serveur sera accessible sur `http://localhost:8000`

### **2. Vérifier que l'API fonctionne**
```bash
# Test de l'API principale
curl http://localhost:8000/api/test

# Test de l'API des paiements
curl http://localhost:8000/api/payments/test
```

## 🔍 **Diagnostic de connexion**

### **1. Bouton de diagnostic**
L'application inclut un bouton "Diagnostiquer la connexion" qui :
- Teste la connexion à l'API principale
- Teste la connexion à l'API des paiements
- Affiche des suggestions de résolution
- Montre l'environnement actuel et l'URL utilisée

### **2. Diagnostic automatique**
Avant chaque paiement, l'application teste automatiquement la connexion et affiche des messages d'erreur détaillés.

## 🛠️ **Résolution des problèmes**

### **Erreur : "Impossible de se connecter au serveur"**

#### **Vérifications à faire :**

1. **Serveur Laravel démarré ?**
   ```bash
   cd backend
   php artisan serve
   ```

2. **Port 8000 accessible ?**
   - Vérifiez qu'aucune autre application n'utilise le port 8000
   - Testez avec : `curl http://localhost:8000/api/test`

3. **Environnement correct ?**
   - Si vous testez sur votre ordinateur : `Environment.local`
   - Si vous utilisez un émulateur : `Environment.emulator`

4. **Pare-feu ?**
   - Vérifiez que le pare-feu n'empêche pas la connexion
   - Autorisez les connexions sur le port 8000

#### **Solutions :**

1. **Changer d'environnement** dans `quick_config.dart`
2. **Redémarrer l'application** Flutter
3. **Vérifier la configuration réseau** de votre appareil/émulateur

### **Erreur : "Délai d'attente dépassé"**

- Vérifiez votre connexion internet
- Augmentez les timeouts dans `ApiConfig`
- Vérifiez que le serveur Laravel répond rapidement

## 📱 **Test de l'application**

### **1. Lancer l'application**
```bash
cd frontend
flutter run
```

### **2. Tester la connexion**
1. Allez sur la page "Montant"
2. Appuyez sur "Diagnostiquer la connexion"
3. Vérifiez les résultats des tests

### **3. Tester un paiement**
1. Saisissez un montant
2. Appuyez sur "Valider"
3. L'application testera automatiquement la connexion

## 🔧 **Configuration avancée**

### **1. Modifier les timeouts**
Dans `lib/config/api_config.dart` :
```dart
static const int connectTimeout = 10; // secondes
static const int receiveTimeout = 10; // secondes
```

### **2. Ajouter de nouveaux endpoints**
Dans `lib/config/api_config.dart` :
```dart
static const String newEndpoint = '/api/new-endpoint';
```

### **3. Modifier les headers**
Dans `lib/config/api_config.dart` :
```dart
static const Map<String, String> defaultHeaders = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'User-Agent': 'DONS-App/1.0',
  'Authorization': 'Bearer your-token', // Si nécessaire
};
```

## 📊 **Structure des fichiers**

```
frontend/lib/
├── config/
│   ├── api_config.dart          # Configuration de l'API
│   ├── environment.dart         # Gestion des environnements
│   └── quick_config.dart       # Configuration rapide
├── services/
│   ├── payment_service.dart     # Service de paiement
│   ├── api_test_service.dart    # Tests de connexion
│   └── connection_diagnostic_service.dart # Diagnostic
└── screens/
    └── client/
        └── amount_screen.dart   # Page de paiement
```

## 🚨 **Dépannage rapide**

| Symptôme | Cause probable | Solution |
|----------|----------------|----------|
| "Connection refused" | Serveur non démarré | `php artisan serve` |
| "Timeout" | Réseau lent/Pare-feu | Vérifier la connexion |
| "Wrong environment" | Mauvaise config | Modifier `quick_config.dart` |
| "API not found" | Routes non définies | Vérifier `backend/routes/api.php` |

## 📞 **Support**

Si vous rencontrez des problèmes :
1. Utilisez le bouton "Diagnostiquer la connexion"
2. Vérifiez les logs du serveur Laravel
3. Testez avec `curl` pour isoler le problème
4. Vérifiez la configuration d'environnement 