<?php

class Amount {
    private $total;
    private $currency;
    
    public function setTotal($amount) {
        $this->total = $amount;
        return $this;
    }
    
    public function setCurrency($currency) {
        $this->currency = $currency;
        return $this;
    }
    
    public function getTotal() {
        return $this->total;
    }
    
    public function getCurrency() {
        return $this->currency;
    }
    
    public function toArray() {
        return [
            'total' => $this->total,
            'currency' => $this->currency
        ];
    }
}
?>

