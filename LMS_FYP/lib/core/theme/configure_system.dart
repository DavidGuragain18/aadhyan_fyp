import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

void configureSystemUI() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      // Modern approach for status bar
      statusBarColor: primaryColor,
      // statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // for dark icons
      statusBarBrightness: Brightness.light, // iOS status bar brightness

      // Modern approach for navigation bar
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark, // for dark icons
    ),
  );

  // Enable edge-to-edge display
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );
}