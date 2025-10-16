<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class CampaignController extends Controller
{
    /**
     * Récupérer les informations de la campagne
     */
    public function getCampaign(): JsonResponse
    {
        try {
            // Données de campagne par défaut
            $campaign = [
                'id' => '1',
                'candidate_name' => 'Candidat ADM 2024',
                'candidate_photo' => '/images/candidate.jpg',
                'biography' => 'Candidat engagé pour le développement de notre communauté avec une vision claire pour l\'avenir.',
                'election_year' => '2024',
                'slogan' => 'Ensemble pour un avenir meilleur',
                'priorities' => [
                    [
                        'id' => '1',
                        'title' => 'Éducation',
                        'description' => 'Améliorer l\'accès à l\'éducation pour tous les enfants de notre communauté.',
                        'image_url' => '/images/education.jpg',
                        'order' => 1,
                        'created_at' => now()->toISOString()
                    ],
                    [
                        'id' => '2',
                        'title' => 'Santé',
                        'description' => 'Renforcer les services de santé et améliorer l\'accès aux soins.',
                        'image_url' => '/images/sante.jpg',
                        'order' => 2,
                        'created_at' => now()->toISOString()
                    ],
                    [
                        'id' => '3',
                        'title' => 'Développement',
                        'description' => 'Promouvoir le développement économique et créer des emplois.',
                        'image_url' => '/images/developpement.jpg',
                        'order' => 3,
                        'created_at' => now()->toISOString()
                    ],
                    [
                        'id' => '4',
                        'title' => 'Environnement',
                        'description' => 'Protéger notre environnement et promouvoir le développement durable.',
                        'image_url' => '/images/environnement.jpg',
                        'order' => 4,
                        'created_at' => now()->toISOString()
                    ]
                ],
                'created_at' => now()->toISOString(),
                'updated_at' => now()->toISOString()
            ];

            return response()->json([
                'success' => true,
                'message' => 'Campagne récupérée avec succès',
                'data' => $campaign
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la récupération de la campagne',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Récupérer les priorités de la campagne
     */
    public function getPriorities(): JsonResponse
    {
        try {
            $priorities = [
                [
                    'id' => '1',
                    'title' => 'Éducation',
                    'description' => 'Améliorer l\'accès à l\'éducation pour tous les enfants de notre communauté.',
                    'image_url' => '/images/education.jpg',
                    'order' => 1,
                    'created_at' => now()->toISOString()
                ],
                [
                    'id' => '2',
                    'title' => 'Santé',
                    'description' => 'Renforcer les services de santé et améliorer l\'accès aux soins.',
                    'image_url' => '/images/sante.jpg',
                    'order' => 2,
                    'created_at' => now()->toISOString()
                ],
                [
                    'id' => '3',
                    'title' => 'Développement',
                    'description' => 'Promouvoir le développement économique et créer des emplois.',
                    'image_url' => '/images/developpement.jpg',
                    'order' => 3,
                    'created_at' => now()->toISOString()
                ],
                [
                    'id' => '4',
                    'title' => 'Environnement',
                    'description' => 'Protéger notre environnement et promouvoir le développement durable.',
                    'image_url' => '/images/environnement.jpg',
                    'order' => 4,
                    'created_at' => now()->toISOString()
                ]
            ];

            return response()->json([
                'success' => true,
                'message' => 'Priorités récupérées avec succès',
                'data' => $priorities
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la récupération des priorités',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
