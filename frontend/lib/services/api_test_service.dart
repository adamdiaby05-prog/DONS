import 'package:dio/dio.dart';
import '../config/api_config.dart';

class ApiTestService {
  final Dio _dio;
  final String _baseUrl;

  ApiTestService({
    Dio? dio,
    String? baseUrl,
  })  : _dio = dio ?? _createDio(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  static Dio _createDio() {
    final dio = Dio();
    dio.options.connectTimeout = Duration(seconds: 5);
    dio.options.receiveTimeout = Duration(seconds: 5);
    return dio;
  }

  // Tester la connexion à l'API
  Future<bool> testConnection() async {
    try {
      // Utiliser directement notre serveur simple PHP
      final response = await _dio.get(
        'http://localhost:8000/api/test',
        options: Options(
          headers: ApiConfig.defaultHeaders,
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Tester l'endpoint des paiements
  Future<bool> testPaymentsEndpoint() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/payments/test',
        options: Options(
          headers: ApiConfig.defaultHeaders,
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Obtenir les informations de connexion
  Future<Map<String, dynamic>> getConnectionInfo() async {
    try {
      // Utiliser directement notre serveur simple PHP
      final response = await _dio.get(
        'http://localhost:8000/api/test',
        options: Options(
          headers: ApiConfig.defaultHeaders,
        ),
      );

      if (response.statusCode == 200) {
        return {
          'connected': true,
          'data': response.data,
          'url': 'http://localhost:8000',
        };
      } else {
        return {
          'connected': false,
          'error': 'Status code: ${response.statusCode}',
          'url': 'http://localhost:8000',
        };
      }
    } catch (e) {
      return {
        'connected': false,
        'error': e.toString(),
        'url': 'http://localhost:8000',
      };
    }
  }
} 