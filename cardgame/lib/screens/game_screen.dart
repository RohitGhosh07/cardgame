import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  Offset _cardPosition = const Offset(0, 0);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: pi / 16).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _dragUpdate(DragUpdateDetails details) {
    setState(() {
      _cardPosition += details.delta;
    });
  }

  void _dragEnd(DragEndDetails details) {
    setState(() {
      _cardPosition = const Offset(0, 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade900, Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Opponent 1 (Top)
          Positioned(top: 40, left: 0, right: 0, child: _buildPlayerHand(true, 'Player 1')),

          // Opponent 2 (Right)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            right: 20,
            child: RotatedBox(quarterTurns: 1, child: _buildPlayerHand(true, 'Player 2')),
          ),

          // Center Pot
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(color: Colors.green.shade400, blurRadius: 10, spreadRadius: 1),
                ],
              ),
              child: const Text(
                'Pot: ₹1000',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Player Cards (Draggable)
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: _buildDraggablePlayerCards('You'),
          ),

          // Action Buttons
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: _buildActionButtons(),
          ),
        ],
      ),
    );
  }

  // Opponent & Player Hand UI
  Widget _buildPlayerHand(bool faceDown, String playerName) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          playerName,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (index) => Transform.rotate(
              angle: faceDown ? 0 : (_rotationAnimation.value * (index - 1)),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 100,
                width: 65,
                decoration: BoxDecoration(
                  color: faceDown ? Colors.red : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Player Cards (Draggable)
  Widget _buildDraggablePlayerCards(String playerName) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          playerName,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return GestureDetector(
              onPanUpdate: _dragUpdate,
              onPanEnd: _dragEnd,
              child: Transform.translate(
                offset: _cardPosition,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 120,
                  width: 75,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.yellow, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellowAccent.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                    image: const DecorationImage(
                      image: AssetImage('assets/card_front.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // Action Buttons
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildGameButton('Fold', Colors.red.shade700, () {}),
          _buildGameButton('Call', Colors.blue.shade700, () {}),
          _buildGameButton('Raise', Colors.green.shade700, () {}),
        ],
      ),
    );
  }

  // Custom Action Buttons
  Widget _buildGameButton(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

