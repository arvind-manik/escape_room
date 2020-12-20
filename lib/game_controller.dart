import 'dart:math';

import 'package:escape_room/components/coords.dart';
import 'package:escape_room/components/enemy.dart';
import 'package:escape_room/components/player.dart';
import 'package:escape_room/constants.dart';
import 'package:escape_room/utils/debouncer.dart';
import 'package:escape_room/utils/event_handler.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/keyboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class GameController extends Game with KeyboardEvents {
  Size screenSize;
  double tileSize;

  Player player;
  Enemy enemy;

  static final Random random = Random();
  EventHandler handler;

  GameController() {
    init();
  }

  void init() async {
    resize(await Flame.util.initialDimensions());
    this.handler = EventHandler(this);
    this.player = new Player(this);
    this.enemy = Enemy(this);
    print(this.screenSize);
  }

  @override
  void render(Canvas canvas) async {
    Rect backgroundRect =
        Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    Paint backgroundPaint = Paint()..color = Color(Constants.backgroundColor);

    canvas.drawRect(backgroundRect, backgroundPaint);

    player.render(canvas);
    enemy.render(canvas);
  }

  @override
  void update(double delta) {
    this.player.update(delta);
    this.enemy.update(delta);
  }

  @override
  void resize(Size size) {
    this.screenSize = size;
    this.tileSize =
        min(screenSize.width / 10, Constants.minTileSize).roundToDouble();
  }

  @override
  void onKeyEvent(RawKeyEvent event) {
    handler.handleKeyboardEvent(event);
  }

  final _dragDebouncer = Debouncer(Constants.touchDebounceTime);
  void onDrag(DragUpdateDetails details) {
    if (this.player.isDead) {
      return;
    }

    Direction direction = details.delta.dx.abs() > details.delta.dy.abs()
        ? Direction.horizontal
        : Direction.vertical;

    _dragDebouncer.run(() => this.handler.handleDragEvent(direction, details));
  }

  bool checkIntersection(Coords coords) {
    Coords playerCoords = this.player.getCoords();
    return playerCoords.getX() == coords.getX() &&
        playerCoords.getY() == coords.getY();
  }

  Coords getRandomCoords() {
    double xBound = this.screenSize.width;
    double yBound = this.screenSize.height;

    double x = random.nextDouble() * xBound;
    double y = random.nextDouble() * yBound;

    return new Coords(x, y);
  }
}
