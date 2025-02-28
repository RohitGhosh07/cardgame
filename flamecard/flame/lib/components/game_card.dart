import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../models/suit.dart';
import '../strategic_game.dart';

class GameCard extends PositionComponent with TapCallbacks {
  final int rank;
  final Suit suit;
  bool isFaceUp = true;
  bool isSelected = false;

  GameCard({
    required this.rank,
    required this.suit,
    required Vector2 position,
  }) : super(
          position: position,
          size: StrategicGame.cardSize,
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    // Load card sprite
    final sprite = await _loadCardSprite();
    add(SpriteComponent(
      sprite: sprite,
      size: StrategicGame.cardSize,
    ));
  }

  Future<Sprite> _loadCardSprite() async {
    // TODO: Implement proper sprite loading from sprite sheet
    return Sprite(await game.images.load('card-sprites.png'));
  }

  @override
  bool onTapDown(TapDownEvent event) {
    isSelected = !isSelected;
    // TODO: Implement selection visual feedback
    return true;
  }
}
