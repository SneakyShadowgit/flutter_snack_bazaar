import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum SellerStatus { active, suspended }

class Seller {
  final String id;
  final String businessName;
  final String phone;
  final String location;
  final SellerStatus status;
  final IconData icon;
  final Color iconBgColor;

  const Seller({
    required this.id,
    required this.businessName,
    required this.phone,
    required this.location,
    this.status = SellerStatus.active,
    this.icon = Icons.store,
    this.iconBgColor = const Color(0xFF5D4037),
  });

  factory Seller.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return Seller(
      id: doc.id,
      businessName: data['businessName'] as String? ?? 'Unnamed business',
      phone: data['phone'] as String? ?? '',
      location: data['location'] as String? ?? '',
    );
  }

  Seller copyWith({SellerStatus? status}) {
    return Seller(
      id: id,
      businessName: businessName,
      phone: phone,
      location: location,
      status: status ?? this.status,
      icon: icon,
      iconBgColor: iconBgColor,
    );
  }
}
