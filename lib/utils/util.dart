import 'dart:async';
import 'dart:ui' as UI;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as IMG;

class Util {
  static int getCurrentTime() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  static Future<UI.Image> loadAsset(String asset, int width, int height) async {
    final IMG.Image image =
        IMG.decodeImage((await rootBundle.load(asset)).buffer.asUint8List());
    final IMG.Image resized =
        IMG.copyResize(image, width: width, height: height);
    final List<int> resizedBytes = IMG.encodePng(resized);
    final Completer<UI.Image> completer = new Completer();

    UI.decodeImageFromList(
        resizedBytes, (UI.Image img) => completer.complete(img));

    return await completer.future;
  }
}
