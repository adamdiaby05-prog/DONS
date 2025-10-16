import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../models/payment.dart';

class BarapayService {
  // Configuration de l'API Barapay
  static const String _baseUrl = 'http://localhost:8000'; // Ton serveur PHP
  static const String _apiKey = 'wjb7lzQVialbcwMNTPD1IojrRzPIIl';
  static const String _apiSecret = 'eXSMVquRfnUi6u5epkKFbxym1bZxSjgfHMxJlGGKq9j1amulx97Cj4QB7vZFzuyRUm4UC9mCHYhfzWn34arIyW4G2EU9vcdcQsb1';

  /// Créer un paiement Barapay
  static Future<BarapayPaymentResponse> createPayment({
    required double amount,
    required String phoneNumber,
    String? description,
    String? orderId,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/api_save_payment.php');
      
      final requestData = {
        'amount': amount.toInt(),
        'phone_number': phoneNumber,
        'payment_method': 'PayMoney',
        'description': description ?? 'Paiement DONS - ${amount.toInt()} FCFA',
        'order_id': orderId ?? 'DONS-${DateTime.now().millisecondsSinceEpoch}',
      };

      print('🚀 Création paiement Barapay: $requestData');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      print('📡 Réponse Barapay: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          return BarapayPaymentResponse(
            success: true,
            paymentId: data['payment']['id'],
            checkoutUrl: data['checkout_url'],
            reference: data['barapay_reference'],
            message: data['message'],
            payment: Payment.fromJson(data['payment']),
          );
        } else {
          return BarapayPaymentResponse(
            success: false,
            error: data['error'] ?? 'Erreur inconnue',
          );
        }
      } else {
        return BarapayPaymentResponse(
          success: false,
          error: 'Erreur serveur: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Erreur Barapay: $e');
      return BarapayPaymentResponse(
        success: false,
        error: 'Erreur de connexion: $e',
      );
    }
  }

  /// Ouvrir la page de paiement Barapay
  static Future<bool> openPaymentPage(String checkoutUrl) async {
    try {
      final uri = Uri.parse(checkoutUrl);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.inAppWebView,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );
        return true;
      } else {
        print('❌ Impossible d\'ouvrir l\'URL: $checkoutUrl');
        return false;
      }
    } catch (e) {
      print('❌ Erreur ouverture page paiement: $e');
      return false;
    }
  }

  /// Vérifier le statut d'un paiement
  static Future<BarapayStatusResponse> checkPaymentStatus(String reference) async {
    try {
      final url = Uri.parse('$_baseUrl/api/barapay/status?reference=$reference');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          return BarapayStatusResponse(
            success: true,
            status: data['status'],
            reference: data['reference'],
            payment: data['payment'] != null ? Payment.fromJson(data['payment']) : null,
          );
        } else {
          return BarapayStatusResponse(
            success: false,
            error: data['error'] ?? 'Erreur inconnue',
          );
        }
      } else {
        return BarapayStatusResponse(
          success: false,
          error: 'Erreur serveur: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Erreur vérification statut: $e');
      return BarapayStatusResponse(
        success: false,
        error: 'Erreur de connexion: $e',
      );
    }
  }

  /// Tester la connexion avec l'API Barapay
  static Future<bool> testConnection() async {
    try {
      final url = Uri.parse('$_baseUrl/api/test');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['barapay_configured'] == true;
      }
      return false;
    } catch (e) {
      print('❌ Erreur test connexion: $e');
      return false;
    }
  }
}

/// Modèle de réponse pour la création de paiement
class BarapayPaymentResponse {
  final bool success;
  final String? paymentId;
  final String? checkoutUrl;
  final String? reference;
  final String? message;
  final String? error;
  final Payment? payment;

  BarapayPaymentResponse({
    required this.success,
    this.paymentId,
    this.checkoutUrl,
    this.reference,
    this.message,
    this.error,
    this.payment,
  });
}

/// Modèle de réponse pour la vérification de statut
class BarapayStatusResponse {
  final bool success;
  final String? status;
  final String? reference;
  final String? error;
  final Payment? payment;

  BarapayStatusResponse({
    required this.success,
    this.status,
    this.reference,
    this.error,
    this.payment,
  });
}
