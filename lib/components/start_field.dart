import 'package:escape_room/components/text_field.dart';
import 'package:escape_room/constants.dart';
import 'package:escape_room/game_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StartField extends GameTextField {
  StartField(GameController controller) : super(controller);

  void update(double delta) {
    this.painter.text = TextSpan(
        text: 'Start!',
        style: TextStyle(
            color: Colors.black,
            fontSize: Constants.menuFontSize,
            fontWeight: FontWeight.bold));

    this.painter.layout();
    this.position = Offset(
        (this.controller.screenSize.width / 2) - (painter.width / 2),
        (this.controller.screenSize.height * 0.7) - (painter.height / 2));
  }
}
