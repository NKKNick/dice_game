import 'package:dice_game/screen/character_display.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'login.dart'; // Import the login screen for logout navigation
import 'create_character_screen.dart'; // Import the character creation screen

class GameLobbyScreen extends StatefulWidget {
  const GameLobbyScreen({super.key});

  @override
  _GameLobbyScreenState createState() => _GameLobbyScreenState();
}

class _GameLobbyScreenState extends State<GameLobbyScreen> {
  final pb = PocketBase('http://10.0.2.2:8090'); // PocketBase instance
  List<RecordModel> rooms = []; // List to store fetched rooms
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRooms(); // Fetch rooms when the screen loads
  }

  // Get the current user ID (assuming you have authentication in place)
  String getCurrentUserId() {
    return pb.authStore.model?.id ??
        ''; // Get the authenticated user's ID from PocketBase
  }

  // Fetch rooms from PocketBase collection (assumed collection name is 'lobbies')
  Future<void> _fetchRooms() async {
    try {
      final records = await pb
          .collection('lobbies')
          .getFullList(); // Fetch all rooms from the 'lobbies' collection
      setState(() {
        rooms = records; // Update the room list
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching rooms: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch rooms')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to join a room and check if the user already has a character
  Future<void> _joinRoom(String roomName, String lobbyId) async {
    final userId = getCurrentUserId(); // Get the current user ID
    
    try {
      // Query to check if the current user has already created a character for this lobby
      final result = await pb.collection('characters').getList(
            filter: 'user_id="$userId" && lobby_id="$lobbyId"',
            perPage:
                1, // Only fetch one record to check if they have a character
          );

      if (result.items.isNotEmpty) {
        // If the user already has a character, redirect them to the UserCharacterDisplayScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserCharacterDisplayScreen(
              lobbyId: lobbyId,
              roomName: roomName,
              userId: userId,
            ),
          ),
        );
      } else {
        // If no character exists, allow the user to create a character
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateCharacterScreen(
              roomName: roomName,
              lobbyId: lobbyId,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error checking character creation: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error joining lobby. Please try again.'),
      ));
    }
  }

  // Logout function
  void _logout() {
    pb.authStore.clear(); // Clear authentication
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => LoginScreen()), // Navigate back to login screen
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged out successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Lobby'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout, // Call the logout function when pressed
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Loading indicator
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Display list of available rooms
                  Expanded(
                    child: rooms.isEmpty
                        ? Center(child: Text('No rooms available'))
                        : ListView.builder(
                            itemCount: rooms.length,
                            itemBuilder: (context, index) {
                              final room = rooms[index];
                              final roomName =
                                  room.data['name'] ?? 'Unnamed Room';
                              final lobbyId = room.id;

                              return Card(
                                child: ListTile(
                                  title: Text(roomName),
                                  trailing: ElevatedButton(
                                    onPressed: () =>
                                        _joinRoom(roomName, lobbyId),
                                    child: Text('Join'),
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
