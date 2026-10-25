import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snack_bazaar/features/admin/models/seller_request.dart';

class SellerApplicationRepository {
  SellerApplicationRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<void> submit({
    required String businessName,
    required String phone,
    required String location,
    required String category,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Sign in before applying.');
    await _firestore.collection('sellerApplications').doc(user.uid).set({
      'ownerId': user.uid,
      'ownerName': user.displayName ?? '',
      'email': user.email ?? '',
      'businessName': businessName.trim(),
      'phone': phone.trim(),
      'location': location.trim(),
      'category': category.trim(),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<SellerRequest>> watchPending() => _firestore
      .collection('sellerApplications')
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => SellerRequest.fromFirestore(doc))
          .toList());

  Future<void> review(SellerRequest request, {required bool approve}) async {
    final applicationRef =
        _firestore.collection('sellerApplications').doc(request.id);
    final userRef = _firestore.collection('users').doc(request.id);
    await _firestore.runTransaction((transaction) async {
      final application = await transaction.get(applicationRef);
      if (!application.exists || application.data()?['status'] != 'pending') {
        throw StateError('This seller application has already been reviewed.');
      }
      transaction.update(applicationRef, {
        'status': approve ? 'approved' : 'rejected',
        'reviewedAt': FieldValue.serverTimestamp(),
      });
      if (approve) {
        transaction.update(userRef, {
          'role': 'seller',
          'status': 'approved',
          'businessName': request.businessName,
          'phone': request.phone,
          'location': request.location,
          'category': request.category,
        });
      }
    });
  }
}
