# 🧪 Test de Connexion - Guide Rapide

## ✅ **Serveur démarré et fonctionnel**

Le serveur PHP simple est maintenant démarré et accessible sur :
- `http://localhost:8000` (depuis votre ordinateur)
- `http://192.168.1.7:8000` (depuis votre appareil mobile)

## 🔧 **Configuration actuelle**

L'application Flutter est configurée pour utiliser :
- **Environnement** : `Environment.localNetwork`
- **URL** : `http://192.168.1.7:8000`

## 📱 **Test de l'application**

### **1. Redémarrez l'application Flutter**
```bash
cd frontend
flutter run
```

### **2. Testez la connexion**
1. Allez sur la page "Montant"
2. Appuyez sur "Diagnostiquer la connexion"
3. Vérifiez que l'environnement affiche "Réseau local (192.168.1.7)"
4. Vérifiez que les tests API passent (✅ au lieu de ❌)

### **3. Testez un paiement**
1. Saisissez un montant (ex: 5000 FCFA)
2. Appuyez sur "Valider"
3. L'application devrait se connecter et traiter le paiement

## 🎯 **Résultat attendu**

Après la correction, vous devriez voir :
- ✅ **Diagnostic de connexion** : Tous les tests passent
- ✅ **Paiement** : Traitement réussi, données stockées
- ✅ **Messages** : Plus d'erreurs "Impossible de se connecter"

## 🚨 **Si le problème persiste**

### **Vérifiez que :**
1. Le serveur PHP fonctionne : `http://192.168.1.7:8000/api/test`
2. Votre appareil mobile est sur le même réseau Wi-Fi
3. L'IP `192.168.1.7` est correcte pour votre réseau

### **Alternative :**
Si le réseau local ne fonctionne pas, utilisez l'émulateur :
```dart
// Dans quick_config.dart
EnvironmentConfig.setEnvironment(Environment.emulator);
```

## 📊 **Endpoints disponibles**

- `GET /api/test` - Test de l'API principale
- `GET /api/payments/test` - Test de l'API des paiements  
- `POST /api/payments/initiate` - Initier un paiement

## 🔄 **Redémarrer le serveur si nécessaire**

```bash
cd backend
taskkill /f /im php.exe
php -S 0.0.0.0:8000 -t . simple_server.php
``` 