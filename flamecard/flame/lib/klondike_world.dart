import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import 'components/card.dart';
import 'components/flat_button.dart';
import 'components/foundation_pile.dart';
import 'components/stock_pile.dart';
import 'components/tableau_pile.dart';
import 'components/waste_pile.dart';

import 'klondike_game.dart';

class KlondikeWorld extends World with HasGameReference<KlondikeGame> {
  final cardGap = KlondikeGame.cardGap;
  final topGap = KlondikeGame.topGap;
  final cardSpaceWidth = KlondikeGame.cardSpaceWidth;
  final cardSpaceHeight = KlondikeGame.cardSpaceHeight;

  final stock = StockPile(position: Vector2(0.0, 0.0));
  final waste = WastePile(position: Vector2(0.0, 0.0));
  final List<FoundationPile> foundations = [];
  final List<TableauPile> tableauPiles = [];
  final List<Card> cards = [];
  late Vector2 playAreaSize;

  @override
  Future<void> onLoad() async {
    await Flame.images.load('klondike-sprites.png');

    // Calculate center-aligned positions
    final totalWidth = 7 * cardSpaceWidth + KlondikeGame.sideGap * 2;
    final startX = KlondikeGame.sideGap;
    final startY = KlondikeGame.headerHeight + KlondikeGame.topGap;

    // Position stock and waste piles
    stock.position = Vector2(startX, startY);
    waste.position = Vector2(startX + cardSpaceWidth, startY);

    // Position foundation piles (right-aligned)
    final foundationStartX = startX + 3 * cardSpaceWidth;
    for (var i = 0; i < 4; i++) {
      foundations.add(
        FoundationPile(
          i,
          checkWin,
          position: Vector2(foundationStartX + i * cardSpaceWidth, startY),
        ),
      );
    }

    // Position tableau piles with proper spacing
    for (var i = 0; i < 7; i++) {
      tableauPiles.add(
        TableauPile(
          position: Vector2(
            startX + i * cardSpaceWidth,
            startY + cardSpaceHeight,
          ),
        ),
      );
    }

    // Add a Base Card to the Stock Pile, above the pile and below other cards.
    final baseCard = Card(1, 0, isBaseCard: true);
    baseCard.position = stock.position;
    baseCard.priority = -1;
    baseCard.pile = stock;
    stock.priority = -2;

    for (var rank = 1; rank <= 13; rank++) {
      for (var suit = 0; suit < 4; suit++) {
        final card = Card(rank, suit);
        card.position = stock.position;
        cards.add(card);
      }
    }

    add(stock);
    add(waste);
    addAll(foundations);
    addAll(tableauPiles);
    addAll(cards);
    add(baseCard);

    // Update play area size
    playAreaSize = Vector2(
      totalWidth,
      5 * cardSpaceHeight + KlondikeGame.headerHeight + KlondikeGame.topGap,
    );

    // Center-align buttons
    final buttonY = KlondikeGame.headerHeight / 2;
    final totalButtonWidth = 4 * (KlondikeGame.buttonWidth + KlondikeGame.buttonGap);
    final buttonStartX = (totalWidth - totalButtonWidth) / 2;

    // Add buttons with proper spacing
    for (var i = 0; i < 4; i++) {
      final buttonX = buttonStartX + i * (KlondikeGame.buttonWidth + KlondikeGame.buttonGap);
      addButton(
        _getButtonLabel(i),
        buttonX,
        _getButtonAction(i),
      );
    }

    // Center camera
    final camera = game.camera;
    camera.viewfinder.visibleGameSize = playAreaSize;
    camera.viewfinder.position = Vector2(totalWidth / 2, 0);
    camera.viewfinder.anchor = Anchor.topCenter;

    deal();
  }

  void addButton(String label, double buttonX, Action action) {
    final button = FlatButton(
      label,
      size: Vector2(KlondikeGame.buttonWidth, KlondikeGame.buttonHeight),
      position: Vector2(
        buttonX - (KlondikeGame.buttonWidth / 2),
        topGap / 2 - (KlondikeGame.buttonHeight / 2),
      ),
      onReleased: () {
        if (action == Action.haveFun) {
          letsCelebrate();
        } else {
          game.action = action;
          game.world = KlondikeWorld();
        }
      },
    );
    add(button);
  }

  String _getButtonLabel(int index) {
    switch (index) {
      case 0: return 'New Deal';
      case 1: return 'Same Deal';
      case 2: return 'Draw ${game.klondikeDraw == 1 ? "3" : "1"}';
      case 3: return 'Have Fun';
      default: return '';
    }
  }

  Action _getButtonAction(int index) {
    switch (index) {
      case 0: return Action.newDeal;
      case 1: return Action.sameDeal;
      case 2: return Action.changeDraw;
      case 3: return Action.haveFun;
      default: throw Exception('Invalid button index');
    }
  }

  void deal() {
    assert(cards.length == 52, 'There are ${cards.length} cards: should be 52');

    if (game.action != Action.sameDeal) {
      // New deal: change the Random Number Generator's seed.
      game.seed = Random().nextInt(KlondikeGame.maxInt);
      if (game.action == Action.changeDraw) {
        game.klondikeDraw = (game.klondikeDraw == 3) ? 1 : 3;
      }
    }
    // For the "Same deal" option, re-use the previous seed, else use a new one.
    cards.shuffle(Random(game.seed));

    // Each card dealt must be seen to come from the top of the deck!
    var dealPriority = 1;
    for (final card in cards) {
      card.priority = dealPriority++;
    }

    // Change priority as cards take off: so later cards fly above earlier ones.
    var cardToDeal = cards.length - 1;
    var nMovingCards = 0;
    for (var i = 0; i < 7; i++) {
      for (var j = i; j < 7; j++) {
        final card = cards[cardToDeal--];
        card.doMove(
          tableauPiles[j].position,
          speed: 15.0,
          start: nMovingCards * 0.15,
          startPriority: 100 + nMovingCards,
          onComplete: () {
            tableauPiles[j].acquireCard(card);
            nMovingCards--;
            if (nMovingCards == 0) {
              var delayFactor = 0;
              for (final tableauPile in tableauPiles) {
                delayFactor++;
                tableauPile.flipTopCard(start: delayFactor * 0.15);
              }
            }
          },
        );
        nMovingCards++;
      }
    }
    for (var n = 0; n <= cardToDeal; n++) {
      stock.acquireCard(cards[n]);
    }
  }

  void checkWin() {
    // Callback from a Foundation Pile when it is full (Ace to King).
    var nComplete = 0;
    for (final f in foundations) {
      if (f.isFull) {
        nComplete++;
      }
    }
    if (nComplete == foundations.length) {
      letsCelebrate();
    }
  }

  void letsCelebrate({int phase = 1}) {
    // Deal won: bring all cards to the middle of the screen (phase 1)
    // then scatter them to points just outside the screen (phase 2).
    //
    // First get the device's screen-size in game co-ordinates, then get the
    // top-left of the off-screen area that will accept the scattered cards.
    // Note: The play area is anchored at TopCenter, so topLeft.y is fixed.

    final cameraZoom = game.camera.viewfinder.zoom;
    final zoomedScreen = game.size / cameraZoom;
    final screenCenter = (playAreaSize - KlondikeGame.cardSize) / 2;
    final topLeft = Vector2(
      (playAreaSize.x - zoomedScreen.x) / 2 - KlondikeGame.cardWidth,
      -KlondikeGame.cardHeight,
    );
    final nCards = cards.length;
    final offscreenHeight = zoomedScreen.y + KlondikeGame.cardSize.y;
    final offscreenWidth = zoomedScreen.x + KlondikeGame.cardSize.x;
    final spacing = 2.0 * (offscreenHeight + offscreenWidth) / nCards;

    // Starting points, directions and lengths of offscreen rect's sides.
    final corner = [
      Vector2(0.0, 0.0),
      Vector2(0.0, offscreenHeight),
      Vector2(offscreenWidth, offscreenHeight),
      Vector2(offscreenWidth, 0.0),
    ];
    final direction = [
      Vector2(0.0, 1.0),
      Vector2(1.0, 0.0),
      Vector2(0.0, -1.0),
      Vector2(-1.0, 0.0),
    ];
    final length = [
      offscreenHeight,
      offscreenWidth,
      offscreenHeight,
      offscreenWidth,
    ];

    var side = 0;
    var cardsToMove = nCards;
    var offScreenPosition = corner[side] + topLeft;
    var space = length[side];
    var cardNum = 0;

    while (cardNum < nCards) {
      final cardIndex = phase == 1 ? cardNum : nCards - cardNum - 1;
      final card = cards[cardIndex];
      card.priority = cardIndex + 1;
      if (card.isFaceDown) {
        card.flip();
      }
      // Start cards a short time apart to give a riffle effect.
      final delay = phase == 1 ? cardNum * 0.02 : 0.5 + cardNum * 0.04;
      final destination = (phase == 1) ? screenCenter : offScreenPosition;
      card.doMove(
        destination,
        speed: (phase == 1) ? 15.0 : 5.0,
        start: delay,
        onComplete: () {
          cardsToMove--;
          if (cardsToMove == 0) {
            if (phase == 1) {
              letsCelebrate(phase: 2);
            } else {
              // Restart with a new deal after winning or pressing "Have fun".
              game.action = Action.newDeal;
              game.world = KlondikeWorld();
            }
          }
        },
      );
      cardNum++;
      if (phase == 1) {
        continue;
      }

      // Phase 2: next card goes to same side with full spacing, if possible.
      offScreenPosition = offScreenPosition + direction[side] * spacing;
      space = space - spacing;
      if ((space < 0.0) && (side < 3)) {
        // Out of space: change to the next side and use excess spacing there.
        side++;
        offScreenPosition = corner[side] + topLeft - direction[side] * space;
        space = length[side] + space;
      }
    }
  }
}