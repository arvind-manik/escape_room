import 'dart:math';
import 'dart:ui' as ui;

import 'package:escape_room/components/coords.dart';
import 'package:escape_room/components/enemy.dart';
import 'package:escape_room/components/player.dart';
import 'package:escape_room/constants.dart';
import 'package:escape_room/utils/debouncer.dart';
import 'package:escape_room/utils/event_handler.dart';
import 'package:escape_room/utils/util.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/game/game_render_box.dart';
import 'package:flame/keyboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class GameController extends Game with KeyboardEvents {
  Size screenSize;
  double tileSize;

  Player player;
  List<Enemy> enemies;

  static final Random random = Random();
  EventHandler handler;

  ui.Image grassSprite;

  GameController() {
    init();
  }

  void init() async {
    resize(await Flame.util.initialDimensions());
    this.handler = EventHandler(this);
    this.player = new Player(this);
    this.enemies = List<Enemy>();
    spawnEnemy();
    this.grassSprite = await Util.loadAsset(Constants.grass,
        this.screenSize.width.toInt(), this.screenSize.height.toInt());
    print(this.screenSize);
  }

  @override
  void render(Canvas canvas) async {
    if (this.grassSprite != null) {
      canvas.drawImage(this.grassSprite, new Offset(0, 0), Paint());
    }

    player.render(canvas);
    enemies.forEach((enemy) {
      enemy.render(canvas);
    });
  }

  @override
  void update(double delta) {
    if (this.player.isDead) {
      return;
    }

    this.player.update(delta);
    this.enemies.forEach((enemy) {
      enemy.update(delta);
    });
  }

  @override
  void resize(Size size) {
    this.screenSize = size;
    this.tileSize =
        max(screenSize.width / Constants.tileSizeFactor, Constants.minTileSize)
            .roundToDouble();
  }

  @override
  void onKeyEvent(RawKeyEvent event) {
    if (this.player.isDead) {
      init();
    }

    handler.handleKeyboardEvent(event);
  }

  final _dragDebouncer = Debouncer(Constants.touchDebounceTime);
  void onDrag(DragUpdateDetails details) {
    if (this.player.isDead) {
      init();
    }

    Axis direction = details.delta.dx.abs() > details.delta.dy.abs()
        ? Axis.horizontal
        : Axis.vertical;

    _dragDebouncer.run(() => this.handler.handleDragEvent(direction, details));
  }

  bool checkIntersection(Coords coords) {
    Coords playerCoords = this.player.getCoords();
    return playerCoords.getX() == coords.getX() &&
        playerCoords.getY() == coords.getY();
  }

  Coords getRandomCoords(double radius) {
    double xBound = this.screenSize.width;
    double yBound = this.screenSize.height;

    double x = random.nextDouble() * xBound;
    double y = random.nextDouble() * yBound;

    Coords coords = new Coords(x, y);
    handleWrap(coords, radius);

    return coords;
  }

  void handleWrap(Coords coords, double radius) {
    if (isHorizontalWrap(coords, radius)) {
      double overflowX = coords.getX() + radius - this.screenSize.width;
      coords.setX(coords.getX() - overflowX);
    }

    if (isVerticalWrap(coords, radius)) {
      double overflowY = coords.getY() + radius - this.screenSize.height;
      coords.setY(coords.getY() - overflowY);
    }

    coords.setX(max(coords.getX(), radius));
    coords.setY(max(coords.getY(), radius));
  }

  bool isVerticalWrap(Coords coords, double radius) {
    return coords.getY() + radius > this.screenSize.height;
  }

  bool isHorizontalWrap(Coords coords, double radius) {
    return coords.getX() + radius > this.screenSize.width;
  }

  bool isWrap(Coords coords, double radius) {
    return isVerticalWrap(coords, radius) || isHorizontalWrap(coords, radius);
  }

  void spawnEnemy() {
    //For 4 directions on the 2D plane
    int directionSeed = random.nextInt(4);
    Direction spawnDirection = Constants.getDirectionByValue(directionSeed);

    this.enemies.add(Enemy(this, spawnDirection));
  }
}
