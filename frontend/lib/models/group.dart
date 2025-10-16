import 'group_member.dart';

class Group {
  final int id;
  final String name;
  final String? description;
  final String type;
  final double contributionAmount;
  final String frequency;
  final String paymentMode;
  final DateTime nextDueDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<GroupMember>? members;
  final List<dynamic>? contributions;

  Group({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.contributionAmount,
    required this.frequency,
    required this.paymentMode,
    required this.nextDueDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.members,
    this.contributions,
  });

  String get typeLabel {
    switch (type) {
      case 'association':
        return 'Association';
      case 'tontine':
        return 'Tontine';
      case 'mutuelle':
        return 'Mutuelle';
      case 'cooperative':
        return 'Coopérative';
      case 'syndicat':
        return 'Syndicat';
      case 'club':
        return 'Club';
      default:
        return type;
    }
  }

  String get frequencyLabel {
    switch (frequency) {
      case 'daily':
        return 'Quotidienne';
      case 'weekly':
        return 'Hebdomadaire';
      case 'monthly':
        return 'Mensuelle';
      case 'yearly':
        return 'Annuelle';
      default:
        return frequency;
    }
  }

  String get paymentModeLabel {
    switch (paymentMode) {
      case 'automatic':
        return 'Automatique';
      case 'manual':
        return 'Manuel';
      default:
        return paymentMode;
    }
  }

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      type: json['type'] ?? '',
      contributionAmount: _parseDouble(json['contribution_amount']),
      frequency: json['frequency'] ?? '',
      paymentMode: json['payment_mode'] ?? '',
      nextDueDate: json['next_due_date'] != null 
          ? DateTime.parse(json['next_due_date']) 
          : DateTime.now(),
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
      members: json['members'] != null
          ? List<GroupMember>.from(
              json['members'].map((x) => GroupMember.fromJson(x)))
          : null,
      contributions: json['contributions'],
    );
  }

  // Fonction utilitaire pour parser les doubles, qu'ils soient String ou num
  static double _parseDouble(dynamic value) {
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'contribution_amount': contributionAmount,
      'frequency': frequency,
      'payment_mode': paymentMode,
      'next_due_date': nextDueDate.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'members': members?.map((x) => x.toJson()).toList(),
      'contributions': contributions,
    };
  }

  Group copyWith({
    int? id,
    String? name,
    String? description,
    String? type,
    double? contributionAmount,
    String? frequency,
    String? paymentMode,
    DateTime? nextDueDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<GroupMember>? members,
    List<dynamic>? contributions,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      contributionAmount: contributionAmount ?? this.contributionAmount,
      frequency: frequency ?? this.frequency,
      paymentMode: paymentMode ?? this.paymentMode,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      members: members ?? this.members,
      contributions: contributions ?? this.contributions,
    );
  }
}
