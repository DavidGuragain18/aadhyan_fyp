import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showNonDismissibleLoadingDialog(String message) {
  Get.dialog(
    WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: false, // Prevent tap outside to dismiss
  );
}
