import 'package:flutter/material.dart';
import 'package:snack_bazaar/core/theme/app_colors.dart';
import 'package:snack_bazaar/features/seller/models/seller_order.dart';
import 'package:snack_bazaar/features/seller/services/seller_order_repository.dart';

class BusinessInsightsTab extends StatelessWidget {
  const BusinessInsightsTab({super.key});

  @override
  Widget build(BuildContext context) => StreamBuilder<List<SellerOrder>>(
        stream: SellerOrderRepository().watchOrders(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Could not load order insights.'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data ?? const <SellerOrder>[];
          final revenue = orders.fold<double>(0, (sum, order) => sum + order.totalAmount);
          final products = <String, ({int quantity, double revenue})>{};
          for (final order in orders) {
            for (final item in order.items) {
              final previous = products[item.productName] ?? (quantity: 0, revenue: 0.0);
              products[item.productName] = (
                quantity: previous.quantity + item.quantity,
                revenue: previous.revenue + item.price * item.quantity,
              );
            }
          }
          final rankedProducts = products.entries.toList()
            ..sort((a, b) => b.value.quantity.compareTo(a.value.quantity));
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text('Shop Insights', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('Calculated from your saved orders.', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 18),
              Row(children: [
                _SummaryCard(title: 'ORDER VALUE', value: '₹${revenue.toStringAsFixed(2)}', icon: Icons.currency_rupee),
                const SizedBox(width: 12),
                _SummaryCard(title: 'TOTAL ORDERS', value: orders.length.toString(), icon: Icons.shopping_basket_outlined),
              ]),
              const SizedBox(height: 28),
              const Text('Products in orders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              if (rankedProducts.isEmpty)
                const Text('Product sales will appear here after orders are placed.')
              else
                ...rankedProducts.take(5).map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(children: [
                        Expanded(
                          flex: 3,
                          child: Text(entry.key, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('${entry.value.quantity} sold', textAlign: TextAlign.center),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('₹${entry.value.revenue.toStringAsFixed(2)}', textAlign: TextAlign.end),
                        ),
                      ]),
                    )),
            ],
          );
        },
      );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.value, required this.icon});

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            ),
          ]),
        ),
      );
}
