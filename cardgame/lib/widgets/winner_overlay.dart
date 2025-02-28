import 'dart:math';

import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';
import 'package:confetti/confetti.dart';

class WinnerOverlay extends StatefulWidget {
  final Map<String, PlayingCard> playedCards;
  final String winner;
  final int points;
  final VoidCallback onComplete;
  final bool isPlayer;

  const WinnerOverlay({
    super.key,
    required this.playedCards,
    required this.winner,
    required this.points,
    required this.onComplete,
    required this.isPlayer,
  });

  @override
  State<WinnerOverlay> createState() => _WinnerOverlayState();
}

class _WinnerOverlayState extends State<WinnerOverlay> with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    );

    _slideController.forward();
    if (widget.isPlayer) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        if (!widget.isPlayer) {
          widget.onComplete();
        }
      },
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Stack(
          children: [
            if (widget.isPlayer) 
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: pi / 2,
                  maxBlastForce: 5,
                  minBlastForce: 2,
                  emissionFrequency: 0.05,
                  numberOfParticles: 50,
                  gravity: 0.1,
                ),
              ),
            AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - _slideAnimation.value)),
                  child: Opacity(
                    opacity: _slideAnimation.value,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildWinnerCard(),
                          const SizedBox(height: 24),
                          _buildOtherCards(),
                          if (!widget.isPlayer)
                            Padding(
                              padding: const EdgeInsets.only(top: 32),
                              child: Text(
                                'Tap anywhere to continue',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWinnerCard() {
    final size = MediaQuery.of(context).size;
    final cardWidth = size.width * 0.2;
    final cardHeight = cardWidth * 1.5;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.amber.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.winner == 'You' ? '🏆 You Won! 🏆' : '${widget.winner} Won',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: cardWidth,
            height: cardHeight,
            child: PlayingCardView(
              card: widget.playedCards[widget.winner]!,
              style: PlayingCardViewStyle(
                suitStyles: {
                  Suit.spades: SuitStyle(
                    style: TextStyle(color: Colors.black87, fontSize: 32),
                  ),
                  Suit.hearts: SuitStyle(
                    style: TextStyle(color: Colors.red, fontSize: 32),
                  ),
                  Suit.diamonds: SuitStyle(
                    style: TextStyle(color: Colors.red, fontSize: 32),
                  ),
                  Suit.clubs: SuitStyle(
                    style: TextStyle(color: Colors.black87, fontSize: 32),
                  ),
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          TweenAnimationBuilder(
            duration: const Duration(milliseconds: 1200),
            tween: Tween<double>(begin: 0, end: widget.points.toDouble()),
            builder: (context, double value, child) {
              return Text(
                '+${value.toInt()} points',
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOtherCards() {
    final size = MediaQuery.of(context).size;
    final cardWidth = size.width * 0.15;
    final cardHeight = cardWidth * 1.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: widget.playedCards.entries
          .where((entry) => entry.key != widget.winner)
          .map((entry) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: PlayingCardView(
                        card: entry.value,
                        style: PlayingCardViewStyle(
                          suitStyles: {
                            Suit.spades: SuitStyle(
                              style: TextStyle(color: Colors.black87, fontSize: 24),
                            ),
                            Suit.hearts: SuitStyle(
                              style: TextStyle(color: Colors.red, fontSize: 24),
                            ),
                            Suit.diamonds: SuitStyle(
                              style: TextStyle(color: Colors.red, fontSize: 24),
                            ),
                            Suit.clubs: SuitStyle(
                              style: TextStyle(color: Colors.black87, fontSize: 24),
                            ),
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.key,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
