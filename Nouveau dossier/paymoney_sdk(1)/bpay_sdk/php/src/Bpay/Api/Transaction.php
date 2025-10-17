<?php

declare(strict_types=1);

namespace Bpay\Api;

class Transaction
{
    private ?Amount $amount = null;
    private ?string $orderNo = null;

    public function setAmount(Amount $amount): self
    {
        $this->amount = $amount;
        return $this;
    }

    public function getAmount(): ?Amount
    {
        return $this->amount;
    }

    public function setOrderNo(string $orderNo): self
    {
        $this->orderNo = $orderNo;
        return $this;
    }

    public function getOrderNo(): ?string
    {
        return $this->orderNo;
    }
} 