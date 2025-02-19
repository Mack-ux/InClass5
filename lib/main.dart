import 'package:flutter/material.dart';
import 'dart:async'; // Import dart:async for Timer

// import 'dart:ui' as ui;
void main() {
  runApp(MaterialApp(
    home: DigitalPetApp(),
    debugShowCheckedModeBanner: false, // Optional: Remove debug banner
  ));
}

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  // State Variables
  String petName = "Your Pet";
  int happinessLevel = 50;
  int hungerLevel = 50;

  // Controllers and Timers
  TextEditingController _nameController = TextEditingController();
  Timer? _hungerTimer;
  Timer? _winTimer;
  Timer? _gameTimer;
  bool _gameOver = false;

  // Game Timer Variables
  int _elapsedTime = 0; // in seconds
  String _statusMessage =
      "Welcome to your Digital Pet! Take good care of your pet.";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showNameInputDialog());

    // Initialize the hunger timer to increase hunger every 30 seconds
    _hungerTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      setState(() {
        hungerLevel = (hungerLevel + 5).clamp(0, 100);
        if (hungerLevel >= 100) {
          hungerLevel = 100;
          happinessLevel = (happinessLevel - 20).clamp(0, 100);
        }
        _checkLossCondition(); // Check for loss conditions
      });
    });

    // Start the win condition timer
    _startWinConditionTimer();

    // Initialize the game timer to track elapsed time
    _gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime += 1;
        if (_elapsedTime % 30 == 0) {
          _updateStatusMessage();
        }
      });
    });
  }

  @override
  void dispose() {
    _hungerTimer?.cancel(); // Cancel the hunger timer
    _winTimer?.cancel(); // Cancel the win timer
    _gameTimer?.cancel(); // Cancel the game timer
    _nameController.dispose(); // Dispose the controller
    super.dispose();
  }

  // Method to get color based on happiness level
  Color _getPetColor() {
    if (happinessLevel > 70) {
      return Colors.green;
    } else if (happinessLevel >= 30) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  // Method to get mood based on happiness level
  String _getPetMood() {
    if (happinessLevel > 70) {
      return 'Happy 😊';
    } else if (happinessLevel >= 30) {
      return 'Neutral 😐';
    } else {
      return 'Unhappy 😟';
    }
  }

  // Method to get mood text color
  Color _getMoodTextColor() {
    if (happinessLevel > 70) {
      return Colors.greenAccent;
    } else if (happinessLevel >= 30) {
      return Colors.amberAccent;
    } else {
      return Colors.redAccent;
    }
  }

  // Method to get dynamic button color
  Color _getButtonColor({required bool isPlay}) {
    if (isPlay) {
      if (happinessLevel > 70) {
        return Colors.blueAccent;
      } else if (happinessLevel >= 30) {
        return Colors.lightBlue;
      } else {
        return Colors.blueGrey;
      }
    } else {
      if (hungerLevel < 30) {
        return Colors.orangeAccent;
      } else if (hungerLevel < 70) {
        return Colors.deepOrange;
      } else {
        return Colors.brown;
      }
    }
  }

  // Method to get background image path based on pet's mood
  String _getBackgroundImagePath() {
    if (happinessLevel > 70) {
      return 'assets/background_happy.png'; // Ensure you have this image
    } else if (happinessLevel >= 30) {
      return 'assets/background_neutral.png'; // Ensure you have this image
    } else {
      return 'assets/background_unhappy.png'; // Ensure you have this image
    }
  }

  // Method to get AppBar color based on pet's mood
  Color _getAppBarColor() {
    if (happinessLevel > 70) {
      return Colors.green;
    } else if (happinessLevel >= 30) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }

  // Function to increase happiness and update hunger when playing with the pet
  void _playWithPet() {
    if (_gameOver) return; // Prevent actions if game is over
    setState(() {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
      _updateHunger();
      _checkWinCondition();
    });
  }

  // Function to decrease hunger and update happiness when feeding the pet
  void _feedPet() {
    if (_gameOver) return; // Prevent actions if game is over
    setState(() {
      hungerLevel = (hungerLevel - 10).clamp(0, 100);
      _updateHappiness();
      _checkWinCondition();
    });
  }

  // Update happiness based on hunger level
  void _updateHappiness() {
    if (hungerLevel < 30) {
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    } else {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
    }
  }

  // Increase hunger level slightly when playing with the pet
  void _updateHunger() {
    hungerLevel = (hungerLevel + 5).clamp(0, 100);
    if (hungerLevel >= 100) {
      hungerLevel = 100;
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    }
  }

  // Method to show name input dialog
  void _showNameInputDialog() {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent closing the dialog by tapping outside
      builder: (context) {
        return AlertDialog(
          title: Text('Set Your Pet\'s Name'),
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

  // Method to start the win condition timer
  void _startWinConditionTimer() {
    _winTimer = Timer(Duration(minutes: 3), () {
      if (!_gameOver && happinessLevel > 80) {
        _showWinDialog();
      }
    });
  }

  // Method to show win dialog
  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent closing the dialog by tapping outside
      builder: (context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          content:
              Text('You have successfully kept your pet happy! You win! 🎉'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Method to show game over dialog
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

  // Method to reset the game
  void _resetGame() {
    setState(() {
      petName = "Your Pet";
      happinessLevel = 50;
      hungerLevel = 50;
      _gameOver = false;
      _elapsedTime = 0;
      _statusMessage =
          "Welcome to your Digital Pet! Take good care of your pet.";
    });
    _winTimer?.cancel();
    _startWinConditionTimer();
  }

  // Method to check for loss conditions
  void _checkLossCondition() {
    if (hungerLevel >= 100 && happinessLevel <= 10 && !_gameOver) {
      _showGameOverDialog();
    }
  }

  // Method to check win condition during interactions
  void _checkWinCondition() {
    if (happinessLevel > 80 && _winTimer?.isActive == false && !_gameOver) {
      _showWinDialog();
    }
  }

  // Method to update the status message every 30 seconds
  void _updateStatusMessage() {
    List<String> messages = [
      "Remember to feed your pet regularly!",
      "Playing with your pet increases happiness!",
      "Keeping your pet happy ensures a happy relationship!",
      "Don't let your pet get too hungry!",
      "Check your pet's mood frequently.",
      "Happy pets are healthy pets!",
      "Take breaks and enjoy playing with your pet!"
    ];

    // Select a random message from the list
    messages.shuffle();
    setState(() {
      _statusMessage = messages.first;
    });
  }

  // Helper method to format elapsed time
  String _formatElapsedTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = remainingSeconds.toString().padLeft(2, '0');
    return "$minutesStr:$secondsStr";
  }

  // Method to build interactive ElevatedButton
  Widget _buildInteractiveButton({
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return GestureDetector(
      onTapDown: (_) {
        // Optional: Add any onTapDown effects here
      },
      onTapUp: (_) {
        // Optional: Add any onTapUp effects here
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors
                .transparent, // Updated from 'primary' to 'backgroundColor'
            shadowColor: Colors.transparent,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: TextStyle(fontSize: 16),
          ),
          child: Text(label),
        ),
      ),
    );
  }

  // Method to build a status bar (e.g., Happiness Level, Hunger Level)
  Widget _buildStatusBar({
    required String label,
    required int value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: $value',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        SizedBox(height: 4.0),
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 12,
            backgroundColor: Colors.white30,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Pet'),
        backgroundColor: _getAppBarColor(),
      ),
      body: Stack(
        fit: StackFit.expand, // Ensures the Stack fills the entire screen
        children: [
          // Background Image
          Image.asset(
            _getBackgroundImagePath(),
            fit: BoxFit.cover, // Ensures the image covers the screen
          ),
          // Semi-Transparent Overlay for Text Readability
          Container(
            color: Colors.black.withOpacity(0.3), // Adjust opacity as needed
          ),
          // Main Content
          SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0), // Uniform padding
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Pet Visual Representation
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: _getPetColor(),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(4, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.pets,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12.0),
                    // Mood Indicator with Shadow
                    Text(
                      _getPetMood(),
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: _getMoodTextColor(),
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black45,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.0),
                    // Pet Name with Shadow
                    Text(
                      'Name: $petName',
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black45,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.0),
                    // Happiness Level
                    _buildStatusBar(
                      label: 'Happiness Level',
                      value: happinessLevel,
                      color: Colors.pinkAccent,
                    ),
                    SizedBox(height: 12.0),
                    // Hunger Level
                    _buildStatusBar(
                      label: 'Hunger Level',
                      value: hungerLevel,
                      color: Colors.deepOrange,
                    ),
                    SizedBox(height: 16.0),
                    // Elapsed Time with Shadow
                    Text(
                      'Elapsed Time: ${_formatElapsedTime(_elapsedTime)}',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        shadows: [
                          Shadow(
                            blurRadius: 2.0,
                            color: Colors.black38,
                            offset: Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.0),
                    // Status Message with Shadow
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        _statusMessage,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontStyle: FontStyle.italic,
                          color: Colors.white70,
                          shadows: [
                            Shadow(
                              blurRadius: 2.0,
                              color: Colors.black38,
                              offset: Offset(1.0, 1.0),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 32.0),
                    // Play Button
                    _buildInteractiveButton(
                      label: 'Play with Your Pet',
                      onPressed: _playWithPet,
                      color: _getButtonColor(isPlay: true),
                    ),
                    SizedBox(height: 16.0),
                    // Feed Button
                    _buildInteractiveButton(
                      label: 'Feed Your Pet',
                      onPressed: _feedPet,
                      color: _getButtonColor(isPlay: false),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
