import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:taxi_booking/screens/WhatToDeliver.dart';
import 'package:taxi_booking/screens/get_started_widget.dart';
import '../utils/Extensions/StringExtensions.dart';
import '../main.dart';
import '../../screens/WalkThroughtScreen.dart';
import '../../utils/Colors.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/app_common.dart';
import '../network/RestApis.dart';
import '../utils/images.dart';
import 'EditProfileScreen.dart';
import 'SignInScreen.dart';
import 'DashBoardScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    await Future.delayed(Duration(seconds: 3));
    // if (sharedPref.getBool(IS_FIRST_TIME) ?? true) {
    // await Geolocator.requestPermission().then((value) async {
    //   await Geolocator.getCurrentPosition().then((value) {
    //     sharedPref.setDouble(LATITUDE, value.latitude);
    //     sharedPref.setDouble(LONGITUDE, value.longitude);
    //     launchScreen(context, WalkThroughScreen(), pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
    //   });
    // });
    // } else {
    if (!appStore.isLoggedIn) {
      launchScreen(context, GetStartedWidget(),
          pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
    } else {
      await Geolocator.requestPermission().then((value) async {
        await Geolocator.getCurrentPosition().then((value) {
          sharedPref.setDouble(LATITUDE, value.latitude);
          sharedPref.setDouble(LONGITUDE, value.longitude);
          launchScreen(context, WhatToDeliver(),
              pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
        });
      });
      // launchScreen(context, SignInScreen(), pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
      //   if (sharedPref.getString(CONTACT_NUMBER).validate().isEmptyOrNull) {
      //     launchScreen(context, EditProfileScreen(isGoogle: true), isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
      //   } else {
      //     launchScreen(context, DashBoardScreen(), pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
      //   }
      // }
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: primaryColor,
      backgroundColor: Color.fromRGBO(20, 86, 241, 1),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(ic_logo_white,
                fit: BoxFit.contain, height: 150, width: 150),
            // SizedBox(height: 16),
            // Text(language.appName, style: boldTextStyle(color: Colors.white, size: 22)),
          ],
        ),
      ),
    );
  }
}
