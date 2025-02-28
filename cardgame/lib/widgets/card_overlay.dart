import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';

class CardPlayOverlay extends StatelessWidget {
  final Map<String, PlayingCard> playedCards;
  final String winner;
  final int points;
  final VoidCallback onComplete;

  const CardPlayOverlay({
    super.key,
    required this.playedCards,
    required this.winner,
    required this.points,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.black.withOpacity(0.7 * value),
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.6,
              child: Stack(
                children: [
                  ...playedCards.entries.map((entry) {
                    final index = playedCards.keys.toList().indexOf(entry.key);
                    return CardRevealAnimation(
                      player: entry.key,
                      card: entry.value,
                      isWinner: entry.key == winner,
                      index: index,
                      totalCards: playedCards.length,
                      points: points,
                      onComplete: onComplete,
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CardRevealAnimation extends StatefulWidget {
  final String player;
  final PlayingCard card;
  final bool isWinner;
  final int index;
  final int totalCards;
  final int points;
  final VoidCallback onComplete;

  const CardRevealAnimation({
    super.key,
    required this.player,
    required this.card,
    required this.isWinner,
    required this.index,
    required this.totalCards,
    required this.points,
    required this.onComplete,
  });

  @override
  State<CardRevealAnimation> createState() => _CardRevealAnimationState();
}

class _CardRevealAnimationState extends State<CardRevealAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.5, curve: Curves.easeOutBack),
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.5,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.5, curve: Curves.easeOutBack),
    ));

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.5, 1.0, curve: Curves.easeInOutBack),
    ));

    _controller.forward().then((_) {
      if (widget.isWinner && widget.index == widget.totalCards - 1) {
        Future.delayed(const Duration(seconds: 2), widget.onComplete);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double dx = widget.index * (size.width * 0.25) * _slideAnimation.value;
        return Positioned(
          top: size.height * 0.3,
          left: size.width * 0.5 - (size.width * 0.15) + dx - (widget.totalCards - 1) * (size.width * 0.25) / 2,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: SizedBox(
                width: size.width * 0.3,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: widget.isWinner
                            ? [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                )
                              ]
                            : null,
                      ),
                      child: PlayingCardView(
                        card: widget.card,
                        style: PlayingCardViewStyle(
                          suitStyles: {
                            Suit.spades: SuitStyle(
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: widget.isWinner ? 32 : 28,
                              ),
                            ),
                            Suit.hearts: SuitStyle(
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: widget.isWinner ? 32 : 28,
                              ),
                            ),
                            Suit.diamonds: SuitStyle(
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: widget.isWinner ? 32 : 28,
                              ),
                            ),
                            Suit.clubs: SuitStyle(
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: widget.isWinner ? 32 : 28,
                              ),
                            ),
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.player,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: widget.isWinner ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (widget.isWinner)
                      TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween<double>(begin: 0, end: widget.points.toDouble()),
                        builder: (context, double value, child) {
                          return Text(
                            '+${value.toInt()} points',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
