import 'package:flutter/material.dart';
import 'package:snack_bazaar/core/theme/app_colors.dart';
import 'package:snack_bazaar/features/seller/models/seller_order.dart';
import 'package:snack_bazaar/features/seller/models/seller_product.dart';
import 'package:snack_bazaar/features/seller/services/seller_order_repository.dart';
import 'package:snack_bazaar/features/seller/services/seller_product_repository.dart';

class SellerDashboardTab extends StatelessWidget {
  const SellerDashboardTab({super.key});

  @override
  Widget build(BuildContext context) => StreamBuilder<List<SellerProduct>>(
        stream: SellerProductRepository().watchProducts(),
        builder: (context, productSnapshot) => StreamBuilder<List<SellerOrder>>(
          stream: SellerOrderRepository().watchOrders(),
          builder: (context, orderSnapshot) {
            if (productSnapshot.hasError || orderSnapshot.hasError) {
              return const Center(child: Text('Could not load shop data.'));
            }
            if (productSnapshot.connectionState == ConnectionState.waiting ||
                orderSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final products = productSnapshot.data ?? const <SellerProduct>[];
            final orders = orderSnapshot.data ?? const <SellerOrder>[];
            final pendingCount = orders.where((order) => order.status == SellerOrderStatus.pending).length;
            final orderValue = orders.fold<double>(0, (sum, order) => sum + order.totalAmount);

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Your shop at a glance',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                const Text('Live figures from your products and orders.', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 24),
                Row(children: [
                  _MetricCard(title: 'Products', value: products.length.toString(), icon: Icons.inventory_2_outlined),
                  const SizedBox(width: 12),
                  _MetricCard(title: 'Pending Orders', value: pendingCount.toString(), icon: Icons.pending_actions_outlined),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  _MetricCard(title: 'Total Orders', value: orders.length.toString(), icon: Icons.shopping_cart_outlined),
                  const SizedBox(width: 12),
                  _MetricCard(title: 'Order Value', value: '₹${orderValue.toStringAsFixed(2)}', icon: Icons.currency_rupee),
                ]),
                const SizedBox(height: 28),
                const Text('Recent Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                if (orders.isEmpty)
                  const Text('Your real orders will appear here.')
                else
                  ...orders.take(5).map((order) => Card(
                        color: Colors.white,
                        child: ListTile(
                          title: Text('Order #${order.orderNumber}'),
                          subtitle: Text('${order.items.fold<int>(0, (sum, item) => sum + item.quantity)} items • ${order.status.name}'),
                          trailing: Text('₹${order.totalAmount.toStringAsFixed(2)}'),
                        ),
                      )),
              ],
            );
          },
        ),
      );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value, required this.icon});

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      );
}
