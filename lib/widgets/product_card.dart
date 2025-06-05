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
      margin: EdgeInsets.all(4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4.0,
      child: Column(
        children: [
          // Image Section
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.19,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
              child: product.imageBase64 != null
                  ? Image.memory(
                      product.imageBytes(),
                      width: double.infinity,
                      height: 100, // Constrain image height
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 100,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: Center(child: Text('No Image')),
                    ),
            ),
          ),

          // Details Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5.0, 3.0, 5.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  //SizedBox(height: 4),
                  Text(
                    product.description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  //Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 16, color: Colors.green),
                        maxLines: 1,
                      ),
                      
                      
                       // Buttons Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!isShopOwner && onAddToCart != null)
                            IconButton(
                              icon: Icon(Icons.add_shopping_cart, color: Colors.blue),
                              onPressed: onAddToCart,
                              tooltip: 'Add to Cart',
                              splashRadius: 20,
                            ),

                          if (isShopOwner && onDelete != null)
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: onDelete,
                              tooltip: 'Delete',
                              splashRadius: 20,
                            ),
                        ],
                      ),
        
                    ],
                  ),
                ],
              ),
            ),
          ),

         
        ],
      ),
    );
  }
}
