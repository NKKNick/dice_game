import 'package:dice_game/screen/register.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'game_lobby_screen.dart'; // For regular users
import 'admin_dashboard_screen.dart'; // For admin users

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  // Initialize PocketBase instance
  final pb =
      PocketBase('http://10.0.2.2:8090'); // Change to your PocketBase URL

  Future<void> _login() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Try logging in as a regular user
      final authData = await pb.collection('users').authWithPassword(
            email,
            password,
          );
      pb.authStore.save(authData.token, authData.record);
      
      // If successful, navigate to the Game Lobby
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GameLobbyScreen()),
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Login successful! Welcome to the Game Lobby.'),
      ));
    } catch (err) {
      // If the regular user login fails, try logging in as an admin
      try {
        await pb.admins.authWithPassword(email, password);

        // If admin login is successful, navigate to the Admin Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Admin login successful! Welcome to the Admin Dashboard.'),
        ));
      } catch (err) {
        // If both regular and admin login fail, show an error message
        setState(() {
          _errorMessage = 'Login failed. Please check your credentials.';
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 40),
            _isLoading
                ? CircularProgressIndicator()
                : Column(
                    children: [
                      ElevatedButton(
                        onPressed: _login,
                        child: Text('Login'),
                      ),
                      SizedBox(height: 20),
                      // Register link
                      TextButton(
                        onPressed: () {
                          // Navigate to the RegisterScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterScreen()),
                          );
                        },
                        child: Text('Don\'t have an account? Register here'),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
