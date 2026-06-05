import 'package:flutter/material.dart';
import 'package:snack_bazaar/core/theme/app_colors.dart';
import 'package:snack_bazaar/features/seller/models/seller_product.dart';
import 'package:snack_bazaar/features/buyer/models/cart_item.dart';
import 'package:snack_bazaar/features/buyer/models/buyer_order.dart';
import 'package:snack_bazaar/features/buyer/screens/buyer_browse_tab.dart';
import 'package:snack_bazaar/features/buyer/screens/cart_tab.dart';
import 'package:snack_bazaar/features/buyer/screens/orders_tab.dart';

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  int _currentTabIndex = 0;

  // Shared state
  final List<CartItem> _cartItems = [];
  late List<BuyerOrder> _buyerOrders;

  @override
  void initState() {
    super.initState();
    _buyerOrders = List.from(sampleBuyerOrders);
    // Cart starts empty — products are now loaded dynamically from Firestore
  }

  void _addToCart(SellerProduct product, {int quantity = 1}) {
    setState(() {
      final index = _cartItems.indexWhere((item) => item.product.id == product.id);
      if (index != -1) {
        _cartItems[index].quantity += quantity;
      } else {
        _cartItems.add(CartItem(product: product, quantity: quantity));
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart!'),
        backgroundColor: Colors.orange[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _currentTabIndex = 1; // Swap to Cart tab
            });
          },
        ),
      ),
    );
  }

  void _updateCartQuantity(SellerProduct product, int delta) {
    setState(() {
      final index = _cartItems.indexWhere((item) => item.product.id == product.id);
      if (index != -1) {
        _cartItems[index].quantity += delta;
        if (_cartItems[index].quantity <= 0) {
          _cartItems.removeAt(index);
        }
      }
    });
  }

  void _removeFromCart(SellerProduct product) {
    setState(() {
      _cartItems.removeWhere((item) => item.product.id == product.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} removed from cart'),
        backgroundColor: AppColors.textPrimary,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _placeOrder() {
    if (_cartItems.isEmpty) return;

    final double total = _cartItems.fold(0.0, (sum, item) => sum + item.total);
    final List<String> summaries = _cartItems.map((item) => '${item.quantity}x ${item.product.name}').toList();

    setState(() {
      // Create new buyer order
      final newOrderNum = 'SB-0${2548 + _buyerOrders.length}';
      final newOrder = BuyerOrder(
        id: 'bo_${DateTime.now().millisecondsSinceEpoch}',
        orderNumber: newOrderNum,
        timeString: 'Just now',
        itemSummaries: summaries,
        totalAmount: total,
        status: BuyerOrderStatus.pending,
      );

      _buyerOrders.insert(0, newOrder);
      _cartItems.clear();
      _currentTabIndex = 2; // Route to Orders tab
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Order placed successfully! Checkout completed.'),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _currentTabIndex,
          children: [
            BuyerBrowseTab(onAddToCart: _addToCart),
            CartTab(
              cartItems: _cartItems,
              onUpdateQuantity: _updateCartQuantity,
              onRemove: _removeFromCart,
              onCheckout: _placeOrder,
            ),
            OrdersTab(orders: _buyerOrders),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: BottomNavigationBar(
            currentIndex: _currentTabIndex,
            onTap: (index) => setState(() => _currentTabIndex = index),
            elevation: 0,
            backgroundColor: Colors.transparent,
            selectedItemColor: Colors.orange[800],
            unselectedItemColor: AppColors.textSecondary,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.storefront_outlined, 0),
                activeIcon: _buildNavIcon(Icons.storefront, 0, isActive: true),
                label: 'Shop',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildNavIcon(Icons.shopping_cart_outlined, 1),
                    if (_cartItems.isNotEmpty)
                      Positioned(
                        right: 8,
                        top: 2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${_cartItems.fold(0, (sum, item) => sum + item.quantity)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                activeIcon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildNavIcon(Icons.shopping_cart, 1, isActive: true),
                    if (_cartItems.isNotEmpty)
                      Positioned(
                        right: 8,
                        top: 2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${_cartItems.fold(0, (sum, item) => sum + item.quantity)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Cart',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.assignment_outlined, 2),
                activeIcon: _buildNavIcon(Icons.assignment, 2, isActive: true),
                label: 'Orders',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index, {bool isActive = false}) {
    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.orange[800]!.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, size: 24),
      );
    }
    return Icon(icon, size: 24);
  }
}
