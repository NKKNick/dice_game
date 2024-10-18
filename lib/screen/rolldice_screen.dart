import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class RollDiceScreen extends StatefulWidget {
  final String player1Id; // Current user ID (Player 1)
  final String player1CharacterId; // Current user's character ID
  final String player2Id; // Opponent ID (Player 2)
  final String player2CharacterId; // Opponent's character ID
  final String player2Name; // Opponent's name

  const RollDiceScreen({
    Key? key,
    required this.player1Id,
    required this.player1CharacterId,
    required this.player2Id,
    required this.player2CharacterId,
    required this.player2Name,
  }) : super(key: key);

  @override
  _RollDiceScreenState createState() => _RollDiceScreenState();
}

class _RollDiceScreenState extends State<RollDiceScreen> {
  final pb = PocketBase('http://10.0.2.2:8090'); // PocketBase instance
  int player1Roll = 0;
  int player2Roll = 0;
  bool _rollDone = false;

  // Function to roll the dice for both players
  void _rollDice() {
    setState(() {
      player1Roll = Random().nextInt(6) + 1; // Dice roll for Player 1
      player2Roll = Random().nextInt(6) + 1; // Dice roll for Player 2
      _rollDone = true;

      // After rolling, update the win and lose counts
      _updateWinAndLoseCounts();
    });
  }
  
  // Function to update win count for the winner and lose count for the loser
  Future<void> _updateWinAndLoseCounts() async {
    if (player1Roll > player2Roll) {
      // Player 1 wins
      await _incrementWinCount(widget.player1CharacterId);
      await _incrementLoseCount(widget.player2CharacterId);
    } else if (player1Roll < player2Roll) {
      // Player 2 wins
      await _incrementWinCount(widget.player2CharacterId);
      await _incrementLoseCount(widget.player1CharacterId);
    }
  }

  // Function to increment win count in PocketBase for the winner
  Future<void> _incrementWinCount(String characterId) async {
    try {
      // Fetch the current character data
      final character = await pb.collection('characters').getOne(characterId);

      // Increment the win count
      final newWinCount = (character.data['win_count'] ?? 0) + 1;

      // Update the character's win count in PocketBase
      await pb.collection('characters').update(characterId, body: {
        'win_count': newWinCount,
      });

      print('Win count updated for character $characterId');
    } catch (e) {
      print('Error updating win count: $e');
    }
  }

  // Function to increment lose count in PocketBase for the loser
  Future<void> _incrementLoseCount(String characterId) async {
    try {
      // Fetch the current character data
      final character = await pb.collection('characters').getOne(characterId);

      // Increment the lose count
      final newLoseCount = (character.data['lose_count'] ?? 0) + 1;

      // Update the character's lose count in PocketBase
      await pb.collection('characters').update(characterId, body: {
        'lose_count': newLoseCount,
      });

      print('Lose count updated for character $characterId');
    } catch (e) {
      print('Error updating lose count: $e');
    }
  }

  // Function to determine the winner
  String _getWinner() {
    if (player1Roll > player2Roll) {
      return 'You Win!';
    } else if (player1Roll < player2Roll) {
      return '${widget.player2Name} Wins!';
    } else {
      return 'It\'s a Draw!';
    }
  }

  // Function to get the dice image based on the roll result
  String _getDiceImage(int roll) {
    return 'assets/images/dice-$roll.png'; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Roll Dice vs ${widget.player2Name}'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Align the content in the center vertically
            crossAxisAlignment: CrossAxisAlignment.center, // Align the content in the center horizontally
            children: [
              Text(
                'Roll Dice to Challenge ${widget.player2Name}',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              if (!_rollDone)
                ElevatedButton(
                  onPressed: _rollDice,
                  child: Text('Roll Dice'),
                ),
              if (_rollDone) ...[
                SizedBox(height: 20),

                // Display dice images and roll values in the center
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Center the dice images and rolls
                  children: [
                    // Player 1 dice and roll value
                    Expanded(
                      child: Column(
                        children: [
                          Image.asset(
                            _getDiceImage(player1Roll),
                            width: 100,
                            height: 100,
                            fit: BoxFit.contain, // Ensure the image scales properly
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Your Roll: $player1Roll',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 40), // Add spacing between the two dice images

                    // Player 2 dice and roll value
                    Expanded(
                      child: Column(
                        children: [
                          Image.asset(
                            _getDiceImage(player2Roll),
                            width: 100,
                            height: 100,
                            fit: BoxFit.contain, // Ensure the image scales properly
                          ),
                          SizedBox(height: 10),
                          Text(
                            '${widget.player2Name}: $player2Roll',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Display the winner or draw message
                Text(
                  _getWinner(),
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Go back to the previous screen
                  },
                  child: Text('Back'),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
