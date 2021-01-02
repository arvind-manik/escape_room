import 'package:flutter/foundation.dart';
import 'package:BlueBlockRun/utils/util.dart';

///
/// Taken as reference from
/// https://medium.com/fantageek/how-to-debounce-action-in-flutter-ed7177843407
///

class Debouncer {
  final int milliseconds;

  int lastEventTime = Util.getCurrentTime();

  Debouncer(this.milliseconds);

  run(VoidCallback action) {
    int now = Util.getCurrentTime();
    if (now - lastEventTime > this.milliseconds) {
      lastEventTime = now;
      action();
    }
  }
}
