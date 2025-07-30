// Option 1: Create a separate utility class
// File: lib/utils/image_picker_utils.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImagePickerUtils {
  static final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery with customizable options
  static Future<File?> pickImageFromGallery({
    double? maxWidth = 1024,
    double? maxHeight = 1024,
    int? imageQuality,
    Function()? onStart,
    Function()? onEnd,
    Function(String error)? onError,
  }) async {
    try {
      // Call onStart callback if provided
      onStart?.call();

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (image != null) {
        // Simulate upload delay (remove if not needed)
        await Future.delayed(const Duration(seconds: 1));
        return File(image.path);
      }
      return null;
    } catch (e) {
      final errorMessage = 'Failed to pick image: ${e.toString()}';
      
      // Call custom error handler or show default snackbar
      if (onError != null) {
        onError(errorMessage);
      } else {
        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      return null;
    } finally {
      // Call onEnd callback if provided
      onEnd?.call();
    }
  }

  /// Pick image from camera
  static Future<File?> pickImageFromCamera({
    double? maxWidth = 1024,
    double? maxHeight = 1024,
    int? imageQuality,
    Function()? onStart,
    Function()? onEnd,
    Function(String error)? onError,
  }) async {
    try {
      onStart?.call();

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (image != null) {
        await Future.delayed(const Duration(seconds: 1));
        return File(image.path);
      }
      return null;
    } catch (e) {
      final errorMessage = 'Failed to take photo: ${e.toString()}';
      
      if (onError != null) {
        onError(errorMessage);
      } else {
        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      return null;
    } finally {
      onEnd?.call();
    }
  }

  /// Show bottom sheet to choose between gallery and camera
  static Future<File?> showImageSourceBottomSheet(BuildContext context, {
    double? maxWidth = 1024,
    double? maxHeight = 1024,
    int? imageQuality,
    Function()? onStart,
    Function()? onEnd,
    Function(String error)? onError,
  }) async {
    return await showModalBottomSheet<File?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Image Source',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.blue),
                  title: const Text('Gallery'),
                  onTap: () async {
                    final file = await pickImageFromGallery(
                      maxWidth: maxWidth,
                      maxHeight: maxHeight,
                      imageQuality: imageQuality,
                      onStart: onStart,
                      onEnd: onEnd,
                      onError: onError,
                    );
                    Navigator.pop(context, file);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.green),
                  title: const Text('Camera'),
                  onTap: () async {
                    final file = await pickImageFromCamera(
                      maxWidth: maxWidth,
                      maxHeight: maxHeight,
                      imageQuality: imageQuality,
                      onStart: onStart,
                      onEnd: onEnd,
                      onError: onError,
                    );
                    Navigator.pop(context, file);
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Option 2: Create a mixin for reusable functionality
// File: lib/mixins/image_picker_mixin.dart

mixin ImagePickerMixin {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage({
    ImageSource source = ImageSource.gallery,
    double? maxWidth = 1024,
    double? maxHeight = 1024,
    int? imageQuality,
    Function()? onStart,
    Function()? onEnd,
    Function(String error)? onError,
  }) async {
    try {
      onStart?.call();

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (image != null) {
        await Future.delayed(const Duration(seconds: 1));
        return File(image.path);
      }
      return null;
    } catch (e) {
      final errorMessage = 'Failed to pick image: ${e.toString()}';
      
      if (onError != null) {
        onError(errorMessage);
      } else {
        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      return null;
    } finally {
      onEnd?.call();
    }
  }
}

// Option 3: Create a service class with GetX
// File: lib/services/image_picker_service.dart

class ImagePickerService extends GetxService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage({
    ImageSource source = ImageSource.gallery,
    double? maxWidth = 1024,
    double? maxHeight = 1024,
    int? imageQuality,
    Function()? onStart,
    Function()? onEnd,
    Function(String error)? onError,
  }) async {
    try {
      onStart?.call();

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (image != null) {
        await Future.delayed(const Duration(seconds: 1));
        return File(image.path);
      }
      return null;
    } catch (e) {
      final errorMessage = 'Failed to pick image: ${e.toString()}';
      
      if (onError != null) {
        onError(errorMessage);
      } else {
        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      return null;
    } finally {
      onEnd?.call();
    }
  }

  static ImagePickerService get to => Get.find<ImagePickerService>();
}