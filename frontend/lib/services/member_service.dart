import 'package:dio/dio.dart';
import '../models/user.dart';
import '../models/group.dart';

class MemberService {
  final Dio _dio;
  final String _baseUrl;

  MemberService({required Dio dio, required String baseUrl})
      : _dio = dio,
        _baseUrl = baseUrl;

  /// Récupérer tous les membres
  Future<List<User>> getAllMembers() async {
    try {
      final response = await _dio.get('/admin/members');
      if (response.data == null) {
        throw Exception('Réponse vide du serveur');
      }
      
      final success = response.data['success'];
      if (success == 1 || success == true) {
        final data = response.data['data'];
        if (data == null) {
          throw Exception('Données manquantes dans la réponse du serveur');
        }
        return List<User>.from(data.map((x) => User.fromJson(x)));
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de la récupération des membres');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('API non trouvée - Vérifiez que le serveur Laravel est démarré');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Erreur serveur - Vérifiez les logs Laravel');
      }
      throw Exception('Erreur de connexion: ${e.message}');
    } catch (e) {
      throw Exception('Erreur lors de la récupération des membres: $e');
    }
  }

  /// Récupérer un membre spécifique
  Future<User> getMember(int id) async {
    try {
      final response = await _dio.get('/admin/members/$id');
      if (response.data == null) {
        throw Exception('Réponse vide du serveur');
      }
      
      final success = response.data['success'];
      if (success == 1 || success == true) {
        final data = response.data['data'];
        if (data == null) {
          throw Exception('Données manquantes dans la réponse du serveur');
        }
        return User.fromJson(data);
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de la récupération du membre');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Membre non trouvé');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Erreur serveur - Vérifiez les logs Laravel');
      }
      throw Exception('Erreur de connexion: ${e.message}');
    } catch (e) {
      throw Exception('Erreur lors de la récupération du membre: $e');
    }
  }

  /// Créer un nouveau membre
  Future<User> createMember(Map<String, dynamic> memberData) async {
    try {
      final response = await _dio.post('/admin/members', data: memberData);
      if (response.data == null) {
        throw Exception('Réponse vide du serveur');
      }
      
      final success = response.data['success'];
      if (success == 1 || success == true) {
        final data = response.data['data'];
        if (data == null) {
          throw Exception('Données manquantes dans la réponse du serveur');
        }
        return User.fromJson(data);
      } else {
        final errors = response.data['errors'];
        if (errors != null) {
          final errorMessages = <String>[];
          errors.forEach((key, value) {
            if (value is List) {
              errorMessages.addAll(value.cast<String>());
            }
          });
          throw Exception('Erreur de validation: ${errorMessages.join(', ')}');
        }
        throw Exception(response.data['message'] ?? 'Erreur lors de la création du membre');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'];
        if (errors != null) {
          final errorMessages = <String>[];
          errors.forEach((key, value) {
            if (value is List) {
              errorMessages.addAll(value.cast<String>());
            }
          });
          throw Exception('Erreur de validation: ${errorMessages.join(', ')}');
        }
      }
      throw Exception('Erreur lors de la création du membre: ${e.message}');
    } catch (e) {
      throw Exception('Erreur lors de la création du membre: $e');
    }
  }

  /// Mettre à jour un membre
  Future<User> updateMember(int id, Map<String, dynamic> memberData) async {
    try {
      final response = await _dio.put('/admin/members/$id', data: memberData);
      if (response.data == null) {
        throw Exception('Réponse vide du serveur');
      }
      
      final success = response.data['success'];
      if (success == 1 || success == true) {
        final data = response.data['data'];
        if (data == null) {
          throw Exception('Données manquantes dans la réponse du serveur');
        }
        return User.fromJson(data);
      } else {
        final errors = response.data['errors'];
        if (errors != null) {
          final errorMessages = <String>[];
          errors.forEach((key, value) {
            if (value is List) {
              errorMessages.addAll(value.cast<String>());
            }
          });
          throw Exception('Erreur de validation: ${errorMessages.join(', ')}');
        }
        throw Exception(response.data['message'] ?? 'Erreur lors de la mise à jour du membre');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Membre non trouvé');
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'];
        if (errors != null) {
          final errorMessages = <String>[];
          errors.forEach((key, value) {
            if (value is List) {
              errorMessages.addAll(value.cast<String>());
            }
          });
          throw Exception('Erreur de validation: ${errorMessages.join(', ')}');
        }
      }
      throw Exception('Erreur lors de la mise à jour du membre: ${e.message}');
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du membre: $e');
    }
  }

  /// Supprimer un membre
  Future<void> deleteMember(int id) async {
    try {
      final response = await _dio.delete('/admin/members/$id');
      if (response.data == null) {
        throw Exception('Réponse vide du serveur');
      }
      
      final success = response.data['success'];
      if (success != 1 && success != true) {
        throw Exception(response.data['message'] ?? 'Erreur lors de la suppression du membre');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Membre non trouvé');
      }
      throw Exception('Erreur lors de la suppression du membre: ${e.message}');
    } catch (e) {
      throw Exception('Erreur lors de la suppression du membre: $e');
    }
  }

  /// Récupérer les groupes disponibles
  Future<List<Group>> getAvailableGroups() async {
    try {
      final response = await _dio.get('/admin/members/available-groups');
      if (response.data == null) {
        throw Exception('Réponse vide du serveur');
      }
      
      final success = response.data['success'];
      if (success == 1 || success == true) {
        final data = response.data['data'];
        if (data == null) {
          throw Exception('Données manquantes dans la réponse du serveur');
        }
        return List<Group>.from(data.map((x) => Group.fromJson(x)));
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de la récupération des groupes');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('API non trouvée - Vérifiez que le serveur Laravel est démarré');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Erreur serveur - Vérifiez les logs Laravel');
      }
      throw Exception('Erreur de connexion: ${e.message}');
    } catch (e) {
      throw Exception('Erreur lors de la récupération des groupes: $e');
    }
  }

  /// Ajouter un membre à un groupe
  Future<void> addMemberToGroup(int userId, int groupId, {String role = 'member'}) async {
    try {
      final response = await _dio.post('/admin/members/add-to-group', data: {
        'user_id': userId,
        'group_id': groupId,
        'role': role,
      });
      
      if (response.data == null) {
        throw Exception('Réponse vide du serveur');
      }
      
      final success = response.data['success'];
      if (success != 1 && success != true) {
        throw Exception(response.data['message'] ?? 'Erreur lors de l\'ajout au groupe');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Le membre est déjà dans ce groupe');
      }
      throw Exception('Erreur lors de l\'ajout au groupe: ${e.message}');
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout au groupe: $e');
    }
  }

  /// Retirer un membre d'un groupe
  Future<void> removeMemberFromGroup(int userId, int groupId) async {
    try {
      final response = await _dio.post('/admin/members/remove-from-group', data: {
        'user_id': userId,
        'group_id': groupId,
      });
      
      if (response.data == null) {
        throw Exception('Réponse vide du serveur');
      }
      
      final success = response.data['success'];
      if (success != 1 && success != true) {
        throw Exception(response.data['message'] ?? 'Erreur lors du retrait du groupe');
      }
    } on DioException catch (e) {
      throw Exception('Erreur lors du retrait du groupe: ${e.message}');
    } catch (e) {
      throw Exception('Erreur lors du retrait du groupe: $e');
    }
  }
} 