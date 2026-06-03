import 'package:flutter/material.dart';
import 'package:snack_bazaar/core/theme/app_colors.dart';
import 'package:snack_bazaar/features/admin/models/seller.dart';

class SellerCard extends StatelessWidget {
  final Seller seller;
  final VoidCallback? onViewDetails;
  final VoidCallback? onToggleStatus;

  const SellerCard({
    super.key,
    required this.seller,
    this.onViewDetails,
    this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = seller.status == SellerStatus.active;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: icon + name + status badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Business icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: seller.iconBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    seller.icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                // Name + badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        seller.businessName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      _buildStatusBadge(isActive),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Phone
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    seller.phone,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Location
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    seller.location,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Action buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // View Details button
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: onViewDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(height: 6),

                // Suspend / Reactivate button
                SizedBox(
                  height: 34,
                  child: TextButton(
                    onPressed: onToggleStatus,
                    style: TextButton.styleFrom(
                      foregroundColor: isActive ? AppColors.error : AppColors.success,
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(
                      isActive ? 'Suspend Seller' : 'Reactivate Seller',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive ? AppColors.successLight : AppColors.warningLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isActive ? 'Active' : 'Suspended',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isActive ? AppColors.success : AppColors.warning,
        ),
      ),
    );
  }
}
