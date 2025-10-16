<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Group;
use App\Models\GroupMember;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class MemberController extends Controller
{
    /**
     * Récupérer tous les membres
     */
    public function index()
    {
        try {
            $members = User::with(['groupMembers.group'])
                ->orderBy('created_at', 'desc')
                ->get();

            return response()->json([
                'success' => 1,
                'data' => $members,
                'message' => 'Membres récupérés avec succès'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => 0,
                'message' => 'Erreur lors de la récupération des membres: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Récupérer un membre spécifique
     */
    public function show($id)
    {
        try {
            $member = User::with(['groupMembers.group'])->findOrFail($id);

            return response()->json([
                'success' => 1,
                'data' => $member,
                'message' => 'Membre récupéré avec succès'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => 0,
                'message' => 'Membre non trouvé'
            ], 404);
        }
    }

    /**
     * Créer un nouveau membre
     */
    public function store(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'first_name' => 'required|string|max:255',
                'last_name' => 'required|string|max:255',
                'phone_number' => 'required|string|unique:users,phone_number',
                'email' => 'nullable|email|unique:users,email',
                'password' => 'required|string|min:6',
                'group_ids' => 'nullable|array',
                'group_ids.*' => 'exists:groups,id'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => 0,
                    'message' => 'Erreur de validation',
                    'errors' => $validator->errors()
                ], 422);
            }

            // Créer le membre
            $member = User::create([
                'first_name' => $request->first_name,
                'last_name' => $request->last_name,
                'phone_number' => $request->phone_number,
                'email' => $request->email,
                'password' => Hash::make($request->password),
                'phone_verified' => true, // Pour simplifier, on considère comme vérifié
            ]);

            // Ajouter aux groupes si spécifiés
            if ($request->has('group_ids') && is_array($request->group_ids)) {
                foreach ($request->group_ids as $groupId) {
                    GroupMember::create([
                        'user_id' => $member->id,
                        'group_id' => $groupId,
                        'role' => 'member',
                        'joined_date' => now(),
                        'is_active' => true,
                    ]);
                }
            }

            // Charger les relations
            $member->load(['groupMembers.group']);

            return response()->json([
                'success' => 1,
                'data' => $member,
                'message' => 'Membre créé avec succès'
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => 0,
                'message' => 'Erreur lors de la création du membre: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Mettre à jour un membre
     */
    public function update(Request $request, $id)
    {
        try {
            $member = User::findOrFail($id);

            $validator = Validator::make($request->all(), [
                'first_name' => 'sometimes|required|string|max:255',
                'last_name' => 'sometimes|required|string|max:255',
                'phone_number' => 'sometimes|required|string|unique:users,phone_number,' . $id,
                'email' => 'nullable|email|unique:users,email,' . $id,
                'password' => 'sometimes|required|string|min:6',
                'group_ids' => 'nullable|array',
                'group_ids.*' => 'exists:groups,id'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => 0,
                    'message' => 'Erreur de validation',
                    'errors' => $validator->errors()
                ], 422);
            }

            // Mettre à jour les champs
            $updateData = $request->only(['first_name', 'last_name', 'phone_number', 'email']);
            if ($request->has('password')) {
                $updateData['password'] = Hash::make($request->password);
            }

            $member->update($updateData);

            // Mettre à jour les groupes si spécifiés
            if ($request->has('group_ids')) {
                // Supprimer les anciennes associations
                GroupMember::where('user_id', $member->id)->delete();
                
                // Ajouter les nouvelles associations
                if (is_array($request->group_ids)) {
                    foreach ($request->group_ids as $groupId) {
                        GroupMember::create([
                            'user_id' => $member->id,
                            'group_id' => $groupId,
                            'role' => 'member',
                            'joined_date' => now(),
                            'is_active' => true,
                        ]);
                    }
                }
            }

            // Charger les relations
            $member->load(['groupMembers.group']);

            return response()->json([
                'success' => 1,
                'data' => $member,
                'message' => 'Membre mis à jour avec succès'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => 0,
                'message' => 'Erreur lors de la mise à jour du membre: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Supprimer un membre
     */
    public function destroy($id)
    {
        try {
            $member = User::findOrFail($id);

            // Supprimer les associations aux groupes
            GroupMember::where('user_id', $member->id)->delete();

            // Supprimer le membre
            $member->delete();

            return response()->json([
                'success' => 1,
                'message' => 'Membre supprimé avec succès'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => 0,
                'message' => 'Erreur lors de la suppression du membre: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Récupérer les groupes disponibles pour l'ajout de membres
     */
    public function getAvailableGroups()
    {
        try {
            $groups = Group::where('is_active', true)
                ->orderBy('name')
                ->get(['id', 'name', 'type']);

            return response()->json([
                'success' => 1,
                'data' => $groups,
                'message' => 'Groupes récupérés avec succès'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => 0,
                'message' => 'Erreur lors de la récupération des groupes: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Ajouter un membre à un groupe
     */
    public function addToGroup(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'user_id' => 'required|exists:users,id',
                'group_id' => 'required|exists:groups,id',
                'role' => 'nullable|string|in:member,admin'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => 0,
                    'message' => 'Erreur de validation',
                    'errors' => $validator->errors()
                ], 422);
            }

            // Vérifier si l'association existe déjà
            $existingMember = GroupMember::where('user_id', $request->user_id)
                ->where('group_id', $request->group_id)
                ->first();

            if ($existingMember) {
                return response()->json([
                    'success' => 0,
                    'message' => 'Le membre est déjà dans ce groupe'
                ], 400);
            }

            // Créer l'association
            GroupMember::create([
                'user_id' => $request->user_id,
                'group_id' => $request->group_id,
                'role' => $request->role ?? 'member',
                'joined_date' => now(),
                'is_active' => true,
            ]);

            return response()->json([
                'success' => 1,
                'message' => 'Membre ajouté au groupe avec succès'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => 0,
                'message' => 'Erreur lors de l\'ajout au groupe: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Retirer un membre d'un groupe
     */
    public function removeFromGroup(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'user_id' => 'required|exists:users,id',
                'group_id' => 'required|exists:groups,id'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => 0,
                    'message' => 'Erreur de validation',
                    'errors' => $validator->errors()
                ], 422);
            }

            // Supprimer l'association
            GroupMember::where('user_id', $request->user_id)
                ->where('group_id', $request->group_id)
                ->delete();

            return response()->json([
                'success' => 1,
                'message' => 'Membre retiré du groupe avec succès'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => 0,
                'message' => 'Erreur lors du retrait du groupe: ' . $e->getMessage()
            ], 500);
        }
    }
} 