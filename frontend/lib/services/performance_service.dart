import 'dart:async';
import 'package:dio/dio.dart';

class PerformanceService {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 2),
    receiveTimeout: const Duration(seconds: 3),
  ));

  // Test de performance de l'API
  static Future<Map<String, dynamic>> testApiPerformance() async {
    final results = <String, dynamic>{};
    
    // Test de connectivité
    final connectivityStart = DateTime.now();
    try {
      final response = await _dio.get('http://localhost:8000/api/test');
      final connectivityEnd = DateTime.now();
      results['connectivity'] = {
        'success': true,
        'time': connectivityEnd.difference(connectivityStart).inMilliseconds,
        'status': response.statusCode,
      };
    } catch (e) {
      results['connectivity'] = {
        'success': false,
        'error': e.toString(),
      };
    }

    // Test de performance des paiements
    final paymentStart = DateTime.now();
    try {
      final response = await _dio.get('http://192.168.100.7:8000/api/payments/test');
      final paymentEnd = DateTime.now();
      results['payments'] = {
        'success': true,
        'time': paymentEnd.difference(paymentStart).inMilliseconds,
        'status': response.statusCode,
      };
    } catch (e) {
      results['payments'] = {
        'success': false,
        'error': e.toString(),
      };
    }

    return results;
  }

  // Optimiser les requêtes
  static void optimizeRequests() {
    // Configuration optimisée pour les requêtes
    _dio.options.headers.addAll({
      'Connection': 'keep-alive',
      'Cache-Control': 'no-cache',
      'Pragma': 'no-cache',
    });
  }

  // Test de latence réseau
  static Future<int> testLatency() async {
    final start = DateTime.now();
    try {
      await _dio.get('http://192.168.100.7:8000');
      final end = DateTime.now();
      return end.difference(start).inMilliseconds;
    } catch (e) {
      return -1; // Erreur
    }
  }
}




