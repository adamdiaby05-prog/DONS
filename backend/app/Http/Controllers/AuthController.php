<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'first_name' => 'required|string|max:255',
            'last_name' => 'required|string|max:255',
            'phone_number' => 'required|string|unique:users|max:20',
            'email' => 'nullable|email|unique:users|max:255',
            'password' => 'required|string|min:6|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => 0,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::create([
            'first_name' => $request->first_name,
            'last_name' => $request->last_name,
            'phone_number' => $request->phone_number,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'phone_verified' => true, // Vérifié par défaut (pas d'OTP)
        ]);

        // Générer un token d'accès directement (pas d'OTP)
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => 1,
            'message' => 'User registered successfully.',
            'user' => $user->only(['id', 'first_name', 'last_name', 'phone_number', 'email']),
            'token' => $token
        ], 201);
    }

    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'phone_number' => 'required|string',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => 0,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::where('phone_number', $request->phone_number)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => 0,
                'message' => 'Invalid credentials'
            ], 401);
        }

        // Temporairement, permettre la connexion sans vérification OTP pour les tests
        // if (!$user->isPhoneVerified()) {
        //     return response()->json([
        //         'success' => false,
        //         'message' => 'Phone number not verified. Please verify first.'
        //     ], 403);
        // }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => 1,
            'message' => 'Login successful',
            'user' => $user->only(['id', 'first_name', 'last_name', 'phone_number', 'email']),
            'token' => $token
        ]);
    }

    public function sendOtp(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'phone_number' => 'required|string|exists:users,phone_number',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => 0,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::where('phone_number', $request->phone_number)->first();
        $otp = $this->generateAndSendOtp($user);

        return response()->json([
            'success' => 1,
            'message' => 'OTP sent successfully',
            'otp_sent' => true
        ]);
    }

    public function verifyOtp(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'phone_number' => 'required|string|exists:users,phone_number',
            'otp_code' => 'required|string|size:6',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => 0,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::where('phone_number', $request->phone_number)->first();

        if (!$user->hasValidOtp() || $user->otp_code !== $request->otp_code) {
            return response()->json([
                'success' => 0,
                'message' => 'Invalid or expired OTP'
            ], 400);
        }

        $user->update([
            'phone_verified' => true,
            'otp_code' => null,
            'otp_expires_at' => null,
        ]);

        return response()->json([
            'success' => 1,
            'message' => 'Phone number verified successfully',
            'user' => $user->only(['id', 'first_name', 'last_name', 'phone_number', 'phone_verified'])
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => 1,
            'message' => 'Logged out successfully'
        ]);
    }

    private function generateAndSendOtp(User $user): string
    {
        $otp = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);
        
        $user->update([
            'otp_code' => $otp,
            'otp_expires_at' => now()->addMinutes(10),
        ]);

        // TODO: Intégrer avec un service SMS pour envoyer l'OTP
        // Pour le moment, on retourne juste l'OTP (en production, ne pas le faire)
        
        return $otp;
    }
}
