import 'dart:math';
import 'dart:ui' as ui;

import 'package:escape_room/components/coords.dart';
import 'package:escape_room/constants.dart';
import 'package:escape_room/game_controller.dart';
import 'package:escape_room/game_event.dart';
import 'package:escape_room/utils/util.dart';
import 'package:flutter/cupertino.dart';

class Player {
  final GameController controller;

  double _size;
  double _speed;

  int livesLeft;

  Rect playerRect;
  bool isDead = false;

  Coords coords;
  final listeners = {};

  ui.Image lifeIcon;

  Player(this.controller) {
    livesLeft = Constants.playerLives;
    _size = controller.tileSize * Constants.playerSizeFactor;
    _speed = controller.tileSize * Constants.playerSpeedFactor;

    Coords coords = controller.getRandomCoords();
    loadAssets();
    move(coords);
  }

  loadAssets() async {
    this.lifeIcon = await Util.loadAsset(Constants.heartIcon);
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

  void render(Canvas canvas) async {
    Paint playerPaint = Paint()..color = Color(Constants.playerColor);
    canvas.drawRect(playerRect, playerPaint);

    if (this.lifeIcon != null) {
      double lifeIconXPos = this.controller.screenSize.width -
          Constants.iconOffset -
          Constants.iconSize;
      double lifeIconYPos = Constants.iconOffset.toDouble();
      for (int i = 0; i < this.livesLeft; i++) {
        canvas.drawImage(
            this.lifeIcon, new Offset(lifeIconXPos, lifeIconYPos), Paint());
        lifeIconXPos -= lifeIcon.width + Constants.iconOffset * 2;
      }
    }
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

    List movementListeners = this.listeners[GameEvent.PLAYER_MOVEMENT];
    if (movementListeners != null) {
      for (Function function in movementListeners) {
        function.call(this.coords);
      }
    }
  }

  void subscribeToMovement(Function listener) {
    List movementListeners = this.listeners[GameEvent.PLAYER_MOVEMENT];
    if (movementListeners == null) {
      movementListeners = this.listeners[GameEvent.PLAYER_MOVEMENT] = [];
    }

    movementListeners.add(listener);
  }

  void update(double delta) async {
    if (!this.isDead && this.livesLeft <= 0) {
      this.isDead = true;
      print('Welp! You\'re dead');
    }
  }

  Coords getCoords() {
    return this.coords;
  }

  double getSpeed() {
    return this._speed;
  }
}
