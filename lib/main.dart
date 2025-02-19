import 'package:flutter/material.dart';
import 'dart:async'; // Import Timer for automated game mechanics

void main() {
  runApp(DigitalPetApp());
}

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp>
    with SingleTickerProviderStateMixin {
  String petName = "Your Pet"; // Default pet name
  int happinessLevel = 50; // Pet's happiness (0-100)
  int hungerLevel = 50; // Pet's hunger (0-100)
  bool _gameOver = false; // Track game status
  Timer? _winTimer; // Timer for checking win condition
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _startWinConditionTimer(); // Start checking for a win condition

    // Initialize animation controller
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
      lowerBound: 0.9,
      upperBound: 1.0,
    )..repeat(reverse: true);

    _scaleAnimation =
        Tween<double>(begin: 0.95, end: 1.05).animate(_controller);
  }

  @override
  void dispose() {
    _winTimer?.cancel(); // Cancel timers when widget is disposed
    _controller.dispose(); // Dispose animation controller
    super.dispose();
  }

  // Function to play with the pet
  void _playWithPet() {
    if (_gameOver) return; // Prevent actions if game is over
    setState(() {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
      hungerLevel = (hungerLevel + 5).clamp(0, 100); // Playing makes pet hungry
      _checkGameStatus();
    });
  }

  // Function to feed the pet
  void _feedPet() {
    if (_gameOver) return; // Prevent actions if game is over
    setState(() {
      hungerLevel = (hungerLevel - 10).clamp(0, 100); // Reduce hunger
      happinessLevel =
          (happinessLevel + 5).clamp(0, 100); // Feeding increases happiness
      _checkGameStatus();
    });
  }

  // Method to start a timer that checks if player wins the game
  void _startWinConditionTimer() {
    _winTimer = Timer(Duration(seconds: 60), () {
      if (!_gameOver && happinessLevel > 80) {
        _showWinDialog();
      }
    });
  }

  // Check if the player has won or lost the game
  void _checkGameStatus() {
    if (hungerLevel >= 100 && happinessLevel < 10 && !_gameOver) {
      _showGameOverDialog();
    }
  }

  // Show Game Over Dialog
  void _showGameOverDialog() {
    setState(() {
      _gameOver = true;
    });
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent closing the dialog by tapping outside
      builder: (context) {
        return AlertDialog(
          title: Text('Game Over'),
          content:
              Text('Your pet is unhappy and hungry. Better luck next time! 😢'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              child: Text('Restart'),
            ),
          ],
        );
      },
    );
  }

  // Show Win Dialog
  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent closing the dialog by tapping outside
      builder: (context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          content: Text('You have successfully kept your pet happy! 🎉'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              child: Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  // Reset game when the player loses or wins
  void _resetGame() {
    setState(() {
      petName = "Your Pet";
      happinessLevel = 50;
      hungerLevel = 50;
      _gameOver = false;
    });
    _startWinConditionTimer();
  }

  // Get background image based on happiness level
  String _getBackgroundImage() {
    if (happinessLevel > 70) {
      return 'assets/happy_background.png';
    } else if (happinessLevel >= 30) {
      return 'assets/neutral_background.png';
    } else {
      return 'assets/sad_background.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digital Pet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Digital Pet'),
          backgroundColor: Colors.blue,
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              _getBackgroundImage(),
              fit: BoxFit.cover,
            ),
            Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Name: $petName',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Happiness: $happinessLevel',
                      style: TextStyle(fontSize: 18, color: Colors.greenAccent),
                    ),
                    Text(
                      'Hunger: $hungerLevel',
                      style: TextStyle(fontSize: 18, color: Colors.redAccent),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _playWithPet,
                      child: Text('Play with Pet 🐾'),
                    ),
                    ElevatedButton(
                      onPressed: _feedPet,
                      child: Text('Feed Pet 🍖'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
