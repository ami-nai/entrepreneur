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
      title: data['title'],
      price: data['price'],
      quantity: data['quantity'],
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
