class Constants {
  //General
  static final int playerLives = 3;
  static final double minTileSize = 30.0;
  static final double spawnTileBuffer = 3;
  static final double spawnKillAvoidBuffer = 5;
  static final double tileSizeFactor = 100;
  static final double playerSpeedFactor = 4.0;
  static final double playerSizeFactor = 1.0;
  static final double enemySpeedFactor = 3.0;
  static final double enemySizeFactor = 1.0;
  static final int initialEnemyCount = 2;
  static final double enemySpawnRate = 0.5;

  static final int touchDebounceTime = 50;
  static final int attackDebounceTime = 300;

  static final int iconOffset = 5;
  static final int iconSize = 20;

  //Colors
  static final int backgroundColor = 0xFFFAFAFA;
  static final int playerColor = 0xFF0000FF;
  static final int enemyColor = 0xFFFF4500;

  //Icons
  static final String heartIcon = 'assets/icons/heart.png';

  //Sprites
  static final String grass = 'assets/sprites/grass.png';

  static Direction getDirectionByValue(int val) {
    switch (val) {
      case 0:
        return Direction.WEST;
      case 1:
        return Direction.NORTH;
      case 2:
        return Direction.EAST;
      case 3:
        return Direction.SOUTH;
    }

    return null;
  }
}

enum GameEvent { PLAYER_MOVEMENT, GAME_OVER }
enum Direction { WEST, NORTH, EAST, SOUTH }
