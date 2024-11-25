import 'package:entrepreneur/screens/add_product_screen.dart';
import 'package:entrepreneur/screens/browse_product_screen.dart';
import 'package:entrepreneur/screens/cart_screen.dart';
import 'package:entrepreneur/screens/login_screen.dart';
import 'package:entrepreneur/screens/order_management_screen.dart';
import 'package:entrepreneur/screens/profile_screen.dart';
import 'package:entrepreneur/screens/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/route_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Junior Entrepreneur',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RoleBasedNavigation(), // Navigate based on role
      routes: {
        '/profile': (context) => ProfileScreen(), // Your Profile Page widget
        '/login': (context) => LoginScreen(), // Your Login Page widget
        '/register': (context) => RegisterScreen(),
        '/browse': (context) => BrowseProductsScreen(),
        '/addProduct': (context) => AddProductScreen(),
        '/cart': (context) => CartScreen(),
        '/orderManagement': (context) => OrderManagementScreen(),
      },
    );
  }
}

class RoleBasedNavigation extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> _determineInitialScreen() async {
    User? currentUser = _auth.currentUser;

    // If user is not logged in, navigate to the Register screen
    if (currentUser == null) {
      return '/login';
    }

    // Fetch the user's role from Firestore
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(currentUser.uid).get();

    if (userDoc.exists) {
      String role = userDoc['role']; // Expected to be 'buyer' or 'shopOwner'
      if (role == 'buyer') {
        return '/browse';
      } else if (role == 'shopOwner') {
        return '/orderManagement';
      }
    }

    // Default fallback if role is not set
    return '/register';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _determineInitialScreen(),
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Navigate to the determined initial screen
        final String initialRoute = snapshot.data ?? '/register';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, initialRoute);
        });

        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
