import 'package:escape_room/components/coords.dart';
import 'package:escape_room/constants.dart';
import 'package:escape_room/game_controller.dart';
import 'package:flutter/cupertino.dart';

class Enemy {
  GameController controller;

  double _size;
  double _speed;

  Rect enemyRect;
  Coords coords;

  Enemy(this.controller) {
    this._size = this.controller.tileSize * Constants.enemySizeFactor;
    this._speed = this.controller.tileSize * Constants.enemySpeedFactor;
    this.coords = getCoords();
    enemyRect =
        Rect.fromLTWH(coords.getX(), coords.getY(), this._size, this._size);
    this.controller.player.subscribeToMovement((coords) => {print(coords)});
  }

  Coords getCoords() {
    Coords coords = this.controller.getRandomCoords();
    while (isInvalidSpawnPoint(coords)) {
      coords = getCoords();
    }

    return coords;
  }

  bool isInvalidSpawnPoint(Coords coords) {
    Coords playerCoords = this.controller.player.getCoords();
    return ((coords.getX() - playerCoords.getX()).abs() <
            Constants.spawnTileBuffer) &&
        ((coords.getY() - playerCoords.getY()).abs() <
            Constants.spawnTileBuffer);
  }

  void render(Canvas canvas) {
    Paint enemyColor = Paint()..color = Color(Constants.enemyColor);
    canvas.drawRect(this.enemyRect, enemyColor);
  }

  void update(double delta) {}
}
