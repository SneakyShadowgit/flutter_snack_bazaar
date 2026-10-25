import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SellerRequest {
  final String id;
  final String businessName;
  final String ownerName;
  final String phone;
  final String location;
  final String category;
  final IconData icon;

  const SellerRequest({
    required this.id,
    required this.businessName,
    required this.ownerName,
    required this.phone,
    required this.location,
    required this.category,
    this.icon = Icons.store,
  });

  factory SellerRequest.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    return SellerRequest(
      id: document.id,
      businessName: data['businessName'] as String? ?? 'Unnamed business',
      ownerName: data['ownerName'] as String? ?? 'Unknown owner',
      phone: data['phone'] as String? ?? '',
      location: data['location'] as String? ?? '',
      category: data['category'] as String? ?? '',
    );
  }
}
