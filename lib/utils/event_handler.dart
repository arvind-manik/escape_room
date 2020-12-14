import 'dart:math';

import 'package:escape_room/components/coords.dart';
import 'package:escape_room/game_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

enum PlayerMovement { up, down, left, right }
enum Direction { horizontal, vertical }

class EventHandler {
  Map<PlayerMovement, Function> eventSubscibers = Map();
  GameController controller;

  EventHandler(this.controller);

  void handleMovement(PlayerMovement movement) {}

  void handleKeyboardEvent(RawKeyEvent event) {
    final bool isKeyDown = event is RawKeyDownEvent;
    if (isKeyDown) {
      String code = event.data.keyLabel;
      Coords coords = this.controller.player.getCoords();
      double coordX = coords.getX();
      double coordY = coords.getY();

      double delta = this.controller.player.getSpeed();

      switch (code) {
        case 'ArrowUp':
          coordY -= delta;
          break;
        case 'ArrowDown':
          coordY += delta;
          break;
        case 'ArrowLeft':
          coordX -= delta;
          break;
        case 'ArrowRight':
          coordX += delta;
          break;
      }

      coordX = max(coordX, 0);
      coordY = max(coordY, 0);
      this.controller.player.move(new Coords(coordX, coordY));
    }
  }

  void handleDragEvent(Direction direction, DragUpdateDetails details) {}
}
