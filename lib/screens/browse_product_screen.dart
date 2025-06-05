import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrepreneur/screens/cart_screen.dart';
import 'package:entrepreneur/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../widgets/product_card.dart';

class BrowseProductsScreen extends StatefulWidget {
  @override
  _BrowseProductsScreenState createState() => _BrowseProductsScreenState();
}

class _BrowseProductsScreenState extends State<BrowseProductsScreen> {
  int _selectedIndex = 0;

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return BrowseProductsContent(); // Extracted as a separate widget
      case 1:
        return CartScreen(); // Replace with Cart widget
      case 2:
        return ProfileScreen(); // Replace with Profile widget
      default:
        return BrowseProductsContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Browse Products"),
        backgroundColor: Colors.blueAccent,
        
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.blueAccent),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Hello, User',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    FirebaseAuth.instance.currentUser?.email ?? "Guest",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 0);
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('Cart'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 1);
              },
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 2);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/register');
              },
            ),
          ],
        ),
      ),
      body: _getCurrentPage(),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onBottomNavTapped,
      ),
    );
  }
}

class BrowseProductsContent extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var products = snapshot.data!.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return Product.fromMap(doc.id, data);
        }).where((product) => product.status == 'available').toList();

        if (products.isEmpty) {
          return Center(child: Text("No available products!"));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 0.65,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            var product = products[index];
            return ProductCard(
              product: product,
              onAddToCart: () async {
                try {
                  await _firestore
                      .collection('users')
                      .doc(userId)
                      .collection('cart')
                      .doc(product.id)
                      .set({
                    'name': product.name,
                    'price': product.price,
                    'quantity': 1,
                    'imageBase64': product.imageBase64,
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${product.name} added to cart')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add to cart. Try again.')),
                  );
                }
              },
              onDelete: () {
                if (product.shopOwnerId == FirebaseAuth.instance.currentUser?.uid) {
                  _firestore.collection('products').doc(product.id).delete();
                }
              },
              isShopOwner: product.shopOwnerId == FirebaseAuth.instance.currentUser?.uid,
            );
          },
        );
      },
    );
  }
}
