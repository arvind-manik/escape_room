import 'package:BlueBlockRun/game_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GameTextField {
  final GameController controller;
  TextPainter painter;
  Offset position;

  GameTextField(this.controller) {
    this.painter = TextPainter(
        textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    this.position = Offset.zero;
  }

  void render(Canvas canvas) {
    if (this.painter.text != null) {
      this.painter.layout();
      this.painter.paint(canvas, this.position);
    }
  }
}
