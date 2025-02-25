import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';
import '../utils/card_styles.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<PlayingCard> playerCards;
  late List<PlayingCard> opponentCards;
  PlayingCard? centerCard;

  @override
  void initState() {
    super.initState();
    _initializeCards();
  }

  void _initializeCards() {
    List<PlayingCard> deck = standardFiftyTwoCardDeck();
    deck.shuffle();
    
    playerCards = deck.sublist(0, 13);
    opponentCards = deck.sublist(13, 26);
    centerCard = deck[26];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/poker_table_bg.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: Column(
          children: [
            _buildPlayersBar(),

            // Center area with opponent cards
            Expanded(
              child: Stack(
                children: [
                  // Opponent Cards (face down)
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      height: 150,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: opponentCards
                              .map((card) => Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2),
                                    child: PlayingCardView(
                                      card: card,
                                      showBack: true,
                                      style: CardStyles.defaultStyle,
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ),

                  // Center Card
                  if (centerCard != null)
                    Center(
                      child: PlayingCardView(
                        card: centerCard!,
                        style: CardStyles.defaultStyle,
                      ),
                    ),
                ],
              ),
            ),

            // Player Cards Area
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 4,
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: playerCards
                            .map((card) => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  child: PlayingCardView(
                                    card: card,
                                    style: CardStyles.defaultStyle,
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayersBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        border: Border(
          bottom: BorderSide(
            color: Colors.amber.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildPlayerProfile('Player 1', '₹5000', 'assets/avatar1.png'),
            _buildPlayerProfile('Player 2', '₹7000', 'assets/avatar2.png'),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerProfile(String name, String balance, String avatarPath) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.amber, width: 2),
            image: DecorationImage(
              image: AssetImage(avatarPath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              balance,
              style: TextStyle(
                color: Colors.amber.shade200,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

