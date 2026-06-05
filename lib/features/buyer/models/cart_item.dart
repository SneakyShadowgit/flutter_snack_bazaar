import 'package:snack_bazaar/features/seller/models/seller_product.dart';

class CartItem {
  final SellerProduct product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get total => product.price * quantity;
}
