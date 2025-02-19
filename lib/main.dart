import 'package:flutter/material.dart';
import 'dart:async'; // Import Timer for automated game mechanics

void main() {
  runApp(DigitalPetApp());
}

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  String petName = "Your Pet"; // Default pet name
  int happinessLevel = 50; // Pet's happiness (0-100)
  int hungerLevel = 50; // Pet's hunger (0-100)
  int energyLevel = 50; // Pet's energy level (0-100)
  bool _gameOver = false; // Track game status
  Timer? _hungerTimer; // Timer for hunger increase
  Timer? _winTimer; // Timer for checking win condition
  String selectedActivity = "Walk"; // Default activity selection
  final List<String> activities = ["Walk", "Run", "Jump", "Rest"];

  @override
  void initState() {
    super.initState();
    _startHungerTimer(); // Start automatic hunger increase
    _startWinConditionTimer(); // Start checking for a win condition
    _showNameInputDialog(); // Ask for pet name at start
  }

  @override
  void dispose() {
    _hungerTimer?.cancel(); // Cancel timers when widget is disposed
    _winTimer?.cancel();
    super.dispose();
  }

  // Start timer to increase hunger every 30 seconds
  void _startHungerTimer() {
    _hungerTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (!_gameOver) {
        setState(() {
          hungerLevel = (hungerLevel + 5).clamp(0, 100);
          _checkGameStatus();
        });
      }
    });
  }

  // Start timer for win condition
  void _startWinConditionTimer() {
    _winTimer = Timer(Duration(minutes: 3), () {
      if (!_gameOver && happinessLevel > 80) {
        _showWinDialog();
      }
    });
  }

  // Ask for pet name
  void _showNameInputDialog() {
    TextEditingController _nameController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Name Your Pet'),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(hintText: "Enter pet name"),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (_nameController.text.trim().isNotEmpty) {
                    petName = _nameController.text.trim();
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  // Function to play with the pet
  void _playWithPet() {
    if (_gameOver) return;
    setState(() {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
      hungerLevel = (hungerLevel + 5).clamp(0, 100);
      energyLevel = (energyLevel - 5).clamp(0, 100);
      _checkGameStatus();
    });
  }

  // Function to feed the pet
  void _feedPet() {
    if (_gameOver) return;
    setState(() {
      hungerLevel = (hungerLevel - 10).clamp(0, 100);
      happinessLevel = (happinessLevel + 5).clamp(0, 100);
      energyLevel = (energyLevel + 5).clamp(0, 100);
      _checkGameStatus();
    });
  }

  // Check win/loss conditions
  void _checkGameStatus() {
    if (hungerLevel >= 100 && happinessLevel < 10 && !_gameOver) {
      _showGameOverDialog();
    }
  }

  // Show win dialog
  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('You Win! 🎉'),
          content: Text('You have successfully kept your pet happy!'),
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

  // Show Game Over dialog
  void _showGameOverDialog() {
    setState(() {
      _gameOver = true;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Game Over 😢'),
          content: Text('Your pet is unhappy and hungry. Try again!'),
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

  // Reset the game
  void _resetGame() {
    setState(() {
      petName = "Your Pet";
      happinessLevel = 50;
      hungerLevel = 50;
      energyLevel = 50;
      _gameOver = false;
    });
    _startWinConditionTimer();
  }

  // Get mood color
  Color _getMoodColor() {
    if (happinessLevel > 70) return Colors.green;
    if (happinessLevel >= 30) return Colors.yellow;
    return Colors.red;
  }

  // Get pet mood text
  String _getMoodText() {
    if (happinessLevel > 70) return 'Happy 😊';
    if (happinessLevel >= 30) return 'Neutral 😐';
    return 'Unhappy 😟';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digital Pet',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(title: Text('Digital Pet')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pet Mood Indicator
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: _getMoodColor(),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.pets, size: 60, color: Colors.white),
              ),
              SizedBox(height: 10),
              Text(_getMoodText(), style: TextStyle(fontSize: 22)),
              SizedBox(height: 10),
              // Pet Name
              Text('Name: $petName', style: TextStyle(fontSize: 22)),
              // Stats
              Text('Happiness: $happinessLevel',
                  style: TextStyle(fontSize: 18)),
              Text('Hunger: $hungerLevel', style: TextStyle(fontSize: 18)),
              Text('Energy: $energyLevel', style: TextStyle(fontSize: 18)),
              // Energy Bar
              LinearProgressIndicator(value: energyLevel / 100, minHeight: 10),
              SizedBox(height: 20),
              // Activity Selection
              DropdownButton<String>(
                value: selectedActivity,
                items: activities.map((String activity) {
                  return DropdownMenuItem(
                      value: activity, child: Text(activity));
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedActivity = newValue!;
                  });
                },
              ),
              // Play & Feed Buttons
              ElevatedButton(onPressed: _playWithPet, child: Text('Play')),
              ElevatedButton(onPressed: _feedPet, child: Text('Feed')),
            ],
          ),
        ),
      ),
    );
  }
}
