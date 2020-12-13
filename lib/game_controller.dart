import 'dart:math';

import 'package:escape_room/components/coords.dart';
import 'package:escape_room/components/player.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/keyboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class GameController extends Game with KeyboardEvents {
  Size screenSize;
  double tileSize;

  Player player;

  static final double _minTileSize = 50.0;

  static final Random random = Random();

  GameController() {
    init();
  }

  void init() async {
    resize(await Flame.util.initialDimensions());
    this.player = new Player(this);
    print(this.screenSize);
  }

  @override
  void render(Canvas canvas) {
    Rect bg = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    Paint bgPaint = Paint()..color = Color(0xFFFAFAFA);

    canvas.drawRect(bg, bgPaint);

    player.render(canvas);
  }

  @override
  void update(double delta) {}

  @override
  void resize(Size size) {
    this.screenSize = size;
    this.tileSize = min(screenSize.width / 10, _minTileSize);
  }

  @override
  void onKeyEvent(event) {
    final bool isKeyDown = event is RawKeyDownEvent;
    if (isKeyDown) {
      String code = event.data.keyLabel;
      Coords coords = this.player.getCoords();
      double coordX = coords.getX();
      double coordY = coords.getY();

      double delta = this.player.getSpeed();

      switch (code) {
        case 'ArrowUp':
          coordY -= delta;
          break;
        case 'ArrowDown':
          coordY += delta;
          break;
        case 'ArrowLeft':
          coordX -= delta;
          break;
        case 'ArrowRight':
          coordX += delta;
          break;
      }

      coordX = max(coordX, 0);
      coordY = max(coordY, 0);
      player.move(new Coords(coordX, coordY));
    }
  }

  bool checkIntersection(Coords coords) {
    return false;
  }

  Coords getRandomCoords() {
    double xBound = this.screenSize.width;
    double yBound = this.screenSize.height;

    double x = random.nextDouble() * xBound;
    double y = random.nextDouble() * yBound;

    return new Coords(x, y);
  }
}
