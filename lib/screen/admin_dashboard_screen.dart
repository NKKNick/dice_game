import 'package:dice_game/screen/login.dart'; // Adjust import as per your project structure
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:dice_game/screen/game_lobby_screen.dart'; // Import GameLobbyScreen

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final pb = PocketBase('http://10.0.2.2:8090'); // PocketBase instance
  List<RecordModel> lobbies = []; // List to store fetched lobbies
  final TextEditingController _lobbyNameController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLobbies();
  }

  // Fetch lobbies from PocketBase collection
  Future<void> _fetchLobbies() async {
    try {
      final records = await pb.collection('lobbies').getFullList();
      setState(() {
        lobbies = records;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching lobbies: $e');
    }
  }

  // Create a new lobby
  Future<void> _createLobby() async {
    try {
      if (_lobbyNameController.text.isNotEmpty) {
        await pb.collection('lobbies').create(body: {
          'name': _lobbyNameController.text,
        });
        _lobbyNameController.clear();
        _fetchLobbies();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lobby created successfully!')),
        );
      }
    } catch (e) {
      print('Error creating lobby: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create lobby')),
      );
    }
  }

  // Update an existing lobby
  Future<void> _updateLobby(String id) async {
    try {
      if (_lobbyNameController.text.isNotEmpty) {
        await pb.collection('lobbies').update(id, body: {
          'name': _lobbyNameController.text,
        });
        _lobbyNameController.clear();
        _fetchLobbies();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lobby updated successfully!')),
        );
      }
    } catch (e) {
      print('Error updating lobby: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update lobby')),
      );
    }
  }

  // Delete a lobby
  Future<void> _deleteLobby(String id) async {
    try {
      await pb.collection('lobbies').delete(id);
      _fetchLobbies();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lobby deleted successfully!')),
      );
    } catch (e) {
      print('Error deleting lobby: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete lobby')),
      );
    }
  }

  // Logout function
  void _logout() {
    pb.authStore.clear(); // Clear admin authentication
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully!')),
    );
  }

  // Show create/update lobby dialog
  void _showLobbyDialog({String? lobbyId, String? existingName}) {
    if (existingName != null) {
      _lobbyNameController.text = existingName;
    } else {
      _lobbyNameController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(lobbyId == null ? 'Create New Lobby' : 'Edit Lobby'),
          content: TextField(
            controller: _lobbyNameController,
            decoration: const InputDecoration(labelText: 'Lobby Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (lobbyId == null) {
                  _createLobby();
                } else {
                  _updateLobby(lobbyId);
                }
              },
              child: Text(lobbyId == null ? 'Create' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  // Navigate to Game Lobby screen
  void _navigateToGameLobby() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GameLobbyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Button to navigate to Game Lobby
                  ElevatedButton(
                    onPressed: _navigateToGameLobby,
                    child: const Text('Go to Game Lobby'),
                  ),
                  const SizedBox(height: 20),
                  // Button to create a new lobby
                  ElevatedButton(
                    onPressed: () => _showLobbyDialog(),
                    child: const Text('Create New Lobby'),
                  ),
                  const SizedBox(height: 20),
                  // Display list of lobbies
                  Expanded(
                    child: ListView.builder(
                      itemCount: lobbies.length,
                      itemBuilder: (context, index) {
                        final lobby = lobbies[index];
                        return Card(
                          child: ListTile(
                            title: Text(lobby.data['name'] ?? 'Unnamed Lobby'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Edit lobby button
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _showLobbyDialog(
                                    lobbyId: lobby.id,
                                    existingName: lobby.data['name'],
                                  ),
                                ),
                                // Delete lobby button
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteLobby(lobby.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
