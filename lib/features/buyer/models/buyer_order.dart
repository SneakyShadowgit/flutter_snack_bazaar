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

// Sample order history matching the design
final List<BuyerOrder> sampleBuyerOrders = [
  const BuyerOrder(
    id: 'bo1',
    orderNumber: 'SB-02547',
    timeString: 'May 25, 2026 - 10:30',
    itemSummaries: ['1x Artisanal Sourdough', '2x Cookies'],
    totalAmount: 42.50,
    status: BuyerOrderStatus.packed,
  ),
  const BuyerOrder(
    id: 'bo2',
    orderNumber: 'SB-02102',
    timeString: 'May 22, 2026 - 15:15',
    itemSummaries: ['1x Homemade Murukku'],
    totalAmount: 8.00,
    status: BuyerOrderStatus.delivered,
  ),
  const BuyerOrder(
    id: 'bo3',
    orderNumber: 'SB-01985',
    timeString: 'May 20, 2026 - 11:45',
    itemSummaries: ['2x Spicy Banana Chips'],
    totalAmount: 10.00,
    status: BuyerOrderStatus.delivered,
  ),
];
