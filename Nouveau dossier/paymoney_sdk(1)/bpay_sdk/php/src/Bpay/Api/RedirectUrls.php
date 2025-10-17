<?php

declare(strict_types=1);

namespace Bpay\Api;

class RedirectUrls
{
    private string $successUrl = '';
    private string $cancelUrl = '';

    public function setSuccessUrl(string $url): self
    {
        $this->successUrl = $url;
        return $this;
    }

    public function getSuccessUrl(): string
    {
        return $this->successUrl;
    }

    public function setCancelUrl(string $url): self
    {
        $this->cancelUrl = $url;
        return $this;
    }

    public function getCancelUrl(): string
    {
        return $this->cancelUrl;
    }
} 