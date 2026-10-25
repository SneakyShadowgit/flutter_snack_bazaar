import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snack_bazaar/core/theme/app_colors.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: db.collection('users').where('role', isEqualTo: 'seller').snapshots(),
      builder: (context, sellersSnapshot) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: db.collection('orders').snapshots(),
        builder: (context, ordersSnapshot) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: db.collection('products').snapshots(),
          builder: (context, productsSnapshot) {
            if (sellersSnapshot.hasError || ordersSnapshot.hasError || productsSnapshot.hasError) {
              return const Center(child: Text('Could not load platform insights.'));
            }
            if (sellersSnapshot.connectionState == ConnectionState.waiting ||
                ordersSnapshot.connectionState == ConnectionState.waiting ||
                productsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final sellers = sellersSnapshot.data?.docs ?? const [];
            final orders = ordersSnapshot.data?.docs ?? const [];
            final products = productsSnapshot.data?.docs ?? const [];
            final revenue = orders.fold<double>(0, (total, order) {
              final amount = order.data()['totalAmount'];
              return total + (amount is num ? amount.toDouble() : 0);
            });

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Platform Insights',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Live totals from the project database.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _InsightCard(label: 'Approved Sellers', value: sellers.length.toString(), icon: Icons.store),
                      _InsightCard(label: 'Orders', value: orders.length.toString(), icon: Icons.shopping_bag_outlined),
                      _InsightCard(label: 'Products', value: products.length.toString(), icon: Icons.inventory_2_outlined),
                      _InsightCard(label: 'Order Value', value: '₹${revenue.toStringAsFixed(2)}', icon: Icons.currency_rupee),
                    ],
                  ),
                  if (sellers.isEmpty && orders.isEmpty && products.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 28),
                      child: Text('Insights will appear here as real sellers, products, and orders are added.'),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 220,
        child: Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
