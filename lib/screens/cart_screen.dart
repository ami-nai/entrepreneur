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

    // Create an order document
    await _firestore.collection('orders').add({
      'userId': userId,
      'items': cartItems.map((item) => item.data()).toList(),
      'status': 'pending', // Order initially marked as pending
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Clear the cart
    for (var item in cartItems) {
      await _firestore.collection('cart').doc(item.id).delete();
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order placed successfully!")));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Cart")),
      body: StreamBuilder(
        stream: _firestore.collection('cart').where('userId', isEqualTo: userId).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var cartItems = snapshot.data!.docs;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    var item = cartItems[index];
                    return ListTile(
                      title: Text(item['title']),
                      subtitle: Text("\$${item['price']}"),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await _firestore.collection('cart').doc(item.id).delete();
                        },
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () => _placeOrder(cartItems),
                child: Text("Place Order"),
              ),
            ],
          );
        },
      ),
    );
  }
}
