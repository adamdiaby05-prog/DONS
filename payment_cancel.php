<?php

/**
 * Page d'annulation de paiement Barapay
 * Cette page est appelée quand l'utilisateur annule le paiement
 */

// Désactiver l'affichage des erreurs en production
ini_set('display_errors', 0);
error_reporting(E_ALL);

?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Paiement Annulé - Barapay</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 600px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .cancel-container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            text-align: center;
        }
        .cancel-icon {
            font-size: 48px;
            color: #dc3545;
            margin-bottom: 20px;
        }
        .cancel-title {
            color: #dc3545;
            font-size: 24px;
            margin-bottom: 20px;
        }
        .info-box {
            background: #fff3cd;
            border: 1px solid #ffeaa7;
            padding: 20px;
            border-radius: 5px;
            margin: 20px 0;
            text-align: left;
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
        .btn-danger {
            background: #dc3545;
        }
        .btn-danger:hover {
            background: #c82333;
        }
        .steps {
            text-align: left;
            margin: 20px 0;
        }
        .steps ol {
            padding-left: 20px;
        }
        .steps li {
            margin-bottom: 10px;
            line-height: 1.5;
        }
    </style>
</head>
<body>
    <div class="cancel-container">
        <div class="cancel-icon">❌</div>
        <h1 class="cancel-title">Paiement Annulé</h1>
        <p>Vous avez annulé le processus de paiement. Aucun montant n'a été débité de votre compte.</p>
        
        <div class="info-box">
            <h3>ℹ️ Que s'est-il passé ?</h3>
            <p>Le paiement a été annulé avant d'être finalisé. Cela peut arriver si :</p>
            <ul>
                <li>Vous avez fermé la fenêtre de paiement</li>
                <li>Vous avez cliqué sur "Annuler" ou "Retour"</li>
                <li>La session a expiré</li>
                <li>Il y a eu un problème technique</li>
            </ul>
        </div>
        
        <?php
        // Récupérer les paramètres de l'URL
        $orderNo = $_GET['orderNo'] ?? null;
        $reason = $_GET['reason'] ?? null;
        
        if ($orderNo) {
            echo '<div class="info-box">';
            echo '<h3>Détails de la commande</h3>';
            echo '<p><strong>Numéro de commande:</strong> ' . htmlspecialchars($orderNo) . '</p>';
            echo '<p><strong>Date:</strong> ' . date('d/m/Y H:i:s') . '</p>';
            if ($reason) {
                echo '<p><strong>Raison:</strong> ' . htmlspecialchars($reason) . '</p>';
            }
            echo '</div>';
        }
        ?>
        
        <div class="steps">
            <h3>🔄 Que faire maintenant ?</h3>
            <ol>
                <li><strong>Vérifiez votre commande</strong> - Assurez-vous que tous les détails sont corrects</li>
                <li><strong>Réessayez le paiement</strong> - Cliquez sur "Réessayer le paiement" ci-dessous</li>
                <li><strong>Choisissez une autre méthode</strong> - Essayez une autre méthode de paiement si disponible</li>
                <li><strong>Contactez le support</strong> - Si le problème persiste, contactez notre équipe</li>
            </ol>
        </div>
        
        <div style="margin-top: 30px;">
            <a href="javascript:history.back()" class="btn btn-danger">Réessayer le paiement</a>
            <a href="/" class="btn">Retour à l'accueil</a>
            <a href="/contact" class="btn btn-secondary">Contacter le support</a>
        </div>
        
        <div style="margin-top: 30px; font-size: 14px; color: #666;">
            <p><strong>Besoin d'aide ?</strong></p>
            <p>Si vous rencontrez des difficultés, notre équipe support est là pour vous aider.</p>
            <p>📧 Email: support@votresite.com | 📞 Téléphone: +225 XX XX XX XX</p>
        </div>
    </div>
    
    <script>
        // Log de l'annulation pour analytics
        console.log('Paiement annulé:', {
            orderNo: '<?php echo $orderNo; ?>',
            reason: '<?php echo $reason; ?>',
            timestamp: new Date().toISOString()
        });
        
        // Optionnel: Envoyer des données à votre système d'analytics
        // gtag('event', 'payment_cancelled', {
        //     order_no: '<?php echo $orderNo; ?>',
        //     reason: '<?php echo $reason; ?>'
        // });
    </script>
</body>
</html>
