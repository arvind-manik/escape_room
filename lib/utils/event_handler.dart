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

  void handleMovement(PlayerMovement movement, Offset offset) {
    Coords coords = this.controller.player.getCoords();
    double coordX = coords.getX();
    double coordY = coords.getY();

    switch (movement) {
      case PlayerMovement.up:
        coordY -= offset.dy;
        break;
      case PlayerMovement.down:
        coordY += offset.dy;
        break;
      case PlayerMovement.left:
        coordX -= offset.dx;
        break;
      case PlayerMovement.right:
        coordX += offset.dy;
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

      double dx =
          movement == PlayerMovement.left || movement == PlayerMovement.right
              ? this.controller.player.getSpeed()
              : 0.0;
      double dy =
          movement == PlayerMovement.up || movement == PlayerMovement.down
              ? this.controller.player.getSpeed()
              : 0.0;

      handleMovement(movement, new Offset(dx, dy));
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

    if (movement != null) {
      double multiplier =
          this.controller.player.getSpeed() * this.controller.tileSize;
      handleMovement(
          movement,
          new Offset(details.delta.dx.abs() * multiplier,
              details.delta.dy.abs() * multiplier));
    }
  }
}
