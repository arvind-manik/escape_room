import 'dart:math';

import 'package:escape_room/components/coords.dart';
import 'package:escape_room/components/game_event.dart';
import 'package:escape_room/constants.dart';
import 'package:escape_room/game_controller.dart';
import 'package:flutter/cupertino.dart';

class Player {
  final GameController controller;

  double _size;
  double _speed;

  double maxHealth;
  double currHealth;

  Rect playerRect;
  bool isDead = false;

  Coords coords;
  final listeners = {};

  Player(this.controller) {
    maxHealth = currHealth = Constants.playerHealth;
    _size = controller.tileSize * Constants.playerSizeFactor;
    _speed = controller.tileSize * Constants.playerSpeedFactor;

    Coords coords = controller.getRandomCoords();
    move(coords);
  }

  void handleWrap(Coords coords, double playerSize) {
    Size screenSize = this.controller.screenSize;
    if (coords.getX() + playerSize > screenSize.width) {
      double overflowX = coords.getX() + playerSize - screenSize.width;
      coords.setX(coords.getX() - overflowX);
    }

    if (coords.getY() + playerSize > screenSize.height) {
      double overflowY = coords.getY() + playerSize - screenSize.height;
      coords.setY(coords.getY() - overflowY);
    }

    coords.setX(max(coords.getX(), 0));
    coords.setY(max(coords.getY(), 0));
  }

  void render(Canvas canvas) {
    Paint playerPaint = Paint()..color = Color(Constants.playerColor);
    canvas.drawRect(playerRect, playerPaint);
  }

  void move(Coords coords) {
    this.isDead = false;
    handleWrap(coords, this._size);
    if (this.playerRect == null) {
      this.playerRect =
          Rect.fromLTWH(coords.getX(), coords.getY(), this._size, this._size);
    }

    Offset movementOffset =
        Offset(coords.getX(), coords.getY()) - this.playerRect.center;
    Offset newPositionOffset =
        Offset.fromDirection(movementOffset.direction, this._speed);
    this.playerRect = this.playerRect.shift(newPositionOffset);

    this.coords = coords;

    List movementListeners = this.listeners[Event.PLAYER_MOVEMENT];
    if (movementListeners != null) {
      for (Function function in movementListeners) {
        function.call(this.coords);
      }
    }
  }

  void subscribeToMovement(Function listener) {
    List movementListeners = this.listeners[Event.PLAYER_MOVEMENT];
    if (movementListeners == null) {
      movementListeners = this.listeners[Event.PLAYER_MOVEMENT] = [];
    }

    movementListeners.add(listener);
  }

  void kill() {
    if (!this.isDead) {
      this.isDead = true;
      print('Welp! You\'re dead');
    }
  }

  void update(double delta) {}

  Coords getCoords() {
    return this.coords;
  }

  double getSpeed() {
    return this._speed;
  }
}
