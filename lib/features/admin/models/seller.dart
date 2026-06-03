import 'package:flutter/material.dart';

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

// Sample data matching the design
final List<Seller> sampleSellers = [
  const Seller(
    id: '1',
    businessName: 'Bean & Bar Artisans',
    phone: '+1 (555) 112-4567',
    location: 'Portland, OR',
    status: SellerStatus.active,
    icon: Icons.coffee,
    iconBgColor: Color(0xFF5D4037),
  ),
  const Seller(
    id: '2',
    businessName: 'Sweet Root Jams',
    phone: '+1 (555) 887-6543',
    location: 'Austin, TX',
    status: SellerStatus.active,
    icon: Icons.local_dining,
    iconBgColor: Color(0xFFC62828),
  ),
  const Seller(
    id: '3',
    businessName: 'Crunch Co.',
    phone: '+1 (555) 234-5678',
    location: 'Chicago, IL',
    status: SellerStatus.suspended,
    icon: Icons.bakery_dining,
    iconBgColor: Color(0xFF37474F),
  ),
  const Seller(
    id: '4',
    businessName: 'Wild Yeast Bakery',
    phone: '+1 (555) 891-7890',
    location: 'Seattle, WA',
    status: SellerStatus.active,
    icon: Icons.breakfast_dining,
    iconBgColor: Color(0xFFE65100),
  ),
];
