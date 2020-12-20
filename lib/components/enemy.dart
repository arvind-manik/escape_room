import 'package:escape_room/components/coords.dart';
import 'package:escape_room/game_controller.dart';
import 'package:flutter/cupertino.dart';

class Enemy {
  GameController controller;

  double _size;
  double _speed;

  double maxHealth;
  double currHealth;

  Rect enemyRect;
  Coords coords;

  Enemy(this.controller, Coords coords) {
    this._size = this.controller.tileSize * 0.5;
    this._speed = this.controller.tileSize * 0.25;
    this.coords = coords;
  }
}
