import 'package:cardgame/widgets/card_overlay.dart';
import 'package:cardgame/widgets/card_reveal.dart';
import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';
import 'dart:math';
import '../widgets/winner_overlay.dart';
import '../constants/game_constants.dart';
import '../styles/card_styles.dart';
import '../widgets/game_table.dart';

class _CardStyles {
  static PlayingCardViewStyle defaultStyle = PlayingCardViewStyle(
    suitStyles: {
      Suit.spades: SuitStyle(
        style: TextStyle(color: Colors.black87, fontSize: 28),
      ),
      Suit.hearts: SuitStyle(
        style: TextStyle(color: Colors.red, fontSize: 28),
      ),
      Suit.diamonds: SuitStyle(
        style: TextStyle(color: Colors.red, fontSize: 28),
      ),
      Suit.clubs: SuitStyle(
        style: TextStyle(color: Colors.black87, fontSize: 28),
      ),
    },
  );

  static PlayingCardViewStyle selectedStyle = PlayingCardViewStyle(
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
  );
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late double cardWidth;
  late double cardHeight;
  late double cardSpacing;

  late List<PlayingCard> playerCards;
  late List<PlayingCard> leftOpponentCards;
  late List<PlayingCard> rightOpponentCards;
  PlayingCard? centerCard;
  PlayingCard? selectedCard;
  PlayingCard? leftOpponentSelectedCard;
  PlayingCard? rightOpponentSelectedCard;

  late AnimationController _animationController;
  late List<Animation<double>> _shuffleAnimations;
  late AnimationController _centerDeckController;
  Suit? selectedSuit;



  // Add new state variables for card locking
  PlayingCard? lockedCard;
  Map<String, bool> opponentLocked = {
    'Player 3': false,
    'Player 4': false,
  };

  // Add new state variables
  Map<String, int> scores = {
    'You': 0,
    'Player 3': 0,
    'Player 4': 0,
  };
  PlayingCard? player3SelectedCard;
  PlayingCard? player4SelectedCard;
  bool isRoundComplete = false;

  // Add new animation controllers
  late AnimationController _cardMovementController;
  final Map<String, Offset> _cardSlotPositions = {
    'You': Offset(0, 0.3),
    'Player 3': Offset(-0.4, -0.1),
    'Player 4': Offset(0.4, -0.1),
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _centerDeckController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _initializeCards();
    _startShufflingAnimation();
    _cardMovementController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _centerDeckController.dispose();
    _cardMovementController.dispose();
    super.dispose();
  }

  void _startShufflingAnimation() {
    _shuffleAnimations = List.generate(
      13,
      (index) => Tween<double>(
        begin: 0.0,
        end: 360.0,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.07,
            min((index * 0.07) + 0.4, 1.0),
            curve: Curves.easeOutBack,
          ),
        ),
      ),
    );

    _animationController.forward().then((_) {
      setState(() {
        _arrangeCards();
      });
    });
  }

  void _arrangeCards() {
    playerCards.sort((a, b) => a.value.index.compareTo(b.value.index));
  }

  void _initializeCards() {
    List<PlayingCard> deck = standardFiftyTwoCardDeck();
    
    selectedSuit = Suit.values[Random().nextInt(4)];
    
    List<PlayingCard> suitCards = deck.where((card) => card.suit == selectedSuit).toList();
    List<PlayingCard> otherCards = deck.where((card) => card.suit != selectedSuit).toList();
    
    suitCards.shuffle();
    otherCards.shuffle();
    
    playerCards = suitCards;
    
    leftOpponentCards = otherCards.sublist(0, 13);
    rightOpponentCards = otherCards.sublist(13, 26);
    
    List<PlayingCard> centerDeck = otherCards.sublist(26);
    centerDeck.shuffle();
    centerCard = centerDeck.first;
  }

  void _onCardTap(PlayingCard card) {
    setState(() {
      if (lockedCard == card) {
        lockedCard = null;
        selectedCard = null;
      } else if (lockedCard == null) {
        selectedCard = card;
      }
    });
  }

  void _lockCard() {
    if (selectedCard != null && lockedCard == null) {
      setState(() {
        lockedCard = selectedCard;
        // Simulate opponent locking after player
        _simulateOpponentLocking();
      });
    }
  }

  void _simulateOpponentLocking() {
    // Simulate Player 3 selection and locking
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        player3SelectedCard = leftOpponentCards[Random().nextInt(leftOpponentCards.length)];
        opponentLocked['Player 3'] = true;
      });
      
      // Simulate Player 4 selection and locking
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          player4SelectedCard = rightOpponentCards[Random().nextInt(rightOpponentCards.length)];
          opponentLocked['Player 4'] = true;
          _checkRoundComplete();
        });
      });
    });
  }

  void _checkRoundComplete() {
    if (lockedCard != null && opponentLocked['Player 3'] == true && opponentLocked['Player 4'] == true) {
      _showRoundResults();
    }
  }

  void _showRoundResults() {
    setState(() {
      isRoundComplete = true;
    });

    int centerValue = centerCard!.value.index + 2;
    Map<String, PlayingCard> playerCards = {
      'You': lockedCard!,
      'Player 3': player3SelectedCard!,
      'Player 4': player4SelectedCard!,
    };

    String winner = '';
    int highestValue = -1;

    playerCards.forEach((player, card) {
      int cardValue = card.value.index + 2;
      if (cardValue > highestValue) {
        highestValue = cardValue;
        winner = player;
      }
    });

    setState(() {
      scores[winner] = scores[winner]! + centerValue;
    });

    showDialog(
      context: context,
      barrierDismissible: winner != 'You',
      barrierColor: Colors.transparent,
      builder: (context) => GestureDetector(
        onTap: () {
          if (winner != 'You') {
            Navigator.of(context).pop();
            _startNewRound();
          }
        },
        child: CardReveal(
          playedCards: playerCards,
          winner: winner,
          points: centerValue,
          onComplete: () {
            Navigator.of(context).pop();
            _startNewRound();
          },
        ),
      ),
    );
  }

  void _startNewRound() {
    setState(() {
      isRoundComplete = false;
      lockedCard = null;
      selectedCard = null;
      player3SelectedCard = null;
      player4SelectedCard = null;
      opponentLocked = {
        'Player 3': false,
        'Player 4': false,
      };
      _initializeCards();
    });
  }

  Widget _buildCenterDeck() {
    return AnimatedBuilder(
      animation: _centerDeckController,
      builder: (context, child) {
        return Transform.rotate(
          angle: sin(_centerDeckController.value * pi * 2) * 0.05,
          child: Container(
            height: cardHeight,
            width: cardWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4), // Reduced from 8 to 4
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: centerCard != null
                ? PlayingCardView(
                    card: centerCard!,
                    style: _CardStyles.defaultStyle,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4), // Added shape parameter
                    ),
                  )
                : Container(),
          ),
        );
      },
    );
  }

  // Widget _buildModernPokerTable() {
  //   return Container(
  //     margin: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: const Color.fromARGB(255, 255, 0, 0),
  //       borderRadius: BorderRadius.circular(200),
  //       border: Border.all(color: const Color(0xFF0d4429), width: 20),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.5),
  //           blurRadius: 30,
  //           spreadRadius: 5,
  //         ),
  //         BoxShadow(
  //           color: Colors.white.withOpacity(0.1),
  //           blurRadius: 10,
  //           spreadRadius: -5,
  //           offset: const Offset(0, -10),
  //         ),
  //       ],
  //       gradient: RadialGradient(
  //         center: Alignment.center,
  //         radius: 1.5,
  //         colors: [
  //           const Color(0xFF2d875a),
  //           const Color(0xFF1a6340),
  //         ],
  //         stops: const [0.4, 1.0],
  //       ),
  //     ),
  //     child: Stack(
  //       fit: StackFit.expand,
  //       children: [
  //         // Felt pattern
  //         CustomPaint(
  //           painter: ModernFeltPatternPainter(
  //             patternColor: const Color(0xFF165535).withOpacity(0.3),
  //           ),
  //         ),
  //         // Card slots
  //         ..._cardSlotPositions.entries.map((entry) {
  //           return _buildCardSlot(entry.key, entry.value);
  //         }),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildCardSlot(String player, Offset position) {
    return Align(
      alignment: Alignment(position.dx, position.dy),
      child: Container(
        width: cardWidth * 1.1,
        height: cardHeight * 1.1,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white30,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: -2,
            ),
          ],
        ),
        child: _buildLockedCardInSlot(player),
      ),
    );
  }

  Widget _buildLockedCardInSlot(String player) {
    PlayingCard? card;
    bool isLocked = false;

    switch (player) {
      case 'You':
        card = lockedCard;
        isLocked = lockedCard != null;
        break;
      case 'Player 3':
        card = player3SelectedCard;
        isLocked = opponentLocked['Player 3'] ?? false;
        break;
      case 'Player 4':
        card = player4SelectedCard;
        isLocked = opponentLocked['Player 4'] ?? false;
        break;
    }

    if (!isLocked) return const SizedBox();

    return AnimatedSlide(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      offset: Offset.zero,
      child: AnimatedRotation(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutBack,
        turns: isRoundComplete ? 0 : 0.5,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: PlayingCardView(
            card: card!,
            showBack: !isRoundComplete,
            style: _CardStyles.defaultStyle,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildPokerTable() {
  //   return Container(
  //     margin: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: GameColors.tableGreen,
  //       borderRadius: BorderRadius.circular(150),
  //       border: Border.all(color: GameColors.feltBorderColor, width: 16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.5),
  //           blurRadius: 20,
  //           spreadRadius: 5,
  //         ),
  //       ],
  //       gradient: RadialGradient(
  //         center: Alignment.center,
  //         radius: 1.5,
  //         colors: [
  //           GameColors.tableGreen.withOpacity(0.9),
  //           GameColors.tableGreen,
  //         ],
  //         stops: const [0.4, 1.0],
  //       ),
  //     ),
  //     child: CustomPaint(
  //       painter: FeltPatternPainter(
  //         patternColor: GameColors.feltBorderColor.withOpacity(0.1),
  //       ),
  //     ),
  //   );
  // }

  void _calculateCardDimensions(BuildContext context) {
    final size = MediaQuery.of(context).size;
    cardWidth = (size.width * 0.17).clamp(70.0, 85.0);
    cardHeight = (cardWidth * 1.5).clamp(105.0, 125.0);
    cardSpacing = (cardWidth * 0.3).clamp(18.0, 25.0);
  }

  @override
  Widget build(BuildContext context) {
    _calculateCardDimensions(context);
    final size = MediaQuery.of(context).size;
    final maxFanAngle = 0.15;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1e1e2a),
              const Color(0xFF2d2d3f),
              const Color(0xFF1e1e2a),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: GameTable(
                  children: [
                    ..._cardSlotPositions.entries.map((entry) {
                      return _buildCardSlot(entry.key, entry.value);
                    }),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.02,
                  vertical: size.height * 0.01,
                ),
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.02),
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Positioned(
                            left: size.width * 0.02,
                            top: size.height * 0.15,
                            child: Transform.rotate(
                              angle: -0.1,
                              child: SizedBox(
                                width: size.width * 0.25,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildPlayerInfo(
                                      name: "Player 3",
                                      score: scores["Player 3"] ?? 0,
                                      isOpponent: true,
                                      compact: true,
                                    ),
                                    SizedBox(
                                      width: cardWidth * 1.2,
                                      height: cardHeight,
                                      child: Stack(
                                        children: [
                                          for (var i = 0; i < leftOpponentCards.length; i++)
                                            Positioned(
                                              left: i * 1.5,
                                              child: SizedBox(
                                                width: cardWidth,
                                                height: cardHeight,
                                                child: PlayingCardView(
                                                  card: leftOpponentCards[i],
                                                  showBack: !isRoundComplete || player3SelectedCard != leftOpponentCards[i],
                                                  style: _CardStyles.defaultStyle,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: size.width * 0.02,
                            top: size.height * 0.15,
                            child: Transform.rotate(
                              angle: 0.1,
                              child: SizedBox(
                                width: size.width * 0.25,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildPlayerInfo(
                                      name: "Player 4",
                                      score: scores["Player 4"] ?? 0,
                                      isOpponent: true,
                                      compact: true,
                                    ),
                                    SizedBox(
                                      width: cardWidth * 1.2,
                                      height: cardHeight,
                                      child: Stack(
                                        children: [
                                          for (var i = 0; i < rightOpponentCards.length; i++)
                                            Positioned(
                                              left: i * 1.5,
                                              child: SizedBox(
                                                width: cardWidth,
                                                height: cardHeight,
                                                child: PlayingCardView(
                                                  card: rightOpponentCards[i],
                                                  showBack: !isRoundComplete || player4SelectedCard != rightOpponentCards[i],
                                                  style: _CardStyles.defaultStyle,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment(0, -0.2),
                            child: _buildCenterDeck(),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selectedCard != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildPlayerCard(selectedCard!, lockedCard == selectedCard),
                              if (selectedCard != null && lockedCard == null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: ElevatedButton.icon(
                                    onPressed: _lockCard,
                                    icon: const Icon(Icons.lock),
                                    label: const Text('Lock Card'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.amber,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        _buildPlayerInfo(name: "You", score: scores["You"] ?? 0, isOpponent: false),
                        SizedBox(
                          height: cardHeight * 1.2,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            clipBehavior: Clip.none,
                            children: [
                              for (var i = 0; i < playerCards.length; i++)
                                Positioned(
                                  bottom: 0,
                                  left: size.width / 2 - (cardWidth / 2) + 
                                        (i - playerCards.length / 2) * (cardSpacing * 0.8),
                                  child: Transform.translate(
                                    offset: Offset(0, selectedCard == playerCards[i] ? -15 : 0),
                                    child: Transform.rotate(
                                      angle: (i - playerCards.length / 2) * (maxFanAngle / playerCards.length),
                                      child: GestureDetector(
                                        onTap: () => _onCardTap(playerCards[i]),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4), // Reduced from 8 to 4
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: SizedBox(
                                            width: cardWidth,
                                            height: cardHeight,
                                            child: PlayingCardView(
                                              card: playerCards[i],
                                              style: _CardStyles.defaultStyle,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(4), // Added shape parameter
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerCard(PlayingCard card, bool isLocked) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4), // Reduced from 10 to 4
            boxShadow: [
              BoxShadow(
                color: isLocked ? Colors.amber.withOpacity(0.5) : Colors.black26,
                blurRadius: isLocked ? 8 : 4,
                spreadRadius: isLocked ? 2 : 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SizedBox(
            width: cardWidth,
            height: cardHeight,
            child: PlayingCardView(
              card: card,
              style: isLocked ? _CardStyles.selectedStyle : _CardStyles.defaultStyle,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4), // Added shape parameter
              ),
            ),
          ),
        ),
        if (isLocked)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.lock, size: 16, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildPlayerInfo({
    required String name,
    required int score,
    required bool isOpponent,
    bool compact = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: compact ? 4 : 8,
        vertical: compact ? 2 : 4,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: compact ? 12 : 16,
            backgroundColor: isOpponent ? Colors.red.shade300 : Colors.blue.shade300,
            child: Text(
              name[0].toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: compact ? 10 : 12,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              name,
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 12 : 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Score: $score',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
          if (isOpponent && opponentLocked[name] == true)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(
                Icons.check_circle,
                size: compact ? 16 : 20,
                color: Colors.green,
              ),
            ),
        ],
      ),
    );
  }
}

class FeltPatternPainter extends CustomPainter {
  final Color patternColor;
  
  FeltPatternPainter({required this.patternColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = patternColor
      ..strokeWidth = 1.0;

    const spacing = 20.0;
    for (double i = 0; i < size.width; i += spacing) {
      for (double j = 0; j < size.height; j += spacing) {
        final path = Path()
          ..moveTo(i + spacing / 2, j)
          ..lineTo(i + spacing, j + spacing / 2)
          ..lineTo(i + spacing / 2, j + spacing)
          ..lineTo(i, j + spacing / 2)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(FeltPatternPainter oldDelegate) => false;
}

class ModernFeltPatternPainter extends CustomPainter {
  final Color patternColor;
  
  ModernFeltPatternPainter({required this.patternColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = patternColor
      ..strokeWidth = 1.0;

    const spacing = 30.0;
    for (double i = 0; i < size.width; i += spacing) {
      for (double j = 0; j < size.height; j += spacing) {
        canvas.drawCircle(
          Offset(i, j),
          1.5,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(ModernFeltPatternPainter oldDelegate) => false;
}

