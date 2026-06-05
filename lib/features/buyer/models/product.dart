// Product model for the Buyer module.
//
// Represents a product document fetched from the Firestore "products" collection.
// Each document contains fields: name (string), price (number), seller (string).
//
// This model also includes optional fields (description, category, stockQuantity,
// rating, imageKey) that may be present in Firestore documents. These map to the
// existing SellerProduct structure so the rest of the buyer UI can work seamlessly.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snack_bazaar/features/seller/models/seller_product.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String seller;

  // Optional fields that may exist in Firestore documents.
  // These provide richer data for the product cards and detail screen.
  final String description;
  final String category;
  final int stockQuantity;
  final double rating;
  final String imageKey;
  final String location;
  final bool isVeg;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.seller,
    this.description = '',
    this.category = 'Snacks',
    this.stockQuantity = 0,
    this.rating = 0.0,
    this.imageKey = 'default',
    this.location = '',
    this.isVeg = true,
  });

  /// Factory constructor to create a Product from a Firestore document snapshot.
  /// Maps the Firestore document fields to our local model, using sensible
  /// defaults for any optional fields that may not be present.
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Product(
      id: doc.id,
      name: data['name'] as String? ?? 'Unnamed Product',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      seller: data['seller'] as String? ?? 'Unknown Seller',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? 'Snacks',
      stockQuantity: (data['stockQuantity'] as num?)?.toInt() ?? 0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      imageKey: data['imageKey'] as String? ?? 'default',
      location: data['location'] as String? ?? '',
      isVeg: data['isVeg'] as bool? ?? true,
    );
  }

  /// Converts this Product to a SellerProduct instance.
  /// This allows seamless integration with existing screens (ProductDetailScreen,
  /// CartTab, etc.) that rely on the SellerProduct type.
  SellerProduct toSellerProduct() {
    return SellerProduct(
      id: id,
      name: name,
      description: description,
      price: price,
      category: category,
      stockQuantity: stockQuantity,
      rating: rating,
      imageKey: imageKey,
    );
  }
}
