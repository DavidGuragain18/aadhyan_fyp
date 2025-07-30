import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/auth/user_model.dart';
import '../../services/api_services.dart';

class UserManagementController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isSuspendingUser = false.obs;
  final RxList<UserModel> allUsers = <UserModel>[].obs;
  final RxList<UserModel> filteredUsers = <UserModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedRole = 'all'.obs; // all, student, teacher, admin

  @override
  void onInit() {
    super.onInit();
    getAllUsers();
    // Listen to search query changes
    ever(searchQuery, (_) => filterUsers());
    ever(selectedRole, (_) => filterUsers());
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void setSelectedRole(String role) {
    selectedRole.value = role;
  }

  void filterUsers() {
    List<UserModel> filtered = allUsers.toList();

    // Filter by role
    if (selectedRole.value != 'all') {
      filtered = filtered
          .where((user) => user.role == selectedRole.value)
          .toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((user) {
        return user.name.toLowerCase().contains(
              searchQuery.value.toLowerCase(),
            ) ||
            user.email.toLowerCase().contains(searchQuery.value.toLowerCase());
      }).toList();
    }

    filteredUsers.assignAll(filtered);
  }

  Future<void> getAllUsers() async {
    isLoading.value = true;
    try {
      log('Debug - Fetching all users');
      final response = await ApiService.getAllUsers();

      if (response.success && response.data != null) {
        log('Debug - API response successful');

        // Now response.data is already List<UserModel>
        final List<UserModel> users = response.data!;

        allUsers.clear();
        allUsers.addAll(users);

        // Initialize filtered users
        filterUsers();

        log('Successfully loaded ${users.length} users');

        if (users.isNotEmpty) {
          Get.snackbar(
            'Success',
            'Loaded ${users.length} users successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        } else {
          Get.snackbar(
            'Info',
            'No users found',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.blue,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        }
      } else {
        log(
          'API response failed. Success: ${response.success}, Message: ${response.message}',
        );

        Get.snackbar(
          'Error',
          response.message.isNotEmpty
              ? response.message
              : 'Failed to fetch users',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e, stackTrace) {
      log('Get all users error: $e');
      log('Stack trace: $stackTrace');

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

  Future<void> suspendUnsuspendUser(String userId, bool shouldSuspend) async {
    if (isSuspendingUser.value) {
      log('Debug - Already processing a suspend/unsuspend operation, ignoring');
      return;
    }

    isSuspendingUser.value = true;
    try {
      log(
        'Debug - ${shouldSuspend ? 'Suspending' : 'Unsuspending'} user: $userId',
      );

      final response = await ApiService.suspendUnsuspendUser(
        userId,
        shouldSuspend,
      );

      if (response.success) {
        // Update the user in local list
        final userIndex = allUsers.indexWhere((user) => user.id == userId);
        if (userIndex != -1) {
          final oldUser = allUsers[userIndex];
          final updatedUser = UserModel(
            id: oldUser.id,
            email: oldUser.email,
            name: oldUser.name,
            image: oldUser.image,
            role: oldUser.role,
            token: oldUser.token,
            enrollments: oldUser.enrollments,
            notificationTokens: oldUser.notificationTokens,
            isSuspended: shouldSuspend,
            createdAt: oldUser.createdAt,
            updatedAt: oldUser.updatedAt,
            version: oldUser.version,
          );

          allUsers[userIndex] = updatedUser;
          filterUsers(); // Refresh filtered list

          log('Debug - Local user status updated successfully');
        } else {
          log('Warning - User not found in local list for ID: $userId');
        }

        Get.snackbar(
          'Success',
          shouldSuspend
              ? 'User suspended successfully'
              : 'User unsuspended successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        log('User ${shouldSuspend ? 'suspended' : 'unsuspended'} successfully');
      } else {
        log('Suspend/Unsuspend API failed. Message: ${response.message}');

        Get.snackbar(
          'Error',
          response.message.isNotEmpty
              ? response.message
              : 'Failed to update user status',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e, stackTrace) {
      log('Suspend/Unsuspend user error: $e');
      log('Stack trace: $stackTrace');

      Get.snackbar(
        'Error',
        'An unexpected error occurred: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isSuspendingUser.value = false;
    }
  }

  void refreshUsers() {
    if (!isLoading.value) {
      getAllUsers();
    } else {
      log('Debug - Already loading users, ignoring refresh request');
    }
  }

  // Helper methods for UI - Added safety checks
  int get totalUsers => allUsers.length;
  int get suspendedUsers => allUsers.where((user) => user.isSuspended).length;
  int get activeUsers => allUsers.where((user) => !user.isSuspended).length;
  int get studentCount =>
      allUsers.where((user) => user.role.toLowerCase() == 'student').length;
  int get teacherCount =>
      allUsers.where((user) => user.role.toLowerCase() == 'teacher').length;
  int get adminCount =>
      allUsers.where((user) => user.role.toLowerCase() == 'admin').length;

  @override
  void onClose() {
    // Clean up if needed
    super.onClose();
  }
}
