import 'dart:async';
import 'dart:ui' as UI;
import 'package:escape_room/constants.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as IMG;

class Util {
  static int getCurrentTime() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  static Future<UI.Image> loadAsset(String asset) async {
    final IMG.Image image =
        IMG.decodeImage((await rootBundle.load(asset)).buffer.asUint8List());
    final IMG.Image resized = IMG.copyResize(image,
        width: Constants.iconSize, height: Constants.iconSize);
    final List<int> resizedBytes = IMG.encodePng(resized);
    final Completer<UI.Image> completer = new Completer();

    UI.decodeImageFromList(
        resizedBytes, (UI.Image img) => completer.complete(img));

    return await completer.future;
  }
}
