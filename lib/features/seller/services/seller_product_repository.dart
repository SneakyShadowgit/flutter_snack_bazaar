// Firestore repository for Seller product CRUD operations.
//
// This service encapsulates all Firestore interactions for the "products"
// collection from the Seller's perspective. It provides create, read, update,
// and delete (CRUD) operations so the UI layer doesn't depend on Firestore
// implementation details directly.
//
// Usage:
//   final repo = SellerProductRepository();
//   await repo.addProduct(product);
//   await repo.updateProduct(product);
//   await repo.deleteProduct(productId);
//   final products = await repo.fetchProducts();

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snack_bazaar/features/seller/models/seller_product.dart';

class SellerProductRepository {
  // Reference to the "products" collection in Firestore
  final CollectionReference _productsCollection =
      FirebaseFirestore.instance.collection('products');

  /// Fetches all products from the Firestore "products" collection.
  ///
  /// Returns a list of [SellerProduct] models parsed from Firestore snapshots.
  /// Throws an exception if the query fails (handled by calling UI layer).
  Future<List<SellerProduct>> fetchProducts() async {
    final querySnapshot = await _productsCollection.get();
    return querySnapshot.docs
        .map((doc) => SellerProduct.fromFirestore(doc))
        .toList();
  }

  /// Adds a new product document to the Firestore "products" collection.
  ///
  /// Firestore auto-generates the document ID. Returns the generated document ID
  /// so the UI can update the local product's ID reference if needed.
  Future<String> addProduct(SellerProduct product) async {
    final docRef = await _productsCollection.add(product.toFirestore());
    return docRef.id;
  }

  /// Updates an existing product document in Firestore.
  ///
  /// Uses the product's [id] field as the Firestore document ID.
  /// Performs a full overwrite of the document fields via merge.
  Future<void> updateProduct(SellerProduct product) async {
    await _productsCollection.doc(product.id).update(product.toFirestore());
  }

  /// Deletes a product document from the Firestore "products" collection.
  ///
  /// Uses the provided [productId] as the Firestore document ID.
  Future<void> deleteProduct(String productId) async {
    await _productsCollection.doc(productId).delete();
  }
}
