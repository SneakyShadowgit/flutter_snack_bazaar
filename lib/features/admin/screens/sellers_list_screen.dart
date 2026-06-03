import 'package:flutter/material.dart';
import 'package:snack_bazaar/core/theme/app_colors.dart';
import 'package:snack_bazaar/features/admin/models/seller.dart';
import 'package:snack_bazaar/features/admin/widgets/seller_card.dart';

class SellersListScreen extends StatefulWidget {
  const SellersListScreen({super.key});

  @override
  State<SellersListScreen> createState() => _SellersListScreenState();
}

class _SellersListScreenState extends State<SellersListScreen> {
  late List<Seller> _sellers;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _sellers = List.from(sampleSellers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Seller> get _filteredSellers {
    if (_searchQuery.isEmpty) return _sellers;
    return _sellers
        .where((s) =>
            s.businessName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            s.location.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _toggleSellerStatus(Seller seller) {
    setState(() {
      final index = _sellers.indexWhere((s) => s.id == seller.id);
      if (index != -1) {
        final newStatus = seller.status == SellerStatus.active
            ? SellerStatus.suspended
            : SellerStatus.active;
        _sellers[index] = seller.copyWith(status: newStatus);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == SellerStatus.active
                  ? '${seller.businessName} reactivated!'
                  : '${seller.businessName} suspended.',
            ),
            backgroundColor: newStatus == SellerStatus.active
                ? AppColors.success
                : AppColors.warning,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredSellers;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Manage Sellers',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Browse and manage verified artisans and vendors',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Search bar
              SizedBox(
                width: 200,
                height: 40,
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search Sellers',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    ),
                    prefixIcon: const Icon(Icons.search,
                        size: 20, color: AppColors.textTertiary),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Sellers grid
          if (filtered.isEmpty)
            _buildEmptyState()
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.82,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final seller = filtered[index];
                return SellerCard(
                  seller: seller,
                  onViewDetails: () {
                    // TODO: Navigate to seller details
                  },
                  onToggleStatus: () => _toggleSellerStatus(seller),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.store_outlined,
            size: 64,
            color: AppColors.textTertiary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No sellers found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting your search query.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
