import 'package:dice_game/screen/rolldice_screen.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class UserCharacterDisplayScreen extends StatefulWidget {
  final String lobbyId;
  final String roomName;
  final String userId;

  const UserCharacterDisplayScreen({Key? key, required this.lobbyId, required this.roomName, required this.userId}) : super(key: key);

  @override
  _UserCharacterDisplayScreenState createState() => _UserCharacterDisplayScreenState();
}

class _UserCharacterDisplayScreenState extends State<UserCharacterDisplayScreen> {
  final pb = PocketBase('http://10.0.2.2:8090'); // PocketBase instance
  List<RecordModel> characters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCharacters(); // Fetch the characters when the screen loads
  }

  // Fetch all characters for the current lobby
  Future<void> _fetchCharacters() async {
    try {
      final result = await pb.collection('characters').getList(
        filter: 'lobby_id="${widget.lobbyId}"',
      );
      setState(() {
        characters = result.items;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching characters: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to fetch characters'),
      ));
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to handle "Versus" button click
  void _challengePlayer(String characterName, String opponentId, String opponentCharacterId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RollDiceScreen(
          player1Id: widget.userId, // Current user ID
          player1CharacterId: characters.firstWhere((c) => c.data['user_id'] == widget.userId).id, // Current user's character ID
          player2Id: opponentId, // Opponent ID
          player2CharacterId: opponentCharacterId, // Opponent's character ID
          player2Name: characterName, // Opponent's name
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Characters in ${widget.roomName}'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : characters.isEmpty
              ? Center(child: Text('No characters found in this lobby'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: characters.length,
                    itemBuilder: (context, index) {
                      final character = characters[index];
                      final characterName = character.data['character_name'] ?? 'Unnamed Character';
                      final characterUserId = character.data['user_id'];
                      final int winCount = character.data['win_count'] ?? 0; // Default to 0 if win_count is not available
                      final int loseCount = character.data['lose_count'] ?? 0; // Default to 0 if lose_count is not available

                      // Exclude the current user's character from showing the "Versus" button
                      return Card(
                        child: ListTile(
                          title: Text(characterName),
                          subtitle: Text('Wins: $winCount | Losses: $loseCount\nLobby: ${widget.roomName}'),
                          trailing: characterUserId != widget.userId
                              ? ElevatedButton(
                                  onPressed: () => _challengePlayer(characterName, characterUserId, character.id),
                                  child: Text('Versus'),
                                )
                              : null, // Do not show the button for the current user's character
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
