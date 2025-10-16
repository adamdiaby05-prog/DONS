class AdminDashboard {
  final int totalGroups;
  final int totalMembers;
  final int totalContributions;
  final double totalAmountCollected;
  final int pendingPayments;
  final int overduePayments;
  final List<GroupSummary> recentGroups;
  final List<PaymentSummary> recentPayments;

  AdminDashboard({
    required this.totalGroups,
    required this.totalMembers,
    required this.totalContributions,
    required this.totalAmountCollected,
    required this.pendingPayments,
    required this.overduePayments,
    required this.recentGroups,
    required this.recentPayments,
  });

  factory AdminDashboard.fromJson(Map<String, dynamic> json) {
    return AdminDashboard(
      totalGroups: json['total_groups'] ?? 0,
      totalMembers: json['total_members'] ?? 0,
      totalContributions: json['total_contributions'] ?? 0,
      totalAmountCollected: _parseDouble(json['total_amount_collected']),
      pendingPayments: json['pending_payments'] ?? 0,
      overduePayments: json['overdue_payments'] ?? 0,
      recentGroups: (json['recent_groups'] as List?)
          ?.map((e) => GroupSummary.fromJson(e))
          .toList() ?? [],
      recentPayments: (json['recent_payments'] as List?)
          ?.map((e) => PaymentSummary.fromJson(e))
          .toList() ?? [],
    );
  }
}

class GroupSummary {
  final int id;
  final String name;
  final String type;
  final int memberCount;
  final double contributionAmount;
  final DateTime createdAt;

  GroupSummary({
    required this.id,
    required this.name,
    required this.type,
    required this.memberCount,
    required this.contributionAmount,
    required this.createdAt,
  });

  factory GroupSummary.fromJson(Map<String, dynamic> json) {
    return GroupSummary(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      memberCount: json['member_count'] ?? 0,
      contributionAmount: _parseDouble(json['contribution_amount']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class PaymentSummary {
  final int id;
  final String memberName;
  final String groupName;
  final double amount;
  final String status;
  final String paymentMethod;
  final DateTime? processedAt;

  PaymentSummary({
    required this.id,
    required this.memberName,
    required this.groupName,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    this.processedAt,
  });

  factory PaymentSummary.fromJson(Map<String, dynamic> json) {
    return PaymentSummary(
      id: json['id'],
      memberName: json['user_name'] ?? '',
      groupName: json['group_name'] ?? '',
      amount: _parseDouble(json['amount']),
      status: json['status'],
      paymentMethod: json['payment_method'] ?? '',
      processedAt: json['processed_at'] != null ? DateTime.parse(json['processed_at']) : null,
    );
  }
}

// Fonction utilitaire pour parser les doubles, qu'ils soient String ou num
double _parseDouble(dynamic value) {
  if (value == null) {
    return 0.0;
  }
  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  if (value is num) {
    return value.toDouble();
  }
  return 0.0;
}
