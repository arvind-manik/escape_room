import 'package:BlueBlockRun/game_controller.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flame/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:page_transition/page_transition.dart';

void main() {
  runApp(SplashScreen());
}

Future<Widget> getGameWidget() async {
  WidgetsFlutterBinding.ensureInitialized();
  Util flameUtil = Util();
  await flameUtil.fullScreen();
  await flameUtil.setOrientation(DeviceOrientation.portraitUp);

  SharedPreferences preferences = await SharedPreferences.getInstance();

  GameController controller = GameController(preferences);
  return controller.widget;
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Expanded(
        child: AnimatedSplashScreen.withScreenFunction(
            splash: Container(
              decoration: BoxDecoration(color: Colors.black),
              child: Text('BlueBoxRun!',
                  style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70)),
            ),
            splashTransition: SplashTransition.slideTransition,
            pageTransitionType: PageTransitionType.rightToLeft,
            screenFunction: () async {
              return getGameWidget();
            }),
      ),
    );
  }
}
