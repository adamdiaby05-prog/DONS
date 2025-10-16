class BarapayPayment {
  final String id;
  final double amount;
  final String phoneNumber;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
  final String type;
  final String checkoutUrl;
  final String barapayReference;
  final bool realPayment;
  final Map<String, dynamic>? barapayData;
  final Map<String, dynamic>? barapayCallback;
  final DateTime? updatedAt;

  BarapayPayment({
    required this.id,
    required this.amount,
    required this.phoneNumber,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    required this.type,
    required this.checkoutUrl,
    required this.barapayReference,
    required this.realPayment,
    this.barapayData,
    this.barapayCallback,
    this.updatedAt,
  });

  factory BarapayPayment.fromJson(Map<String, dynamic> json) {
    return BarapayPayment(
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      phoneNumber: json['phone_number'] ?? '',
      paymentMethod: json['payment_method'] ?? 'PayMoney',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      type: json['type'] ?? 'barapay_real',
      checkoutUrl: json['checkout_url'] ?? '',
      barapayReference: json['barapay_reference'] ?? '',
      realPayment: json['real_payment'] ?? false,
      barapayData: json['barapay_data'],
      barapayCallback: json['barapay_callback'],
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'phone_number': phoneNumber,
      'payment_method': paymentMethod,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'type': type,
      'checkout_url': checkoutUrl,
      'barapay_reference': barapayReference,
      'real_payment': realPayment,
      'barapay_data': barapayData,
      'barapay_callback': barapayCallback,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  BarapayPayment copyWith({
    String? id,
    double? amount,
    String? phoneNumber,
    String? paymentMethod,
    String? status,
    DateTime? createdAt,
    String? type,
    String? checkoutUrl,
    String? barapayReference,
    bool? realPayment,
    Map<String, dynamic>? barapayData,
    Map<String, dynamic>? barapayCallback,
    DateTime? updatedAt,
  }) {
    return BarapayPayment(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      checkoutUrl: checkoutUrl ?? this.checkoutUrl,
      barapayReference: barapayReference ?? this.barapayReference,
      realPayment: realPayment ?? this.realPayment,
      barapayData: barapayData ?? this.barapayData,
      barapayCallback: barapayCallback ?? this.barapayCallback,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Vérifier si le paiement est en attente
  bool get isPending => status == 'pending';

  /// Vérifier si le paiement est confirmé
  bool get isConfirmed => status == 'confirmed' || status == 'success';

  /// Vérifier si le paiement est échoué
  bool get isFailed => status == 'failed' || status == 'cancelled';

  /// Obtenir le statut formaté
  String get formattedStatus {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'confirmed':
      case 'success':
        return 'Confirmé';
      case 'failed':
        return 'Échoué';
      case 'cancelled':
        return 'Annulé';
      default:
        return 'Inconnu';
    }
  }

  /// Obtenir le montant formaté
  String get formattedAmount => '${amount.toInt()} FCFA';

  /// Obtenir la date formatée
  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year} à ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  }
}
