import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';
import 'dart:math';

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

  final tableGreen = const Color(0xFF35654d);
  final feltBorderColor = const Color(0xFF2d503f);

  // Add new state variables for card locking
  PlayingCard? lockedCard;
  Map<String, bool> opponentLocked = {
    'Player 3': false,
    'Player 4': false,
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _centerDeckController.dispose();
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
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        opponentLocked['Player 3'] = true;
      });
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          opponentLocked['Player 4'] = true;
        });
      });
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

  Widget _buildPokerTable() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tableGreen,
        borderRadius: BorderRadius.circular(150),
        border: Border.all(color: feltBorderColor, width: 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.5,
          colors: [
            tableGreen.withOpacity(0.9),
            tableGreen,
          ],
          stops: const [0.4, 1.0],
        ),
      ),
      child: CustomPaint(
        painter: FeltPatternPainter(
          patternColor: feltBorderColor.withOpacity(0.1),
        ),
      ),
    );
  }

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
              Colors.brown.shade900,
              Colors.brown.shade800,
              Colors.brown.shade700,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(child: _buildPokerTable()),
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
                                      score: 0,
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
                                                  showBack: true,
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
                                      score: 0,
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
                                                  showBack: true,
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
                        _buildPlayerInfo(name: "You", score: 0, isOpponent: false),
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

