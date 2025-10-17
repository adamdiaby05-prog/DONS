<?php

declare(strict_types=1);

namespace Bpay\Common;

use Bpay\Rest\Connections;

abstract class BpayModel
{
    /** @var array<string, string> */
    protected array $props = [];
    
    protected readonly Connections $connection;

    public function __construct(?string $baseUrl = null)
    {
        $this->connection = new Connections($baseUrl ?? '');
        
        $class = new \ReflectionClass($this);
        foreach ($class->getMethods() as $method) {
            if (!array_key_exists($method->name, $this->props)) {
                $this->props[$method->name] = $method->name;
            }
        }
    }
    
    protected function execute(string $url, string $method, array $payload = [], ?array $headers = null): object
    {
        return $this->connection->execute($url, $method, $payload, $headers);
    }
    
    protected function getBaseUrl(): string
    {
        return $this->connection->getBaseUrl();
    }
} 