<?php

namespace App\Http\Controllers;

use App\Models\Contribution;
use App\Models\Payment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class ContributionController extends Controller
{
    public function index(Request $request)
    {
        $user = Auth::user();
        $query = $user->contributions()->with(['group', 'payment']);

        // Filtrer par groupe si spécifié
        if ($request->has('group_id')) {
            $query->where('group_id', $request->group_id);
        }

        // Filtrer par statut si spécifié
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        $contributions = $query->latest()->paginate(20);

        return response()->json([
            'success' => 1,
            'contributions' => $contributions
        ]);
    }

    public function show(Contribution $contribution)
    {
        $user = Auth::user();
        
        // Vérifier si l'utilisateur a accès à cette cotisation
        if ($contribution->user_id !== $user->id) {
            return response()->json([
                'success' => 0,
                'message' => 'Access denied'
            ], 403);
        }

        $contribution->load(['group', 'payment']);

        return response()->json([
            'success' => 1,
            'contribution' => $contribution
        ]);
    }

    public function pay(Request $request, Contribution $contribution)
    {
        $user = Auth::user();
        
        // Vérifier si l'utilisateur a accès à cette cotisation
        if ($contribution->user_id !== $user->id) {
            return response()->json([
                'success' => 0,
                'message' => 'Access denied'
            ], 403);
        }

        // Vérifier si la cotisation n'est pas déjà payée
        if ($contribution->isPaid()) {
            return response()->json([
                'success' => 0,
                'message' => 'Contribution is already paid'
            ], 400);
        }

        $validator = Validator::make($request->all(), [
            'payment_method' => 'required|string|in:orange_money,mtn_mobile_money,moov_money',
            'phone_number' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => 0,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        // Créer le paiement
        $payment = Payment::create([
            'contribution_id' => $contribution->id,
            'payment_reference' => 'PAY-' . time() . '-' . $contribution->id,
            'amount' => $contribution->amount,
            'payment_method' => $request->payment_method,
            'phone_number' => $request->phone_number,
            'status' => 'pending',
        ]);

        // Mettre à jour le statut de la cotisation
        $contribution->update([
            'status' => 'processing',
            'payment_reference' => $payment->payment_reference,
        ]);

        // TODO: Intégrer avec l'agrégateur de paiement (Barapay)
        // Pour le moment, on simule un paiement réussi après 5 secondes
        
        // Simuler le traitement du paiement
        $this->processPayment($payment);

        return response()->json([
            'success' => 1,
            'message' => 'Payment initiated successfully',
            'payment' => $payment,
            'contribution' => $contribution->fresh()
        ]);
    }

    private function processPayment(Payment $payment)
    {
        // Simuler le traitement du paiement
        // En production, cela serait géré par l'agrégateur via webhook
        
        // Pour le moment, on simule un succès après 5 secondes
        \Log::info("Processing payment: {$payment->payment_reference}");
        
        // TODO: Remplacer par l'intégration réelle avec l'agrégateur
        // $this->initiatePaymentWithGateway($payment);
    }

    public function generateContributions(Group $group)
    {
        $user = Auth::user();
        
        // Vérifier si l'utilisateur est admin du groupe
        if (!$group->members()->where('user_id', $user->id)->where('role', 'admin')->exists()) {
            return response()->json([
                'success' => 0,
                'message' => 'Access denied. Admin role required.'
            ], 403);
        }

        // Générer les cotisations pour tous les membres actifs
        $members = $group->activeMembers;
        $contributions = [];

        foreach ($members as $member) {
            $contribution = Contribution::create([
                'user_id' => $member->user_id,
                'group_id' => $group->id,
                'amount' => $group->contribution_amount,
                'due_date' => $group->next_due_date,
                'status' => 'pending',
            ]);

            $contributions[] = $contribution;
        }

        // Mettre à jour la prochaine date d'échéance
        $nextDueDate = $this->calculateNextDueDate($group->next_due_date, $group->frequency);
        $group->update(['next_due_date' => $nextDueDate]);

        return response()->json([
            'success' => 1,
            'message' => 'Contributions generated successfully',
            'contributions_count' => count($contributions),
            'next_due_date' => $nextDueDate
        ]);
    }

    private function calculateNextDueDate($currentDate, $frequency)
    {
        $date = \Carbon\Carbon::parse($currentDate);
        
        return match($frequency) {
            'daily' => $date->addDay(),
            'weekly' => $date->addWeek(),
            'monthly' => $date->addMonth(),
            'yearly' => $date->addYear(),
            default => $date->addMonth()
        };
    }
}
