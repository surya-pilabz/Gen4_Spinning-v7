import 'package:flutter/material.dart';
import 'package:flyer/screens/select_machine.dart';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';


class SplashScreenUI extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: AnimatedSplashScreen(
            nextScreen: SelectMachineUI(),
            splash: "assets/logo.jpeg",
            splashTransition: SplashTransition.fadeTransition,
            centered: true,
            pageTransitionType: PageTransitionType.leftToRightWithFade,
            splashIconSize: 400,
          ),
        ),
        Container(
          color: Colors.white,
          width: double.infinity,
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.only(right: 12.0, bottom: 8.0),
            child: Text(
              "version V7",
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,

              ),
            ),
          ),
        )

      ],
    );
  }

}

/*
SplashScreen(
      seconds: 3,
      navigateAfterSeconds: SelectMachineUI(),
      image: Image.asset("assets/logo.jpeg"),
      photoSize: 200.0,
      backgroundColor: Colors.white,
      loaderColor: Theme.of(context).primaryColor,
      loadingText: Text("Loading", style: TextStyle(color: Theme.of(context).primaryColor),),
    );
 */