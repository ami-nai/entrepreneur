import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onAddToCart;
  final VoidCallback? onDelete;
  final bool isShopOwner;

  const ProductCard({
    Key? key,
    required this.product,
    this.onAddToCart,
    this.onDelete,
    this.isShopOwner = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display the product image
          product.imageBase64 != null
              ? Image.memory(
                  product.imageBytes(),
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                )
              : Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Center(child: Text('No Image')),
                ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  product.description,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16, color: Colors.green),
                ),
              ],
            ),
          ),
          OverflowBar(
            alignment: MainAxisAlignment.end,
            children: [
              if (!isShopOwner && onAddToCart != null)
                ElevatedButton(
                  onPressed: onAddToCart,
                  child: Text('Add to Cart'),
                ),
              if (isShopOwner && onDelete != null)
                ElevatedButton(
                  onPressed: onDelete,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text('Delete'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
