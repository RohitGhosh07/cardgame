import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';

class CardStyles {
  static PlayingCardViewStyle defaultStyle = PlayingCardViewStyle(
    suitStyles: {
      Suit.spades: SuitStyle(
        style: TextStyle(color: Colors.black),
      ),
      Suit.hearts: SuitStyle(
        style: TextStyle(color: Colors.red),
      ),
      Suit.diamonds: SuitStyle(
        style: TextStyle(color: Colors.red),
      ),
      Suit.clubs: SuitStyle(
        style: TextStyle(color: Colors.black),
      ),
    },
    decorationStyle: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(color: Colors.amber.withOpacity(0.5)),
    ),
  );
}
