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

  const SellerOrder({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.timeString,
    required this.items,
    required this.totalAmount,
    required this.status,
  });

  SellerOrder copyWith({
    String? customerName,
    String? timeString,
    List<SellerOrderItem>? items,
    double? totalAmount,
    SellerOrderStatus? status,
  }) {
    return SellerOrder(
      id: id,
      orderNumber: orderNumber,
      customerName: customerName ?? this.customerName,
      timeString: timeString ?? this.timeString,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
    );
  }
}

// Mock active orders matching the designs
final List<SellerOrder> sampleSellerOrders = [
  const SellerOrder(
    id: 'o1',
    orderNumber: '9021',
    customerName: 'Juliana Moore',
    timeString: 'Today, 10:45 AM',
    items: [
      SellerOrderItem(productName: 'Artisanal Wild Yeast Sourdough', quantity: 1, price: 12.00),
      SellerOrderItem(productName: 'Spicy Banana Chips', quantity: 2, price: 5.00),
      SellerOrderItem(productName: 'Honey Mustard Pretzels', quantity: 3, price: 4.50),
    ],
    totalAmount: 35.50,
    status: SellerOrderStatus.shipped,
  ),
  const SellerOrder(
    id: 'o2',
    orderNumber: '8514',
    customerName: 'David Sterling',
    timeString: 'Oct 25, 02:30 PM',
    items: [
      SellerOrderItem(productName: 'Artisanal Wild Yeast Sourdough', quantity: 12, price: 12.00),
    ],
    totalAmount: 148.00,
    status: SellerOrderStatus.packed,
  ),
  const SellerOrder(
    id: 'o3',
    orderNumber: '8204',
    customerName: 'Sarah Jenkins',
    timeString: 'Yesterday, 04:15 PM',
    items: [
      SellerOrderItem(productName: 'Pure Truffle Cake', quantity: 1, price: 18.00),
    ],
    totalAmount: 18.00,
    status: SellerOrderStatus.pending,
  ),
];
