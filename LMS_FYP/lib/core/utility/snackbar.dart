import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackBarMessage {
  // Show success message - separate method
  static void showSuccessMessage(String message) {
    // Use a slight delay to ensure navigation completes first
    Future.delayed(const Duration(milliseconds: 300), () {
      Get.snackbar(
        'Success',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    });
  }

  static void showErrorMessage(String message, {String error = 'Error'}) {
    // Use a slight delay to ensure navigation completes first
    Future.delayed(const Duration(milliseconds: 300), () {
      Get.snackbar(
        error,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        //  colorText: Colors.white,
        colorText: Get.theme.colorScheme.onPrimary,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    });
  }
}
