<?php

declare(strict_types=1);

namespace Bpay\Api;

class Payer
{
    private string $paymentMethod = 'Bpay';

    public function setPaymentMethod(string $method): self
    {
        $this->paymentMethod = $method;
        return $this;
    }

    public function getPaymentMethod(): string
    {
        return $this->paymentMethod;
    }
} 