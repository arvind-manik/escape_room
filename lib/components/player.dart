import 'dart:ui' as ui;

import 'package:escape_room/components/coords.dart';
import 'package:escape_room/constants.dart';
import 'package:escape_room/game_controller.dart';
import 'package:escape_room/utils/util.dart';
import 'package:flutter/cupertino.dart';

class Player {
  final GameController controller;

  double _size;
  double _speed;

  int livesLeft;

  Rect playerRect;
  bool isDead = false;

  Coords targetCoords;
  final listeners = {};

  ui.Image lifeIcon;

  Player(this.controller) {
    livesLeft = Constants.playerLives;
    _size = controller.tileSize * Constants.playerSizeFactor;
    _speed = controller.tileSize * Constants.playerSpeedFactor;

    Coords coords = controller.getRandomCoords(_getRadius());
    loadAssets();
    move(coords);
  }

  _getRadius() => this._size / 2;

  Coords getCoords() => this.targetCoords;

  loadAssets() async {
    this.lifeIcon = await Util.loadAsset(
        Constants.heartIcon, Constants.iconSize, Constants.iconSize);
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
    if (this.playerRect == null) {
      this.playerRect =
          Rect.fromLTWH(coords.getX(), coords.getY(), this._size, this._size);
    }

    this.controller.handleWrap(coords, _getRadius());
    this.targetCoords = coords;

    List movementListeners = this.listeners[GameEvent.PLAYER_MOVEMENT];
    if (movementListeners != null) {
      for (Function function in movementListeners) {
        function.call(this.targetCoords);
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
      return;
    }

    double stepDistance = this._speed * delta;
    this.controller.handleWrap(this.targetCoords, _getRadius());
    Offset stepOffset = this.targetCoords.toOffset() - this.playerRect.center;

    Coords newCoords = Coords.applyOffset(this.targetCoords, stepOffset);
    Offset stepToNewPosition =
        Offset.fromDirection(stepOffset.direction, stepDistance);
    this.playerRect = this.playerRect.shift(stepToNewPosition);
  }

  double getSpeed() {
    return this._speed;
  }
}
