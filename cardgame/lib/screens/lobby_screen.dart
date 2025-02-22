import 'package:flutter/material.dart';
import 'game_screen.dart';

class LobbyScreen extends StatelessWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Lobby'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Waiting for Players...',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: List.generate(3, (index) {
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: index == 0 ? Colors.green : Colors.grey,
                        child: Icon(
                          index == 0 ? Icons.person : Icons.person_outline,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        index == 0 ? 'You' : 'Waiting...',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GameScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text('Start Game'),
            ),
          ),
        ],
      ),
    );
  }
}
