import 'package:BlueBlockRun/components/coords.dart';
import 'package:BlueBlockRun/constants.dart';
import 'package:BlueBlockRun/game_controller.dart';
import 'package:BlueBlockRun/utils/debouncer.dart';
import 'package:flutter/cupertino.dart';

class Enemy {
  GameController controller;

  double _size;
  double _speed;

  Rect enemyRect;
  Coords coords;

  bool isDead = false;

  double health = Constants.enemyHealth;

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
    Color color;
    switch (this.health.toInt()) {
      case 1:
        color = Color(Constants.enemyColorLowHealth);
        break;
      case 2:
        color = Color(Constants.enemyColorMedHealth);
        break;
      case 3:
        color = Color(Constants.enemyColorFullHealth);
        break;
      default:
        color = Color(Constants.transparentColor);
        break;
    }
    Paint enemyColor = Paint()..color = color;
    canvas.drawRect(this.enemyRect, enemyColor);
  }

  void update(double delta) {
    if (this.isDead) {
      return;
    }

    double stepDistance = this._speed * delta;
    Offset toPlayer =
        this.controller.player.playerRect.center - this.enemyRect.center;
    if (stepDistance <=
        toPlayer.distance -
            this.controller.tileSize * Constants.enemyHitRange) {
      Offset stepToPlayer =
          Offset.fromDirection(toPlayer.direction, stepDistance);
      this.enemyRect = this.enemyRect.shift(stepToPlayer);
    } else {
      attack();
    }
  }

  void onTap() {
    this.health--;

    if (this.health <= 0) {
      this.isDead = true;
      this.controller.handleEnemyKill();
    }
  }

  Debouncer _attackDeboucer = Debouncer(Constants.attackDebounceTime);
  void attack() {
    if (!this.isDead) {
      _attackDeboucer.run(() => this.controller.handleAttack());
    }
  }
}
