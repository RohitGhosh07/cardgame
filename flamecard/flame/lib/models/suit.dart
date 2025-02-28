enum Suit {
  hearts,
  diamonds,
  clubs,
  spades,
  bidding; // The fourth suit used for bidding

  bool get isRed => this == hearts || this == diamonds;
  String get label {
    switch (this) {
      case Suit.hearts: return '♥';
      case Suit.diamonds: return '♦';
      case Suit.clubs: return '♣';
      case Suit.spades: return '♠';
      case Suit.bidding: return '★';
    }
  }
}
