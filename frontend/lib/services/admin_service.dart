import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/admin_dashboard.dart';
import '../models/group.dart';
import '../models/user.dart';
import '../models/contribution.dart';
import '../models/payment.dart';

class AdminService {
  final Dio _dio;
  final String _baseUrl;

  AdminService({required Dio dio, required String baseUrl})
      : _dio = dio,
        _baseUrl = baseUrl;

  // Récupérer le tableau de bord administrateur
  Future<AdminDashboard> getDashboard() async {
    try {
      final response = await _dio.get('/admin/dashboard');
      
      // Vérifier que la réponse existe et a le bon format
      if (response.data == null) {
        throw Exception('Réponse vide du serveur');
      }
      
      // Gérer le cas où success est un int (1) ou un bool (true)
      final success = response.data['success'];
      if (success == 1 || success == true) {
        final data = response.data['data'];
        if (data == null) {
          throw Exception('Données manquantes dans la réponse du serveur');
        }
        return AdminDashboard.fromJson(data);
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de la récupération du tableau de bord');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('API non trouvée - Vérifiez que le serveur Laravel est démarré');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Erreur serveur - Vérifiez les logs Laravel');
      }
      throw Exception('Erreur de connexion: ${e.message}');
    } catch (e) {
      throw Exception('Erreur lors de la récupération du tableau de bord: $e');
    }
  }

  // Lister tous les groupes
  Future<List<Group>> getAllGroups() async {
    try {
      final response = await _dio.get('/admin/groups');
      
      // Gérer le cas où success est un int (1) ou un bool (true)
      final success = response.data['success'];
      if (success == 1 || success == true) {
        return (response.data['groups'] as List)
            .map((json) => Group.fromJson(json))
            .toList();
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de la récupération des groupes');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des groupes: $e');
    }
  }

  // Créer un nouveau groupe
  Future<Group> createGroup(Map<String, dynamic> groupData) async {
    try {
      final response = await _dio.post(
        '/admin/groups',
        data: groupData,
      );
      
      // Gérer le cas où success est un int (1) ou un bool (true)
      final success = response.data['success'];
      if (success == 1 || success == true) {
        return Group.fromJson(response.data['group']);
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de la création du groupe');
      }
    } catch (e) {
      throw Exception('Erreur lors de la création du groupe: $e');
    }
  }

  // Mettre à jour un groupe
  Future<Group> updateGroup(int groupId, Map<String, dynamic> groupData) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/api/admin/groups/$groupId',
        data: groupData,
      );
      return Group.fromJson(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du groupe: $e');
    }
  }

  // Supprimer un groupe
  Future<void> deleteGroup(int groupId) async {
    try {
      await _dio.delete('/admin/groups/$groupId');
    } catch (e) {
      throw Exception('Erreur lors de la suppression du groupe: $e');
    }
  }

  // Lister tous les membres d'un groupe
  Future<List<User>> getGroupMembers(int groupId) async {
    try {
      final response = await _dio.get('$_baseUrl/api/admin/groups/$groupId/members');
      return (response.data['data'] as List)
          .map((json) => User.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des membres: $e');
    }
  }

  // Ajouter un membre à un groupe
  Future<void> addMemberToGroup(int groupId, int userId, String role) async {
    try {
      await _dio.post(
        '$_baseUrl/api/admin/groups/$groupId/members',
        data: {
          'user_id': userId,
          'role': role,
        },
      );
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du membre: $e');
    }
  }

  // Supprimer un membre d'un groupe
  Future<void> removeMemberFromGroup(int groupId, int userId) async {
    try {
      await _dio.delete(
        '$_baseUrl/api/admin/groups/$groupId/members',
        data: {'user_id': userId},
      );
    } catch (e) {
      throw Exception('Erreur lors de la suppression du membre: $e');
    }
  }

  // Lister toutes les cotisations
  Future<List<Contribution>> getAllContributions() async {
    try {
      final response = await _dio.get('$_baseUrl/api/admin/contributions');
      return (response.data['data'] as List)
          .map((json) => Contribution.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des cotisations: $e');
    }
  }

  // Lister tous les paiements
  Future<List<Payment>> getAllPayments() async {
    try {
      final response = await _dio.get('$_baseUrl/api/admin/payments');
      return (response.data['data'] as List)
          .map((json) => Payment.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des paiements: $e');
    }
  }

  // Générer des cotisations pour un groupe
  Future<void> generateContributions(int groupId, DateTime dueDate) async {
    try {
      await _dio.post(
        '$_baseUrl/api/admin/groups/$groupId/generate-contributions',
        data: {'due_date': dueDate.toIso8601String()},
      );
    } catch (e) {
      throw Exception('Erreur lors de la génération des cotisations: $e');
    }
  }

  // Exporter les données en Excel
  Future<String> exportToExcel(String type, Map<String, dynamic> filters) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/admin/export/$type',
        data: filters,
      );
      return response.data['download_url'];
    } catch (e) {
      throw Exception('Erreur lors de l\'export: $e');
    }
  }

  // Obtenir les statistiques détaillées
  Future<Map<String, dynamic>> getDetailedStats(Map<String, dynamic> filters) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/admin/stats',
        queryParameters: filters,
      );
      return response.data;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des statistiques: $e');
    }
  }
}
