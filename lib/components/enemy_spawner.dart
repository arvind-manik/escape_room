import 'dart:math';

import 'package:escape_room/components/enemy.dart';
import 'package:escape_room/constants.dart';
import 'package:escape_room/game_controller.dart';

class EnemySpawner {
  final GameController controller;
  int currentInterval;
  int nextSpawn;

  EnemySpawner(this.controller) {
    init();
  }

  void init() {
    this.currentInterval = Constants.maxSpawnInterval;
    this.nextSpawn =
        DateTime.now().millisecondsSinceEpoch + this.currentInterval;
  }

  void clearEnemies() {
    this.controller.enemies.forEach((Enemy enemy) => enemy.isDead = true);
  }

  void update(double delta) {
    int now = DateTime.now().millisecondsSinceEpoch;
    if (this.controller.enemies.length < Constants.maxEnemies &&
        now >= nextSpawn) {
      this.controller.spawnEnemy();

      this.currentInterval = max(
          GameController.random.nextInt(Constants.maxSpawnInterval),
          Constants.minSpawnInterval);
      this.nextSpawn = now + this.currentInterval;
    }
  }
}
