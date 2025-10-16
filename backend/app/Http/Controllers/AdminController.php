<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Group;
use App\Models\User;
use App\Models\Contribution;
use App\Models\Payment;
use App\Models\GroupMember;

class AdminController extends Controller
{
    /**
     * Obtenir le tableau de bord administrateur
     */
    public function dashboard()
    {
        try {
            // Statistiques générales
            $totalGroups = Group::count();
            $totalMembers = User::count();
            $totalContributions = Contribution::count();
            $totalAmountCollected = Contribution::where('status', 'paid')->sum('amount') ?? 0;

            // Paiements en attente et en retard
            $pendingPayments = Contribution::where('status', 'pending')->count();
            $overduePayments = Contribution::where('due_date', '<', now())
                ->where('status', '!=', 'paid')
                ->count();

            // Groupes récents avec nombre de membres
            $recentGroups = Group::latest()
                ->take(5)
                ->get()
                ->map(function ($group) {
                    $memberCount = GroupMember::where('group_id', $group->id)->count();
                    return [
                        'id' => $group->id,
                        'name' => $group->name,
                        'type' => $group->type,
                        'member_count' => $memberCount,
                        'contribution_amount' => $group->contribution_amount,
                        'created_at' => $group->created_at->toISOString(),
                    ];
                });

            // Paiements récents avec informations utilisateur et groupe
            $recentPayments = Payment::with(['contribution.user', 'contribution.group'])
                ->latest()
                ->take(5)
                ->get()
                ->map(function ($payment) {
                    return [
                        'id' => $payment->id,
                        'amount' => $payment->amount,
                        'status' => $payment->status,
                        'payment_method' => $payment->payment_method,
                        'user_name' => $payment->contribution->user->first_name . ' ' . $payment->contribution->user->last_name,
                        'group_name' => $payment->contribution->group->name,
                        'processed_at' => $payment->processed_at ? $payment->processed_at->toISOString() : null,
                    ];
                });

            return response()->json([
                'success' => 1,
                'data' => [
                    'total_groups' => $totalGroups,
                    'total_members' => $totalMembers,
                    'total_contributions' => $totalContributions,
                    'total_amount_collected' => $totalAmountCollected,
                    'pending_payments' => $pendingPayments,
                    'overdue_payments' => $overduePayments,
                    'recent_groups' => $recentGroups,
                    'recent_payments' => $recentPayments,
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => 0,
                'message' => 'Erreur lors de la récupération du tableau de bord: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Obtenir tous les groupes (pour l'administration)
     */
    public function getAllGroups()
    {
        try {
            $groups = Group::latest()
                ->get()
                ->map(function ($group) {
                    $memberCount = GroupMember::where('group_id', $group->id)->count();
                    return [
                        'id' => $group->id,
                        'name' => $group->name,
                        'description' => $group->description,
                        'type' => $group->type,
                        'contribution_amount' => $group->contribution_amount,
                        'frequency' => $group->frequency,
                        'payment_mode' => $group->payment_mode,
                        'next_due_date' => $group->next_due_date ? $group->next_due_date->toISOString() : null,
                        'is_active' => $group->is_active,
                        'member_count' => $memberCount,
                        'created_at' => $group->created_at->toISOString(),
                    ];
                });

            return response()->json([
                'success' => 1,
                'groups' => $groups
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => 0,
                'message' => 'Erreur lors de la récupération des groupes: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Supprimer un groupe
     */
    public function createGroup(Request $request)
    {
        try {
            $request->validate([
                'name' => 'required|string|max:255',
                'description' => 'nullable|string',
                'type' => 'required|in:association,tontine,mutuelle,cooperative',
                'contribution_amount' => 'required|numeric|min:0',
                'frequency' => 'required|in:daily,weekly,monthly,yearly',
                'payment_mode' => 'required|in:automatic,manual',
            ]);

            $group = Group::create([
                'name' => $request->name,
                'description' => $request->description,
                'type' => $request->type,
                'contribution_amount' => $request->contribution_amount,
                'frequency' => $request->frequency,
                'payment_mode' => $request->payment_mode,
                'next_due_date' => now()->addDays(30),
                'is_active' => true,
            ]);

            return response()->json([
                'success' => 1,
                'message' => 'Groupe créé avec succès',
                'group' => $group
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => 0,
                'message' => 'Erreur lors de la création du groupe: ' . $e->getMessage()
            ], 500);
        }
    }

    public function deleteGroup($groupId)
    {
        try {
            $group = Group::findOrFail($groupId);
            $group->delete();

            return response()->json([
                'success' => 1,
                'message' => 'Groupe supprimé avec succès'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => 0,
                'message' => 'Erreur lors de la suppression du groupe: ' . $e->getMessage()
            ], 500);
        }
    }

    // Méthodes pour les rapports
    public function generateFinancialReport(Request $request)
    {
        try {
            // TODO: Implémenter la génération du rapport financier
            return response()->json([
                'success' => 1,
                'message' => 'Rapport financier généré avec succès',
                'data' => [
                    'total_revenue' => 0,
                    'total_expenses' => 0,
                    'net_profit' => 0,
                    'period' => $request->get('period', 'monthly')
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => 0,
                'message' => 'Erreur lors de la génération: ' . $e->getMessage()
            ], 500);
        }
    }

    public function generateMembersReport(Request $request)
    {
        try {
            // TODO: Implémenter la génération du rapport des membres
            return response()->json([
                'success' => 1,
                'message' => 'Rapport des membres généré avec succès',
                'data' => [
                    'total_members' => 0,
                    'active_members' => 0,
                    'inactive_members' => 0,
                    'period' => $request->get('period', 'monthly')
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => 0,
                'message' => 'Erreur lors de la génération: ' . $e->getMessage()
            ], 500);
        }
    }

    public function generateContributionsReport(Request $request)
    {
        try {
            // TODO: Implémenter la génération du rapport des cotisations
            return response()->json([
                'success' => 1,
                'message' => 'Rapport des cotisations généré avec succès',
                'data' => [
                    'total_contributions' => 0,
                    'paid_contributions' => 0,
                    'pending_contributions' => 0,
                    'overdue_contributions' => 0,
                    'period' => $request->get('period', 'monthly')
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => 0,
                'message' => 'Erreur lors de la génération: ' . $e->getMessage()
            ], 500);
        }
    }

    public function generateGroupsReport(Request $request)
    {
        try {
            // TODO: Implémenter la génération du rapport des groupes
            return response()->json([
                'success' => 1,
                'message' => 'Rapport des groupes généré avec succès',
                'data' => [
                    'total_groups' => 0,
                    'active_groups' => 0,
                    'inactive_groups' => 0,
                    'period' => $request->get('period', 'monthly')
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => 0,
                'message' => 'Erreur lors de la génération: ' . $e->getMessage()
            ], 500);
        }
    }

    // Méthodes pour l'export
    public function exportToExcel(Request $request)
    {
        try {
            // TODO: Implémenter l'export Excel
            return response()->json([
                'success' => 1,
                'message' => 'Export Excel en cours',
                'data' => [
                    'download_url' => '/exports/excel/report.xlsx',
                    'expires_at' => now()->addHours(24)
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => 0,
                'message' => 'Erreur lors de l\'export: ' . $e->getMessage()
            ], 500);
        }
    }

    public function exportToPDF(Request $request)
    {
        try {
            // TODO: Implémenter l'export PDF
            return response()->json([
                'success' => 1,
                'message' => 'Export Excel en cours',
                'data' => [
                    'download_url' => '/exports/pdf/report.pdf',
                    'expires_at' => now()->addHours(24)
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => 0,
                'message' => 'Erreur lors de l\'export: ' . $e->getMessage()
            ], 500);
        }
    }

    public function exportToCSV(Request $request)
    {
        try {
            // TODO: Implémenter l'export CSV
            return response()->json([
                'success' => 1,
                'message' => 'Export CSV en cours',
                'data' => [
                    'download_url' => '/exports/csv/report.csv',
                    'expires_at' => now()->addHours(24)
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => 0,
                'message' => 'Erreur lors de l\'export: ' . $e->getMessage()
            ], 500);
        }
    }

    // Méthodes pour les paramètres
    public function getSettings()
    {
        try {
            // TODO: Implémenter la récupération des paramètres
            return response()->json([
                'success' => 1,
                'data' => [
                    'notifications_enabled' => true,
                    'auto_debit_enabled' => true,
                    'default_currency' => 'FCFA',
                    'default_language' => 'Français',
                    'contribution_reminder_days' => 3
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => 0,
                'message' => 'Erreur lors de la récupération: ' . $e->getMessage()
            ], 500);
        }
    }

    public function updateSettings(Request $request)
    {
        try {
            // TODO: Implémenter la récupération des paramètres
            $validated = $request->validate([
                'notifications_enabled' => 'boolean',
                'auto_debit_enabled' => 'boolean',
                'default_currency' => 'string',
                'default_language' => 'string',
                'contribution_reminder_days' => 'integer|min:1|max:7'
            ]);

            return response()->json([
                'success' => 1,
                'message' => 'Paramètres mis à jour avec succès',
                'data' => $validated
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => 0,
                'message' => 'Erreur lors de la mise à jour: ' . $e->getMessage()
            ], 500);
        }
    }
} 