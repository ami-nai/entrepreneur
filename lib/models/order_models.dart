import 'order_item_model.dart';

class Order {
  final String id; // Firestore document ID
  final String buyerId;
  final String sellerId; // New field for seller ID
  final List<OrderItem> items;
  final double totalAmount;
  final String status;

  Order({
    required this.id,
    required this.buyerId,
    required this.sellerId, // Add sellerId here
    required this.items,
    required this.totalAmount,
    this.status = 'pending', // Default to pending
  });

  // Factory constructor to create an Order object from Firestore data
  factory Order.fromMap(String id, Map<String, dynamic> data) {
    return Order(
      id: id, // Use document ID from Firestore
      buyerId: data['buyerId'] ?? '', // Fallback to empty string if null
      sellerId: data['sellerId'] ?? '', // Fallback to empty string if null
      items: (data['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0, // Fallback to 0.0 if null
      status: data['status'] ?? 'pending', // Fallback to 'pending' if null
    );
  }

  // Convert an Order object into a Map to save to Firestore
  Map<String, dynamic> toMap() {
    return {
      'buyerId': buyerId,
      'sellerId': sellerId, // Include sellerId in the map
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
    };
  }
}
