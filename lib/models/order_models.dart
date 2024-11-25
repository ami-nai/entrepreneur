import 'order_item_model.dart';

class Order {
  final String id; // Firestore document ID
  final String buyerId;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;

  Order({
    required this.id,
    required this.buyerId,
    required this.items,
    required this.totalAmount,
    this.status = 'pending', // Default to pending
  });

  // Factory constructor to create an Order object from Firestore data
  factory Order.fromMap(String id, Map<String, dynamic> data) {
    var items = (data['items'] as List)
        .map((item) => OrderItem.fromMap(item)) // Convert items list into OrderItem objects
        .toList();
    return Order(
      id: id, // Use document ID from Firestore
      buyerId: data['buyerId'],
      items: items,
      totalAmount: (data['totalAmount'] as num).toDouble(),
      status: data['status'] ?? 'pending',
    );
  }

  // Convert an Order object into a Map to save to Firestore
  Map<String, dynamic> toMap() {
    return {
      'buyerId': buyerId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
    };
  }
}
