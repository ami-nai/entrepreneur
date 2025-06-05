import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _firestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _placeOrder(List<DocumentSnapshot> cartItems) async {
    if (cartItems.isEmpty) return;

    try {
      await _firestore.collection('orders').add({
        'userId': userId,
        'items': cartItems.map((item) => item.data()).toList(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Clear the cart
      for (var item in cartItems) {
        await _firestore.collection('users').doc(userId).collection('cart').doc(item.id).delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order placed successfully!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to place order. Try again.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Cart")),
      body: StreamBuilder(
        stream: _firestore.collection('users').doc(userId).collection('cart').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var cartItems = snapshot.data!.docs;

          if (cartItems.isEmpty) {
            return Center(child: Text("Your cart is empty."));
          }

          double totalPrice = cartItems.fold(0.0, (sum, item) => sum + (item['price'] * item['quantity']));

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    var item = cartItems[index];
                    return ListTile(
                      leading: item['imageBase64'] != null
                          ? Image.memory(
                              base64Decode(item['imageBase64']),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.image, size: 50),
                      title: Text(item['name']),
                      subtitle: Text("Price: \$${item['price']}"),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await _firestore.collection('users').doc(userId).collection('cart').doc(item.id).delete();
                        },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total: \$${totalPrice.toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ElevatedButton(
                      onPressed: () => _placeOrder(cartItems),
                      child: Text("Place Order"),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
