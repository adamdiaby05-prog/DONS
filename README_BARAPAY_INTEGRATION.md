# Intégration Barapay - Documentation Complète

## 📋 Vue d'ensemble

Ce projet implémente l'intégration complète de la passerelle de paiement Barapay selon la documentation officielle. L'intégration utilise le SDK Bpay fourni et inclut tous les composants nécessaires pour un système de paiement fonctionnel.

## 🔧 Configuration

### Credentials Barapay
```php
// Identifiants fournis
CLIENT_ID: wjb7lzQVialbcwMNTPD1IojrRzPIIl
CLIENT_SECRET: eXSMVquRfnUi6u5epkKFbxym1bZxSjgfHMxJlGGKq9j1amulx97Cj4QB7vZFzuyRUm4UC9mCHYhfzWn34arIyW4G2EU9vcdcQsb1
```

### Structure des fichiers
```
DONS/
├── bpay_sdk/                    # SDK officiel Barapay
│   └── php/
│       ├── vendor/
│       ├── src/Bpay/
│       └── examples/
├── barapay_payment_integration.php  # Fichier principal d'intégration
├── payment_success.php              # Page de succès
├── payment_cancel.php               # Page d'annulation
├── payment_callback.php             # Traitement des callbacks
├── test_barapay_integration.php     # Script de test
└── README_BARAPAY_INTEGRATION.md    # Cette documentation
```

## 🚀 Utilisation

### 1. Création d'un paiement

```php
require_once 'barapay_payment_integration.php';

try {
    $paymentUrl = createBarapayPayment(
        $amount = 10000,           // Montant en centimes
        $currency = 'XOF',         // Devise
        $orderNo = 'CMD123456',    // Numéro de commande unique
        $paymentMethod = 'Bpay'    // Méthode de paiement
    );
    
    // Rediriger vers l'URL de paiement
    header("Location: " . $paymentUrl);
    exit;
    
} catch (BpayException $e) {
    echo "Erreur: " . $e->getMessage();
}
```

### 2. Configuration des URLs de redirection

```php
// Dans barapay_payment_integration.php
$baseUrl = 'https://votre-domaine.com'; // À adapter
$successUrl = $baseUrl . '/payment_success.php';
$cancelUrl = $baseUrl . '/payment_cancel.php';
```

### 3. Traitement des callbacks

Le fichier `payment_callback.php` traite automatiquement les notifications de Barapay :

- ✅ Paiement réussi
- ❌ Paiement échoué  
- ⏳ Paiement en attente

## 📁 Fichiers détaillés

### `barapay_payment_integration.php`
Fichier principal contenant :
- Configuration des credentials
- Fonction `createBarapayPayment()`
- Fonction `handlePaymentCallback()`
- Gestion des erreurs

### `payment_success.php`
Page affichée après un paiement réussi :
- Affichage des détails du paiement
- Numéro de transaction
- Montant payé
- Boutons de navigation

### `payment_cancel.php`
Page affichée en cas d'annulation :
- Explication de l'annulation
- Options pour réessayer
- Contact support

### `payment_callback.php`
Traitement des notifications Barapay :
- Vérification de la signature
- Mise à jour de la base de données
- Envoi d'emails de confirmation
- Logging des transactions

### `test_barapay_integration.php`
Script de test complet :
- Vérification des credentials
- Test de création de paiement
- Simulation de callbacks
- Vérification des fichiers requis

## 🔐 Sécurité

### Vérification de signature
```php
if (isset($headers['X-Bpay-Signature'])) {
    $signature = $headers['X-Bpay-Signature'];
    $expectedSignature = hash_hmac('sha256', $rawData, BARAPAY_CLIENT_SECRET);
    
    if ($signature !== $expectedSignature) {
        throw new BpayException('Signature invalide');
    }
}
```

### Logging sécurisé
- Tous les callbacks sont loggés
- Les erreurs sont enregistrées
- Pas d'affichage d'erreurs en production

## 🧪 Tests

### Lancer les tests
```bash
# Accéder au script de test
http://localhost/test_barapay_integration.php
```

### Tests inclus
1. ✅ Vérification des credentials
2. ✅ Création de paiement
3. ✅ Vérification des fichiers
4. ✅ URLs de redirection
5. ✅ Simulation de callback

## 📊 Monitoring

### Logs disponibles
- `logs/barapay_callbacks.log` - Callbacks reçus
- `logs/bpay_api.log` - Requêtes API
- Logs PHP standard

### Métriques importantes
- Taux de succès des paiements
- Temps de réponse API
- Erreurs de signature
- Échecs de callback

## 🚀 Déploiement

### 1. Configuration du serveur
```bash
# Installer Composer si nécessaire
composer install

# Configurer les permissions
chmod 755 logs/
chmod 644 *.php
```

### 2. Configuration Barapay
1. Se connecter à votre compte Barapay
2. Aller dans les paramètres
3. Configurer les URLs :
   - Success URL: `https://votre-domaine.com/payment_success.php`
   - Cancel URL: `https://votre-domaine.com/payment_cancel.php`
   - Callback URL: `https://votre-domaine.com/payment_callback.php`

### 3. Base de données
Implémenter les fonctions dans `payment_callback.php` :
```php
function updateOrderStatus($orderNo, $status, $transactionId = null, $reason = null) {
    // Votre logique de mise à jour BDD
}

function sendConfirmationEmail($orderNo, $transactionId, $amount, $currency) {
    // Votre logique d'envoi d'email
}
```

## 🔧 Personnalisation

### Méthodes de paiement supportées
- `Bpay` - Barapay (recommandé)
- `Orange` - Orange Money
- `MTN` - MTN Mobile Money
- `Wave` - Wave Money

### Devises supportées
- `XOF` - Franc CFA (recommandé)
- `USD` - Dollar américain
- `EUR` - Euro

### Personnalisation des pages
- Modifier `payment_success.php` pour votre design
- Adapter `payment_cancel.php` selon vos besoins
- Personnaliser les emails de confirmation

## 🆘 Dépannage

### Erreurs courantes

#### "Credentials manquants"
- Vérifier que les constantes sont définies
- S'assurer que les credentials sont corrects

#### "Signature invalide"
- Vérifier le CLIENT_SECRET
- S'assurer que les headers sont corrects

#### "URL de paiement manquante"
- Vérifier la configuration API
- Contacter le support Barapay

### Support
- 📧 Email: support@barapay.net
- 📚 Documentation: [barapay.net/docs](https://barapay.net/docs)
- 🐛 Issues: Créer un ticket sur le support

## 📈 Évolutions futures

### Fonctionnalités prévues
- [ ] Support multi-devises
- [ ] Interface d'administration
- [ ] Rapports de transactions
- [ ] API REST pour intégration
- [ ] Webhooks avancés

### Améliorations techniques
- [ ] Cache des tokens d'accès
- [ ] Retry automatique
- [ ] Monitoring avancé
- [ ] Tests automatisés

---

**Version:** 1.0.0  
**Dernière mise à jour:** <?php echo date('Y-m-d'); ?>  
**Auteur:** Équipe DONS  
**Licence:** MIT
