import 'dart:math';
import 'dart:ui' as ui;

import 'package:escape_room/components/coords.dart';
import 'package:escape_room/components/enemy.dart';
import 'package:escape_room/components/enemy_spawner.dart';
import 'package:escape_room/components/highscore_field.dart';
import 'package:escape_room/components/player.dart';
import 'package:escape_room/components/score_field.dart';
import 'package:escape_room/components/start_field.dart';
import 'package:escape_room/components/text_field.dart';
import 'package:escape_room/constants.dart';
import 'package:escape_room/utils/debouncer.dart';
import 'package:escape_room/utils/event_handler.dart';
import 'package:escape_room/utils/util.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/keyboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameController extends Game
    with KeyboardEvents, TapDetector, PanDetector {
  final SharedPreferences storage;
  Size screenSize;
  double tileSize;

  Player player;
  List<Enemy> enemies;
  EnemySpawner enemySpawner;

  double score;
  int perKillScore;
  int timeScoreRate;
  int timeScoreUpdateTime; //dumb name I know :(
  int timeScoreRateMultiplierSchedule;

  ScoreField scoreField;
  HighscoreField highscoreField;
  StartField startField;

  static final Random random = Random();
  EventHandler handler;

  GameState state;

  ui.Image grassSprite;

  GameController(this.storage) {
    init();
  }

  void init() async {
    resize(await Flame.util.initialDimensions());
    state = GameState.MENU;

    this.handler = EventHandler(this);

    this.player = new Player(this);

    this.enemies = List<Enemy>();
    this.enemySpawner = EnemySpawner(this);
    spawnEnemy();

    this.score = 0;
    this.scoreField = ScoreField(this);
    this.highscoreField = HighscoreField(this);
    this.startField = StartField(this);

    int now = DateTime.now().millisecondsSinceEpoch;
    this.timeScoreUpdateTime = now;
    this.timeScoreRateMultiplierSchedule =
        now + Constants.timeScoreMultiplierInterval;
    this.perKillScore = Constants.baseKillScoreRate;
    this.timeScoreRate = Constants.baseTimeScoreRate;

    this.grassSprite = await Util.loadAsset(Constants.grass,
        this.screenSize.width.toInt(), this.screenSize.height.toInt());
    print(this.screenSize);
  }

  @override
  void render(Canvas canvas) async {
    if (this.grassSprite != null) {
      canvas.drawImage(this.grassSprite, new Offset(0, 0), Paint());
    }

    this.player.render(canvas);

    if (this.state == GameState.MENU) {
      this.startField.render(canvas);
      this.highscoreField.render(canvas);
    } else {
      this.enemies.forEach((enemy) {
        enemy.render(canvas);
      });

      this.scoreField.render(canvas);
    }
  }

  @override
  void update(double delta) {
    if (this.state == GameState.MENU) {
      this.startField.update(delta);
      this.highscoreField.update(delta);
    } else {
      int now = DateTime.now().millisecondsSinceEpoch;
      if (now > this.timeScoreRateMultiplierSchedule &&
          this.timeScoreRate + 1 < Constants.maxTimeScoreRate) {
        this.timeScoreRate++;
        this.timeScoreRateMultiplierSchedule =
            now + Constants.timeScoreMultiplierInterval;
      }

      if (now - this.timeScoreUpdateTime > Constants.timeScoreUpdateInterval) {
        this.score += this.timeScoreRate;
        checkAndUpdateHighscore();
        this.timeScoreUpdateTime = now;
      }

      this.scoreField.update(delta);
      this.player.update(delta);
      this.enemySpawner.update(delta);
      this.enemies.removeWhere((Enemy enemy) => enemy.isDead);
      this.enemies.forEach((Enemy enemy) {
        enemy.update(delta);
      });
    }
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
  @override
  void onPanUpdate(DragUpdateDetails details) {
    if (this.state == GameState.MENU) {
      this.state = GameState.PLAYING;
    } else {
      if (this.player.isDead) {
        init();
      }

      Axis direction = details.delta.dx.abs() > details.delta.dy.abs()
          ? Axis.horizontal
          : Axis.vertical;

      _dragDebouncer
          .run(() => this.handler.handleDragEvent(direction, details));
    }
  }

  @override
  void onTapDown(TapDownDetails details) {
    if (this.state == GameState.MENU) {
      this.state = GameState.PLAYING;
    } else {
      this.enemies.forEach((Enemy enemy) {
        if (enemy.enemyRect.contains(details.globalPosition)) {
          enemy.onTap();
        }
      });
    }
  }

  @override
  void onPanEnd(DragEndDetails details) {}

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

  void handleAttack() {
    this.player.livesLeft--;

    if (this.player.isDead == true) {
      this.state = GameState.MENU;
    }

    this.perKillScore = Constants.baseKillScoreRate;
  }

  void handleEnemyKill() {
    this.score += this.perKillScore;
    checkAndUpdateHighscore();

    if (this.perKillScore + Constants.killScoreGrowRate <
        Constants.maxKillScoreRate) {
      this.perKillScore += Constants.killScoreGrowRate;
    }
  }

  void checkAndUpdateHighscore() {
    int existingHighScore = getHighScore();
    if (this.score > existingHighScore) {
      this.storage.setInt(Constants.highScoreKey, this.score.toInt());
    }
  }

  int getHighScore() {
    return this.storage.getInt(Constants.highScoreKey) ?? 0;
  }
}
