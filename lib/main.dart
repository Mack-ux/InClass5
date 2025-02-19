import 'package:flutter/material.dart';

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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Name: $petName',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Happiness: $happinessLevel',
                style: TextStyle(fontSize: 18, color: Colors.green),
              ),
              Text(
                'Hunger: $hungerLevel',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    happinessLevel = (happinessLevel + 5).clamp(0, 100);
                  });
                },
                child: Text('Increase Happiness'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    hungerLevel = (hungerLevel - 5).clamp(0, 100);
                  });
                },
                child: Text('Reduce Hunger'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

