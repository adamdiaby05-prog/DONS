<?php
// Page d'annulation pour les paiements Barapay
header('Content-Type: text/html; charset=UTF-8');
?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Paiement Annulé - DONS</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #ff6b6b 0%, #ee5a24 100%);
            margin: 0;
            padding: 20px;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .container {
            background: white;
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            max-width: 500px;
            width: 100%;
            text-align: center;
        }
        .cancel-icon {
            width: 80px;
            height: 80px;
            background: #ff6b6b;
            border-radius: 50%;
            margin: 0 auto 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 40px;
        }
        h1 {
            color: #333;
            margin-bottom: 10px;
        }
        .subtitle {
            color: #666;
            margin-bottom: 30px;
        }
        .payment-details {
            background: #f8f9fa;
            border-radius: 15px;
            padding: 20px;
            margin: 20px 0;
        }
        .detail-row {
            display: flex;
            justify-content: space-between;
            margin: 10px 0;
            padding: 5px 0;
        }
        .btn {
            background: #ff6b6b;
            color: white;
            border: none;
            padding: 15px 30px;
            border-radius: 10px;
            font-size: 16px;
            cursor: pointer;
            margin: 10px;
            text-decoration: none;
            display: inline-block;
        }
        .btn:hover {
            background: #ee5a24;
        }
        .btn-secondary {
            background: #6c757d;
        }
        .btn-secondary:hover {
            background: #5a6268;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="cancel-icon">✗</div>
        <h1>Paiement Annulé</h1>
        <p class="subtitle">Le paiement a été annulé</p>
        
        <div class="payment-details">
            <div class="detail-row">
                <span>Montant:</span>
                <span><?php echo htmlspecialchars($_GET['amount'] ?? 'N/A'); ?> FCFA</span>
            </div>
            <div class="detail-row">
                <span>Téléphone:</span>
                <span><?php echo htmlspecialchars($_GET['phone'] ?? 'N/A'); ?></span>
            </div>
            <div class="detail-row">
                <span>Référence:</span>
                <span><?php echo htmlspecialchars($_GET['ref'] ?? 'N/A'); ?></span>
            </div>
            <div class="detail-row">
                <span>Date:</span>
                <span><?php echo date('d/m/Y H:i'); ?></span>
            </div>
        </div>
        
        <p style="color: #ff6b6b; font-weight: bold; margin: 20px 0;">
            ❌ Aucun montant n'a été débité de votre compte
        </p>
        
        <a href="http://localhost:3000" class="btn">
            Réessayer le paiement
        </a>
        
        <a href="http://localhost:8000" class="btn btn-secondary">
            Page d'accueil API
        </a>
    </div>
    
    <script>
        // Redirection automatique vers l'app Flutter après 5 secondes
        setTimeout(() => {
            window.location.href = 'http://localhost:3000';
        }, 5000);
    </script>
</body>
</html>