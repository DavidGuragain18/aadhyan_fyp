import 'package:flutter/material.dart';

class ClearFocus {
  static void clearAllFocus(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
