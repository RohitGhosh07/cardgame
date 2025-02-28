import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flamecard/bidding_world.dart';

import 'klondike_world.dart';

enum Action { newDeal, sameDeal, changeDraw, haveFun }

class KlondikeGame extends FlameGame<KlondikeWorld> {
  // Modern UI constants with better spacing
  static const double cardGap = 100.0;
  static const double topGap = 250.0;  // Reduced for better top spacing
  static const double sideGap = 150.0; // New side padding
  static const double headerHeight = 180.0; // New header area height
  static const double cardWidth = 800.0;  // Slightly smaller for better fit
  static const double cardHeight = 1120.0;
  static const double cardRadius = 160.0;
  static const double cardSpaceWidth = cardWidth + cardGap;
  static const double cardSpaceHeight = cardHeight + cardGap;
  
  // Button styling
  static const double buttonRadius = 80.0;
  static const double buttonHeight = 100.0;
  static const double buttonWidth = 250.0;
  static const double buttonGap = 30.0; // Gap between buttons
  
  // Colors
  static const Color accentColor = Color(0xFF2196F3);
  static const Color tableColor = Color(0xFF1E1E1E);
  static const Color shadowColor = Color(0x40000000);
  static final Vector2 cardSize = Vector2(cardWidth, cardHeight);
  static final cardRRect = RRect.fromRectAndRadius(
    const Rect.fromLTWH(0, 0, cardWidth, cardHeight),
    const Radius.circular(cardRadius),
  );

  /// Constant used to decide when a short drag is treated as a TapUp event.
  static const double dragTolerance = cardWidth / 5;

  /// Constant used when creating Random seed.
  static const int maxInt = 0xFFFFFFFE; // = (2 to the power 32) - 1

  // This KlondikeGame constructor also initiates the first KlondikeWorld.
  KlondikeGame() : super(world: KlondikeWorld());

  // These three values persist between games and are starting conditions
  // for the next game to be played in KlondikeWorld. The actual seed is
  // computed in KlondikeWorld but is held here in case the player chooses
  // to replay a game by selecting Action.sameDeal.
  int klondikeDraw = 1;
  int seed = 1;
  Action action = Action.newDeal;
}

Sprite klondikeSprite(double x, double y, double width, double height) {
  return Sprite(
    Flame.images.fromCache('klondike-sprites.png'),
    srcPosition: Vector2(x, y),
    srcSize: Vector2(width, height),
  );
}