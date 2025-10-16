import 'package:dio/dio.dart';
import '../models/campaign.dart';
import '../config/api_config.dart';

class CampaignService {
  final Dio _dio;
  final String _baseUrl;

  CampaignService({
    Dio? dio,
    String? baseUrl,
  })  : _dio = dio ?? _createDio(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  static Dio _createDio() {
    return Dio(BaseOptions(
      connectTimeout: Duration(seconds: ApiConfig.connectTimeout),
      receiveTimeout: Duration(seconds: ApiConfig.receiveTimeout),
      headers: ApiConfig.defaultHeaders,
    ));
  }

  // Récupérer les informations de la campagne
  Future<Campaign> getCampaign() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/campaign',
        options: Options(
          headers: ApiConfig.defaultHeaders,
        ),
      );

      if (response.statusCode == 200) {
        return Campaign.fromJson(response.data['data']);
      } else {
        throw Exception('Erreur lors de la récupération de la campagne');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Retourner des données par défaut si la campagne n'existe pas
        return _getDefaultCampaign();
      }
      throw Exception('Erreur de connexion: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  // Récupérer les priorités de la campagne
  Future<List<Priority>> getPriorities() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/campaign/priorities',
        options: Options(
          headers: ApiConfig.defaultHeaders,
        ),
      );

      if (response.statusCode == 200) {
        return (response.data['data'] as List)
            .map((priority) => Priority.fromJson(priority))
            .toList();
      } else {
        throw Exception('Erreur lors de la récupération des priorités');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de connexion: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  // Données par défaut pour la campagne
  Campaign _getDefaultCampaign() {
    return Campaign(
      id: '1',
      candidateName: 'Ahoua Don Mello',
      candidatePhoto: 'https://via.placeholder.com/300x400/1e3a8a/ffffff?text=ADM',
      biography: 'Ahoua Don Mello, né le 23 juin 1958 à Bongouanou, est un enseignant-chercheur et homme politique ivoirien. Il a été directeur du Bureau national d\'études techniques et de développement (BNETD) de 2000 à 2011. Il est candidat à l\'élection présidentielle de 2025.',
      electionYear: '2025',
      slogan: 'SOUVERAINETÉ - ÉGALITÉ - JUSTICE',
      priorities: [
        Priority(
          id: '1',
          title: 'L\'Éducation pour tous',
          description: 'Garantir un accès équitable à une éducation de qualité pour tous les Ivoiriens, de la maternelle à l\'université.',
          imageUrl: 'https://via.placeholder.com/400x250/3b82f6/ffffff?text=Education',
          order: 1,
          createdAt: DateTime.now(),
        ),
        Priority(
          id: '2',
          title: 'Les meilleurs centres de santé',
          description: 'Développer un système de santé moderne et accessible à tous, avec des infrastructures de pointe.',
          imageUrl: 'https://via.placeholder.com/400x250/ef4444/ffffff?text=Sante',
          order: 2,
          createdAt: DateTime.now(),
        ),
        Priority(
          id: '3',
          title: 'Emploi et développement économique',
          description: 'Créer des opportunités d\'emploi durables et stimuler la croissance économique du pays.',
          imageUrl: 'https://via.placeholder.com/400x250/10b981/ffffff?text=Economie',
          order: 3,
          createdAt: DateTime.now(),
        ),
        Priority(
          id: '4',
          title: 'Infrastructure et modernisation',
          description: 'Moderniser les infrastructures du pays pour améliorer la qualité de vie des citoyens.',
          imageUrl: 'https://via.placeholder.com/400x250/f59e0b/ffffff?text=Infrastructure',
          order: 4,
          createdAt: DateTime.now(),
        ),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
