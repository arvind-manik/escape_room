import 'package:flutter/foundation.dart';
import 'package:escape_room/utils/util.dart';
import 'dart:async';

///
/// Taken as reference from
/// https://medium.com/fantageek/how-to-debounce-action-in-flutter-ed7177843407
///

class Debouncer {
  final int milliseconds;
  VoidCallback action;
  Timer _timer;

  int lastEventTime;

  Debouncer(this.milliseconds);

  run(VoidCallback action) {
    int now = Util.getCurrentTime();
    if (_timer != null && now - lastEventTime > this.milliseconds) {
      _timer.cancel();
    }

    lastEventTime = now;
    _timer = Timer(Duration(milliseconds: this.milliseconds), action);
  }
}
