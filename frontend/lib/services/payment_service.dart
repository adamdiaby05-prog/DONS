import 'package:dio/dio.dart';
import '../models/payment_network.dart';
import '../config/api_config.dart';
import 'barapay_service.dart';

class PaymentService {
  final Dio _dio;
  final String _baseUrl;
  final BarapayService _barapayService;

  PaymentService({
    Dio? dio,
    String? baseUrl,
  })  : _dio = dio ?? _createDio(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _barapayService = BarapayService();

  static Dio _createDio() {
    final dio = Dio();
    dio.options.connectTimeout = Duration(seconds: ApiConfig.connectTimeout);
    dio.options.receiveTimeout = Duration(seconds: ApiConfig.receiveTimeout);
    return dio;
  }

  // Initier un paiement
  Future<Map<String, dynamic>> initiatePayment({
    required PaymentNetwork network,
    required String phoneNumber,
    required int amount,
  }) async {
    try {
      // Utiliser le service Barapay pour créer le paiement
      final barapayResult = await _barapayService.createPayment(
        phoneNumber: phoneNumber,
        amount: amount,
        network: network.name,
      );

      // Vérifier que le résultat n'est pas null
      if (barapayResult == null) {
        throw Exception('Réponse du service Barapay invalide');
      }

      if (barapayResult['success'] == true) {
        // Vérifier si c'est un paiement Barapay avec redirection
        if (barapayResult['redirect_required'] == true && barapayResult['checkout_url'] != null) {
          // C'est un paiement Barapay RÉEL - rediriger vers l'URL de checkout
          return {
            'id': barapayResult['payment_id']?.toString() ?? 'unknown',
            'reference': barapayResult['reference'] ?? 'unknown',
            'status': 'pending',
            'amount': barapayResult['amount'] ?? amount,
            'phone_number': barapayResult['phone_number'] ?? phoneNumber,
            'payment_method': 'barapay',
            'created_at': barapayResult['created_at'] ?? DateTime.now().toIso8601String(),
            'checkout_url': barapayResult['checkout_url'],
            'redirect_required': true,
            'real_payment': true,
            'barapay_payment': true,
          };
        } else {
          // Paiement normal sans redirection
          return {
            'id': barapayResult['payment_id']?.toString() ?? 'unknown',
            'reference': barapayResult['reference'] ?? 'unknown',
            'status': barapayResult['status'] ?? 'pending',
            'amount': barapayResult['amount'] ?? amount,
            'phone_number': barapayResult['phone_number'] ?? phoneNumber,
            'payment_method': 'barapay',
            'created_at': barapayResult['created_at'] ?? DateTime.now().toIso8601String(),
            'redirect_required': false,
            'real_payment': false,
            'barapay_payment': false,
          };
        }
      } else {
        throw Exception('Erreur lors de la création du paiement Barapay');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'initiation du paiement: $e');
    }
  }

  // Convertir le nom du réseau en méthode de paiement
  String _getPaymentMethod(String networkName) {
    switch (networkName.toLowerCase()) {
      case 'orange money':
        return 'barapay'; // Utiliser Barapay pour tous les paiements
      case 'mtn money':
        return 'barapay';
      case 'airtel money':
        return 'barapay';
      case 'wave ci':
        return 'barapay';
      case 'moov money':
        return 'barapay';
      default:
        return 'barapay'; // Par défaut, utiliser Barapay
    }
  }

  // Vérifier le statut d'un paiement
  Future<Map<String, dynamic>> checkPaymentStatus(String paymentId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/payments/$paymentId/status',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception('Erreur lors de la vérification du statut');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de connexion: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  // Confirmer un paiement
  Future<Map<String, dynamic>> confirmPayment(String paymentId) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/payments/$paymentId/confirm',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception('Erreur lors de la confirmation du paiement');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de connexion: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  // Obtenir l'historique des paiements
  Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/payments/history',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      } else {
        throw Exception('Erreur lors de la récupération de l\'historique');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de connexion: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  // Simuler un paiement (pour les tests)
  Future<Map<String, dynamic>> simulatePayment({
    required PaymentNetwork network,
    required String phoneNumber,
    required double amount,
  }) async {
    // Simuler un délai de traitement
    await Future.delayed(const Duration(seconds: 2));
    
    // Retourner une réponse simulée
    return {
      'id': 'sim_${DateTime.now().millisecondsSinceEpoch}',
      'status': 'pending',
      'network': network.name,
      'phone_number': phoneNumber,
      'amount': amount,
      'currency': 'XOF',
      'created_at': DateTime.now().toIso8601String(),
      'reference': 'REF_${DateTime.now().millisecondsSinceEpoch}',
    };
  }
}
