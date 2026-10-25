import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snack_bazaar/core/theme/app_colors.dart';
import 'package:snack_bazaar/features/seller/models/seller_product.dart';
import 'package:snack_bazaar/features/buyer/models/cart_item.dart';
import 'package:snack_bazaar/features/buyer/models/buyer_order.dart';
import 'package:snack_bazaar/features/buyer/screens/buyer_browse_tab.dart';
import 'package:snack_bazaar/features/buyer/screens/cart_tab.dart';
import 'package:snack_bazaar/features/buyer/screens/orders_tab.dart';
import 'package:snack_bazaar/features/buyer/services/buyer_order_repository.dart';

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  int _currentTabIndex = 0;

  // Shared state
  final List<CartItem> _cartItems = [];
  final BuyerOrderRepository _orderRepository = BuyerOrderRepository();
  late final Stream<List<BuyerOrder>> _ordersStream;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    _ordersStream = _orderRepository.watchOrders();
    // Cart starts empty — products are now loaded dynamically from Firestore
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
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

  Future<void> _placeOrder() async {
    if (_cartItems.isEmpty || _isPlacingOrder) return;
    _phoneController.clear();
    _addressController.clear();
    final details = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delivery details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone number'),
            ),
            TextField(
              controller: _addressController,
              textCapitalization: TextCapitalization.sentences,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Delivery address'),
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Payment: Cash on delivery'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (_phoneController.text.trim().isEmpty ||
                  _addressController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter a phone number and delivery address.')),
                );
                return;
              }
              Navigator.pop(dialogContext, {
                'phone': _phoneController.text.trim(),
                'address': _addressController.text.trim(),
              });
            },
            child: const Text('Confirm order'),
          ),
        ],
      ),
    );
    if (details == null || !mounted) return;

    setState(() => _isPlacingOrder = true);
    final subtotal = _cartItems.fold(0.0, (sum, item) => sum + item.total);
    final deliveryFee = subtotal > 499.0 ? 0.0 : 49.0;
    try {
      await _orderRepository.placeCashOnDeliveryOrder(
        items: List<CartItem>.from(_cartItems),
        customerName: FirebaseAuth.instance.currentUser?.displayName ?? 'Buyer',
        phone: details['phone']!,
        deliveryAddress: details['address']!,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
      );
      if (!mounted) return;
      setState(() {
        _cartItems.clear();
        _currentTabIndex = 2;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cash-on-delivery order saved.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save order: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
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
              isCheckoutBusy: _isPlacingOrder,
            ),
            StreamBuilder<List<BuyerOrder>>(
              stream: _ordersStream,
              builder: (context, snapshot) => OrdersTab(
                orders: snapshot.data ?? const [],
                isLoading: snapshot.connectionState == ConnectionState.waiting,
                errorMessage: snapshot.hasError ? 'Could not load orders: ${snapshot.error}' : null,
              ),
            ),
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
