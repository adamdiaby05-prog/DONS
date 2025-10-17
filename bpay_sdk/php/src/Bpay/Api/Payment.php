<?php

declare(strict_types=1);

namespace Bpay\Api;

use Bpay\Common\BpayModel;
use Bpay\Exception\BpayException;

class Payment extends BpayModel
{
    private ?Payer $payer = null;
    private ?Transaction $transaction = null;
    private ?RedirectUrls $redirectUrls = null;
    private ?array $credentials = null;
    private ?string $approvedUrl = null;

    public function setPayer(Payer $payer): self
    {
        $this->payer = $payer;
        return $this;
    }

    public function getPayer(): ?Payer
    {
        return $this->payer;
    }

    public function setTransaction(Transaction $transaction): self
    {
        $this->transaction = $transaction;
        return $this;
    }

    public function getTransaction(): ?Transaction
    {
        return $this->transaction;
    }

    public function setRedirectUrls(RedirectUrls $redirectUrls): self
    {
        $this->redirectUrls = $redirectUrls;
        return $this;
    }

    public function getRedirectUrls(): ?RedirectUrls
    {
        return $this->redirectUrls;
    }

    public function setCredentials(array $credentials): self
    {
        $this->credentials = $credentials;
        return $this;
    }

    public function getCredentials(): ?array
    {
        return $this->credentials;
    }

    public function setApprovedUrl(string $url): self
    {
        $this->approvedUrl = $url;
        return $this;
    }

    public function getApprovedUrl(): ?string
    {
        return $this->approvedUrl;
    }

    /**
     * @throws BpayException
     */
    public function create(): void
    {
        $accessToken = $this->getAccessToken();
        $approveUrl = $this->sendTransactionInfo($accessToken);
        $this->setApprovedUrl($approveUrl);
    }

    /**
     * @throws BpayException
     */
    private function getAccessToken(): string
    {
        $credentials = $this->getCredentials();
        if (!$credentials || !isset($credentials['client_id'], $credentials['client_secret'])) {
            throw new BpayException('Les paramètres client_id et client_secret sont requis.');
        }

        $payload = [
            'client_id' => $credentials['client_id'],
            'client_secret' => $credentials['client_secret']
        ];

        $headers = [
            'Content-Type: application/json',
            'Accept: application/json',
            'User-Agent: BpaySDK/1.0 PHP/' . PHP_VERSION,
            'X-Requested-With: XMLHttpRequest'
        ];

        $response = $this->execute('merchant/api/verify', 'POST', $payload, $headers);

        if (!isset($response->status) || $response->status !== 'success' || !isset($response->data->access_token)) {
            $message = isset($response->message) ? $response->message : 'Erreur d\'authentification inconnue';
            throw new BpayException('Erreur d\'authentification: ' . $message);
        }

        return $response->data->access_token;
    }

    /**
     * @throws BpayException
     */
    private function sendTransactionInfo(string $token): string
    {
        if (!$this->transaction || !$this->payer || !$this->redirectUrls) {
            throw new BpayException('Transaction, Payer et RedirectUrls sont requis.');
        }

        $transactionAmount = $this->transaction->getAmount();
        if (!$transactionAmount) {
            throw new BpayException('Le montant de la transaction est requis.');
        }

        $amount = $transactionAmount->getTotal();
        $currency = $transactionAmount->getCurrency();
        $successUrl = $this->redirectUrls->getSuccessUrl();
        $cancelUrl = $this->redirectUrls->getCancelUrl();
        $paymentMethod = $this->payer->getPaymentMethod();
        $orderNo = $this->transaction->getOrderNo();

        $payload = [
            'payer' => $paymentMethod,
            'amount' => $amount,
            'currency' => $currency,
            'successUrl' => $successUrl,
            'cancelUrl' => $cancelUrl,
            'orderNo' => $orderNo
        ];

        $headers = [
            'Content-Type: application/json',
            'Accept: application/json',
            'User-Agent: BpaySDK/1.0 PHP/' . PHP_VERSION,
            'X-Requested-With: XMLHttpRequest',
            'Authorization: Bearer ' . $token
        ];

        $response = $this->execute('merchant/api/transaction-info', 'POST', $payload, $headers);

        if (!isset($response->status) || $response->status !== 'success') {
            $message = isset($response->message) ? $response->message : 'Erreur inconnue lors de la création du paiement';
            throw new BpayException('Erreur de création de paiement: ' . $message);
        }

        if (!isset($response->data->approvedUrl)) {
            throw new BpayException('L\'URL de paiement est manquante dans la réponse');
        }

        return $response->data->approvedUrl;
    }
} 