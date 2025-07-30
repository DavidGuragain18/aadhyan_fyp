import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utility/image_picker_utils.dart';
import '../../controller/course/course_controller.dart';
import '../../model/course/course_model.dart';

class AddEditCourseScreen extends StatefulWidget {
  final CourseModel? course; // Made nullable to support add mode
  final bool isEditMode; // Flag to determine if we're editing or adding

  const AddEditCourseScreen({
    Key? key,
    this.course, // Optional now
    this.isEditMode = true, // Default to edit mode for backward compatibility
  }) : super(key: key);

  @override
  State<AddEditCourseScreen> createState() => _AddEditCourseScreenState();
}

class _AddEditCourseScreenState extends State<AddEditCourseScreen> {
  late final CourseController courseController;
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final GlobalKey<FormState> formKey;
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

    // Initialize form key based on mode
    if (widget.isEditMode) {
      formKey = GlobalKey<FormState>();
    } else {
      // Use the controller's form key for add mode consistency
      formKey = courseController.createCourseFormKey;
    }

    // Initialize controllers with existing course data or empty for add mode
    if (widget.isEditMode && widget.course != null) {
      titleController = TextEditingController(text: widget.course!.title);
      descriptionController = TextEditingController(
        text: widget.course!.description,
      );
    } else {
      // For add mode, use controller's text controllers if available
      titleController = courseController.titleController;
      descriptionController = courseController.descriptionController;
    }
  }

  @override
  void dispose() {
    // Only dispose controllers if in edit mode (add mode uses controller's controllers)
    if (widget.isEditMode) {
      titleController.dispose();
      descriptionController.dispose();
    }
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
      onStart: () {
        if (widget.isEditMode) {
          isImageUploading.value = true;
        } else {
          courseController.setImageUploading(true);
        }
      },
      onEnd: () {
        if (widget.isEditMode) {
          isImageUploading.value = false;
        } else {
          courseController.setImageUploading(false);
        }
      },
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
      if (widget.isEditMode) {
        selectedImage.value = selectedFile;
      } else {
        courseController.setSelectedImage(selectedFile);
      }
    }
  }

  Future<void> _handleSubmit() async {
    // Dismiss keyboard first
    FocusScope.of(context).unfocus();

    if (!formKey.currentState!.validate()) {
      return;
    }

    // Add a small delay to ensure keyboard is dismissed
    await Future.delayed(const Duration(milliseconds: 100));

    bool isSuccess = false;

    if (widget.isEditMode) {
      // Update course
      isSuccess = await courseController.updateCourse(
        widget.course!.id,
        titleController.text.trim(),
        descriptionController.text.trim(),
        imagePath: selectedImage.value?.path,
      );
    } else {
      // Create course
      isSuccess = await courseController.createCourse();
      log('Course creation result: $isSuccess');
    }

    if (isSuccess) {
      Navigator.pop(context);
    } else if (!widget.isEditMode) {
      // Show error message for add mode
      Get.snackbar(
        'Error',
        'Failed to create course',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    }
  }

  // Get the appropriate reactive boolean for image uploading
  RxBool get imageUploadingState {
    return widget.isEditMode
        ? isImageUploading
        : courseController.isImageUploading;
  }

  // Get the appropriate reactive boolean for operation in progress
  bool get isOperationInProgress {
    return widget.isEditMode
        ? courseController.isUpdating
        : courseController.isCreating;
  }

  // Get the appropriate selected image
  Rx<File?> get currentSelectedImage {
    return widget.isEditMode ? selectedImage : courseController.selectedImage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode ? 'Edit Course' : 'Add New Course'),
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
                    key: formKey,
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
                            validator: widget.isEditMode
                                ? validateTitle
                                : courseController.validateTitle,
                            enabled: !isOperationInProgress,
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
                              filled: isOperationInProgress,
                              fillColor: isOperationInProgress
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
                            validator: widget.isEditMode
                                ? validateDescription
                                : courseController.validateDescription,
                            enabled: !isOperationInProgress,
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
                              filled: isOperationInProgress,
                              fillColor: isOperationInProgress
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
                              if (currentSelectedImage.value != null) {
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
                                            currentSelectedImage.value!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        widget.isEditMode
                                            ? 'New Selected Image'
                                            : 'Selected Image',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              // Show existing image if no new image is selected (edit mode only)
                              else if (widget.isEditMode &&
                                  widget.course != null &&
                                  widget.course!.coverImage != null &&
                                  widget.course!.coverImage!.isNotEmpty) {
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
                                            widget.course!.coverImage!,
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
                                      imageUploadingState.value ||
                                          isOperationInProgress
                                      ? null
                                      : _pickImage,
                                  icon: imageUploadingState.value
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
                                    imageUploadingState.value
                                        ? 'Uploading...'
                                        : _getImageButtonText(),
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
                          isOperationInProgress || imageUploadingState.value
                          ? null
                          : _handleSubmit,
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
                      child: isOperationInProgress
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  widget.isEditMode
                                      ? 'Updating Course...'
                                      : 'Creating Course...',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              widget.isEditMode
                                  ? 'Update Course'
                                  : 'Create Course',
                              style: const TextStyle(
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

  String _getImageButtonText() {
    if (widget.isEditMode) {
      // Edit mode logic
      bool hasExistingImage =
          widget.course?.coverImage != null &&
          widget.course!.coverImage!.isNotEmpty;
      bool hasNewImage = currentSelectedImage.value != null;

      if (hasExistingImage || hasNewImage) {
        return 'Change Image';
      } else {
        return 'Upload Image';
      }
    } else {
      // Add mode logic
      return currentSelectedImage.value != null
          ? 'Change Image'
          : 'Upload Image';
    }
  }
}
