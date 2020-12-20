import 'dart:ui' as ui;

import 'package:flutter/services.dart';

class Util {
  static int getCurrentTime() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  static Future<ui.Image> loadAsset(String asset) async {
    ByteData data = await rootBundle.load(asset);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }
}
