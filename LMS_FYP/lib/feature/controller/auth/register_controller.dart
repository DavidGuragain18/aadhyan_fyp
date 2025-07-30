// controllers/registration_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../screen/auth/login_screen.dart';
import '../../services/api_services.dart';

class RegistrationController extends GetxController {
  final registerFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isImageUploading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);

  // Added role selection
  final RxString selectedRole = ''.obs;
  final List<String> roles = ['student', 'teacher'];

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void setSelectedImage(File? image) {
    selectedImage.value = image;
  }

  void setImageUploading(bool loading) {
    isImageUploading.value = loading;
  }

  // Added role selection method
  void setSelectedRole(String role) {
    selectedRole.value = role;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name cannot be empty';
    }
    return null;
  }

  // Added role validation method
  String? validateRole() {
    if (selectedRole.value.isEmpty) {
      return 'Please select a role';
    }
    return null;
  }

  Future<void> registerUser() async {
    FocusScope.of(Get.context!).unfocus();

    // Validate form and role
    if (!registerFormKey.currentState!.validate()) {
      return;
    }

    // Check role validation separately since it's not a TextFormField
    if (validateRole() != null) {
      Get.snackbar(
        'Validation Error',
        'Please select a role (Student or Teacher)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await ApiService.registerUser(
        emailController.text.trim(),
        passwordController.text,
        nameController.text.trim(),
        selectedRole.value,
        imagePath:
            selectedImage.value?.path, // Pass the image path if available
      );

      if (response.success) {
        Get.snackbar(
          'Success',
          "Register Successfully",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        _clearForm();
        Get.offAll(() => LoginScreen());
      } else {
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error at RegistrationController',
        'An unexpected error occurred: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _clearForm() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    selectedImage.value = null;
    selectedRole.value = ''; // Clear selected role
    isPasswordVisible.value = false;
  }
}
