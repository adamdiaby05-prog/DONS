import 'package:dio/dio.dart';
import '../models/payment_network.dart';
import '../config/api_config.dart';

class PaymentService {
  final Dio _dio;
  final String _baseUrl;

  PaymentService({
    Dio? dio,
    String? baseUrl,
  })  : _dio = dio ?? _createDio(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl;

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
      // Utiliser notre API de sauvegarde des paiements
      final response = await _dio.post(
        'http://localhost:8000/api_save_payment.php',
        data: {
          'amount': amount,
          'phone_number': phoneNumber,
          'payment_method': _getPaymentMethod(network.name),
          'status': 'completed',
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Vérifier si c'est un paiement Barapay avec redirection
        if (response.data['success'] == true && response.data['checkout_url'] != null) {
          // C'est un paiement Barapay RÉEL - rediriger vers l'URL de checkout
          final checkoutUrl = response.data['checkout_url'];
          final paymentData = response.data['payment'];
          
          // Ouvrir l'URL de paiement Barapay dans une nouvelle fenêtre/onglet
          // Note: En web, cela ouvrira dans un nouvel onglet
          // En mobile, cela ouvrira l'application de paiement par défaut
          if (checkoutUrl.isNotEmpty) {
            // Pour Flutter Web, nous devons utiliser url_launcher
            // Mais d'abord, retournons les données avec l'URL de redirection
            return {
              'id': paymentData['id'].toString(),
              'reference': paymentData['barapay_reference'] ?? paymentData['id'],
              'status': 'pending',
              'amount': paymentData['amount'],
              'phone_number': paymentData['phone_number'],
              'payment_method': paymentData['payment_method'],
              'created_at': DateTime.now().toIso8601String(),
              'checkout_url': checkoutUrl,
              'redirect_required': true,
              'real_payment': true,
              'barapay_payment': true,
            };
          }
        }
        
        // Retourner les données dans le format attendu (paiement normal)
        final paymentData = response.data['payment'] ?? response.data;
        return {
          'id': paymentData['id'].toString(),
          'reference': paymentData['payment_reference'] ?? paymentData['id'],
          'status': paymentData['status'],
          'amount': paymentData['amount'],
          'phone_number': paymentData['phone_number'],
          'payment_method': paymentData['payment_method'],
          'created_at': DateTime.now().toIso8601String(),
        };
      } else {
        throw Exception('Erreur lors de l\'initiation du paiement: ${response.statusCode}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Erreur de connexion';
      
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage = 'Délai de connexion dépassé. Vérifiez votre connexion internet.';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Délai de réception dépassé. Le serveur met trop de temps à répondre.';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'Impossible de se connecter au serveur. Vérifiez que le backend est démarré.';
          break;
        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 422) {
            errorMessage = 'Données invalides. Vérifiez les informations saisies.';
          } else if (e.response?.statusCode == 500) {
            errorMessage = 'Erreur serveur. Veuillez réessayer plus tard.';
          } else {
            errorMessage = 'Erreur serveur: ${e.response?.statusCode}';
          }
          break;
        default:
          errorMessage = 'Erreur de connexion: ${e.message}';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  // Convertir le nom du réseau en méthode de paiement
  String _getPaymentMethod(String networkName) {
    switch (networkName.toLowerCase()) {
      case 'orange money':
        return 'orange_money';
      case 'mtn money':
        return 'mtn_money';
      case 'airtel money':
        return 'airtel_money';
      default:
        return 'mobile_money';
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
