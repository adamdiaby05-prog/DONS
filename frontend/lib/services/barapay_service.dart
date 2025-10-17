import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../utils/url_launcher.dart';

class BarapayService {
  final Dio _dio;
  final String _baseUrl;

  BarapayService({
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

  /// Créer un paiement Barapay
  Future<Map<String, dynamic>> createPayment({
    required String phoneNumber,
    required int amount,
    required String network,
  }) async {
    try {
      // Générer un numéro de commande unique
      final orderNo = 'DONS_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomId()}';
      
      // Préparer les données pour l'API
      final paymentData = {
        'amount': amount,
        'phone_number': phoneNumber,
        'payment_method': 'barapay',
        'status': 'pending',
        'order_no': orderNo,
        'network': network,
        'currency': 'XOF'
      };

      // Appeler l'API de sauvegarde qui intègre Barapay
      final response = await _dio.post(
        '$_baseUrl/api_save_payment_simple.php',
        data: paymentData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Log pour débogage
        print('DEBUG: Réponse du serveur reçue');
        print('DEBUG: Type de données: ${data.runtimeType}');
        print('DEBUG: Contenu: $data');
        
        // Vérifier que les données sont valides
        if (data == null) {
          throw Exception('Réponse du serveur invalide');
        }
        
        // Log détaillé pour débogage
        if (data is Map) {
          print('DEBUG: Clés disponibles dans la réponse: ${data.keys.toList()}');
          if (data['payment'] != null) {
            print('DEBUG: Payment object: ${data['payment']}');
          }
          if (data['data'] != null) {
            print('DEBUG: Data object: ${data['data']}');
          }
        }
        
        // Si la réponse est HTML (redirection Wave), la traiter comme un succès
        if (data is String && data.contains('<!DOCTYPE html>')) {
          return {
            'success': true,
            'payment_id': 'wave_redirect_${DateTime.now().millisecondsSinceEpoch}',
            'reference': 'wave_redirect_${DateTime.now().millisecondsSinceEpoch}',
            'barapay_reference': 'wave_redirect',
            'checkout_url': 'wave_redirect_detected',
            'amount': amount,
            'phone_number': phoneNumber,
            'network': network,
            'currency': 'XOF',
            'status': 'pending',
            'redirect_required': true,
            'real_payment': true,
            'barapay_payment': true,
            'created_at': DateTime.now().toIso8601String(),
          };
        }
        
        if (data['success'] == true) {
          print('DEBUG: Paiement réussi, traitement des données');
          
          // Vérifier si c'est un paiement Barapay avec URL de checkout
          if (data['checkout_url'] != null) {
            print('DEBUG: Redirection Wave détectée');
            
            // Extraction sécurisée des données de paiement
            String paymentId = 'unknown';
            String reference = 'unknown';
            
            if (data['payment'] != null && data['payment'] is Map) {
              paymentId = data['payment']['id']?.toString() ?? 'unknown';
              reference = data['payment']['payment_reference']?.toString() ?? paymentId;
            } else if (data['data'] != null && data['data'] is Map) {
              paymentId = data['data']['id']?.toString() ?? 'unknown';
              reference = paymentId;
            }
            
            // Ouvrir automatiquement l'URL Barapay
            if (data['checkout_url'] != null && data['checkout_url'].toString().isNotEmpty) {
              await openPaymentUrl(data['checkout_url'].toString());
            }
            
            return {
              'success': true,
              'payment_id': paymentId,
              'reference': reference,
              'barapay_reference': data['barapay_reference']?.toString() ?? 'unknown',
              'checkout_url': data['checkout_url'],
              'amount': amount,
              'phone_number': phoneNumber,
              'network': network,
              'currency': 'XOF',
              'status': 'pending',
              'redirect_required': true,
              'real_payment': true,
              'barapay_payment': true,
              'created_at': DateTime.now().toIso8601String(),
            };
          } else {
            print('DEBUG: Paiement normal sans redirection');
            
            // Extraction sécurisée des données de paiement
            String paymentId = 'unknown';
            String reference = 'unknown';
            String status = 'pending';
            
            if (data['payment'] != null && data['payment'] is Map) {
              paymentId = data['payment']['id']?.toString() ?? 'unknown';
              reference = data['payment']['payment_reference']?.toString() ?? paymentId;
              status = data['payment']['status']?.toString() ?? 'pending';
            } else if (data['data'] != null && data['data'] is Map) {
              paymentId = data['data']['id']?.toString() ?? 'unknown';
              reference = paymentId;
            }
            
            return {
              'success': true,
              'payment_id': paymentId,
              'reference': reference,
              'amount': amount,
              'phone_number': phoneNumber,
              'network': network,
              'currency': 'XOF',
              'status': status,
              'redirect_required': false,
              'real_payment': false,
              'barapay_payment': false,
              'created_at': DateTime.now().toIso8601String(),
            };
          }
        } else {
          // Gérer le cas où la réponse n'est pas au format JSON attendu
          if (data is String && data.contains('<!DOCTYPE html>')) {
            // C'est une redirection HTML vers Wave
            return {
              'success': true,
              'payment_id': 'wave_redirect_${DateTime.now().millisecondsSinceEpoch}',
              'reference': 'wave_redirect_${DateTime.now().millisecondsSinceEpoch}',
              'barapay_reference': 'wave_redirect',
              'checkout_url': 'wave_redirect_detected',
              'amount': amount,
              'phone_number': phoneNumber,
              'network': network,
              'currency': 'XOF',
              'status': 'pending',
              'redirect_required': true,
              'real_payment': true,
              'barapay_payment': true,
              'created_at': DateTime.now().toIso8601String(),
            };
          } else {
            // Gestion d'erreur plus robuste
            String errorMessage = 'Erreur lors de la création du paiement';
            if (data is Map && data['error'] != null) {
              errorMessage = data['error'].toString();
            } else if (data is String) {
              errorMessage = data;
            }
            print('DEBUG: Erreur du serveur: $errorMessage');
            throw Exception(errorMessage);
          }
        }
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
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
      print('DEBUG: Erreur générale: $e');
      print('DEBUG: Type d\'erreur: ${e.runtimeType}');
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Vérifier le statut d'un paiement Barapay
  Future<Map<String, dynamic>> checkPaymentStatus(String paymentId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api_payments_status.php',
        queryParameters: {'payment_id': paymentId},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Erreur lors de la vérification du statut');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de connexion: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Obtenir l'historique des paiements Barapay
  Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api_payments_history.php',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      } else {
        throw Exception('Erreur lors de la récupération de l\'historique');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de connexion: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Ouvrir l'URL de paiement Barapay
  Future<void> openPaymentUrl(String checkoutUrl) async {
    try {
      if (checkoutUrl.isNotEmpty) {
        if (checkoutUrl.startsWith('https://barapay.net/')) {
          // Ouvrir l'URL Barapay dans un nouvel onglet
          UrlLauncher.openBarapayUrl(checkoutUrl);
          print('URL Barapay ouverte: $checkoutUrl');
        } else {
          // Ouvrir toute autre URL
          UrlLauncher.openUrl(checkoutUrl);
          print('URL ouverte: $checkoutUrl');
        }
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'ouverture de l\'URL: $e');
    }
  }

  /// Générer un ID aléatoire
  String _generateRandomId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return '$timestamp$random';
  }

  /// Valider les données de paiement
  bool validatePaymentData({
    required String phoneNumber,
    required int amount,
    required String network,
  }) {
    // Valider le numéro de téléphone (format ivoirien)
    final phoneRegex = RegExp(r'^(\+225|225)?[0-9]{8}$');
    if (!phoneRegex.hasMatch(phoneNumber.replaceAll(' ', ''))) {
      return false;
    }

    // Valider le montant
    if (amount <= 0 || amount > 1000000) { // Max 1,000,000 FCFA
      return false;
    }

    // Valider le réseau
    final validNetworks = ['orange money', 'mtn money', 'wave ci', 'moov money'];
    if (!validNetworks.contains(network.toLowerCase())) {
      return false;
    }

    return true;
  }

  /// Formater le numéro de téléphone
  String formatPhoneNumber(String phoneNumber) {
    // Nettoyer le numéro
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    
    // Ajouter l'indicatif si nécessaire
    if (cleaned.startsWith('0')) {
      cleaned = '+225' + cleaned.substring(1);
    } else if (!cleaned.startsWith('+225') && !cleaned.startsWith('225')) {
      cleaned = '+225' + cleaned;
    }
    
    return cleaned;
  }

  /// Obtenir les informations du réseau
  Map<String, dynamic> getNetworkInfo(String networkName) {
    switch (networkName.toLowerCase()) {
      case 'orange money':
        return {
          'id': 'orange_money',
          'name': 'Orange Money',
          'logo': 'assets/images/orange.jpg',
          'color': 0xFFFFA500,
          'description': 'Orange Money - Paiement mobile'
        };
      case 'mtn money':
        return {
          'id': 'mtn_money',
          'name': 'MTN MoMo',
          'logo': 'assets/images/mtn.jpg',
          'color': 0xFFFFD700,
          'description': 'MTN Mobile Money'
        };
      case 'wave ci':
        return {
          'id': 'wave_ci',
          'name': 'WAVE CI',
          'logo': 'assets/images/Wave.jpg',
          'color': 0xFF87CEEB,
          'description': 'Wave CI - Paiement mobile'
        };
      case 'moov money':
        return {
          'id': 'moov_money',
          'name': 'MOOV Money',
          'logo': 'assets/images/moov.jpg',
          'color': 0xFF87CEEB,
          'description': 'Moov Money - Paiement mobile'
        };
      default:
        return {
          'id': 'barapay',
          'name': 'Barapay',
          'logo': 'assets/images/Wave.jpg',
          'color': 0xFF87CEEB,
          'description': 'Barapay - Paiement mobile'
        };
    }
  }
}
