class OrderItem {
  final String title;
  final double price;
  final int quantity;

  OrderItem({
    required this.title,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      title: data['title'] ?? 'Unknown Item', // Fallback to 'Unknown Item' if null
      price: (data['price'] as num?)?.toDouble() ?? 0.0, // Fallback to 0.0 if null
      quantity: data['quantity'] ?? 0, // Fallback to 0 if null
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'quantity': quantity,
    };
  }
}
