import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/course/enrollment_controller.dart';

class EnrollmentScreen extends StatelessWidget {
  final EnrollmentController controller = Get.put(EnrollmentController());

  EnrollmentScreen({super.key}) {
    // controller.fetchEnrollments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Enrollments')),
      body: Center(),
    );
  }
}
