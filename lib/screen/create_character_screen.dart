import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class CreateCharacterScreen extends StatefulWidget {
  final String roomName;
  final String lobbyId;

  const CreateCharacterScreen({Key? key, required this.roomName, required this.lobbyId}) : super(key: key);

  @override
  _CreateCharacterScreenState createState() => _CreateCharacterScreenState();
}

class _CreateCharacterScreenState extends State<CreateCharacterScreen> {
  final pb = PocketBase('http://10.0.2.2:8090'); // PocketBase instance
  final TextEditingController _characterNameController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  // Get the current user ID (assuming you have authentication in place)
  String getCurrentUserId() {
    return pb.authStore.model?.id ?? ''; // Get the authenticated user's ID from PocketBase
  }

  // Function to submit the character name and create the character for the user and lobby
  Future<void> _submitCharacter() async {
    final characterName = _characterNameController.text;
    final userId = getCurrentUserId(); // Fetch the user ID here

    if (characterName.isNotEmpty) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        // Create a new character for this user in this lobby
        await pb.collection('characters').create(body: {
          'user_id': userId, // Assign the user ID
          'lobby_id': widget.lobbyId, // Assign the lobby ID
          'character_name': characterName,
          'win_count': 0, // Set default win count
          'lose_count': 0, // Set default lose count
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Character $characterName created for ${widget.roomName}!'),
        ));

        Navigator.pop(context); // Return to the previous screen (Game Lobby)
      } catch (e) {
        print('Error creating character: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to create character'),
        ));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Character name cannot be empty';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Character for ${widget.roomName}'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _characterNameController,
              decoration: InputDecoration(labelText: 'Enter character name'),
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
                : ElevatedButton(
                    onPressed: _submitCharacter,
                    child: Text('Create Character'),
                  ),
          ],
        ),
      ),
    );
  }
}
