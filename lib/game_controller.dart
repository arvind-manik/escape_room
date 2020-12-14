import 'dart:math';

import 'package:escape_room/components/coords.dart';
import 'package:escape_room/components/player.dart';
import 'package:escape_room/utils/event_handler.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/keyboard.dart';
import 'package:flutter/cupertino.dart';

class GameController extends Game with KeyboardEvents {
  Size screenSize;
  double tileSize;

  Player player;

  static final double _minTileSize = 50.0;

  static final Random random = Random();
  EventHandler handler;

  GameController() {
    init();
  }

  void init() async {
    resize(await Flame.util.initialDimensions());
    this.handler = EventHandler(this);
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
  void onKeyEvent(RawKeyEvent event) {
    handler.handleKeyboardEvent(event);
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    this.handler.handleDragEvent(Direction.horizontal, details);
  }

  void onVerticalDragUpdate(DragUpdateDetails details) {
    this.handler.handleDragEvent(Direction.vertical, details);
  }

  void onDrag(DragUpdateDetails event) {
    print(event);
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
