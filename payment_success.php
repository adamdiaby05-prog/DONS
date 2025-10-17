<?php

/**
 * Page de succès de paiement Barapay
 * Cette page est appelée après un paiement réussi
 */

require_once 'barapay_payment_integration.php';

// Désactiver l'affichage des erreurs en production
ini_set('display_errors', 0);
error_reporting(E_ALL);

?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Paiement Réussi - Barapay</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 600px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .success-container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            text-align: center;
        }
        .success-icon {
            font-size: 48px;
            color: #28a745;
            margin-bottom: 20px;
        }
        .success-title {
            color: #28a745;
            font-size: 24px;
            margin-bottom: 20px;
        }
        .payment-details {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 5px;
            margin: 20px 0;
            text-align: left;
        }
        .detail-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
            padding: 5px 0;
            border-bottom: 1px solid #eee;
        }
        .detail-label {
            font-weight: bold;
            color: #333;
        }
        .detail-value {
            color: #666;
        }
        .btn {
            display: inline-block;
            padding: 12px 24px;
            background: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            margin: 10px;
            transition: background 0.3s;
        }
        .btn:hover {
            background: #0056b3;
        }
        .btn-secondary {
            background: #6c757d;
        }
        .btn-secondary:hover {
            background: #545b62;
        }
    </style>
</head>
<body>
    <div class="success-container">
        <div class="success-icon">✅</div>
        <h1 class="success-title">Paiement Réussi !</h1>
        <p>Votre paiement a été traité avec succès. Merci pour votre confiance !</p>
        
        <?php
        // Récupérer les paramètres de l'URL
        $orderNo = $_GET['orderNo'] ?? null;
        $transactionId = $_GET['transactionId'] ?? null;
        $amount = $_GET['amount'] ?? null;
        $currency = $_GET['currency'] ?? null;
        
        if ($orderNo || $transactionId || $amount) {
            echo '<div class="payment-details">';
            echo '<h3>Détails du Paiement</h3>';
            
            if ($orderNo) {
                echo '<div class="detail-row">';
                echo '<span class="detail-label">Numéro de commande:</span>';
                echo '<span class="detail-value">' . htmlspecialchars($orderNo) . '</span>';
                echo '</div>';
            }
            
            if ($transactionId) {
                echo '<div class="detail-row">';
                echo '<span class="detail-label">ID de transaction:</span>';
                echo '<span class="detail-value">' . htmlspecialchars($transactionId) . '</span>';
                echo '</div>';
            }
            
            if ($amount && $currency) {
                echo '<div class="detail-row">';
                echo '<span class="detail-label">Montant:</span>';
                echo '<span class="detail-value">' . number_format($amount, 0, ',', ' ') . ' ' . htmlspecialchars($currency) . '</span>';
                echo '</div>';
            }
            
            echo '<div class="detail-row">';
            echo '<span class="detail-label">Date:</span>';
            echo '<span class="detail-value">' . date('d/m/Y H:i:s') . '</span>';
            echo '</div>';
            
            echo '</div>';
        }
        ?>
        
        <div style="margin-top: 30px;">
            <a href="/" class="btn">Retour à l'accueil</a>
            <a href="/dashboard" class="btn btn-secondary">Tableau de bord</a>
        </div>
        
        <div style="margin-top: 30px; font-size: 14px; color: #666;">
            <p>Vous recevrez un email de confirmation sous peu.</p>
            <p>Si vous avez des questions, contactez notre support client.</p>
        </div>
    </div>
    
    <script>
        // Log du succès pour analytics
        console.log('Paiement réussi:', {
            orderNo: '<?php echo $orderNo; ?>',
            transactionId: '<?php echo $transactionId; ?>',
            amount: '<?php echo $amount; ?>',
            currency: '<?php echo $currency; ?>',
            timestamp: new Date().toISOString()
        });
        
        // Optionnel: Envoyer des données à votre système d'analytics
        // gtag('event', 'purchase', {
        //     transaction_id: '<?php echo $transactionId; ?>',
        //     value: <?php echo $amount ? $amount / 100 : 0; ?>,
        //     currency: '<?php echo $currency; ?>'
        // });
    </script>
</body>
</html>
