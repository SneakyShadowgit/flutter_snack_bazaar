import 'package:flutter/material.dart';
import 'package:snack_bazaar/core/theme/app_colors.dart';
import 'package:snack_bazaar/features/seller/models/seller_product.dart';
import 'package:snack_bazaar/features/seller/screens/product_management_tab.dart'; // for SnackVisualThumbnail
import 'package:snack_bazaar/features/buyer/screens/product_detail_screen.dart';
import 'package:snack_bazaar/features/buyer/models/product.dart';
import 'package:snack_bazaar/features/buyer/services/product_repository.dart';

class BuyerBrowseTab extends StatefulWidget {
  final Function(SellerProduct, {int quantity}) onAddToCart;

  const BuyerBrowseTab({super.key, required this.onAddToCart});

  @override
  State<BuyerBrowseTab> createState() => _BuyerBrowseTabState();
}

class _BuyerBrowseTabState extends State<BuyerBrowseTab> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _filterVegetarianOnly = false;

  final List<String> _categories = ['All', 'Chips', 'Snacks', 'Breads', 'Cookies', 'Cakes', 'Pickles'];

  // --- Firestore integration ---
  // Repository instance for fetching products from Firestore
  final ProductRepository _productRepository = ProductRepository();

  // List of products fetched from Firestore (replaces the old hardcoded _buyerProducts)
  List<Product> _firestoreProducts = [];

  // Loading state: true while the initial Firestore fetch is in progress
  bool _isLoading = true;

  // Error message: non-null when the Firestore fetch fails
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Fetch products from Firestore as soon as this tab is initialized
    _loadProducts();
  }

  /// Fetches products from the Firestore "products" collection via the repository.
  /// Updates the loading, error, and data states accordingly.
  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await _productRepository.fetchProducts();
      setState(() {
        _firestoreProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load products. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Apply search and filter criteria to the Firestore-fetched product list
    final filteredList = _firestoreProducts.where((product) {
      final matchesQuery = product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.seller.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.category.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'All' || product.category == _selectedCategory;

      final matchesVeg = !_filterVegetarianOnly || product.isVeg;

      return matchesQuery && matchesCategory && matchesVeg;
    }).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          _buildHeaderRow(),
          const SizedBox(height: 16),

          // Search Input
          _buildSearchInput(),
          const SizedBox(height: 18),

          // Category Chips List (horizontal slider)
          _buildCategorySlider(),
          const SizedBox(height: 14),

          // Filter tags
          _buildFilterRow(),
          const SizedBox(height: 18),

          // --- Loading State ---
          // Displays a centered loading indicator while fetching products from Firestore
          if (_isLoading)
            _buildLoadingState(),

          // --- Error State ---
          // Displays an error message with a retry button when the Firestore fetch fails
          if (!_isLoading && _errorMessage != null)
            _buildErrorState(),

          // --- Data / Empty State ---
          // Shows the product cards when data is loaded, or an empty-state when
          // there are no products matching the current filters
          if (!_isLoading && _errorMessage == null) ...[
            ...filteredList.map((product) => _buildProductCard(product)),

            if (filteredList.isEmpty)
              _buildEmptyBrowseState(),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          tooltip: 'Change Portal',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SnackCraft',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.orange[800],
                  letterSpacing: -0.5,
                ),
              ),
              Row(
                children: const [
                  Icon(Icons.location_on, size: 12, color: AppColors.textSecondary),
                  SizedBox(width: 2),
                  Text(
                    'Dallas, Texas',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.orange[800]!.withValues(alpha: 0.1),
          child: Icon(Icons.person, color: Colors.orange[800], size: 18),
        ),
      ],
    );
  }

  Widget _buildSearchInput() {
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
        decoration: const InputDecoration(
          hintText: 'Search for chips, cookies, or cakes...',
          hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 13.5),
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCategorySlider() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = cat == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = cat;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.orange[800] : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.orange[800]! : AppColors.border,
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        FilterChip(
          label: const Text('Vegetarian'),
          selected: _filterVegetarianOnly,
          onSelected: (val) {
            setState(() {
              _filterVegetarianOnly = val;
            });
          },
          selectedColor: Colors.orange[800]!.withValues(alpha: 0.12),
          checkmarkColor: Colors.orange[800],
          labelStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _filterVegetarianOnly ? Colors.orange[800] : AppColors.textSecondary,
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: _filterVegetarianOnly ? Colors.orange[800]! : AppColors.border),
          ),
        ),
      ],
    );
  }

  /// Builds a product card from a Firestore-fetched [Product].
  /// Converts it to a SellerProduct internally so the rest of the UI
  /// (ProductDetailScreen, cart operations) continues to work unchanged.
  Widget _buildProductCard(Product product) {
    // Convert to SellerProduct for compatibility with existing screens
    final sellerProduct = product.toSellerProduct();
    final String sellerName = product.seller;
    final String location = product.location;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(
                  product: sellerProduct,
                  sellerName: sellerName,
                  location: location,
                  onAddToCart: widget.onAddToCart,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image / Visual Box
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 160,
                    color: Colors.amber.withValues(alpha: 0.05),
                    child: Center(
                      child: SnackVisualThumbnail(imageKey: sellerProduct.imageKey, size: 100),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange[800],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'New Seller',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 1, color: AppColors.border),

              // Title, rating, seller
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sellerProduct.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'by $sellerName • $location',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                '\$${sellerProduct.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.orange[800],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 14, color: Color(0xFFFFC107)),
                                  const SizedBox(width: 2),
                                  Text(
                                    sellerProduct.rating.toString(),
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Add Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[800],
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onPressed: () => widget.onAddToCart(sellerProduct),
                      child: const Icon(Icons.add_shopping_cart, size: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Loading state widget — shown while products are being fetched from Firestore.
  /// Uses a CircularProgressIndicator styled to match the app's orange theme.
  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[800]!),
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
  /// Displays an error icon, message, and a retry button to re-attempt the fetch.
  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.cloud_off, size: 64, color: Colors.orange[300]),
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
              backgroundColor: Colors.orange[800],
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

  /// Empty state widget — shown when no products match the current search/filter.
  Widget _buildEmptyBrowseState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: const Column(
        children: [
          Icon(Icons.search_off, size: 64, color: AppColors.textTertiary),
          SizedBox(height: 16),
          Text(
            'No matching snacks',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Try widening your search queries or select a different category.',
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
