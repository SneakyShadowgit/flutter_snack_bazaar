import 'package:flutter/material.dart';
import 'package:snack_bazaar/core/theme/app_colors.dart';
import 'package:snack_bazaar/features/buyer/models/buyer_order.dart';

class OrdersTab extends StatefulWidget {
  final List<BuyerOrder> orders;

  const OrdersTab({super.key, required this.orders});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  int _activeFilterIndex = 0;

  final List<String> _filters = ['All Orders', 'Active', 'Completed', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    // Filter orders based on active index
    final filteredOrders = widget.orders.where((order) {
      if (_activeFilterIndex == 0) return true; // All
      
      if (_activeFilterIndex == 1) {
        // Active
        return order.status == BuyerOrderStatus.pending ||
            order.status == BuyerOrderStatus.packed ||
            order.status == BuyerOrderStatus.shipped;
      }
      
      if (_activeFilterIndex == 2) {
        // Completed
        return order.status == BuyerOrderStatus.delivered;
      }
      
      if (_activeFilterIndex == 3) {
        // Cancelled
        return order.status == BuyerOrderStatus.cancelled;
      }
      
      return true;
    }).toList();

    return Column(
      children: [
        // Header
        _buildOrdersHeader(),
        
        // Filter Chips Slider
        _buildFilterSlider(),
        const SizedBox(height: 12),

        // Orders list
        Expanded(
          child: filteredOrders.isEmpty
              ? _buildEmptyOrdersState()
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    return _buildOrderCard(filteredOrders[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildOrdersHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Order History',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Track and manage your active and past orders.',
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSlider() {
    return Container(
      color: Colors.white,
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = index == _activeFilterIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (val) {
                if (val) {
                  setState(() {
                    _activeFilterIndex = index;
                  });
                }
              },
              selectedColor: Colors.orange[800]!.withValues(alpha: 0.12),
              checkmarkColor: Colors.orange[800],
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.orange[800] : AppColors.textSecondary,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? Colors.orange[800]! : AppColors.border),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(BuyerOrder order) {
    Color statusColor = Colors.grey;
    String statusLabel = '';
    String actionBtnLabel = '';

    switch (order.status) {
      case BuyerOrderStatus.pending:
        statusColor = const Color(0xFFFFB300); // Amber
        statusLabel = 'Pending Approval';
        actionBtnLabel = 'Track Order';
        break;
      case BuyerOrderStatus.packed:
        statusColor = const Color(0xFF8D6E63); // Brown
        statusLabel = 'Packed';
        actionBtnLabel = 'Track Order';
        break;
      case BuyerOrderStatus.shipped:
        statusColor = const Color(0xFF4CAF50); // Green
        statusLabel = 'Shipped';
        actionBtnLabel = 'Track Order';
        break;
      case BuyerOrderStatus.delivered:
        statusColor = AppColors.primary;
        statusLabel = 'Delivered';
        actionBtnLabel = 'Order Again';
        break;
      case BuyerOrderStatus.cancelled:
        statusColor = AppColors.error;
        statusLabel = 'Cancelled';
        actionBtnLabel = 'View Details';
        break;
    }

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
          // Order Header
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order ID #${order.orderNumber}',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.timeString,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusLabel.toUpperCase(),
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Items Summary & Total Amount
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...order.itemSummaries.map((summary) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      summary,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total AmountPaid',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '\$${order.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Bottom Action Button
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              width: double.infinity,
              height: 38,
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Mock: Triggered "$actionBtnLabel" action for order #${order.orderNumber}'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange[800],
                  side: BorderSide(color: Colors.orange[200]!),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                child: Text(actionBtnLabel),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyOrdersState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.assignment_turned_in_outlined, size: 64, color: AppColors.textTertiary),
          SizedBox(height: 16),
          Text(
            'No orders to display',
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Orders matching your select filter will appear here.',
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
