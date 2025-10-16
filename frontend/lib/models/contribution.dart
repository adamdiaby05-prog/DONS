import 'group.dart';
import 'user.dart';

class Contribution {
  final int id;
  final int userId;
  final int groupId;
  final double amount;
  final DateTime dueDate;
  final DateTime? paidDate;
  final String status;
  final String? paymentReference;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Relations
  final Group? group;
  final User? user;

  Contribution({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    required this.status,
    this.paymentReference,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.group,
    this.user,
  });

  factory Contribution.fromJson(Map<String, dynamic> json) {
    return Contribution(
      id: json['id'],
      userId: json['user_id'],
      groupId: json['group_id'],
      amount: (json['amount'] ?? 0).toDouble(),
      dueDate: DateTime.parse(json['due_date']),
      paidDate: json['paid_date'] != null ? DateTime.parse(json['paid_date']) : null,
      status: json['status'],
      paymentReference: json['payment_reference'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      group: json['group'] != null ? Group.fromJson(json['group']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'group_id': groupId,
      'amount': amount,
      'due_date': dueDate.toIso8601String(),
      'paid_date': paidDate?.toIso8601String(),
      'status': status,
      'payment_reference': paymentReference,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'group': group?.toJson(),
      'user': user?.toJson(),
    };
  }
}
