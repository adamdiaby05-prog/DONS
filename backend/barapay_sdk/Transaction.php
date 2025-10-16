<?php

class Transaction {
    private $amount;
    
    public function setAmount($amount) {
        $this->amount = $amount;
        return $this;
    }
    
    public function getAmount() {
        return $this->amount;
    }
    
    public function toArray() {
        return [
            'amount' => $this->amount->toArray()
        ];
    }
}
?>
