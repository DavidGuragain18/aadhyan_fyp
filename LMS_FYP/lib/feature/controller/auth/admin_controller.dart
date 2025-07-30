import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/auth/user_model.dart';
import '../../services/api_services.dart';

/// Controller for managing users - fetching, filtering, suspending/unsuspending, etc.
class UserManagementController extends GetxController {
  // Observable variables for loading states
  final RxBool isLoading = false.obs;
  final RxBool isSuspendingUser = false.obs;

  // List of all users from the API
  final RxList<UserModel> allUsers = <UserModel>[].obs;

  // Filtered list of users based on search/role
  final RxList<UserModel> filteredUsers = <UserModel>[].obs;

  // Current search query and selected role filter
  final RxString searchQuery = ''.obs;
  final RxString selectedRole = 'all'.obs; // Options: all, student, teacher, admin

  @override
  void onInit() {
    super.onInit();
    getAllUsers();

    // Automatically re-filter when search query or role changes
    ever(searchQuery, (_) => filterUsers());
    ever(selectedRole, (_) => filterUsers());
  }

  /// Sets the search query and triggers filtering
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Sets the selected role filter and triggers filtering
  void setSelectedRole(String role) {
    selectedRole.value = role;
  }

  /// Filters users based on current search query and role
  void filterUsers() {
    List<UserModel> filtered = allUsers.toList();

    // Filter by selected role if not 'all'
    if (selectedRole.value != 'all') {
      filtered = filtered
          .where((user) => user.role == selectedRole.value)
          .toList();
    }

    // Filter by name or email based on search query
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((user) {
        return user.name.toLowerCase().contains(
              searchQuery.value.toLowerCase(),
            ) ||
            user.email.toLowerCase().contains(searchQuery.value.toLowerCase());
      }).toList();
    }

    // Assign the filtered list
    filteredUsers.assignAll(filtered);
  }

  /// Fetches all users from the API and updates the local lists
  Future<void> getAllUsers() async {
    isLoading.value = true;
    try {
      log('Debug - Fetching all users');
      final response = await ApiService.getAllUsers();

      if (response.success && response.data != null) {
        log('Debug - API response successful');
        final List<UserModel> users = response.data!;

        allUsers.clear();
        allUsers.addAll(users);

        // Update filtered list based on current filters
        filterUsers();

        log('Successfully loaded ${users.length} users');

        // Show success or info message
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
      // Handle unexpected errors
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

  /// Suspend or unsuspend a user by their ID
  Future<void> suspendUnsuspendUser(String userId, bool shouldSuspend) async {
    if (isSuspendingUser.value) {
      log('Debug - Already processing a suspend/unsuspend operation, ignoring');
      return;
    }

    isSuspendingUser.value = true;
    try {
      log('Debug - ${shouldSuspend ? 'Suspending' : 'Unsuspending'} user: $userId');

      final response = await ApiService.suspendUnsuspendUser(
        userId,
        shouldSuspend,
      );

      if (response.success) {
        // Update the user locally
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
          filterUsers(); // Re-apply filters to refresh UI

          log('Debug - Local user status updated successfully');
        } else {
          log('Warning - User not found in local list for ID: $userId');
        }

        // Show success message
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
      // Handle exceptions
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

  /// Triggers manual refresh of user list if not already loading
  void refreshUsers() {
    if (!isLoading.value) {
      getAllUsers();
    } else {
      log('Debug - Already loading users, ignoring refresh request');
    }
  }

  // ---------- UI Helper Methods ----------

  /// Total number of users
  int get totalUsers => allUsers.length;

  /// Count of suspended users
  int get suspendedUsers => allUsers.where((user) => user.isSuspended).length;

  /// Count of active (non-suspended) users
  int get activeUsers => allUsers.where((user) => !user.isSuspended).length;

  /// Count of users with role 'student'
  int get studentCount =>
      allUsers.where((user) => user.role.toLowerCase() == 'student').length;

  /// Count of users with role 'teacher'
  int get teacherCount =>
      allUsers.where((user) => user.role.toLowerCase() == 'teacher').length;

  /// Count of users with role 'admin'
  int get adminCount =>
      allUsers.where((user) => user.role.toLowerCase() == 'admin').length;

  @override
  void onClose() {
    // Cleanup if necessary
    super.onClose();
  }
}
