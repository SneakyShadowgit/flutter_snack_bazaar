import 'package:flutter/material.dart';
import 'package:snack_bazaar/core/theme/app_colors.dart';
import 'package:snack_bazaar/features/admin/models/seller_request.dart';

class SellerRequestCard extends StatelessWidget {
  final SellerRequest request;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const SellerRequestCard({
    super.key,
    required this.request,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Business icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.iconBgDark,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  request.icon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Business info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.businessName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Owner: ${request.ownerName}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              // Action buttons
              _buildRejectButton(),
              const SizedBox(width: 8),
              _buildApproveButton(),
            ],
          ),
          const SizedBox(height: 12),
          // Details row
          Row(
            children: [
              const SizedBox(width: 56), // align under text, past the icon
              _buildDetailChip(Icons.phone_outlined, request.phone),
              const SizedBox(width: 12),
              _buildDetailChip(Icons.location_on_outlined, request.location),
              const SizedBox(width: 12),
              _buildDetailChip(Icons.category_outlined, request.category),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRejectButton() {
    return SizedBox(
      height: 36,
      child: OutlinedButton(
        onPressed: onReject,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: const Text('Reject'),
      ),
    );
  }

  Widget _buildApproveButton() {
    return SizedBox(
      height: 36,
      child: ElevatedButton(
        onPressed: onApprove,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: const Text('Approve'),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
