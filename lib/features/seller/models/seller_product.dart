import 'package:cloud_firestore/cloud_firestore.dart';

class SellerProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final int stockQuantity;
  final double rating;
  final String imageKey; // Category-style fallback illustration when no photo URL is set.
  final String imageUrl;
  final String? sellerId;
  final String sellerName;

  const SellerProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.stockQuantity,
    required this.rating,
    required this.imageKey,
    this.imageUrl = '',
    this.sellerId,
    this.sellerName = 'Local Seller',
  });

  /// Factory constructor to create a SellerProduct from a Firestore document snapshot.
  /// Maps document fields to our model, using sensible defaults for optional fields.
  factory SellerProduct.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SellerProduct(
      id: doc.id,
      name: data['name'] as String? ?? 'Unnamed Product',
      description: data['description'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      category: data['category'] as String? ?? 'Snacks',
      stockQuantity: (data['stockQuantity'] as num?)?.toInt() ?? 0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      imageKey: data['imageKey'] as String? ?? 'default',
      imageUrl: data['imageUrl'] as String? ?? '',
      sellerId: data['sellerId'] as String?,
      sellerName: data['seller'] as String? ?? 'Local Seller',
    );
  }

  /// Converts this SellerProduct to a Map suitable for Firestore document writes.
  /// The document ID is managed separately by Firestore, so it's not included here.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'stockQuantity': stockQuantity,
      'rating': rating,
      'imageKey': imageKey,
      'imageUrl': imageUrl,
      'seller': sellerName,
    };
  }

  SellerProduct copyWith({
    String? name,
    String? description,
    double? price,
    String? category,
    int? stockQuantity,
    double? rating,
    String? imageKey,
    String? imageUrl,
  }) {
    return SellerProduct(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      rating: rating ?? this.rating,
      imageKey: imageKey ?? this.imageKey,
      imageUrl: imageUrl ?? this.imageUrl,
      sellerId: sellerId,
      sellerName: sellerName,
    );
  }
}
