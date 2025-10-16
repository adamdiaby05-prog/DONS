import 'package:flutter/material.dart';

class PaymentNetwork {
  final String id;
  final String name;
  final String logo;
  final Color backgroundColor;
  final String description;

  PaymentNetwork({
    required this.id,
    required this.name,
    required this.logo,
    required this.backgroundColor,
    required this.description,
  });

  factory PaymentNetwork.fromJson(Map<String, dynamic> json) {
    return PaymentNetwork(
      id: json['id'],
      name: json['name'],
      logo: json['logo'],
      backgroundColor: Color(int.parse(json['background_color'])),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'background_color': backgroundColor.value.toString(),
      'description': description,
    };
  }
}
