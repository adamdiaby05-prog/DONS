<?php

declare(strict_types=1);

namespace Bpay\Api;

class Amount
{
    private float $total = 0.0;
    private string $currency = 'XOF';

    public function setTotal(float $amount): self
    {
        $this->total = $amount;
        return $this;
    }

    public function getTotal(): float
    {
        return $this->total;
    }

    public function setCurrency(string $currency): self
    {
        $this->currency = $currency;
        return $this;
    }

    public function getCurrency(): string
    {
        return $this->currency;
    }
} 