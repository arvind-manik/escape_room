import 'package:BlueBlockRun/components/text_field.dart';
import 'package:BlueBlockRun/constants.dart';
import 'package:BlueBlockRun/game_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScoreField extends GameTextField {
  ScoreField(GameController controller) : super(controller);

  void update(double delta) {
    String currentScore = this.controller.score.toInt().toString();
    if ((this.painter.text ?? '') != currentScore) {
      this.painter.text = TextSpan(
          text: currentScore,
          style: TextStyle(
              color: Colors.black, fontSize: Constants.scoreFontSize));

      this.painter.layout();
      this.position = Offset(
          (this.controller.screenSize.width / 2) - (painter.width / 2),
          (this.controller.screenSize.height * 0.1) - (painter.height / 2));
    }
  }
}
