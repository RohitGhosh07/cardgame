import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'strategic_world.dart';

class StrategicGame extends FlameGame {
  // Constants for card dimensions and spacing
  static const double cardWidth = 100.0;
  static const double cardHeight = 140.0;
  static const double cardGap = 20.0;
  static const double sideGap = 40.0;
  static const double headerHeight = 80.0;

  static const Vector2 cardSize = Vector2(cardWidth, cardHeight);

  // Game state
  int currentRound = 0;
  int playerCount = 3;
  
  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    world = StrategicWorld();
  }
}
