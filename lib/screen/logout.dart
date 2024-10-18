import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'login.dart'; // Import the login screen to navigate back

class LogoutScreen extends StatefulWidget {
  const LogoutScreen({super.key});

  @override
  _LogoutScreenState createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  // Initialize PocketBase instance
  final pb = PocketBase('http://10.0.2.2:8090'); // Replace with your PocketBase URL

  Future<void> _logout() async {
    try {
      // Clear the PocketBase authStore, effectively logging out the user
      pb.authStore.clear();

      // Navigate back to the login screen after logout
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Logout successful!'),
      ));
    } catch (error) {
      // Handle any errors during logout
      print('Logout failed: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Logout failed: $error'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logout'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _logout,
          child: const Text('Logout'),
        ),
      ),
    );
  }
}
