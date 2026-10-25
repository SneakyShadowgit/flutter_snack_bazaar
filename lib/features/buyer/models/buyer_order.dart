import 'package:cloud_firestore/cloud_firestore.dart';

enum BuyerOrderStatus { pending, packed, shipped, delivered, cancelled }

class BuyerOrder {
  final String id;
  final String orderNumber;
  final String timeString;
  final List<String> itemSummaries;
  final double totalAmount;
  final BuyerOrderStatus status;

  const BuyerOrder({
    required this.id,
    required this.orderNumber,
    required this.timeString,
    required this.itemSummaries,
    required this.totalAmount,
    required this.status,
  });

  factory BuyerOrder.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    final createdAt = data['createdAt'];
    final date = createdAt is Timestamp ? createdAt.toDate() : DateTime.now();
    final rawItems = data['items'] as List<dynamic>? ?? const [];
    final summaries = rawItems.map((rawItem) {
      final item = Map<String, dynamic>.from(rawItem as Map);
      return '${item['quantity'] ?? 0}x ${item['productName'] ?? 'Item'}';
    }).toList();
    final statusName = data['status'] as String? ?? 'pending';

    return BuyerOrder(
      id: document.id,
      orderNumber: data['orderNumber'] as String? ?? document.id,
      timeString: date.toLocal().toString().substring(0, 16),
      itemSummaries: summaries,
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0,
      status: BuyerOrderStatus.values.firstWhere(
        (value) => value.name == statusName,
        orElse: () => BuyerOrderStatus.pending,
      ),
    );
  }

  BuyerOrder copyWith({
    String? timeString,
    List<String>? itemSummaries,
    double? totalAmount,
    BuyerOrderStatus? status,
  }) {
    return BuyerOrder(
      id: id,
      orderNumber: orderNumber,
      timeString: timeString ?? this.timeString,
      itemSummaries: itemSummaries ?? this.itemSummaries,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
    );
  }
}
