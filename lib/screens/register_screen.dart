import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}



class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> registerUser(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}


class _RegisterScreenState extends State<RegisterScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  String _role = 'buyer'; // Default role
  String? _shopName;

  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            DropdownButtonFormField(
              value: _role,
              items: ['buyer', 'shop_owner'].map((role) {
                return DropdownMenuItem(value: role, child: Text(role));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _role = value!;
                });
              },
              decoration: InputDecoration(labelText: "Role"),
            ),
            if (_role == 'shop_owner')
              TextField(
                onChanged: (value) => _shopName = value,
                decoration: InputDecoration(labelText: "Shop Name"),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _registerUser(context);
              },
              child: Text("Register"),
            ),
            Row(
              children: [
                Text("Already a member! "),
                GestureDetector(
                  onTap: (){
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text("login here",
                    style:
                      TextStyle(
                        color: Colors.blueAccent,
                      ),),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _registerUser(BuildContext context) async {
    try {
      // Create user with Firebase Authentication
      UserCredential userCredential = await _authService.registerUser(
        _emailController.text,
        _passwordController.text,
      );

      // Add user details to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': _nameController.text,
        'email': _emailController.text,
        'role': _role,
        if (_role == 'shop_owner') 'shopName': _shopName,
      });

      // Navigate based on role
      if (_role == 'buyer') {
        Navigator.pushReplacementNamed(context, '/browse');
      } else if (_role == 'shop_owner') {
        Navigator.pushReplacementNamed(context, '/orderManagement');
      }
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: ${e.toString()}")),
      );
    }
  }
}
