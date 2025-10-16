<?php

class RedirectUrls {
    private $successUrl;
    private $cancelUrl;
    
    public function setSuccessUrl($url) {
        $this->successUrl = $url;
        return $this;
    }
    
    public function setCancelUrl($url) {
        $this->cancelUrl = $url;
        return $this;
    }
    
    public function getSuccessUrl() {
        return $this->successUrl;
    }
    
    public function getCancelUrl() {
        return $this->cancelUrl;
    }
    
    public function toArray() {
        return [
            'success_url' => $this->successUrl,
            'cancel_url' => $this->cancelUrl
        ];
    }
}
?>
