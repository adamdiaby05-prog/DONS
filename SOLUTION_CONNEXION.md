# 🔧 Solution au Problème de Connexion - DONS

## ❌ **Problème identifié :**
L'application Flutter ne peut pas se connecter au serveur PHP, affichant l'erreur "Impossible de se connecter au serveur".

## ✅ **Solutions appliquées :**

### 1. **Configuration de l'environnement Flutter corrigée**
- ✅ Modifié `frontend/lib/config/quick_config.dart` pour utiliser `Environment.local`
- ✅ L'application utilisera maintenant `localhost:8000` au lieu de l'IP réseau

### 2. **Serveurs de test créés**
- ✅ `backend/test_simple.php` - Serveur de test simple
- ✅ `backend/simple_test_server.php` - Serveur de test avancé
- ✅ `backend/test_server_final.php` - Serveur de test final
- ✅ Scripts de démarrage créés pour chaque serveur

### 3. **Scripts de démarrage disponibles**
- ✅ `backend/start_simple_test.bat` - Démarre le serveur simple
- ✅ `backend/start_final_server.bat` - Démarre le serveur final
- ✅ `backend/start_backend.bat` - Démarre le serveur Laravel complet

## 🚀 **Instructions de démarrage :**

### **Option 1 : Serveur de test simple (Recommandé)**
```bash
cd backend
start_simple_test.bat
```

### **Option 2 : Serveur Laravel complet**
```bash
cd backend
start_backend.bat
```

### **Option 3 : Démarrage manuel**
```bash
cd backend
php -S localhost:8000 test_server_final.php
```

## 🔍 **Vérification de la connexion :**

### **1. Tester le serveur :**
```bash
curl http://localhost:8000/api/test
```

### **2. Tester les paiements :**
```bash
curl http://localhost:8000/api/payments/test
```

### **3. Tester l'initiation de paiement :**
```bash
curl -X POST http://localhost:8000/api/payments/initiate \
  -H "Content-Type: application/json" \
  -d '{"amount": 1000, "phone_number": "0701234567", "network": "MTN"}'
```

## 📱 **Démarrage de l'application Flutter :**

### **1. Démarrer le serveur backend :**
```bash
cd backend
start_simple_test.bat
```

### **2. Démarrer l'application Flutter :**
```bash
cd frontend
flutter run -d web-server --web-port 3000
```

### **3. Accéder à l'application :**
- Ouvrir http://localhost:3000 dans votre navigateur
- Tester la page "Montant" pour vérifier la connexion

## 🛠️ **Dépannage avancé :**

### **Si le serveur ne démarre pas :**
1. Vérifier que PHP est installé : `php --version`
2. Vérifier que le port 8000 est libre : `netstat -an | findstr :8000`
3. Essayer un autre port : `php -S localhost:8001 test_server_final.php`

### **Si l'application Flutter ne se connecte toujours pas :**
1. Vérifier la configuration dans `frontend/lib/config/quick_config.dart`
2. Changer l'environnement si nécessaire :
   - `Environment.local` pour localhost
   - `Environment.localNetwork` pour l'IP réseau
   - `Environment.emulator` pour l'émulateur Android

### **Si vous utilisez un appareil mobile :**
1. Changer la configuration vers `Environment.localNetwork`
2. Utiliser l'IP de votre ordinateur (ex: 192.168.1.7:8000)
3. Démarrer le serveur avec : `php -S 0.0.0.0:8000 test_server_final.php`

## 📋 **Endpoints disponibles :**

| Endpoint | Méthode | Description |
|----------|---------|-------------|
| `/api/test` | GET | Test de l'API principale |
| `/api/payments/test` | GET | Test de l'API des paiements |
| `/api/payments/initiate` | POST | Initier un nouveau paiement |

## 🎯 **Résultat attendu :**

Après avoir suivi ces instructions, votre application Flutter devrait pouvoir :
- ✅ Se connecter au serveur backend
- ✅ Afficher la page "Montant" sans erreur
- ✅ Initier des paiements avec succès
- ✅ Recevoir des réponses JSON du serveur

## 📞 **Support :**

Si le problème persiste, vérifiez :
1. Que le serveur PHP fonctionne (test avec curl)
2. Que l'application Flutter utilise la bonne configuration
3. Que le pare-feu n'empêche pas la connexion
4. Que les ports 8000 et 3000 sont disponibles
