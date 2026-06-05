import 'package:flutter/material.dart';
import 'package:snack_bazaar/core/theme/app_colors.dart';

class SellerDashboardTab extends StatelessWidget {
  const SellerDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome text
          const Text(
            'Welcome back, Baker',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Here's what's happening in your shop today:",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // 2x2 Grid of Metrics
          Row(
            children: [
              _buildMetricCard(
                title: 'Total Products',
                value: '24',
                icon: Icons.inventory_2_outlined,
                iconColor: AppColors.primary,
                backgroundColor: Colors.white,
                textColor: AppColors.textPrimary,
                subtext: 'Live in catalog',
              ),
              const SizedBox(width: 16),
              _buildMetricCard(
                title: 'Pending Orders',
                value: '5',
                icon: Icons.pending_actions_outlined,
                iconColor: AppColors.warning,
                backgroundColor: Colors.white,
                textColor: AppColors.textPrimary,
                subtext: 'Needs packaging',
                badgeText: 'Action required',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMetricCard(
                title: 'Total Orders',
                value: '120',
                icon: Icons.shopping_cart_outlined,
                iconColor: AppColors.success,
                backgroundColor: Colors.white,
                textColor: AppColors.textPrimary,
                subtext: 'Lifetime orders',
              ),
              const SizedBox(width: 16),
              _buildMetricCard(
                title: "Today's Revenue",
                value: '\$450.00',
                icon: Icons.payments_outlined,
                iconColor: Colors.white,
                backgroundColor: AppColors.primary,
                textColor: Colors.white,
                subtext: '+25% vs yesterday',
                isDark: true,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Recent Activity Section
          const Text(
            'Recent Notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 16),

          _buildNotificationItem(
            icon: Icons.payment,
            iconColor: Colors.green,
            title: 'Payment received for Order #9021',
            time: '2 minutes ago',
            description: 'Amount of \$35.50 was credited to your seller wallet.',
          ),
          _buildNotificationItem(
            icon: Icons.store,
            iconColor: Colors.blue,
            title: 'Stock Alert: Masala Peanuts',
            time: '1 hour ago',
            description: 'Inventory is down to 8 units. Consider restocking.',
          ),
          _buildNotificationItem(
            icon: Icons.star,
            iconColor: Colors.amber,
            title: 'New Review on Spicy Banana Chips',
            time: '5 hours ago',
            description: 'Juliana Moore rated 5.0: "Best banana chips in town!"',
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required Color textColor,
    required String subtext,
    String? badgeText,
    bool isDark = false,
  }) {
    return Expanded(
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: isDark ? null : Border.all(color: AppColors.border),
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white.withValues(alpha: 0.8) : AppColors.textSecondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                if (badgeText != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.warning,
                      ),
                    ),
                  )
                else
                  Text(
                    subtext,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String time,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
