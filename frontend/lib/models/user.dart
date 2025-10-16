import 'group_member.dart';

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? email;
  final bool phoneVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<GroupMember>? groupMembers;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.email,
    required this.phoneVerified,
    required this.createdAt,
    required this.updatedAt,
    this.groupMembers,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    List<GroupMember>? groupMembers;
    if (json['group_members'] != null) {
      groupMembers = (json['group_members'] as List)
          .map((member) => GroupMember.fromJson(member))
          .toList();
    }

    return User(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      email: json['email'],
      phoneVerified: json['phone_verified'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
      groupMembers: groupMembers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'email': email,
      'phone_verified': phoneVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'group_members': groupMembers?.map((member) => member.toJson()).toList(),
    };
  }

  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? email,
    bool? phoneVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<GroupMember>? groupMembers,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      groupMembers: groupMembers ?? this.groupMembers,
    );
  }
}
