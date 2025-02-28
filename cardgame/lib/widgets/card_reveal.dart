import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';
import '../constants/game_constants.dart';

class CardReveal extends StatelessWidget {
  final Map<String, PlayingCard> playedCards;
  final String winner;
  final int points;
  final VoidCallback onComplete;

  const CardReveal({
    super.key,
    required this.playedCards,
    required this.winner,
    required this.points,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardWidth = size.width * 0.15;
    final cardHeight = cardWidth * 1.4;

    return Material(
      color: Colors.black54,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            vertical: size.height * 0.05,
            horizontal: size.width * 0.05,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Winner banner
              _buildWinnerBanner(context),
              const SizedBox(height: 40),

              // Cards display
              Center(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 32,
                  alignment: WrapAlignment.center,
                  children: playedCards.entries.map((entry) {
                    final index = playedCards.keys.toList().indexOf(entry.key);
                    return _buildPlayerCard(
                      context,
                      entry.key,
                      entry.value,
                      entry.key == winner,
                      index,
                      cardWidth,
                      cardHeight,
                    );
                  }).toList(),
                ),
              ),

              // Continue text
              if (winner != 'You') ...[
                const SizedBox(height: 40),
                Text(
                  'Tap to continue',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWinnerBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            winner == 'You' ? '🏆 YOU WIN! 🏆' : '${winner.toUpperCase()} WINS!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          Text(
            '+$points POINTS',
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(
    BuildContext context,
    String player,
    PlayingCard card,
    bool isWinner,
    int index,
    double cardWidth,
    double cardHeight,
  ) {
    return Container(
      width: cardWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: cardWidth,
            height: cardHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                if (isWinner)
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
              ],
            ),
            child: PlayingCardView(
              card: card,
              style: PlayingCardViewStyle(
                suitStyles: {
                  Suit.spades: SuitStyle(style: TextStyle(fontSize: isWinner ? 32 : 28)),
                  Suit.hearts: SuitStyle(style: TextStyle(fontSize: isWinner ? 32 : 28)),
                  Suit.diamonds: SuitStyle(style: TextStyle(fontSize: isWinner ? 32 : 28)),
                  Suit.clubs: SuitStyle(style: TextStyle(fontSize: isWinner ? 32 : 28)),
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            player,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
