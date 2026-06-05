import 'package:flutter/material.dart';
import 'package:snack_bazaar/core/theme/app_colors.dart';

class BusinessInsightsTab extends StatelessWidget {
  const BusinessInsightsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section: Insights Summary
          const Text(
            'Insights Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            "A snapshot of your shop's performance over the last 30 days.",
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),

          // Side-by-side metric cards
          Row(
            children: [
              _buildSummaryCard(
                title: 'TOTAL REVENUE',
                value: '\$5,240',
                subtitle: '+12% growth (vs last 30d)',
                icon: Icons.analytics_outlined,
                color: AppColors.primary,
              ),
              const SizedBox(width: 14),
              _buildSummaryCard(
                title: 'TOTAL ORDERS',
                value: '145',
                subtitle: 'Customers love snacks',
                icon: Icons.shopping_basket_outlined,
                color: AppColors.secondary,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Section: Top 5 Selling Products
          const Text(
            'Top 5 Selling Products',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 16),

          _buildTopProductItem(
            rank: 1,
            name: 'Honey Caramel Cups',
            salesCount: 142,
            revenue: 710.00,
            maxSales: 142,
          ),
          _buildTopProductItem(
            rank: 2,
            name: 'Spicy Banana Chips',
            salesCount: 120,
            revenue: 600.00,
            maxSales: 142,
          ),
          _buildTopProductItem(
            rank: 3,
            name: 'Artisanal Sourdough',
            salesCount: 85,
            revenue: 1020.00,
            maxSales: 142,
          ),
          _buildTopProductItem(
            rank: 4,
            name: 'Chocolate Fudge',
            salesCount: 55,
            revenue: 440.00,
            maxSales: 142,
          ),
          _buildTopProductItem(
            rank: 5,
            name: 'Sea Salt Pretzels',
            salesCount: 35,
            revenue: 157.50,
            maxSales: 142,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textTertiary,
                    letterSpacing: 0.5,
                  ),
                ),
                Icon(icon, color: color, size: 18),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductItem({
    required int rank,
    required String name,
    required int salesCount,
    required double revenue,
    required int maxSales,
  }) {
    final double percentage = salesCount / maxSales;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Rank Circle
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: rank == 1 ? AppColors.primary : AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    rank.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: rank == 1 ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name & Category
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              // Details: Sales & Revenue
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$salesCount sold',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '\$${revenue.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(
                rank == 1 ? AppColors.primary : AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
