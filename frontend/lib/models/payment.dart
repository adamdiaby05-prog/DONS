class Payment {
  final int id;
  final int contributionId;
  final String paymentReference;
  final double amount;
  final String paymentMethod;
  final String phoneNumber;
  final String status;
  final String? gatewayResponse;
  final DateTime? processedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Payment({
    required this.id,
    required this.contributionId,
    required this.paymentReference,
    required this.amount,
    required this.paymentMethod,
    required this.phoneNumber,
    required this.status,
    this.gatewayResponse,
    this.processedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      contributionId: json['contribution_id'],
      paymentReference: json['payment_reference'],
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'],
      phoneNumber: json['phone_number'],
      status: json['status'],
      gatewayResponse: json['gateway_response'],
      processedAt: json['processed_at'] != null ? DateTime.parse(json['processed_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contribution_id': contributionId,
      'payment_reference': paymentReference,
      'amount': amount,
      'payment_method': paymentMethod,
      'phone_number': phoneNumber,
      'status': status,
      'gateway_response': gatewayResponse,
      'processed_at': processedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
