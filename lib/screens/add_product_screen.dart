import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String _selectedStatus = 'available'; // Default status

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _convertImageToBase64() async {
    if (_imageFile == null) return null;
    try {
      final bytes = await _imageFile!.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      print("Error converting image to Base64: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Product")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Product Title"),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: "Description"),
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: "Price"),
              keyboardType: TextInputType.number,
            ),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 16.0),
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _imageFile != null
                    ? Image.file(_imageFile!, fit: BoxFit.cover)
                    : Center(child: Text("Tap to select image")),
              ),
            ),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(labelText: "Status"),
              items: ['available', 'sold', 'pending']
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isEmpty ||
                    _descriptionController.text.isEmpty ||
                    _priceController.text.isEmpty ||
                    _imageFile == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please fill all fields and add an image")),
                  );
                  return;
                }

                String? imageBase64 = await _convertImageToBase64();
                if (imageBase64 != null) {
                  await _firestore.collection('products').add({
                    'title': _titleController.text,
                    'description': _descriptionController.text,
                    'price': double.parse(_priceController.text),
                    'imageBase64': imageBase64,
                    'shopOwnerId': FirebaseAuth.instance.currentUser!.uid,
                    'status': _selectedStatus,
                  });
                  Navigator.pushReplacementNamed(context, '/addProduct');
                  //Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to process image")),
                  );
                }
              },
              child: Text("Add Your Product"),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
      currentIndex: 0, // Highlight "Orders" as the current page
      onTap: (index) {
        if (index == 0) {
          Navigator.of(context).pushReplacementNamed('/orderManagement');
        } else if (index == 1) {
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
