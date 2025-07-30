import 'package:flutter/material.dart';
import 'app_colors.dart';

final ThemeData appThemeData = ThemeData(
  primaryColor: primaryColor,
  hintColor: darkGrey,
  splashColor: complementary2Color,
  highlightColor: ancientColor,
  fontFamily: "Poppins",
  appBarTheme: AppBarTheme(
    elevation: 0,
    centerTitle: true,
    color: primaryColor,
    iconTheme: IconThemeData(
      color: neutralWhiteColor,
    ),
    titleTextStyle: const TextStyle(
      fontFamily: "Poppins",
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),

    //  systemOverlayStyle: SystemUiOverlayStyle(
    //   statusBarColor: Colors.transparent, // Transparent status bar
    //   statusBarIconBrightness: Brightness.light,
    //   statusBarBrightness: Brightness.light,
    //   systemNavigationBarColor:
    //       Colors.transparent, // Transparent navigation bar
    //   systemNavigationBarIconBrightness: Brightness.light,
    // ),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
  ),
);