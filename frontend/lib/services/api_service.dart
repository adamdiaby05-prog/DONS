import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';
  late Dio _dio;
  String? _token;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 5),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Token expiré, rediriger vers la connexion
          _clearToken();
        }
        handler.next(error);
      },
    ));

    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Authentification
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _dio.post('/register', data: {
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phoneNumber,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

      // Gérer le cas où success est un int (1) ou un bool (true)
      final success = response.data['success'];
      if (success == 1 || success == true) {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de l\'inscription');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/login', data: {
        'phone_number': phoneNumber,
        'password': password,
      });

      // Gérer le cas où success est un int (1) ou un bool (true)
      final success = response.data['success'];
      if ((success == 1 || success == true) && response.data['token'] != null) {
        await _saveToken(response.data['token']);
      }

      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    try {
      final response = await _dio.post('/send-otp', data: {
        'phone_number': phoneNumber,
      });

      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    try {
      final response = await _dio.post('/verify-otp', data: {
        'phone_number': phoneNumber,
        'otp_code': otpCode,
      });

      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/logout');
      await _clearToken();
    } on DioException catch (e) {
      // Même en cas d'erreur, on supprime le token local
      await _clearToken();
      throw _handleDioError(e);
    }
  }

  // Groupes
  Future<List<dynamic>> getGroups() async {
    try {
      final response = await _dio.get('/groups');
      return response.data['groups'];
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> createGroup({
    required String name,
    String? description,
    required String type,
    required double contributionAmount,
    required String frequency,
    required String paymentMode,
    required DateTime nextDueDate,
  }) async {
    try {
      final response = await _dio.post('/groups', data: {
        'name': name,
        'description': description,
        'type': type,
        'contribution_amount': contributionAmount,
        'frequency': frequency,
        'payment_mode': paymentMode,
        'next_due_date': nextDueDate.toIso8601String(),
      });

      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getGroup(int groupId) async {
    try {
      final response = await _dio.get('/groups/$groupId');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> updateGroup({
    required int groupId,
    String? name,
    String? description,
    double? contributionAmount,
    String? frequency,
    String? paymentMode,
    DateTime? nextDueDate,
    bool? isActive,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (contributionAmount != null) data['contribution_amount'] = contributionAmount;
      if (frequency != null) data['frequency'] = frequency;
      if (paymentMode != null) data['payment_mode'] = paymentMode;
      if (nextDueDate != null) data['next_due_date'] = nextDueDate.toIso8601String();
      if (isActive != null) data['is_active'] = isActive;

      final response = await _dio.put('/groups/$groupId', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> addMember({
    required int groupId,
    required String phoneNumber,
    required String role,
  }) async {
    try {
      final response = await _dio.post('/groups/$groupId/members', data: {
        'phone_number': phoneNumber,
        'role': role,
      });

      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> removeMember({
    required int groupId,
    required int userId,
  }) async {
    try {
      final response = await _dio.delete('/groups/$groupId/members', data: {
        'user_id': userId,
      });

      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getGroupDashboard(int groupId) async {
    try {
      final response = await _dio.get('/groups/$groupId/dashboard');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Profil utilisateur
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _dio.get('/user');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Vérifier si l'utilisateur est connecté
  bool get isAuthenticated => _token != null;

  Exception _handleDioError(DioException e) {
    if (e.response?.data != null) {
      final errorData = e.response!.data;
      if (errorData['message'] != null) {
        return Exception(errorData['message']);
      }
    }
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Délai d\'attente dépassé. Vérifiez votre connexion.');
      case DioExceptionType.connectionError:
        return Exception('Erreur de connexion. Vérifiez votre connexion internet.');
      default:
        return Exception('Une erreur est survenue. Veuillez réessayer.');
    }
  }
}
