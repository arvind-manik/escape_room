import 'package:escape_room/components/coords.dart';
import 'package:escape_room/constants.dart';
import 'package:escape_room/game_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class EventHandler {
  GameController controller;

  EventHandler(this.controller);

  void handleMovement(Offset offset) {
    Coords coords = this.controller.player.getCoords();
    double coordX = coords.getX();
    double coordY = coords.getY();

    this
        .controller
        .player
        .move(new Coords(coordX + offset.dx, coordY + offset.dy));
  }

  void handleKeyboardEvent(RawKeyEvent event) {
    final bool isKeyDown = event is RawKeyDownEvent;
    double dx, dy;
    double playerSpeed = this.controller.player.getSpeed();

    if (isKeyDown) {
      String code = event.data.keyLabel;
      switch (code) {
        case 'ArrowUp':
          dy = playerSpeed;
          break;
        case 'ArrowDown':
          dy = -playerSpeed;
          break;
        case 'ArrowLeft':
          dx = -playerSpeed;
          break;
        case 'ArrowRight':
          dx = playerSpeed;
          break;
      }

      handleMovement(new Offset(dx, dy));
    }
  }

  void handleDragEvent(Axis direction, DragUpdateDetails details) {
    double xMultipler, yMultipler;
    xMultipler = yMultipler = 1.0;
    double playerSpeed = this.controller.player.getSpeed();

    if (direction == Axis.horizontal) {
      xMultipler = playerSpeed;
    } else if (direction == Axis.vertical) {
      yMultipler = playerSpeed;
    }

    handleMovement(new Offset(
        details.delta.dx * xMultipler, details.delta.dy * yMultipler));
  }
}
