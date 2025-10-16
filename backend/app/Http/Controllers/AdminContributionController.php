<?php

namespace App\Http\Controllers;

use App\Models\Contribution;
use App\Models\Group;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AdminContributionController extends Controller
{
    /**
     * Afficher toutes les cotisations (pour l'administration)
     */
    public function index()
    {
        try {
            $contributions = Contribution::with(['group', 'user', 'payment'])
                ->latest()
                ->get()
                ->map(function ($contribution) {
                    return [
                        'id' => $contribution->id,
                        'group' => $contribution->group ? [
                            'id' => $contribution->group->id,
                            'name' => $contribution->group->name,
                        ] : null,
                        'member' => [
                            'id' => $contribution->user->id,
                            'user' => [
                                'id' => $contribution->user->id,
                                'firstName' => $contribution->user->first_name,
                                'lastName' => $contribution->user->last_name,
                            ],
                        ],
                        'amount' => $contribution->amount,
                        'status' => $contribution->status,
                        'due_date' => $contribution->due_date ? $contribution->due_date->toISOString() : null,
                        'created_at' => $contribution->created_at->toISOString(),
                    ];
                });

            return response()->json([
                'success' => 1,
                'data' => $contributions
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => 0,
                'message' => 'Erreur lors de la récupération des cotisations: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Créer une nouvelle cotisation
     */
    public function store(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'group_id' => 'required|exists:groups,id',
                'user_id' => 'required|exists:users,id',
                'amount' => 'required|numeric|min:0',
                'due_date' => 'required|date',
                'status' => 'required|in:pending,paid,overdue',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => 0,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            $contribution = Contribution::create([
                'group_id' => $request->group_id,
                'user_id' => $request->user_id,
                'amount' => $request->amount,
                'due_date' => $request->due_date,
                'status' => $request->status,
            ]);

            $contribution->load(['group', 'user']);

            return response()->json([
                'success' => 1,
                'message' => 'Cotisation créée avec succès',
                'data' => [
                    'id' => $contribution->id,
                    'group' => $contribution->group ? [
                        'id' => $contribution->group->id,
                        'name' => $contribution->group->name,
                    ] : null,
                    'member' => $contribution->member ? [
                        'id' => $contribution->member->id,
                        'user' => $contribution->member->user ? [
                            'id' => $contribution->member->user->id,
                            'firstName' => $contribution->member->user->first_name,
                            'lastName' => $contribution->member->user->last_name,
                        ] : null,
                    ] : null,
                    'amount' => $contribution->amount,
                    'status' => $contribution->status,
                    'due_date' => $contribution->due_date ? $contribution->due_date->toISOString() : null,
                    'created_at' => $contribution->created_at->toISOString(),
                ]
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => 0,
                'message' => 'Erreur lors de la création de la cotisation: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Afficher une cotisation spécifique
     */
    public function show(Contribution $contribution)
    {
        try {
            $contribution->load(['group', 'user', 'payment']);

            return response()->json([
                'success' => 1,
                'data' => [
                    'id' => $contribution->id,
                    'group' => $contribution->group ? [
                        'id' => $contribution->group->id,
                        'name' => $contribution->group->name,
                    ] : null,
                    'member' => $contribution->member ? [
                        'id' => $contribution->member->id,
                        'user' => $contribution->member->user ? [
                            'id' => $contribution->member->user->id,
                            'firstName' => $contribution->member->user->first_name,
                            'lastName' => $contribution->member->user->last_name,
                        ] : null,
                    ] : null,
                    'amount' => $contribution->amount,
                    'status' => $contribution->status,
                    'due_date' => $contribution->due_date ? $contribution->due_date->toISOString() : null,
                    'created_at' => $contribution->created_at->toISOString(),
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => 0,
                'message' => 'Erreur lors de la récupération de la cotisation: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Mettre à jour une cotisation
     */
    public function update(Request $request, Contribution $contribution)
    {
        try {
            $validator = Validator::make($request->all(), [
                'amount' => 'sometimes|numeric|min:0',
                'due_date' => 'sometimes|date',
                'status' => 'sometimes|in:pending,paid,overdue',
                'frequency' => 'sometimes|in:daily,weekly,monthly,quarterly,yearly',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => 0,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            $contribution->update($request->only(['amount', 'due_date', 'status', 'frequency']));

            return response()->json([
                'success' => 1,
                'message' => 'Cotisation mise à jour avec succès',
                'data' => $contribution
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => 0,
                'message' => 'Erreur lors de la mise à jour de la cotisation: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Supprimer une cotisation
     */
    public function destroy(Contribution $contribution)
    {
        try {
            $contribution->delete();

            return response()->json([
                'success' => 1,
                'message' => 'Cotisation supprimée avec succès'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => 0,
                'message' => 'Erreur lors de la suppression de la cotisation: ' . $e->getMessage()
            ], 500);
        }
    }
}
