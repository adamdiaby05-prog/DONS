# Exemples d'utilisation du SDK Bpay

Ce dossier contient des exemples d'utilisation du SDK Bpay.

## Création d'un paiement (`create_payment.php`)

Exemple complet de création d'un paiement avec :
- Configuration du montant et de la devise
- Définition du numéro de commande
- Choix de la méthode de paiement
- Configuration des URLs de redirection
- Gestion des erreurs

```php
require_once 'vendor/autoload.php';
$payment = new Payment();
$payment->setCredentials([...])
        ->setPayer($payer)
        ->setTransaction($transaction)
        ->setRedirectUrls($redirectUrls)
        ->create();
```

## Traitement du callback (`payment_callback.php`)

Exemple de traitement de la réponse de paiement avec :
- Vérification de la signature
- Logging des données reçues
- Traitement selon le statut (success, failed, pending)
- Gestion des erreurs
- Réponses appropriées

### Format de la réponse attendue

```json
{
    "status": "success",
    "orderNo": "CMD123456789",
    "transactionId": "BPAY123456789",
    "amount": 10000,
    "currency": "XOF"
}
```

### Headers de sécurité
- `X-Bpay-Signature` : Signature HMAC SHA256 des données

## Sécurité

- Toujours vérifier la signature du callback
- Logger toutes les erreurs
- Ne pas afficher les erreurs en production
- Répondre 200 même en cas d'échec pour acquitter la réception 