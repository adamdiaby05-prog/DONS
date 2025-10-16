import 'user.dart';

class GroupMember {
  final int id;
  final int userId;
  final int groupId;
  final String role;
  final DateTime joinedDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;

  GroupMember({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.role,
    required this.joinedDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  bool get isAdmin => role == 'admin';
  bool get isMember => role == 'member';

  String get roleLabel {
    switch (role) {
      case 'admin':
        return 'Administrateur';
      case 'member':
        return 'Membre';
      default:
        return role;
    }
  }

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      groupId: json['group_id'] ?? 0,
      role: json['role'] ?? '',
      joinedDate: json['joined_date'] != null 
          ? DateTime.parse(json['joined_date']) 
          : DateTime.now(),
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'group_id': groupId,
      'role': role,
      'joined_date': joinedDate.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user': user?.toJson(),
    };
  }

  GroupMember copyWith({
    int? id,
    int? userId,
    int? groupId,
    String? role,
    DateTime? joinedDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
  }) {
    return GroupMember(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      groupId: groupId ?? this.groupId,
      role: role ?? this.role,
      joinedDate: joinedDate ?? this.joinedDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }
}
