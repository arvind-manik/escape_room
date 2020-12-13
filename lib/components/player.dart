import 'package:escape_room/components/coords.dart';
import 'package:escape_room/game_controller.dart';
import 'package:flutter/cupertino.dart';

class Player {
  final GameController controller;

  double _playerSize;
  double _speed;

  int maxHealth;
  int currHealth;

  Rect playerRect;
  bool isDead = false;

  Coords coords;

  Player(this.controller) {
    maxHealth = currHealth = 100;
    _playerSize = controller.tileSize * 1.5;
    _speed = controller.tileSize * 0.5;

    Coords coords = controller.getRandomCoords();
    adjustBounds(coords, _playerSize);

    playerRect =
        Rect.fromLTWH(coords.getX(), coords.getY(), _playerSize, _playerSize);

    this.coords = coords;
  }

  void adjustBounds(Coords coords, double playerSize) {
    Size screenSize = this.controller.screenSize;
    if (coords.getX() + playerSize > screenSize.width) {
      double overflowX = coords.getX() + playerSize - screenSize.width;
      coords.setX(coords.getX() - overflowX);
    }

    if (coords.getY() + playerSize > screenSize.height) {
      double overflowY = coords.getY() + playerSize - screenSize.height;
      coords.setY(coords.getY() - overflowY);
    }
  }

  void render(Canvas canvas) {
    Paint playerPaint = Paint()..color = Color(0xFF0000FF);
    canvas.drawRect(playerRect, playerPaint);
  }

  void move(Coords coords) {
    adjustBounds(coords, this._playerSize);
    playerRect =
        Rect.fromLTWH(coords.getX(), coords.getY(), _playerSize, _playerSize);
    this.coords = coords;
  }

  void update(double delta) {}

  Coords getCoords() {
    return this.coords;
  }

  double getSpeed() {
    return this._speed;
  }
}
