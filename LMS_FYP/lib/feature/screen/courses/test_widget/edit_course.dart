import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utility/image_picker_utils.dart';
import '../../../controller/course/course_controller.dart';
import '../../../model/course/course_model.dart';

class EditCourseScreen extends StatefulWidget {
  final CourseModel course;

  const EditCourseScreen({Key? key, required this.course}) : super(key: key);

  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  late final CourseController courseController;
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  final GlobalKey<FormState> editFormKey = GlobalKey<FormState>();
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxBool isImageUploading = false.obs;

  @override
  void initState() {
    super.initState();

    // Initialize controller
    try {
      courseController = Get.find<CourseController>();
    } catch (e) {
      courseController = Get.put(CourseController());
    }

    // Initialize controllers with existing course data
    titleController = TextEditingController(text: widget.course.title);
    descriptionController = TextEditingController(
      text: widget.course.description,
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Course Title cannot be empty';
    }
    return null;
  }

  String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Course description cannot be empty';
    }
    return null;
  }

  Future<void> _pickImage() async {
    final File? selectedFile = await ImagePickerUtils.pickImageFromGallery(
      maxWidth: 1024,
      maxHeight: 1024,
      onStart: () => isImageUploading.value = true,
      onEnd: () => isImageUploading.value = false,
      onError: (error) {
        log('Image picker error: $error');
        Get.snackbar(
          'Error',
          'Failed to pick image: $error',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      },
    );

    if (selectedFile != null) {
      selectedImage.value = selectedFile;
    }
  }

  Future<void> _handleUpdateCourse() async {
    // Dismiss keyboard first
    FocusScope.of(context).unfocus();

    if (!editFormKey.currentState!.validate()) {
      return;
    }

    // Add a small delay to ensure keyboard is dismissed
    await Future.delayed(const Duration(milliseconds: 100));

    final isUpdated = await courseController.updateCourse(
      widget.course.id,
      titleController.text.trim(),
      descriptionController.text.trim(),
      imagePath: selectedImage.value?.path,
    );

    if (isUpdated) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Course'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FAFF), Color(0xFFFFFFFF), Color(0xFFF3E8FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: editFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title field
                        const Text(
                          'Course Title *',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => TextFormField(
                            controller: titleController,
                            validator: validateTitle,
                            enabled: !courseController.isUpdating,
                            decoration: InputDecoration(
                              hintText: 'Enter course title',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF6366F1),
                                  width: 2,
                                ),
                              ),
                              filled: courseController.isUpdating,
                              fillColor: courseController.isUpdating
                                  ? Colors.grey.shade100
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Description field
                        const Text(
                          'Description *',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => TextFormField(
                            controller: descriptionController,
                            maxLines: 4,
                            validator: validateDescription,
                            enabled: !courseController.isUpdating,
                            decoration: InputDecoration(
                              hintText: 'Enter course description',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF6366F1),
                                  width: 2,
                                ),
                              ),
                              filled: courseController.isUpdating,
                              fillColor: courseController.isUpdating
                                  ? Colors.grey.shade100
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Image upload section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Center(
                              child: Text(
                                'Course Image',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Image Preview Section
                            Obx(() {
                              // Show selected image if user picked a new one
                              if (selectedImage.value != null) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 200,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.file(
                                            selectedImage.value!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'New Selected Image',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              // Show existing image if no new image is selected
                              else if (widget.course.coverImage != null &&
                                  widget.course.coverImage!.isNotEmpty) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 200,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            widget.course.coverImage!,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Container(
                                                    color: Colors.grey.shade200,
                                                    child: const Icon(
                                                      Icons.image_not_supported,
                                                      size: 40,
                                                      color: Colors.grey,
                                                    ),
                                                  );
                                                },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Current Image',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              // Show placeholder if no image
                              else {
                                return Container(
                                  width: 200,
                                  height: 120,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'No Image',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }),

                            // Image Upload/Change Button
                            SizedBox(
                              height: 60,
                              width: 250,
                              child: Obx(
                                () => ElevatedButton.icon(
                                  onPressed:
                                      isImageUploading.value ||
                                          courseController.isUpdating
                                      ? null
                                      : _pickImage,
                                  icon: isImageUploading.value
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : const Icon(Icons.cloud_upload),
                                  label: Text(
                                    isImageUploading.value
                                        ? 'Uploading...'
                                        : (widget.course.coverImage != null &&
                                                  widget
                                                      .course
                                                      .coverImage!
                                                      .isNotEmpty) ||
                                              selectedImage.value != null
                                        ? 'Change Image'
                                        : 'Upload Image',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Add some bottom padding for the submit button area
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),

              // Submit button - fixed at bottom
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed:
                          courseController.isUpdating || isImageUploading.value
                          ? null
                          : _handleUpdateCourse,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shadowColor: const Color(0xFF6366F1).withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: courseController.isUpdating
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Updating Course...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : const Text(
                              'Update Course',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
