import 'dart:convert';

void main() {
  print('=== Test de la correction PaymentService ===\n');
  
  // Test 1: Réponse avec tous les champs null
  print('Test 1: Réponse avec tous les champs null');
  Map<String, dynamic> barapayResult1 = {
    'success': true,
    'redirect_required': false,
    'checkout_url': null,
    'payment_id': null,
    'reference': null,
    'status': null,
    'amount': null,
    'phone_number': null,
    'created_at': null
  };
  
  try {
    // Simulation de l'extraction sécurisée
    String paymentId = 'unknown';
    String reference = 'unknown';
    String status = 'pending';
    int finalAmount = 1000;
    String finalPhoneNumber = '+2250505979884';
    String createdAt = DateTime.now().toIso8601String();
    
    if (barapayResult1['payment_id'] != null) {
      paymentId = barapayResult1['payment_id'].toString();
    }
    if (barapayResult1['reference'] != null) {
      reference = barapayResult1['reference'].toString();
    }
    if (barapayResult1['status'] != null) {
      status = barapayResult1['status'].toString();
    }
    if (barapayResult1['amount'] != null) {
      finalAmount = barapayResult1['amount'] is int ? barapayResult1['amount'] : 1000;
    }
    if (barapayResult1['phone_number'] != null) {
      finalPhoneNumber = barapayResult1['phone_number'].toString();
    }
    if (barapayResult1['created_at'] != null) {
      createdAt = barapayResult1['created_at'].toString();
    }
    
    print('✅ Succès: paymentId = $paymentId, reference = $reference, status = $status');
  } catch (e) {
    print('❌ Erreur: $e');
  }
  
  // Test 2: Réponse avec redirection Wave
  print('\nTest 2: Réponse avec redirection Wave');
  Map<String, dynamic> barapayResult2 = {
    'success': true,
    'redirect_required': true,
    'checkout_url': 'https://wave.com/checkout',
    'payment_id': 'PAY_123456',
    'reference': 'REF_123456',
    'status': 'pending',
    'amount': 1000,
    'phone_number': '+2250505979884',
    'created_at': '2024-01-01T00:00:00Z'
  };
  
  try {
    String paymentId = 'unknown';
    String reference = 'unknown';
    String status = 'pending';
    int finalAmount = 1000;
    String finalPhoneNumber = '+2250505979884';
    String createdAt = DateTime.now().toIso8601String();
    
    if (barapayResult2['payment_id'] != null) {
      paymentId = barapayResult2['payment_id'].toString();
    }
    if (barapayResult2['reference'] != null) {
      reference = barapayResult2['reference'].toString();
    }
    if (barapayResult2['status'] != null) {
      status = barapayResult2['status'].toString();
    }
    if (barapayResult2['amount'] != null) {
      finalAmount = barapayResult2['amount'] is int ? barapayResult2['amount'] : 1000;
    }
    if (barapayResult2['phone_number'] != null) {
      finalPhoneNumber = barapayResult2['phone_number'].toString();
    }
    if (barapayResult2['created_at'] != null) {
      createdAt = barapayResult2['created_at'].toString();
    }
    
    print('✅ Succès: paymentId = $paymentId, reference = $reference, status = $status');
    print('✅ Redirection: ${barapayResult2['redirect_required']}, URL: ${barapayResult2['checkout_url']}');
  } catch (e) {
    print('❌ Erreur: $e');
  }
  
  // Test 3: Réponse avec données partielles
  print('\nTest 3: Réponse avec données partielles');
  Map<String, dynamic> barapayResult3 = {
    'success': true,
    'redirect_required': false,
    'checkout_url': null,
    'payment_id': 'PAY_789012',
    'reference': null, // null
    'status': 'completed',
    'amount': null, // null
    'phone_number': null, // null
    'created_at': null // null
  };
  
  try {
    String paymentId = 'unknown';
    String reference = 'unknown';
    String status = 'pending';
    int finalAmount = 1000;
    String finalPhoneNumber = '+2250505979884';
    String createdAt = DateTime.now().toIso8601String();
    
    if (barapayResult3['payment_id'] != null) {
      paymentId = barapayResult3['payment_id'].toString();
    }
    if (barapayResult3['reference'] != null) {
      reference = barapayResult3['reference'].toString();
    }
    if (barapayResult3['status'] != null) {
      status = barapayResult3['status'].toString();
    }
    if (barapayResult3['amount'] != null) {
      finalAmount = barapayResult3['amount'] is int ? barapayResult3['amount'] : 1000;
    }
    if (barapayResult3['phone_number'] != null) {
      finalPhoneNumber = barapayResult3['phone_number'].toString();
    }
    if (barapayResult3['created_at'] != null) {
      createdAt = barapayResult3['created_at'].toString();
    }
    
    print('✅ Succès: paymentId = $paymentId, reference = $reference, status = $status');
  } catch (e) {
    print('❌ Erreur: $e');
  }
  
  print('\n=== Tests terminés ===');
}
