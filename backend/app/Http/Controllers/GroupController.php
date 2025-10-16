<?php

namespace App\Http\Controllers;

use App\Models\Group;
use App\Models\GroupMember;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class GroupController extends Controller
{
    public function index()
    {
        $user = Auth::user();
        $groups = $user->groups()->with('members.user')->get();

        return response()->json([
            'success' => 1,
            'groups' => $groups
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'type' => 'required|string|in:association,tontine,mutuelle,cooperative,syndicat,club',
            'contribution_amount' => 'required|numeric|min:0',
            'frequency' => 'required|string|in:daily,weekly,monthly,yearly',
            'payment_mode' => 'required|string|in:automatic,manual',
            'next_due_date' => 'required|date|after:today',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => 0,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $group = Group::create($request->all());

        // Créer l'utilisateur actuel comme admin du groupe
        GroupMember::create([
            'user_id' => Auth::id(),
            'group_id' => $group->id,
            'role' => 'admin',
            'joined_date' => now(),
        ]);

        return response()->json([
            'success' => 1,
            'message' => 'Group created successfully',
            'group' => $group->load('members.user')
        ], 201);
    }

    public function show(Group $group)
    {
        $user = Auth::user();
        
        // Vérifier si l'utilisateur est membre du groupe
        if (!$group->members()->where('user_id', $user->id)->exists()) {
            return response()->json([
                'success' => 0,
                'message' => 'Access denied'
            ], 403);
        }

        $group->load(['members.user', 'contributions.user']);

        return response()->json([
            'success' => 1,
            'group' => $group
        ]);
    }

    public function update(Request $request, Group $group)
    {
        $user = Auth::user();
        
        // Vérifier si l'utilisateur est admin du groupe
        if (!$group->members()->where('user_id', $user->id)->where('role', 'admin')->exists()) {
            return response()->json([
                'success' => 0,
                'message' => 'Access denied. Admin role required.'
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:255',
            'description' => 'nullable|string',
            'contribution_amount' => 'sometimes|numeric|min:0',
            'frequency' => 'sometimes|string|in:daily,weekly,monthly,yearly',
            'payment_mode' => 'sometimes|string|in:automatic,manual',
            'next_due_date' => 'sometimes|date|after:today',
            'is_active' => 'sometimes|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => 0,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $group->update($request->all());

        return response()->json([
            'success' => 1,
            'message' => 'Group updated successfully',
            'group' => $group->load('members.user')
        ]);
    }

    public function addMember(Request $request, Group $group)
    {
        $user = Auth::user();
        
        // Vérifier si l'utilisateur est admin du groupe
        if (!$group->members()->where('user_id', $user->id)->where('role', 'admin')->exists()) {
            return response()->json([
                'success' => 0,
                'message' => 'Access denied. Admin role required.'
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'phone_number' => 'required|string|exists:users,phone_number',
            'role' => 'required|string|in:member,admin',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => 0,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $newMember = User::where('phone_number', $request->phone_number)->first();

        // Vérifier si l'utilisateur n'est pas déjà membre
        if ($group->members()->where('user_id', $newMember->id)->exists()) {
            return response()->json([
                'success' => 0,
                'message' => 'User is already a member of this group'
            ], 400);
        }

        GroupMember::create([
            'user_id' => $newMember->id,
            'group_id' => $group->id,
            'role' => $request->role,
            'joined_date' => now(),
        ]);

        return response()->json([
            'success' => 1,
            'message' => 'Member added successfully',
            'member' => $newMember->only(['id', 'first_name', 'last_name', 'phone_number'])
        ]);
    }

    public function removeMember(Request $request, Group $group)
    {
        $user = Auth::user();
        
        // Vérifier si l'utilisateur est admin du groupe
        if (!$group->members()->where('user_id', $user->id)->where('role', 'admin')->exists()) {
            return response()->json([
                'success' => 0,
                'message' => 'Access denied. Admin role required.'
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'user_id' => 'required|integer|exists:users,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => 0,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $memberToRemove = $group->members()->where('user_id', $request->user_id)->first();

        if (!$memberToRemove) {
            return response()->json([
                'success' => 0,
                'message' => 'User is not a member of this group'
            ], 400);
        }

        // Empêcher la suppression du dernier admin
        if ($memberToRemove->role === 'admin' && $group->admins()->count() === 1) {
            return response()->json([
                'success' => 0,
                'message' => 'Cannot remove the last admin of the group'
            ], 400);
        }

        $memberToRemove->delete();

        return response()->json([
            'success' => 1,
            'message' => 'Member removed successfully'
        ]);
    }

    public function dashboard(Group $group)
    {
        $user = Auth::user();
        
        // Vérifier si l'utilisateur est membre du groupe
        if (!$group->members()->where('user_id', $user->id)->exists()) {
            return response()->json([
                'success' => 0,
                'message' => 'Access denied'
            ], 403);
        }

        $totalMembers = $group->activeMembers()->count();
        $totalContributions = $group->contributions()->where('status', 'paid')->sum('amount');
        $pendingContributions = $group->contributions()->where('status', 'pending')->count();
        $overdueContributions = $group->contributions()->where('status', 'overdue')->count();

        return response()->json([
            'success' => 1,
            'dashboard' => [
                'total_members' => $totalMembers,
                'total_collected' => $totalContributions,
                'pending_contributions' => $pendingContributions,
                'overdue_contributions' => $overdueContributions,
                'next_due_date' => $group->next_due_date,
                'contribution_amount' => $group->contribution_amount,
            ]
        ]);
    }
}
