import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';
import '../widgets/product_card.dart';

class BrowseProductsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Browse Products"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/register');
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var products = snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return Product.fromMap(doc.id, data);
          }).where((product) => product.status == 'available') // Filter by status
              .toList();

          if (products.isEmpty) {
            return Center(child: Text("No available products!"));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              var product = products[index];

              return ProductCard(
                product: product,
                onAddToCart: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${product.name} added to cart')),
                  );
                },
                onDelete: () {
                  if (product.shopOwnerId == FirebaseAuth.instance.currentUser?.uid) {
                    FirebaseFirestore.instance.collection('products').doc(product.id).delete();
                  }
                },
                isShopOwner: product.shopOwnerId == FirebaseAuth.instance.currentUser?.uid,
              );
            },
          );
        },
      ),
    );
  }
}
