class GameEvent {
  Event event;
  Map payload;

  GameEvent(this.event, this.payload);

  Event getEvent() {
    return this.event;
  }

  Map getPayload() {
    return this.payload;
  }
}

enum Event { PLAYER_MOVEMENT, GAME_OVER }
