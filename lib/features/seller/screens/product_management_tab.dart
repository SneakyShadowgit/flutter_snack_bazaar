import 'package:flutter/material.dart';
import 'package:snack_bazaar/core/theme/app_colors.dart';
import 'package:snack_bazaar/features/seller/models/seller_product.dart';
import 'package:snack_bazaar/features/seller/screens/add_edit_product_screen.dart';
import 'package:snack_bazaar/features/seller/services/seller_product_repository.dart';

class ProductManagementTab extends StatefulWidget {
  const ProductManagementTab({super.key});

  @override
  State<ProductManagementTab> createState() => _ProductManagementTabState();
}

class _ProductManagementTabState extends State<ProductManagementTab> {
  // Firestore repository instance for product CRUD operations
  final SellerProductRepository _productRepository = SellerProductRepository();

  // List of products fetched from Firestore (replaces old sampleSellerProducts)
  List<SellerProduct> _products = [];
  String _searchQuery = '';

  // Loading state: true while initial Firestore fetch is in progress
  bool _isLoading = true;

  // Error message: non-null when the Firestore fetch fails
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Fetch products from Firestore when the tab is first initialized
    _loadProducts();
  }

  /// Fetches all products from Firestore via the repository.
  /// Updates loading, error, and data states accordingly.
  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await _productRepository.fetchProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load products. Please try again.';
        _isLoading = false;
      });
    }
  }

  /// Handles product deletion with a confirmation dialog.
  /// On confirm, deletes the product from Firestore and refreshes the local list.
  void _handleDelete(SellerProduct product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);

              // Capture messenger before the async gap to avoid lint warnings
              final messenger = ScaffoldMessenger.of(context);

              // Show a loading indicator while deleting
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Deleting product...'),
                  duration: Duration(seconds: 1),
                ),
              );

              try {
                // Delete from Firestore
                await _productRepository.deleteProduct(product.id);

                // Remove from local list
                setState(() {
                  _products.removeWhere((p) => p.id == product.id);
                });

                messenger.showSnackBar(
                  SnackBar(
                    content: Text('${product.name} deleted'),
                    backgroundColor: AppColors.error,
                  ),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete ${product.name}. Please try again.'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Navigates to the Add/Edit product screen.
  /// On return, refreshes the product list from Firestore to reflect any changes.
  void _navigateToAddEdit({SellerProduct? product}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditProductScreen(product: product),
      ),
    );

    // If the add/edit screen returned true (success), refresh the product list
    if (result == true) {
      _loadProducts();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(product == null ? 'Product added successfully!' : 'Product updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _products.where((product) {
      return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            _buildSearchBar(),
            const SizedBox(height: 24),

            // Inventory header
            const Text(
              'Inventory',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const Text(
              'Manage your snack products and availability',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // --- Loading State ---
            if (_isLoading)
              _buildLoadingState(),

            // --- Error State ---
            if (!_isLoading && _errorMessage != null)
              _buildErrorState(),

            // --- Data / Empty State ---
            if (!_isLoading && _errorMessage == null) ...[
              if (filteredProducts.isEmpty)
                _buildEmptyInventoryState()
              else
                ...filteredProducts.map((p) => _buildProductCard(p)),
            ],

            const SizedBox(height: 80), // Offset for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEdit(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildProductCard(SellerProduct product) {
    final bool isLowStock = product.stockQuantity <= 10;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Snack visual drawing
                SnackVisualThumbnail(imageKey: product.imageKey),
                const SizedBox(width: 14),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              product.category,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 14, color: Color(0xFFFFC107)),
                              const SizedBox(width: 2),
                              Text(
                                product.rating.toString(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Stock status indicator
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isLowStock ? AppColors.error : AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isLowStock
                                ? 'Low Stock: ${product.stockQuantity} items left'
                                : 'In Stock: ${product.stockQuantity} items available',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isLowStock ? AppColors.error : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _navigateToAddEdit(product: product),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _handleDelete(product),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.errorLight),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Loading state widget — shown while products are being fetched from Firestore.
  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading products...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Error state widget — shown when the Firestore fetch fails.
  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.cloud_off, size: 64, color: AppColors.primary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _errorMessage ?? 'An unexpected error occurred.',
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadProducts,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyInventoryState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: const Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textTertiary),
          SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Try adjusting your search query or add a new product.',
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Reusable Thumbnail drawing component to display beautiful, local representations of food items
class SnackVisualThumbnail extends StatelessWidget {
  final String imageKey;
  final double size;

  const SnackVisualThumbnail({
    super.key,
    required this.imageKey,
    this.size = 76,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData = Icons.cookie;
    Color circleColor = Colors.orange;

    switch (imageKey) {
      case 'banana_chips':
        iconData = Icons.bakery_dining_outlined;
        circleColor = const Color(0xFFFBC02D);
        break;
      case 'pretzels':
        iconData = Icons.cookie_outlined;
        circleColor = const Color(0xFF8D6E63);
        break;
      case 'peanuts':
        iconData = Icons.eco_outlined;
        circleColor = const Color(0xFFFFA726);
        break;
      case 'sourdough':
        iconData = Icons.breakfast_dining_outlined;
        circleColor = const Color(0xFFFFCC80);
        break;
      case 'pickle':
        iconData = Icons.dining_outlined;
        circleColor = const Color(0xFF66BB6A);
        break;
      case 'cake':
        iconData = Icons.cake_outlined;
        circleColor = const Color(0xFFEC407A);
        break;
      case 'murukku':
        iconData = Icons.motion_photos_on_outlined;
        circleColor = const Color(0xFFFF7043);
        break;
      case 'cookies':
        iconData = Icons.cookie;
        circleColor = const Color(0xFF5D4037);
        break;
      default:
        iconData = Icons.storefront;
        circleColor = AppColors.primary;
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: circleColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: circleColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Center(
        child: Icon(
          iconData,
          size: size * 0.45,
          color: circleColor,
        ),
      ),
    );
  }
}
