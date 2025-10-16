import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OptimizedApiService {
  static const String baseUrl = 'http://localhost:8000/api';
  late Dio _dio;
  String? _token;

  OptimizedApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 3),
      receiveTimeout: const Duration(seconds: 5),
      sendTimeout: const Duration(seconds: 3),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
      },
    ));

    // Intercepteur pour optimiser les requêtes
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Ajouter le token si disponible
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        
        // Optimiser les headers
        options.headers['X-Requested-With'] = 'XMLHttpRequest';
        options.headers['Accept-Encoding'] = 'gzip, deflate';
        
        handler.next(options);
      },
      onResponse: (response, handler) {
        // Log rapide des réponses
        print('✅ API Response: ${response.statusCode} - ${response.requestOptions.path}');
        handler.next(response);
      },
      onError: (error, handler) {
        // Gestion d'erreur optimisée
        print('❌ API Error: ${error.message}');
        
        if (error.response?.statusCode == 401) {
          _clearToken();
        }
        
        // Retry automatique pour les erreurs de réseau
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          print('🔄 Retry automatique...');
          // Implémenter retry si nécessaire
        }
        
        handler.next(error);
      },
    ));

    _loadToken();
  }

  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
    } catch (e) {
      print('Erreur chargement token: $e');
    }
  }

  Future<void> _saveToken(String token) async {
    _token = token;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
    } catch (e) {
      print('Erreur sauvegarde token: $e');
    }
  }

  Future<void> _clearToken() async {
    _token = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
    } catch (e) {
      print('Erreur suppression token: $e');
    }
  }

  // Test de connexion rapide
  Future<bool> testConnection() async {
    try {
      final response = await _dio.get('/test');
      return response.statusCode == 200;
    } catch (e) {
      print('Test connexion échoué: $e');
      return false;
    }
  }

  // Initier un paiement optimisé
  Future<Map<String, dynamic>> initiatePayment({
    required double amount,
    required String phoneNumber,
    required String network,
  }) async {
    try {
      final response = await _dio.post('/payments/initiate', 
        data: {
          'amount': amount,
          'phone_number': phoneNumber,
          'network': network,
        }
      );
      
      return response.data;
    } catch (e) {
      print('Erreur paiement: $e');
      rethrow;
    }
  }

  // Vérifier le statut d'un paiement
  Future<Map<String, dynamic>> checkPaymentStatus(String paymentId) async {
    try {
      final response = await _dio.get('/payments/$paymentId');
      
      return response.data;
    } catch (e) {
      print('Erreur statut paiement: $e');
      rethrow;
    }
  }
}




