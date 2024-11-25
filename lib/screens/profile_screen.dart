import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser; // Fetch current user

  // Mock user details (can be updated to fetch from Firestore if needed)
  String username = "John Doe";
  String email = "john.doe@example.com";
  String phone = "123-456-7890";
  String address = "123, Main Street, Cityville";

  // Sign-out method
  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacementNamed('/login'); // Redirect to login screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error signing out: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        leading: IconButton(
  icon: Icon(Icons.arrow_back),
  onPressed: () {
    if (Navigator.canPop(context)) {
      Navigator.pop(context); // Navigate back if possible
    } else {
      Navigator.of(context).pushReplacementNamed('/browse'); // Redirect if stack is empty
    }
  },
),

      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Section
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      user?.photoURL ??
                          "https://via.placeholder.com/150", // Default profile picture
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    username,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    email,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // User Info Section
            _buildInfoTile(Icons.phone, "Phone", phone, () {
              _editInfoDialog(context, "Phone", phone, (value) {
                setState(() => phone = value);
              });
            }),
            _buildInfoTile(Icons.location_on, "Address", address, () {
              _editInfoDialog(context, "Address", address, (value) {
                setState(() => address = value);
              });
            }),

            SizedBox(height: 20),

            // Action Buttons Section
            Divider(),
            ListTile(
              leading: Icon(Icons.history),
              title: Text("Order History"),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pushNamed(context, '/orderHistory'); // Navigate to Order History
              },
            ),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text("Change Password"),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pushNamed(context, '/changePassword'); // Navigate to Change Password
              },
            ),
            Divider(),

            // Logout Button
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.logout),
                label: Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _signOut(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build an info tile with an edit option
  Widget _buildInfoTile(IconData icon, String label, String value, VoidCallback onEdit) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
      trailing: IconButton(
        icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
        onPressed: onEdit,
      ),
    );
  }

  // Show a dialog to edit user information
  Future<void> _editInfoDialog(BuildContext context, String field, String initialValue, Function(String) onSave) async {
    TextEditingController controller = TextEditingController(text: initialValue);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $field"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: field),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text); // Save the updated value
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }
}
