import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../klondike_game.dart';

class FlatButton extends PositionComponent with TapCallbacks {
  final String text;
  final VoidCallback onReleased;
  bool _isPressed = false;
  late TextComponent _label;
  late final Paint _bgPaint;
  late final Paint _pressedPaint;

  FlatButton(
    this.text, {
    required Vector2 size,
    required Vector2 position,
    required this.onReleased,
  }) : super(size: size, position: position) {
    _bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          KlondikeGame.accentColor,
          KlondikeGame.accentColor.withOpacity(0.8),
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, size.x, size.y),
      );

    _pressedPaint = Paint()
      ..color = KlondikeGame.accentColor.withOpacity(0.6);
  }

  @override
  Future<void> onLoad() async {
    _label = TextComponent(
      text: text,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 48,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    _label.anchor = Anchor.center;
    _label.position = size / 2;
    add(_label);
  }

  @override
  bool onTapDown(TapDownEvent event) {
    _isPressed = true;
    return true;
  }

  @override
  bool onTapUp(TapUpEvent event) {
    _isPressed = false;
    onReleased();
    return true;
  }

  @override
  bool onTapCancel(TapCancelEvent event) {
    _isPressed = false;
    return true;
  }

  @override
  void render(Canvas canvas) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(KlondikeGame.buttonRadius),
    );
    canvas.drawRRect(rrect, _isPressed ? _pressedPaint : _bgPaint);
  }
}