<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Créer un utilisateur admin de test
        User::create([
            'first_name' => 'Admin',
            'last_name' => 'Test',
            'phone_number' => '0701234567',
            'email' => 'admin@test.com',
            'password' => Hash::make('password123'),
            'phone_verified' => true,
            'otp_code' => null,
            'otp_expires_at' => null,
        ]);

        // Créer quelques utilisateurs de test supplémentaires
        User::create([
            'first_name' => 'Jean',
            'last_name' => 'Dupont',
            'phone_number' => '0701234568',
            'email' => 'jean@test.com',
            'password' => Hash::make('password123'),
            'phone_verified' => true,
        ]);

        User::create([
            'first_name' => 'Marie',
            'last_name' => 'Martin',
            'phone_number' => '0701234569',
            'email' => 'marie@test.com',
            'password' => Hash::make('password123'),
            'phone_verified' => true,
        ]);
    }
}
