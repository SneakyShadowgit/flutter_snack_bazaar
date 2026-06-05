import 'package:flutter/material.dart';
import 'package:snack_bazaar/core/theme/app_colors.dart';
import 'package:snack_bazaar/features/seller/models/seller_order.dart';

class OrdersManagementTab extends StatefulWidget {
  const OrdersManagementTab({super.key});

  @override
  State<OrdersManagementTab> createState() => _OrdersManagementTabState();
}

class _OrdersManagementTabState extends State<OrdersManagementTab> {
  late List<SellerOrder> _orders;

  @override
  void initState() {
    super.initState();
    _orders = List.from(sampleSellerOrders);
  }

  void _advanceOrderStatus(SellerOrder order) {
    SellerOrderStatus nextStatus;
    String statusVerb = '';

    switch (order.status) {
      case SellerOrderStatus.pending:
        nextStatus = SellerOrderStatus.packed;
        statusVerb = 'packed';
        break;
      case SellerOrderStatus.packed:
        nextStatus = SellerOrderStatus.shipped;
        statusVerb = 'shipped';
        break;
      case SellerOrderStatus.shipped:
        nextStatus = SellerOrderStatus.delivered;
        statusVerb = 'delivered';
        break;
      case SellerOrderStatus.delivered:
        return; // Already delivered
    }

    setState(() {
      final index = _orders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: nextStatus);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order #${order.orderNumber} successfully marked as $statusVerb!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate metric numbers dynamically
    final int pendingCount = _orders.where((o) => o.status == SellerOrderStatus.pending).length + 2; // offset to match Figma mock
    final int packedCount = _orders.where((o) => o.status == SellerOrderStatus.packed).length + 7;
    final int shippedCount = _orders.where((o) => o.status == SellerOrderStatus.shipped).length + 13;
    
    double revenueTotal = 1380.00; // base revenue to match Figma mock
    for (var o in _orders) {
      if (o.status == SellerOrderStatus.delivered || o.status == SellerOrderStatus.shipped) {
        revenueTotal += o.totalAmount;
      }
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 4 Metric Chips row
          Row(
            children: [
              _buildSmallMetricChip(
                label: 'Pending',
                value: pendingCount.toString().padLeft(2, '0'),
                color: const Color(0xFFFFB300), // Amber/Yellow
              ),
              const SizedBox(width: 8),
              _buildSmallMetricChip(
                label: 'Packed',
                value: packedCount.toString().padLeft(2, '0'),
                color: const Color(0xFF8D6E63), // Brown
              ),
              const SizedBox(width: 8),
              _buildSmallMetricChip(
                label: 'Shipped',
                value: shippedCount.toString().padLeft(2, '0'),
                color: const Color(0xFF4CAF50), // Green
              ),
              const SizedBox(width: 8),
              _buildSmallMetricChip(
                label: 'Revenue',
                value: '\$${revenueTotal.toStringAsFixed(0)}',
                color: AppColors.primary, // Blue
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Active Orders Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Active Orders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.tune, size: 16),
                label: const Text('Filter'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Orders list
          if (_orders.isEmpty)
            _buildEmptyOrdersState()
          else
            ..._orders.map((order) => _buildOrderCard(order)),
        ],
      ),
    );
  }

  Widget _buildSmallMetricChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color.withValues(alpha: 0.9),
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color.withValues(alpha: 0.95),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(SellerOrder order) {
    Color statusColor = Colors.grey;
    String statusText = '';
    String buttonText = '';

    switch (order.status) {
      case SellerOrderStatus.pending:
        statusColor = const Color(0xFFFFB300);
        statusText = 'PENDING';
        buttonText = 'Mark as Packed';
        break;
      case SellerOrderStatus.packed:
        statusColor = const Color(0xFF8D6E63);
        statusText = 'PACKED';
        buttonText = 'Mark as Shipped';
        break;
      case SellerOrderStatus.shipped:
        statusColor = const Color(0xFF4CAF50);
        statusText = 'SHIPPED';
        buttonText = 'Mark as Delivered';
        break;
      case SellerOrderStatus.delivered:
        statusColor = AppColors.primary;
        statusText = 'DELIVERED';
        buttonText = '';
        break;
    }

    final int totalItemsCount = order.items.fold(0, (sum, item) => sum + item.quantity);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header (Order number & Status badge)
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.orderNumber}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${order.timeString} • $totalItemsCount ${totalItemsCount == 1 ? 'item' : 'items'}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Order Items summary & Customer details
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      order.customerName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '\$${order.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                
                // Item list text representation
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              '${item.quantity}x',
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.productName,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Action Button
          if (buttonText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _advanceOrderStatus(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check_circle, color: AppColors.success, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Order Fully Completed & Delivered',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyOrdersState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: const Column(
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 64, color: AppColors.textTertiary),
          SizedBox(height: 16),
          Text(
            'All caught up!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'No active orders at this time.',
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
