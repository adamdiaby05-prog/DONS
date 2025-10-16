import 'package:dio/dio.dart';
import '../config/environment.dart';
import '../config/api_config.dart';

class ConnectionDiagnosticService {
  final Dio _dio;
  
  ConnectionDiagnosticService({Dio? dio}) : _dio = dio ?? _createDio();

  static Dio _createDio() {
    final dio = Dio();
    dio.options.connectTimeout = Duration(seconds: 5);
    dio.options.receiveTimeout = Duration(seconds: 5);
    return dio;
  }

  // Tester la connexion à l'API
  Future<Map<String, dynamic>> diagnoseConnection() async {
    final results = <String, dynamic>{};
    
    // Tester l'endpoint principal (notre serveur simple PHP)
    results['main_api'] = await _testEndpoint('http://localhost:8000/api/test');
    
    // Tester l'endpoint des paiements (notre serveur simple PHP)
    results['payments_api'] = await _testPaymentEndpoint('http://localhost:8000/api_save_payment.php');
    
    // Informations générales
    results['environment'] = 'Serveur PHP Simple';
    results['base_url'] = 'http://localhost:8000';
    results['timestamp'] = DateTime.now().toIso8601String();
    
    return results;
  }

  // Tester un endpoint spécifique
  Future<Map<String, dynamic>> _testEndpoint(String url) async {
    try {
      final response = await _dio.get(
        url,
        options: Options(
          headers: ApiConfig.defaultHeaders,
        ),
      );

      return {
        'status': 'success',
        'status_code': response.statusCode,
        'response_time': '${response.requestOptions.connectTimeout?.inMilliseconds ?? 0}ms',
        'data': response.data,
      };
    } on DioException catch (e) {
      return {
        'status': 'error',
        'error_type': e.type.toString(),
        'error_message': e.message,
        'status_code': e.response?.statusCode,
      };
    } catch (e) {
      return {
        'status': 'error',
        'error_type': 'unknown',
        'error_message': e.toString(),
      };
    }
  }

  // Tester l'endpoint de paiement avec POST
  Future<Map<String, dynamic>> _testPaymentEndpoint(String url) async {
    try {
      final response = await _dio.post(
        url,
        data: {
          'amount': 1000,
          'phone_number': '0701234567',
          'payment_method': 'orange_money',
          'status': 'completed'
        },
        options: Options(
          headers: ApiConfig.defaultHeaders,
        ),
      );

      return {
        'status': 'success',
        'status_code': response.statusCode,
        'response_time': '${response.requestOptions.connectTimeout?.inMilliseconds ?? 0}ms',
        'data': response.data,
      };
    } on DioException catch (e) {
      return {
        'status': 'error',
        'error_type': e.type.toString(),
        'error_message': e.message,
        'status_code': e.response?.statusCode,
      };
    } catch (e) {
      return {
        'status': 'error',
        'error_type': 'unknown',
        'error_message': e.toString(),
      };
    }
  }

  // Obtenir des suggestions de résolution
  List<String> getResolutionSuggestions(Map<String, dynamic> diagnosis) {
    final suggestions = <String>[];
    
    if (diagnosis['main_api']['status'] == 'error') {
      suggestions.add('Vérifiez que le serveur PHP est démarré (php -S 0.0.0.0:8000 test_simple.php)');
      suggestions.add('Vérifiez que le serveur écoute sur le port 8000');
      suggestions.add('Vérifiez que le pare-feu n\'empêche pas la connexion');
    }
    
    if (diagnosis['payments_api']['status'] == 'error') {
      suggestions.add('Vérifiez que l\'API de sauvegarde des paiements est accessible');
      suggestions.add('Vérifiez que la base de données PostgreSQL est accessible');
    }
    
    if (suggestions.isEmpty) {
      suggestions.add('La connexion semble fonctionner correctement');
    }
    
    return suggestions;
  }
} 