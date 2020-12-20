import 'dart:math';

import 'package:escape_room/components/coords.dart';
import 'package:escape_room/components/player.dart';
import 'package:escape_room/game_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

enum PlayerMovement { up, down, left, right }
enum Direction { horizontal, vertical }

class EventHandler {
  Map<PlayerMovement, Function> eventSubscibers = Map();
  GameController controller;

  EventHandler(this.controller);

  void handleMovement(PlayerMovement movement) {
    Coords coords = this.controller.player.getCoords();
    double coordX = coords.getX();
    double coordY = coords.getY();

    double delta = this.controller.player.getSpeed();

    switch (movement) {
      case PlayerMovement.up:
        coordY -= delta;
        break;
      case PlayerMovement.down:
        coordY += delta;
        break;
      case PlayerMovement.left:
        coordX -= delta;
        break;
      case PlayerMovement.right:
        coordX += delta;
    }

    this.controller.player.move(new Coords(coordX, coordY));
  }

  void handleKeyboardEvent(RawKeyEvent event) {
    final bool isKeyDown = event is RawKeyDownEvent;
    if (isKeyDown) {
      PlayerMovement movement;
      String code = event.data.keyLabel;
      switch (code) {
        case 'ArrowUp':
          movement = PlayerMovement.up;
          break;
        case 'ArrowDown':
          movement = PlayerMovement.down;
          break;
        case 'ArrowLeft':
          movement = PlayerMovement.left;
          break;
        case 'ArrowRight':
          movement = PlayerMovement.right;
          break;
      }

      handleMovement(movement);
    }
  }

  void handleDragEvent(Direction direction, DragUpdateDetails details) {
    PlayerMovement movement;
    if (direction == Direction.horizontal) {
      movement =
          details.delta.dx > 0 ? PlayerMovement.right : PlayerMovement.left;
    } else if (direction == Direction.vertical) {
      movement = details.delta.dy > 0 ? PlayerMovement.down : PlayerMovement.up;
    }

    handleMovement(movement);
  }
}
