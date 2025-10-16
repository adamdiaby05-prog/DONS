<?php

namespace App\Http\Controllers;

use App\Models\Payment;
use App\Models\Contribution;
use App\Models\Notification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;

class PaymentController extends Controller
{
    public function initiatePayment(Request $request)
    {
        try {
            // Valider les données reçues
            $request->validate([
                'network_id' => 'required|string',
                'phone_number' => 'required|string',
                'amount' => 'required|numeric|min:1',
                'currency' => 'required|string',
                'description' => 'required|string',
            ]);

            // Créer une nouvelle contribution
            $contribution = Contribution::create([
                'user_id' => 1, // Utilisateur par défaut pour les tests
                'group_id' => 1, // Groupe par défaut pour les tests
                'amount' => $request->amount,
                'description' => $request->description,
                'status' => 'pending',
                'due_date' => now()->addDays(30),
            ]);

            // Créer un nouveau paiement
            $payment = Payment::create([
                'contribution_id' => $contribution->id,
                'payment_reference' => 'PAY_' . time() . '_' . rand(1000, 9999),
                'amount' => $request->amount,
                'payment_method' => $request->network_id,
                'phone_number' => $request->phone_number,
                'status' => 'pending',
                'gateway_response' => json_encode([
                    'network' => $request->network_id,
                    'currency' => $request->currency,
                    'description' => $request->description,
                    'initiated_at' => now()->toISOString(),
                ]),
            ]);

            // Log de l'opération
            Log::info('Payment initiated successfully', [
                'payment_id' => $payment->id,
                'contribution_id' => $contribution->id,
                'amount' => $request->amount,
                'network' => $request->network_id,
                'phone_number' => $request->phone_number,
            ]);

            return response()->json([
                'success' => 1,
                'message' => 'Paiement initié avec succès',
                'data' => [
                    'id' => $payment->id,
                    'reference' => $payment->payment_reference,
                    'status' => $payment->status,
                    'network' => $request->network_id,
                    'phone_number' => $request->phone_number,
                    'amount' => $request->amount,
                    'currency' => $request->currency,
                    'created_at' => $payment->created_at->toISOString(),
                ]
            ], 201);

        } catch (\Illuminate\Validation\ValidationException $e) {
            Log::error('Payment validation failed', [
                'errors' => $e->errors(),
                'request_data' => $request->all()
            ]);

            return response()->json([
                'success' => 0,
                'message' => 'Données invalides',
                'errors' => $e->errors()
            ], 422);

        } catch (\Exception $e) {
            Log::error('Payment initiation failed', [
                'error' => $e->getMessage(),
                'request_data' => $request->all()
            ]);

            return response()->json([
                'success' => 0,
                'message' => 'Erreur lors de l\'initiation du paiement',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function store(Request $request)
    {
        try {
            // Valider les données reçues
            $request->validate([
                'amount' => 'required|numeric|min:1',
                'phone_number' => 'required|string',
                'payment_method' => 'required|string',
                'status' => 'sometimes|string',
            ]);

            // Créer une nouvelle contribution
            $contribution = Contribution::create([
                'user_id' => 1, // Utilisateur par défaut pour les tests
                'group_id' => 1, // Groupe par défaut pour les tests
                'amount' => $request->amount,
                'description' => 'Paiement via ' . $request->payment_method,
                'status' => $request->status ?? 'pending',
                'due_date' => now()->addDays(30),
            ]);

            // Créer un nouveau paiement
            $payment = Payment::create([
                'contribution_id' => $contribution->id,
                'payment_reference' => 'PAY_' . time() . '_' . rand(1000, 9999),
                'amount' => $request->amount,
                'payment_method' => $request->payment_method,
                'phone_number' => $request->phone_number,
                'status' => $request->status ?? 'completed',
                'gateway_response' => json_encode([
                    'method' => $request->payment_method,
                    'phone' => $request->phone_number,
                    'created_at' => now()->toISOString(),
                ]),
            ]);

            // Log de l'opération
            Log::info('Payment created successfully', [
                'payment_id' => $payment->id,
                'contribution_id' => $contribution->id,
                'amount' => $request->amount,
                'method' => $request->payment_method,
                'phone_number' => $request->phone_number,
            ]);

            return response()->json([
                'success' => 1,
                'message' => 'Paiement créé avec succès',
                'payment' => [
                    'id' => $payment->id,
                    'payment_reference' => $payment->payment_reference,
                    'status' => $payment->status,
                    'amount' => $payment->amount,
                    'phone_number' => $payment->phone_number,
                    'payment_method' => $payment->payment_method,
                    'created_at' => $payment->created_at->toISO8601String(),
                ]
            ], 201);

        } catch (\Illuminate\Validation\ValidationException $e) {
            Log::error('Payment validation failed', [
                'errors' => $e->errors(),
                'request_data' => $request->all()
            ]);

            return response()->json([
                'success' => 0,
                'message' => 'Données invalides',
                'errors' => $e->errors()
            ], 422);

        } catch (\Exception $e) {
            Log::error('Payment creation failed', [
                'error' => $e->getMessage(),
                'request_data' => $request->all()
            ]);

            return response()->json([
                'success' => 0,
                'message' => 'Erreur lors de la création du paiement',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function index(Request $request)
    {
        try {
            // Pour les tests, on récupère tous les paiements sans authentification
            $query = Payment::with(['contribution.group']);

            // Filtrer par statut si spécifié
            if ($request->has('status')) {
                $query->where('status', $request->status);
            }

            // Filtrer par méthode de paiement si spécifié
            if ($request->has('payment_method')) {
                $query->where('payment_method', $request->payment_method);
            }

            $payments = $query->latest()->paginate(20);

            return response()->json([
                'success' => 1,
                'message' => 'Liste des paiements récupérée avec succès',
                'payments' => $payments
            ]);

        } catch (\Exception $e) {
            Log::error('Error retrieving payments', [
                'error' => $e->getMessage(),
                'request_data' => $request->all()
            ]);

            return response()->json([
                'success' => 0,
                'message' => 'Erreur lors de la récupération des paiements',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function show(Payment $payment)
    {
        $user = Auth::user();
        
        // Vérifier si l'utilisateur a accès à ce paiement
        if ($payment->contribution->user_id !== $user->id) {
            return response()->json([
                'success' => 0,
                'message' => 'Access denied'
            ], 403);
        }

        $payment->load(['contribution.group']);

        return response()->json([
            'success' => 1,
            'payment' => $payment
        ]);
    }

    public function webhook(Request $request, Payment $payment)
    {
        // Webhook pour recevoir les notifications de l'agrégateur de paiement
        // Cette route ne nécessite pas d'authentification car elle est appelée par l'agrégateur
        
        Log::info('Payment webhook received', [
            'payment_id' => $payment->id,
            'payment_reference' => $payment->payment_reference,
            'webhook_data' => $request->all()
        ]);

        // Vérifier la signature du webhook pour la sécurité
        if (!$this->verifyWebhookSignature($request)) {
            Log::warning('Invalid webhook signature', [
                'payment_id' => $payment->id,
                'ip' => $request->ip()
            ]);
            
            return response()->json(['error' => 'Invalid signature'], 400);
        }

        // Traiter le statut du paiement selon la réponse de l'agrégateur
        $status = $request->input('status');
        $transactionId = $request->input('transaction_id');
        $gatewayResponse = $request->all();

        switch ($status) {
            case 'success':
            case 'completed':
                $this->processSuccessfulPayment($payment, $transactionId, $gatewayResponse);
                break;
                
            case 'failed':
            case 'declined':
                $this->processFailedPayment($payment, $gatewayResponse);
                break;
                
            case 'pending':
                $this->processPendingPayment($payment, $gatewayResponse);
                break;
                
            default:
                Log::warning('Unknown payment status', [
                    'payment_id' => $payment->id,
                    'status' => $status
                ]);
                break;
        }

        return response()->json(['success' => 1]);
    }

    private function verifyWebhookSignature(Request $request): bool
    {
        // TODO: Implémenter la vérification de signature selon la documentation de l'agrégateur
        // Pour le moment, on accepte tous les webhooks (à ne pas faire en production)
        
        return true;
    }

    private function processSuccessfulPayment(Payment $payment, $transactionId, $gatewayResponse)
    {
        // Mettre à jour le statut du paiement
        $payment->update([
            'status' => 'completed',
            'gateway_response' => json_encode($gatewayResponse),
            'processed_at' => now(),
        ]);

        // Mettre à jour le statut de la cotisation
        $contribution = $payment->contribution;
        $contribution->update([
            'status' => 'paid',
            'paid_date' => now(),
        ]);

        // Créer une notification de confirmation
        $this->createNotification(
            $contribution->user_id,
            'payment_confirmation',
            'Paiement confirmé',
            "Votre paiement de {$contribution->amount} FCFA a été confirmé avec succès.",
            'push'
        );

        Log::info('Payment completed successfully', [
            'payment_id' => $payment->id,
            'contribution_id' => $contribution->id,
            'transaction_id' => $transactionId
        ]);
    }

    private function processFailedPayment(Payment $payment, $gatewayResponse)
    {
        // Mettre à jour le statut du paiement
        $payment->update([
            'status' => 'failed',
            'gateway_response' => json_encode($gatewayResponse),
            'processed_at' => now(),
        ]);

        // Mettre à jour le statut de la cotisation
        $contribution = $payment->contribution;
        $contribution->update([
            'status' => 'failed',
        ]);

        // Créer une notification d'échec
        $this->createNotification(
            $contribution->user_id,
            'payment_failed',
            'Échec du paiement',
            "Votre paiement de {$contribution->amount} FCFA a échoué. Veuillez réessayer.",
            'push'
        );

        Log::info('Payment failed', [
            'payment_id' => $payment->id,
            'contribution_id' => $contribution->id
        ]);
    }

    private function processPendingPayment(Payment $payment, $gatewayResponse)
    {
        // Mettre à jour le statut du paiement
        $payment->update([
            'status' => 'processing',
            'gateway_response' => json_encode($gatewayResponse),
        ]);

        Log::info('Payment processing', [
            'payment_id' => $payment->id
        ]);
    }

    private function createNotification($userId, $type, $title, $message, $channel)
    {
        Notification::create([
            'user_id' => $userId,
            'type' => $type,
            'title' => $title,
            'message' => $message,
            'channel' => $channel,
            'status' => 'pending',
        ]);
    }

    public function getPaymentMethods()
    {
        // Retourner les méthodes de paiement disponibles
        $paymentMethods = [
            [
                'id' => 'orange_money',
                'name' => 'Orange Money',
                'logo' => 'orange_money_logo.png',
                'description' => 'Payer avec Orange Money'
            ],
            [
                'id' => 'mtn_mobile_money',
                'name' => 'MTN Mobile Money',
                'logo' => 'mtn_mobile_money_logo.png',
                'description' => 'Payer avec MTN Mobile Money'
            ],
            [
                'id' => 'moov_money',
                'name' => 'Moov Money',
                'logo' => 'moov_money_logo.png',
                'description' => 'Payer avec Moov Money'
            ]
        ];

        return response()->json([
            'success' => 1,
            'payment_methods' => $paymentMethods
        ]);
    }
}
