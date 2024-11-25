import 'dart:convert';
import 'dart:typed_data';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageBase64;
  final String shopOwnerId;
  final String status; // New field to handle product status

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageBase64,
    required this.shopOwnerId,
    required this.status,
  });

  // Convert imageBase64 string back to bytes for rendering images
  Uint8List imageBytes() {
    return Base64Decoder().convert(imageBase64);
  }

  // Factory to create a Product object from Firestore document
  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      name: map['title'] as String? ?? 'Untitled Product',
      description: map['description'] as String? ?? 'No description provided',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageBase64: map['imageBase64'] as String? ?? '',
      shopOwnerId: map['shopOwnerId'] as String? ?? '',
      status: map['status'] as String? ?? 'unknown', // Default to 'unknown' if not set
    );
  }

  // Convert Product object to Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'title': name,
      'description': description,
      'price': price,
      'imageBase64': imageBase64,
      'shopOwnerId': shopOwnerId,
      'status': status, // Ensure status is included when saving
    };
  }
}
