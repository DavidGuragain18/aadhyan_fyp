import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fyp/feature/screen/auth/login_screen.dart';
import 'package:get/get.dart';

import 'core/theme/app_themes.dart';
import 'core/theme/configure_system.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Restrict to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  configureSystemUI();

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appThemeData,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        physics: const BouncingScrollPhysics(),
      ),

      // home: LoginScreen(),
      home: SplashScreen(),
    ),
  );
}
