//   import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../model/auth/user_model.dart';
// import '../auth/login_screen.dart';

// void _showLogoutDialog() {
//     Get.dialog(
//       AlertDialog(
//         title: Text('Logout'),
//         content: Text('Are you sure you want to logout?'),
//         actions: [
//           TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
//           TextButton(
//             onPressed: () {
//               Get.back();
//               // Clear user data and reset controller state
//               loginController.resetState();
//               Get.delete<UserModel>();
//               // Navigate to login screen
//               Get.offAll(() => LoginScreen()); // Replace with your login screen
//             },
//             child: Text('Logout', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }

