import 'package:escape_room/components/coords.dart';
import 'package:escape_room/constants.dart';
import 'package:escape_room/game_controller.dart';
import 'package:escape_room/utils/debouncer.dart';
import 'package:flutter/cupertino.dart';

class Enemy {
  GameController controller;

  double _size;
  double _speed;

  Rect enemyRect;
  Coords coords;

  Enemy(this.controller, Direction direction) {
    this._size = this.controller.tileSize * Constants.enemySizeFactor;
    this._speed = this.controller.tileSize * Constants.enemySpeedFactor;
    this.coords = getCoords(direction);
    enemyRect =
        Rect.fromLTWH(coords.getX(), coords.getY(), this._size, this._size);
    this.controller.player.subscribeToMovement((coords) => {});
  }

  Coords getCoords(Direction direction) {
    Coords coords = this.controller.getRandomCoords(this._size);

    //Overriding to spawn outside screen
    switch (direction) {
      case Direction.WEST:
        coords.setX(0 - this._size * Constants.spawnTileBuffer);
        break;
      case Direction.NORTH:
        coords.setY(0 - this._size * Constants.spawnTileBuffer);
        break;
      case Direction.EAST:
        coords.setX(this.controller.screenSize.width +
            this._size * Constants.spawnTileBuffer);
        break;
      case Direction.SOUTH:
        coords.setY(this.controller.screenSize.height +
            this._size * Constants.spawnTileBuffer);
    }

    while (isInvalidSpawnPoint(coords)) {
      coords = getCoords(direction);
    }

    return coords;
  }

  bool isInvalidSpawnPoint(Coords coords) {
    Coords playerCoords = this.controller.player.getCoords();
    return ((coords.getX() - playerCoords.getX()).abs() <
            Constants.spawnKillAvoidBuffer) &&
        ((coords.getY() - playerCoords.getY()).abs() <
            Constants.spawnKillAvoidBuffer);
  }

  void render(Canvas canvas) {
    Paint enemyColor = Paint()..color = Color(Constants.enemyColor);
    canvas.drawRect(this.enemyRect, enemyColor);
  }

  void update(double delta) {
    double stepDistance = this._speed * delta;
    Offset toPlayer =
        this.controller.player.playerRect.center - this.enemyRect.center;
    if (stepDistance <= toPlayer.distance - this.controller.tileSize * 0.8) {
      Offset stepToPlayer =
          Offset.fromDirection(toPlayer.direction, stepDistance);
      this.enemyRect = this.enemyRect.shift(stepToPlayer);
    } else {
      attack();
    }
  }

  Debouncer _attackDeboucer = Debouncer(Constants.attackDebounceTime);
  void attack() {
    _attackDeboucer.run(() => this.controller.player.livesLeft--);
  }
}
