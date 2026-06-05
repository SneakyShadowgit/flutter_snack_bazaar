// Firestore repository for fetching products in the Buyer module.
//
// This service encapsulates all Firestore interactions for the "products"
// collection. It provides a clean API for the UI layer to fetch products
// without directly depending on Firestore implementation details.
//
// Usage:
//   final repo = ProductRepository();
//   final products = await repo.fetchProducts();

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snack_bazaar/features/buyer/models/product.dart';

class ProductRepository {
  // Reference to the "products" collection in Firestore
  final CollectionReference _productsCollection =
      FirebaseFirestore.instance.collection('products');

  /// Fetches all products from the Firestore "products" collection.
  ///
  /// Returns a list of [Product] models parsed from Firestore document snapshots.
  /// Throws an exception if the Firestore query fails, which should be handled
  /// by the calling UI layer.
  Future<List<Product>> fetchProducts() async {
    final querySnapshot = await _productsCollection.get();

    return querySnapshot.docs
        .map((doc) => Product.fromFirestore(doc))
        .toList();
  }
}
