import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_models.dart' as custom; // Adjust the path to where your Order class is located
// Adjust the path to where your OrderItem class is located

class OrderManagementScreen extends StatelessWidget {
  final _firestore = FirebaseFirestore.instance;

  // Update the order status in Firestore
  Future<void> _updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({'status': status});
      print("Order $orderId updated to $status");
    } catch (e) {
      print("Error updating order: $e");
    }
  }

  // Sign out the user
  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacementNamed('/login'); // Adjust the route to your login screen
    } catch (e) {
      print("Error signing out: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to sign out. Please try again.")),
      );
    }
  }

 @override
Widget build(BuildContext context) {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  return Scaffold(
    appBar: AppBar(
      title: Text("Manage Orders"),
      actions: [
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: () => _signOut(context),
        ),
      ],
    ),
    body: Column(
      children: [
        Expanded( // Use Expanded or Flexible to allow the ListView to take only available space
          child: StreamBuilder<QuerySnapshot>(
  stream: _firestore
      .collection('orders')
      .where('sellerId', isEqualTo: userId) // Filter by sellerId
      .snapshots(),
  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

    var orders = snapshot.data!.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return custom.Order.fromMap(doc.id, data); // Map Firestore doc to Order model
    }).toList();

    if (orders.isEmpty) {
      return Center(child: Text("No orders available."));
    }

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        var order = orders[index];

        return Card(
          child: ExpansionTile(
            title: Text("Order #${order.id} - ${order.status}"),
            subtitle: Text("Total: \$${order.totalAmount.toStringAsFixed(2)}"),
            children: [
              ...order.items.map((item) => ListTile(
                    title: Text(item.title),
                    subtitle: Text("\$${item.price.toStringAsFixed(2)} x ${item.quantity}"),
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () => _updateOrderStatus(order.id, 'confirmed'),
                    child: Text("Confirm"),
                  ),
                  ElevatedButton(
                    onPressed: () => _updateOrderStatus(order.id, 'shipped'),
                    child: Text("Ship"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  },
)

        ),
      ],
    ),
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: 0, // Highlight "Orders" as the current page
      onTap: (index) {
        if (index == 0) {
          // Stay on the current page
        } else if (index == 1) {
          context;
          Navigator.of(context).pushReplacementNamed('/browse'); // Navigate to Browse Products
        } else if (index == 2) {
          Navigator.of(context).pushReplacementNamed('/profile'); // Navigate to Profile
        } else if (index == 3) {
          Navigator.of(context).pushReplacementNamed('/addProduct'); // Navigate to Add Product
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart, color: Colors.black,),
          label: "Orders",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store, color: Colors.black,),
          label: "Browse Products",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, color: Colors.black,),
          label: "Profile",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.card_giftcard, color: Colors.black,),
          label: "Add product",
        ),
      ],
    ),
  );
}
}
