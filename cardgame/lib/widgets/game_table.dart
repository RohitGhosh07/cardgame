import 'package:cardgame/screens/game_screen.dart';
import 'package:flutter/material.dart';
import '../constants/game_constants.dart';
import '../painters/felt_pattern_painter.dart';

class GameTable extends StatelessWidget {
  final List<Widget> children;
  final Color tableColor;
  final double borderRadius;

  const GameTable({
    super.key,
    required this.children,
    this.tableColor = const Color(0xFF1a6340),
    this.borderRadius = 150,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tableColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Color(0xFF267245),
          width: 16,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: -5,
            offset: const Offset(0, -10),
          ),
        ],
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.5,
          colors: [
            Color(0xFF267245),
            tableColor,
          ],
          stops: const [0.4, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: ModernFeltPatternPainter(
              patternColor:Color(0xFF267245).withOpacity(0.2),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
