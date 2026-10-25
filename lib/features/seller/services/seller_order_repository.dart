import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snack_bazaar/features/seller/models/seller_order.dart';

class SellerOrderRepository {
  SellerOrderRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Stream<List<SellerOrder>> watchOrders() {
    final sellerId = _auth.currentUser?.uid;
    if (sellerId == null) throw StateError('Sign in to view seller orders.');
    return _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map((snapshot) {
          final docs = [...snapshot.docs];
          docs.sort((a, b) {
            final aTime = a.data()['createdAt'];
            final bTime = b.data()['createdAt'];
            if (aTime is! Timestamp || bTime is! Timestamp) return 0;
            return bTime.compareTo(aTime);
          });
          return docs.map(SellerOrder.fromFirestore).toList();
        });
  }

  Future<void> advanceStatus(SellerOrder order) async {
    final nextStatus = switch (order.status) {
      SellerOrderStatus.pending => SellerOrderStatus.packed,
      SellerOrderStatus.packed => SellerOrderStatus.shipped,
      SellerOrderStatus.shipped => SellerOrderStatus.delivered,
      SellerOrderStatus.delivered => null,
    };
    if (nextStatus == null) return;
    await _firestore.collection('orders').doc(order.id).update({
      'status': nextStatus.name,
    });
  }
}
