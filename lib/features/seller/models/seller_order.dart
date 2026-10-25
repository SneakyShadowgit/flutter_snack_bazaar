import 'package:cloud_firestore/cloud_firestore.dart';

enum SellerOrderStatus { pending, packed, shipped, delivered }

class SellerOrderItem {
  final String productName;
  final int quantity;
  final double price;

  const SellerOrderItem({
    required this.productName,
    required this.quantity,
    required this.price,
  });
}

class SellerOrder {
  final String id;
  final String orderNumber;
  final String customerName;
  final String timeString;
  final List<SellerOrderItem> items;
  final double totalAmount;
  final SellerOrderStatus status;
  final String phone;
  final String deliveryAddress;

  const SellerOrder({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.timeString,
    required this.items,
    required this.totalAmount,
    required this.status,
    this.phone = '',
    this.deliveryAddress = '',
  });

  factory SellerOrder.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    final createdAt = data['createdAt'];
    final date = createdAt is Timestamp ? createdAt.toDate() : DateTime.now();
    final rawItems = data['items'] as List<dynamic>? ?? const [];
    final items = rawItems.map((rawItem) {
      final item = Map<String, dynamic>.from(rawItem as Map);
      return SellerOrderItem(
        productName: item['productName'] as String? ?? 'Item',
        quantity: (item['quantity'] as num?)?.toInt() ?? 0,
        price: (item['unitPrice'] as num?)?.toDouble() ?? 0,
      );
    }).toList();
    final statusName = data['status'] as String? ?? 'pending';

    return SellerOrder(
      id: document.id,
      orderNumber: data['orderNumber'] as String? ?? document.id,
      customerName: data['customerName'] as String? ?? 'Buyer',
      timeString: date.toLocal().toString().substring(0, 16),
      items: items,
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0,
      status: SellerOrderStatus.values.firstWhere(
        (value) => value.name == statusName,
        orElse: () => SellerOrderStatus.pending,
      ),
      phone: data['phone'] as String? ?? '',
      deliveryAddress: data['deliveryAddress'] as String? ?? '',
    );
  }

  SellerOrder copyWith({
    String? customerName,
    String? timeString,
    List<SellerOrderItem>? items,
    double? totalAmount,
    SellerOrderStatus? status,
    String? phone,
    String? deliveryAddress,
  }) {
    return SellerOrder(
      id: id,
      orderNumber: orderNumber,
      customerName: customerName ?? this.customerName,
      timeString: timeString ?? this.timeString,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      phone: phone ?? this.phone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
    );
  }
}
