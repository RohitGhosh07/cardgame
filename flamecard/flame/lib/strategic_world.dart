import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'models/suit.dart';
import 'strategic_game.dart';
import 'components/game_card.dart';

class StrategicWorld extends World 
    with HasGameReference<StrategicGame>, TapCallbacks {
  
  // Game components
  final List<GameCard> playerCards = [];
  final List<GameCard> biddingCards = [];
  late GameCard currentBiddingCard;
  
  @override
  Future<void> onLoad() async {
    await Flame.images.load('card-sprites.png');
    
    // Setup initial game state
    _dealCards();
    _setupBiddingArea();
  }

  void _dealCards() {
    // Deal 13 cards to each player (one suit each)
    for (int rank = 1; rank <= 13; rank++) {
      for (int suitIndex = 0; suitIndex < 3; suitIndex++) {
        final card = GameCard(
          rank: rank,
          suit: Suit.values[suitIndex],
          position: Vector2(
            StrategicGame.sideGap + rank * StrategicGame.cardGap,
            StrategicGame.headerHeight + suitIndex * StrategicGame.cardHeight * 1.2,
          ),
        );
        playerCards.add(card);
        add(card);
      }
    }
  }

  void _setupBiddingArea() {
    // Setup bidding cards (fourth suit)
    for (int rank = 1; rank <= 13; rank++) {
      final card = GameCard(
        rank: rank,
        suit: Suit.bidding,
        position: Vector2(-200, -200), // Off screen initially
      );
      biddingCards.add(card);
      add(card);
    }
  }
}
