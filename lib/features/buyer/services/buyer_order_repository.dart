import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snack_bazaar/features/buyer/models/cart_item.dart';
import 'package:snack_bazaar/features/buyer/models/buyer_order.dart';

class BuyerOrderRepository {
  BuyerOrderRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Stream<List<BuyerOrder>> watchOrders() {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Sign in to view your orders.');
    return _firestore
        .collection('orders')
        .where('buyerId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          final documents = [...snapshot.docs];
          documents.sort((a, b) {
            final aTime = a.data()['createdAt'];
            final bTime = b.data()['createdAt'];
            if (aTime is! Timestamp || bTime is! Timestamp) return 0;
            return bTime.compareTo(aTime);
          });
          return documents.map(BuyerOrder.fromFirestore).toList();
        });
  }

  Future<void> placeCashOnDeliveryOrder({
    required List<CartItem> items,
    required String customerName,
    required String phone,
    required String deliveryAddress,
    required double subtotal,
    required double deliveryFee,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Sign in before placing an order.');
    if (items.isEmpty) throw StateError('Your cart is empty.');

    final groupedItems = <String, List<CartItem>>{};
    for (final item in items) {
      final key = item.product.sellerId ?? 'unassigned';
      groupedItems.putIfAbsent(key, () => []).add(item);
    }

    final batch = _firestore.batch();
    var groupIndex = 0;
    for (final entry in groupedItems.entries) {
      final group = entry.value;
      final sellerSubtotal =
          group.fold<double>(0, (sum, item) => sum + item.total);
      final groupDeliveryFee = groupIndex == 0 ? deliveryFee : 0.0;
      final orderRef = _firestore.collection('orders').doc();
      final now = DateTime.now();
      final data = <String, dynamic>{
        'buyerId': user.uid,
        'customerName': customerName.trim(),
        'customerEmail': user.email,
        'phone': phone.trim(),
        'deliveryAddress': deliveryAddress.trim(),
        'orderNumber': 'SB-${now.millisecondsSinceEpoch}-$groupIndex',
        'items': group
            .map((item) => {
                  'productId': item.product.id,
                  'productName': item.product.name,
                  'category': item.product.category,
                  'quantity': item.quantity,
                  'unitPrice': item.product.price,
                  'lineTotal': item.total,
                  'sellerName': group.first.product.sellerName,
                  'sellerId': item.product.sellerId,
                })
            .toList(),
        'subtotal': sellerSubtotal,
        'deliveryFee': groupDeliveryFee,
        'totalAmount': sellerSubtotal + groupDeliveryFee,
        'paymentMethod': 'cash_on_delivery',
        'paymentStatus': 'due_on_delivery',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };
      if (entry.key != 'unassigned') data['sellerId'] = entry.key;
      batch.set(orderRef, data);
      groupIndex++;
    }
    await batch.commit();
  }
}
