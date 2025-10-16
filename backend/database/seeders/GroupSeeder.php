<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Group;
use App\Models\GroupMember;
use App\Models\Contribution;
use App\Models\Payment;
use App\Models\User;

class GroupSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Créer des groupes de test
        $group1 = Group::create([
            'name' => 'Association des Commerçants',
            'description' => 'Association pour les commerçants du quartier',
            'type' => 'association',
            'contribution_amount' => 5000,
            'frequency' => 'monthly',
            'payment_mode' => 'automatic',
            'next_due_date' => now()->addDays(30),
            'is_active' => true,
        ]);

        $group2 = Group::create([
            'name' => 'Tontine des Femmes',
            'description' => 'Tontine pour l\'autonomisation des femmes',
            'type' => 'tontine',
            'contribution_amount' => 10000,
            'frequency' => 'weekly',
            'payment_mode' => 'manual',
            'next_due_date' => now()->addDays(7),
            'is_active' => true,
        ]);

        $group3 = Group::create([
            'name' => 'Coopérative Agricole',
            'description' => 'Coopérative pour les agriculteurs',
            'type' => 'cooperative',
            'contribution_amount' => 15000,
            'frequency' => 'monthly',
            'payment_mode' => 'automatic',
            'next_due_date' => now()->addDays(30),
            'is_active' => true,
        ]);

        // Ajouter des membres aux groupes
        $users = User::all();
        
        foreach ($users as $index => $user) {
            // Ajouter chaque utilisateur à au moins un groupe
            GroupMember::create([
                'user_id' => $user->id,
                'group_id' => $group1->id,
                'role' => $index === 0 ? 'admin' : 'member',
                'joined_date' => now()->subDays(rand(1, 30)),
                'is_active' => true,
            ]);

            if ($index < 2) {
                GroupMember::create([
                    'user_id' => $user->id,
                    'group_id' => $group2->id,
                    'role' => $index === 0 ? 'admin' : 'member',
                    'joined_date' => now()->subDays(rand(1, 30)),
                    'is_active' => true,
                ]);
            }
        }

        // Créer des contributions de test
        foreach ([$group1, $group2, $group3] as $group) {
            $members = GroupMember::where('group_id', $group->id)->get();
            
            foreach ($members as $member) {
                // Contribution payée
                $contribution1 = Contribution::create([
                    'user_id' => $member->user_id,
                    'group_id' => $group->id,
                    'amount' => $group->contribution_amount,
                    'due_date' => now()->subDays(30),
                    'paid_date' => now()->subDays(25),
                    'status' => 'paid',
                    'payment_reference' => 'REF' . rand(100000, 999999),
                    'notes' => 'Paiement effectué avec succès',
                ]);

                // Créer un paiement associé
                Payment::create([
                    'contribution_id' => $contribution1->id,
                    'payment_reference' => $contribution1->payment_reference,
                    'amount' => $contribution1->amount,
                    'payment_method' => 'orange_money',
                    'phone_number' => $member->user->phone_number,
                    'status' => 'completed',
                    'gateway_response' => '{"status": "success", "transaction_id": "TXN' . rand(100000, 999999) . '"}',
                    'processed_at' => $contribution1->paid_date,
                ]);

                // Contribution en attente
                Contribution::create([
                    'user_id' => $member->user_id,
                    'group_id' => $group->id,
                    'amount' => $group->contribution_amount,
                    'due_date' => now()->addDays(7),
                    'status' => 'pending',
                    'notes' => 'En attente de paiement',
                ]);
            }
        }
    }
}
