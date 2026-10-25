import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountService {
  AccountService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> createBuyerAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    try {
      await credential.user!.updateDisplayName(name.trim());
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'displayName': name.trim(),
        'email': email.trim(),
        'role': 'buyer',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Avoid leaving a signed-in Auth account that has no usable profile.
      await credential.user!.delete();
      rethrow;
    }
  }

  Future<void> signOut() => _auth.signOut();

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchProfile(String uid) =>
      _firestore.collection('users').doc(uid).snapshots();
}
