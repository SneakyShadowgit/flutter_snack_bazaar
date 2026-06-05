import 'package:flutter/material.dart';
import 'package:snack_bazaar/core/theme/app_colors.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Platform Insights',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Real-time performance metrics across the snack ecosystem.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 20),

          // Stats row
          _buildStatsRow(),
          const SizedBox(height: 20),

          // Top Categories + Top Sellers side by side
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildTopCategories()),
                const SizedBox(width: 14),
                Expanded(child: _buildTopSellers()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildInsightStatCard(
          icon: Icons.store,
          label: 'Total Sellers',
          value: '1,284',
        ),
        const SizedBox(width: 12),
        _buildInsightStatCard(
          icon: Icons.shopping_bag_outlined,
          label: 'Total Orders',
          value: '42,901',
        ),
        const SizedBox(width: 12),
        _buildInsightStatCard(
          icon: Icons.inventory_2_outlined,
          label: 'Total Products',
          value: '8,432',
        ),
      ],
    );
  }

  Widget _buildInsightStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Top Categories Card ──
  Widget _buildTopCategories() {
    final categories = [
      _CategoryData('Spicy Snacks', '12.4k sales', Icons.local_fire_department, const Color(0xFFE65100)),
      _CategoryData('Sweets', '10.1k sales', Icons.cake, const Color(0xFFC2185B)),
      _CategoryData('Savory Crunch', '8.7k sales', Icons.cookie, const Color(0xFFF9A825)),
      _CategoryData('Dried Fruits', '6.2k sales', Icons.eco, const Color(0xFF2E7D32)),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Categories',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Icon(Icons.category_outlined, size: 18, color: AppColors.textTertiary),
            ],
          ),
          const SizedBox(height: 16),

          // Category list
          ...categories.map((cat) => _buildCategoryRow(cat)),

          const SizedBox(height: 12),

          // View All button
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('View All Categories'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(_CategoryData category) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          // Category icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(category.icon, size: 18, color: category.color),
          ),
          const SizedBox(width: 12),
          // Category name
          Expanded(
            child: Text(
              category.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // Sales badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              category.sales,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Top Sellers Card ──
  Widget _buildTopSellers() {
    final sellers = [
      _TopSellerData('OC', 'Oven-Fresh Crisps', 'Bakery & Chips', '2,481 orders', 4.9),
      _TopSellerData('MK', "Mama's Kitchen", 'Traditional Sweets', '1,902 orders', 4.8),
      _TopSellerData('SN', 'Spice Nation', 'Hot & Spicy', '1,755 orders', 4.7),
      _TopSellerData('GT', 'Green Treats', 'Organic/Vegan', '1,420 orders', 4.6),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Sellers',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Icon(Icons.open_in_new, size: 16, color: AppColors.textTertiary),
            ],
          ),
          const SizedBox(height: 14),

          // Table header
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: Row(
              children: const [
                Expanded(
                  flex: 3,
                  child: Text(
                    'SELLER NAME',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'VOLUME',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    'RATING',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Seller rows
          ...sellers.map((s) => _buildSellerRow(s)),
        ],
      ),
    );
  }

  Widget _buildSellerRow(_TopSellerData seller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Initials avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                seller.initials,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Name + subtitle
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seller.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  seller.subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Volume
          Expanded(
            flex: 2,
            child: Text(
              seller.volume,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          // Rating
          SizedBox(
            width: 40,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  seller.rating.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.star, size: 14, color: Color(0xFFFFC107)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper data classes ──

class _CategoryData {
  final String name;
  final String sales;
  final IconData icon;
  final Color color;

  const _CategoryData(this.name, this.sales, this.icon, this.color);
}

class _TopSellerData {
  final String initials;
  final String name;
  final String subtitle;
  final String volume;
  final double rating;

  const _TopSellerData(this.initials, this.name, this.subtitle, this.volume, this.rating);
}
