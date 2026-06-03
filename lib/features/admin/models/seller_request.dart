import 'package:flutter/material.dart';

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
}

// Sample data matching the design
final List<SellerRequest> sampleSellerRequests = [
  const SellerRequest(
    id: '1',
    businessName: 'Nourish Naturals',
    ownerName: 'Sarah Jenkins',
    phone: '+1 (555) 012-3456',
    location: 'Portland, OR',
    category: 'Organic Granola',
    icon: Icons.store_mall_directory,
  ),
  const SellerRequest(
    id: '2',
    businessName: 'Sweet & Savory Chips',
    ownerName: 'Michael Chen',
    phone: '+1 (555) 987-6543',
    location: 'Austin, TX',
    category: 'Artisan Crisps',
    icon: Icons.storefront,
  ),
  const SellerRequest(
    id: '3',
    businessName: 'Peak Protein Packs',
    ownerName: 'Diana Ross',
    phone: '+1 (555) 444-5566',
    location: 'Boulder, CO',
    category: 'Health Bars',
    icon: Icons.fitness_center,
  ),
];
