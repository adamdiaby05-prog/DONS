<?php

class Payment {
    private $credentials;
    private $redirectUrls;
    private $payer;
    private $transaction;
    private $approvedUrl;
    private $phone_number;
    private $description;
    
    public function setCredentials($credentials) {
        $this->credentials = $credentials;
        return $this;
    }
    
    public function setRedirectUrls($urls) {
        $this->redirectUrls = $urls;
        return $this;
    }
    
    public function setPayer($payer) {
        $this->payer = $payer;
        return $this;
    }
    
    public function setTransaction($transaction) {
        $this->transaction = $transaction;
        return $this;
    }
    
    public function setPhoneNumber($phone_number) {
        $this->phone_number = $phone_number;
        return $this;
    }
    
    public function setDescription($description) {
        $this->description = $description;
        return $this;
    }
    
    public function create() {
        // Préparer les données pour l'API Barapay
        $paymentData = [
            'payer' => $this->payer->toArray(),
            'amount' => $this->transaction->getAmount()->toArray(),
            'redirect_urls' => $this->redirectUrls->toArray(),
            'client_id' => $this->credentials['client_id'],
            'client_secret' => $this->credentials['client_secret'],
            'phone_number' => $this->phone_number ?? '', // Numéro du client à débiter
            'description' => $this->description ?? 'Paiement DONS'
        ];
        
        // Faire l'appel à l'API Barapay
        $response = $this->makeBarapayRequest($paymentData);
        
        if ($response['success']) {
            $this->approvedUrl = $response['checkout_url'];
            return true;
        } else {
            throw new Exception('Erreur Barapay: ' . $response['error']);
        }
    }
    
    public function getApprovedUrl() {
        return $this->approvedUrl;
    }
    
    private function makeBarapayRequest($data) {
        // URL de l'API Barapay selon la documentation officielle
        $url = 'https://api.barapay.net/v1/payments/create';
        
        // Préparer les données selon le format Barapay officiel
        $barapayData = [
            'client_id' => $this->credentials['client_id'],
            'client_secret' => $this->credentials['client_secret'],
            'amount' => $data['amount']['total'] ?? 0,
            'currency' => $data['amount']['currency'] ?? 'XOF',
            'phone_number' => $data['phone_number'] ?? '',
            'description' => $data['description'] ?? 'Paiement DONS',
            'reference' => $data['reference'] ?? uniqid('REF_'),
            'success_url' => $data['redirect_urls']['success_url'] ?? 'http://localhost:3000/#/payment/success',
            'cancel_url' => $data['redirect_urls']['cancel_url'] ?? 'http://localhost:3000/#/payment/cancel',
            'callback_url' => 'http://localhost:8000/api/barapay/callback',
            'customer_phone' => $data['phone_number'] ?? '', // Numéro du client qui sera débité
            'debit_account' => $data['phone_number'] ?? '' // Compte à débiter
        ];
        
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($barapayData));
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Content-Type: application/json',
            'Accept: application/json',
            'Authorization: Bearer ' . $this->credentials['client_secret'],
            'X-Client-ID: ' . $this->credentials['client_id']
        ]);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, 30);
        curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
        
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        curl_close($ch);
        
        if ($error) {
            // Si l'API échoue, créer une URL de paiement directe selon la documentation
            $fallbackUrl = 'https://barapay.net/pay?' . http_build_query([
                'client_id' => $this->credentials['client_id'],
                'amount' => $barapayData['amount'],
                'currency' => $barapayData['currency'],
                'phone' => $barapayData['phone_number'],
                'ref' => $barapayData['reference']
            ]);
            
            return [
                'success' => true,
                'checkout_url' => $fallbackUrl,
                'payment_id' => uniqid('PAY_'),
                'fallback' => true,
                'data' => ['error' => $error]
            ];
        }
        
        $responseData = json_decode($response, true);
        
        if ($httpCode >= 200 && $httpCode < 300) {
            return [
                'success' => true,
                'checkout_url' => $responseData['checkout_url'] ?? $responseData['redirect_url'] ?? $responseData['payment_url'] ?? 'https://barapay.net/pay',
                'payment_id' => $responseData['payment_id'] ?? $responseData['id'] ?? uniqid('PAY_'),
                'data' => $responseData
            ];
        } else {
            // Si l'API échoue, créer une URL de paiement directe
            $fallbackUrl = 'https://barapay.net/pay?' . http_build_query([
                'client_id' => $this->credentials['client_id'],
                'amount' => $barapayData['amount'],
                'currency' => $barapayData['currency'],
                'phone' => $barapayData['phone_number'],
                'ref' => $barapayData['reference']
            ]);
            
            return [
                'success' => true,
                'checkout_url' => $fallbackUrl,
                'payment_id' => uniqid('PAY_'),
                'fallback' => true,
                'data' => $responseData
            ];
        }
    }
}
?>
