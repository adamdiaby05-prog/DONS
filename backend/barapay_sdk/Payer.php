<?php

class Payer {
    private $paymentMethod;
    
    public function setPaymentMethod($method) {
        $this->paymentMethod = $method;
        return $this;
    }
    
    public function getPaymentMethod() {
        return $this->paymentMethod;
    }
    
    public function toArray() {
        return [
            'payment_method' => $this->paymentMethod
        ];
    }
}
?>
