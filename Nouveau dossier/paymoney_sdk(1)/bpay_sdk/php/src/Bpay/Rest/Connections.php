<?php

declare(strict_types=1);

namespace Bpay\Rest;

use Bpay\Exception\BpayException;

readonly class Connections
{
    private string $baseUrl;
    private string $logFile;
    private bool $debug;

    public function __construct(string $baseUrl = '', bool $debug = false)
    {
        // S'assurer que l'URL se termine par un slash
        $this->baseUrl = rtrim($baseUrl ?: 'https://barapay.net', '/') . '/';
        $this->logFile = dirname(__DIR__, 4) . '/logs/bpay_api.log';
        $this->debug = $debug;
        
        // Créer le dossier logs s'il n'existe pas
        $logDir = dirname($this->logFile);
        if (!is_dir($logDir)) {
            mkdir($logDir, 0777, true);
        }
    }

    private function log(string $message): void
    {
        $timestamp = date('Y-m-d H:i:s');
        $formattedMessage = "[$timestamp] $message" . PHP_EOL;
        file_put_contents($this->logFile, $formattedMessage, FILE_APPEND);
        
        // N'afficher les logs que si le mode debug est activé
        if ($this->debug) {
            echo $formattedMessage;
        }
    }

    private function buildUrl(string $path): string
    {
        // Nettoyer le chemin et s'assurer qu'il n'y a pas de double slash
        $path = ltrim($path, '/');
        return $this->baseUrl . $path;
    }

    /**
     * @throws BpayException
     */
    public function execute(string $path, string $method, array $payload = [], ?array $headers = null): object
    {
        $url = $this->buildUrl($path);
        
        $this->log("=== DÉBUT DE LA REQUÊTE API ===");
        $this->log("URL: $url");
        $this->log("Méthode: $method");
        
        if (!empty($payload)) {
            $this->log("Payload: " . json_encode($payload, JSON_PRETTY_PRINT));
        }
        if (!empty($headers)) {
            $this->log("Headers: " . json_encode($headers, JSON_PRETTY_PRINT));
        }

        $ch = curl_init();
        
        // Configuration du debug CURL
        $curlDebug = fopen('php://temp', 'w+');
        curl_setopt($ch, CURLOPT_VERBOSE, true);
        curl_setopt($ch, CURLOPT_STDERR, $curlDebug);

        $options = [
            CURLOPT_URL => $url,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_FOLLOWLOCATION => true,
            CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
            CURLOPT_CUSTOMREQUEST => strtoupper($method),
            CURLOPT_SSL_VERIFYPEER => false,
            CURLOPT_SSL_VERIFYHOST => false,
            CURLOPT_TIMEOUT => 30
        ];

        if ($method === 'POST') {
            $options[CURLOPT_POST] = true;
            if (!empty($payload)) {
                $jsonPayload = json_encode($payload, JSON_THROW_ON_ERROR);
                $options[CURLOPT_POSTFIELDS] = $jsonPayload;
                
                if ($headers === null) {
                    $headers = ['Content-Type: application/json'];
                } elseif (!$this->hasContentTypeHeader($headers)) {
                    $headers[] = 'Content-Type: application/json';
                }
            }
        }

        if ($headers !== null) {
            $options[CURLOPT_HTTPHEADER] = $headers;
        }

        curl_setopt_array($ch, $options);

        $this->log("Options CURL: " . json_encode($options, JSON_PRETTY_PRINT));

        $response = curl_exec($ch);
        $error = curl_error($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $info = curl_getinfo($ch);
        
        // Log des informations CURL
        rewind($curlDebug);
        $verboseLog = stream_get_contents($curlDebug);
        $this->log("Debug CURL: " . $verboseLog);
        fclose($curlDebug);
        
        $this->log("Info CURL: " . json_encode($info, JSON_PRETTY_PRINT));
        $this->log("Code HTTP: $httpCode");
        $this->log("Réponse brute: " . $response);
        
        curl_close($ch);

        if ($error) {
            $this->log("ERREUR CURL: $error");
            throw new BpayException("Erreur CURL: $error");
        }

        if ($response === false) {
            $this->log("ERREUR: Réponse invalide de l'API");
            throw new BpayException('Réponse invalide de l\'API');
        }

        if ($httpCode >= 400) {
            $errorInfo = [
                'http_code' => $httpCode,
                'response' => $response,
                'curl_info' => curl_getinfo($ch)
            ];
            
            $this->log("ERREUR: Code HTTP $httpCode");
            $this->log("Détails de l'erreur: " . json_encode($errorInfo, JSON_PRETTY_PRINT));
            
            // Essayer de décoder la réponse JSON même en cas d'erreur
            try {
                $jsonResponse = json_decode($response, false, 512, JSON_THROW_ON_ERROR);
                $errorMessage = isset($jsonResponse->message) ? $jsonResponse->message : 'Erreur inconnue';
                throw new BpayException("Erreur API ($httpCode): $errorMessage", $httpCode);
            } catch (\JsonException $e) {
                // Si ce n'est pas du JSON, renvoyer la réponse brute
                throw new BpayException("Erreur HTTP $httpCode. Réponse: " . $response, $httpCode);
            }
        }

        try {
            $jsonResponse = json_decode($response, false, 512, JSON_THROW_ON_ERROR);
            $this->log("Réponse décodée: " . json_encode($jsonResponse, JSON_PRETTY_PRINT));
            $this->log("=== FIN DE LA REQUÊTE API ===\n");
            return $jsonResponse;
        } catch (\JsonException $e) {
            $this->log("ERREUR: Décodage JSON échoué - " . $e->getMessage());
            throw new BpayException('Erreur de décodage JSON: ' . $e->getMessage() . '. Réponse brute: ' . $response);
        }
    }

    private function hasContentTypeHeader(array $headers): bool
    {
        foreach ($headers as $header) {
            if (str_starts_with(strtolower($header), 'content-type:')) {
                return true;
            }
        }
        return false;
    }

    public function getBaseUrl(): string
    {
        return $this->baseUrl;
    }
} 