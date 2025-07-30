import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../model/auth/user_model.dart';
import '../../screen/main_screen.dart';
import '../../services/api_services.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final profileFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isImageUploading = false.obs;
  final RxBool isBiometricEnabled = false.obs;
  final RxBool canUseBiometrics = false.obs;

  // Using Rx<UserModel?> for reactive user state management
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final Rx<File?> selectedProfileImage = Rx<File?>(null);

  // Local authentication instance
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  // Flag to control when the controller can be deleted
  bool _canDelete = false;

  @override
  void onInit() {
    super.onInit();
    _checkBiometricAvailability();
    _loadBiometricPreference();
  }

  @override
  void onClose() {
    // Only dispose controllers if we're allowed to delete
    if (_canDelete) {
      emailController.dispose();
      passwordController.dispose();
      nameController.dispose();
    }
    super.onClose();
  }

  // Renamed to avoid conflict with GetLifeCycleBase.onDelete field
  void deleteController() {
    if (_canDelete) {
      super.onClose();
    }
  }

  // Method to allow deletion (called during logout)
  void allowDeletion() {
    _canDelete = true;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void setImageUploading(bool value) {
    isImageUploading.value = value;
  }

  void setSelectedProfileImage(File? image) {
    selectedProfileImage.value = image;
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      bool canCheck = await _localAuth.canCheckBiometrics;
      canUseBiometrics.value = canCheck;
      log('Biometric availability: $canCheck');
    } catch (e) {
      log('Error checking biometrics: $e');
      canUseBiometrics.value = false;
    }
  }

  Future<void> _loadBiometricPreference() async {
    try {
      String? value = await secureStorage.read(key: 'biometric_enabled');
      isBiometricEnabled.value = value == 'true' && canUseBiometrics.value;
      log('Biometric preference loaded: ${isBiometricEnabled.value}');
    } catch (e) {
      log('Error loading biometric preference: $e');
      isBiometricEnabled.value = false;
    }
  }

  Future<bool> enableBiometrics() async {
    if (!canUseBiometrics.value) {
      Get.snackbar(
        'Error',
        'Biometric authentication is not available on this device.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return false;
    }

    try {
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to enable biometric login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        await secureStorage.write(key: 'biometric_enabled', value: 'true');
        isBiometricEnabled.value = true;
        Get.snackbar(
          'Success',
          'Biometric authentication enabled.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Biometric authentication failed.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return false;
      }
    } catch (e) {
      log('Error enabling biometrics: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    if (!isBiometricEnabled.value || !canUseBiometrics.value) {
      return false;
    }

    try {
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to log in to LMS',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return authenticated;
    } catch (e) {
      log('Biometric authentication error: $e');
      Get.snackbar(
        'Error',
        'Biometric authentication failed: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return false;
    }
  }

  // Store user credentials securely after successful login - FIXED VERSION
  Future<void> storeUserCredentials() async {
    if (user.value != null) {
      try {
        // Convert UserModel to JSON string properly
        String userDataJson = jsonEncode(user.value!.toJson());

        await secureStorage.write(key: 'user_data', value: userDataJson);
        await secureStorage.write(key: 'user_token', value: user.value!.token);
        await secureStorage.write(key: 'user_email', value: user.value!.email);

        log('User credentials stored successfully');
        log('Stored user data: ${user.value!.name}, ${user.value!.email}');
      } catch (e) {
        log('Error storing user credentials: $e');
      }
    }
  }

  // Retrieve stored user data - FIXED VERSION
  Future<UserModel?> _getStoredUserData() async {
    try {
      String? userData = await secureStorage.read(key: 'user_data');
      String? token = await secureStorage.read(key: 'user_token');

      log('Retrieved user data: $userData');
      log('Retrieved token: $token');

      if (userData != null && token != null) {
        // Parse the JSON string back to Map<String, dynamic>
        Map<String, dynamic> userMap = jsonDecode(userData);
        UserModel storedUser = UserModel.fromJson(userMap);

        log(
          'Successfully parsed stored user: ${storedUser.name}, ${storedUser.email}',
        );
        return storedUser;
      } else {
        log('No stored user data or token found');
        return null;
      }
    } catch (e) {
      log('Error retrieving stored user data: $e');
      return null;
    }
  }

  // Enhanced biometric login method with better error handling
  Future<void> loginUser({bool useBiometrics = false}) async {
    if (useBiometrics) {
      log('Attempting biometric login...');

      bool authenticated = await authenticateWithBiometrics();
      if (!authenticated) {
        Get.snackbar(
          'Error',
          'Biometric authentication failed.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      isLoading.value = true;
      try {
        // Retrieve stored user data
        UserModel? storedUser = await _getStoredUserData();
        if (storedUser == null) {
          Get.snackbar(
            'Error',
            'No stored user data found. Please log in with email and password first.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          isLoading.value = false;
          return;
        }

        // Verify token is still valid with the server (optional but recommended)
        ApiService.setAuthToken(storedUser.token);

        // Optional: Make a quick API call to verify token validity
        // You can uncomment this if you have a token verification endpoint
        /*
        final response = await ApiService.verifyToken();
        if (!response.success) {
          // Token expired, clear stored data and ask for regular login
          await _clearStoredCredentials();
          Get.snackbar(
            'Error', 
            'Session expired. Please log in again.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          isLoading.value = false;
          return;
        }
        */

        user.value = storedUser;
        Get.put<UserModel>(user.value!, permanent: true);

        if (Get.isRegistered<LoginController>()) {
          Get.delete<LoginController>();
        }
        Get.put<LoginController>(this, permanent: true);

        Get.offAll(() => MainScreen());
        Get.snackbar(
          'Success',
          'Logged in with biometrics successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } catch (e) {
        log('Biometric login error: $e');
        Get.snackbar(
          'Error',
          'An unexpected error occurred: $e',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } finally {
        isLoading.value = false;
      }
      return;
    }

    // Regular email/password login
    FocusScope.of(Get.context!).unfocus();
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;
    try {
      final response = await ApiService.loginUser(
        emailController.text.trim(),
        passwordController.text,
      );

      if (response.success && response.data != null) {
        user.value = UserModel.fromJson(response.data!);

        if (user.value!.isSuspended) {
          Get.snackbar(
            'Account Suspended',
            'Your account has been suspended. Please contact support for assistance.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
          );
          user.value = null;
          return;
        }

        if (user.value!.token.isNotEmpty) {
          ApiService.setAuthToken(user.value!.token);
        }

        // Store credentials for biometric login if biometrics are available and enabled
        if (isBiometricEnabled.value && canUseBiometrics.value) {
          await storeUserCredentials();
          log('Credentials stored for future biometric login');
        }

        log('Name from login controller: ${user.value!.name}');
        log('Email from login controller: ${user.value!.email}');
        log('Token from login controller: ${user.value!.token}');

        Get.put<UserModel>(user.value!, permanent: true);

        if (Get.isRegistered<LoginController>()) {
          Get.delete<LoginController>();
        }
        Get.put<LoginController>(this, permanent: true);

        Get.snackbar(
          'Success',
          'Login successful',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        Get.offAll(() => MainScreen());
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
      log('Login error: $e');
      Get.snackbar(
        'Error at LoginController',
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

  // Clear stored credentials (call during logout)
  Future<void> _clearStoredCredentials() async {
    try {
      await secureStorage.delete(key: 'user_data');
      await secureStorage.delete(key: 'user_token');
      await secureStorage.delete(key: 'user_email');
      log('Stored credentials cleared');
    } catch (e) {
      log('Error clearing stored credentials: $e');
    }
  }

  // Disable biometrics (call from settings)
  Future<void> disableBiometrics() async {
    try {
      await secureStorage.delete(key: 'biometric_enabled');
      await _clearStoredCredentials();
      isBiometricEnabled.value = false;
      log('Biometrics disabled and credentials cleared');
    } catch (e) {
      log('Error disabling biometrics: $e');
    }
  }

  // Update resetState method to clear stored credentials
  void resetState() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    isLoading.value = false;
    isPasswordVisible.value = false;
    isImageUploading.value = false;
    isBiometricEnabled.value = false;
    user.value = null;
    selectedProfileImage.value = null;
    _clearStoredCredentials(); // Clear stored credentials
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
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }
    if (value.trim().length > 50) {
      return 'Name must not exceed 50 characters';
    }
    final nameRegExp = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegExp.hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  Future<void> updateProfile() async {
    FocusScope.of(Get.context!).unfocus();

    if (!profileFormKey.currentState!.validate()) {
      return;
    }

    if (user.value == null) {
      Get.snackbar(
        'Error',
        'User not found. Please login again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (user.value!.token.isEmpty) {
      Get.snackbar(
        'Error',
        'Authentication token not found. Please login again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 1000));
    try {
      log('Setting auth token before API call: ${user.value!.token}');
      ApiService.setAuthToken(user.value!.token);

      final response = await ApiService.updateUserProfile(
        nameController.text.trim(),
        imagePath: selectedProfileImage.value?.path,
      );

      if (response.success) {
        if (response.data != null) {
          if (response.data!.containsKey('user')) {
            user.value = UserModel.fromJson(response.data!['user']);
          } else {
            user.value = UserModel(
              id: user.value!.id,
              name: nameController.text.trim(),
              email: user.value!.email,
              role: user.value!.role,
              token: user.value!.token,
              image: user.value!.image,
              enrollments: [],
              notificationTokens: user.value!.notificationTokens,
              isSuspended: user.value!.isSuspended,
            );
          }

          // Update stored credentials if biometrics are enabled
          if (isBiometricEnabled.value && canUseBiometrics.value) {
            await storeUserCredentials();
          }

          Get.delete<UserModel>();
          Get.put<UserModel>(user.value!, permanent: true);

          Get.back();
        }

        nameController.clear();
        selectedProfileImage.value = null;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            'Success',
            'Profile updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(16),
          );
        });
        log('Profile updated successfully');
        log('Updated name: ${user.value!.name}');
      } else {
        Get.snackbar(
          'Error',
          response.message.isNotEmpty
              ? response.message
              : 'Failed to update profile',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      log('Update profile error: $e');
      Get.snackbar(
        'Error',
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
}
