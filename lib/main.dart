import 'package:escape_room/game_controller.dart';
import 'package:flame/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Util flameUtil = Util();
  await flameUtil.fullScreen();
  await flameUtil.setOrientation(DeviceOrientation.portraitUp);

  GameController controller = GameController();
  runApp(controller.widget);

  HorizontalDragGestureRecognizer draggerH = HorizontalDragGestureRecognizer();
  draggerH.onUpdate = controller.onHorizontalDragUpdate;
  flameUtil.addGestureRecognizer(draggerH);

  VerticalDragGestureRecognizer draggerV = VerticalDragGestureRecognizer();
  draggerV.onUpdate = controller.onVerticalDragUpdate;
  flameUtil.addGestureRecognizer(draggerV);
}
