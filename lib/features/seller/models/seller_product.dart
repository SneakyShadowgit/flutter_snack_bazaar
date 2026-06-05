import 'package:cloud_firestore/cloud_firestore.dart';

class SellerProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final int stockQuantity;
  final double rating;
  final String imageKey; // Identifies which snack style/mock representation to draw or load

  const SellerProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.stockQuantity,
    required this.rating,
    required this.imageKey,
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
      'seller': "Baker's Kitchen", // Default seller name for the current seller portal
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
    );
  }
}


// Global list of mock seller inventory
final List<SellerProduct> sampleSellerProducts = [
  const SellerProduct(
    id: 'p1',
    name: 'Spicy Banana Chips',
    description: 'Crispy, thinly sliced plantains seasoned with a spicy blend of chili powder, salt, and local spices. The perfect salty crunch with a hot kick!',
    price: 5.00,
    category: 'Chips',
    stockQuantity: 24,
    rating: 4.8,
    imageKey: 'banana_chips',
  ),
  const SellerProduct(
    id: 'p2',
    name: 'Honey Mustard Pretzels',
    description: 'Classic crunchy pretzels coated in a thick, sweet, and tangy honey mustard seasoning. A satisfying sweet-salty combination.',
    price: 4.50,
    category: 'Snacks',
    stockQuantity: 12,
    rating: 4.9,
    imageKey: 'pretzels',
  ),
  const SellerProduct(
    id: 'p3',
    name: 'Masala Peanuts',
    description: 'Roasted peanuts tossed in a rich, aromatic mix of Indian masalas and spices. Great for sharing or enjoying as a quick savory snack.',
    price: 3.75,
    category: 'Snacks',
    stockQuantity: 8,
    rating: 3.5,
    imageKey: 'peanuts',
  ),
  const SellerProduct(
    id: 'p4',
    name: 'Artisanal Wild Yeast Sourdough',
    description: 'Our signature 48-hour fermented wild yeast sourdough. Hand-shaped and stone-baked for a thick, bubbly crust and an airy, tangy crumb. No preservatives.',
    price: 12.00,
    category: 'Breads',
    stockQuantity: 25,
    rating: 4.5,
    imageKey: 'sourdough',
  ),
];
