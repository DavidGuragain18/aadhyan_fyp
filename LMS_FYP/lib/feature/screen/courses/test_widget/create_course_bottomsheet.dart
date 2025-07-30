// import 'dart:developer';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../../core/theme/app_colors.dart';
// import '../../../../core/utility/image_picker_utils.dart';
// import '../../../controller/course/course_controller.dart';

// class AddCourseBottomSheet extends StatefulWidget {
//   final CourseController courseController;

//   const AddCourseBottomSheet({Key? key, required this.courseController})
//     : super(key: key);

//   @override
//   State<AddCourseBottomSheet> createState() => _AddCourseBottomSheetState();

//   static Future<dynamic> show(
//     BuildContext context,
//     CourseController courseController,
//   ) {
//     return showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       isDismissible: false, // Prevent accidental dismissal during creation
//       enableDrag: false, // Disable drag to dismiss during creation
//       builder: (BuildContext context) {
//         return AddCourseBottomSheet(courseController: courseController);
//       },
//     );
//   }
// }

// class _AddCourseBottomSheetState extends State<AddCourseBottomSheet> {
//   late final CourseController courseController;

//   @override
//   void initState() {
//     super.initState();
//     courseController = widget.courseController;
//   }

//   Future<void> _pickImage() async {
//     final File? selectedFile = await ImagePickerUtils.pickImageFromGallery(
//       maxWidth: 1024,
//       maxHeight: 1024,
//       onStart: () => courseController.setImageUploading(true),
//       onEnd: () => courseController.setImageUploading(false),
//       onError: (error) {
//         log('Image picker error: $error');
//         Get.snackbar(
//           'Error',
//           'Failed to pick image: $error',
//           snackPosition: SnackPosition.TOP,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//       },
//     );

//     if (selectedFile != null) {
//       courseController.setSelectedImage(selectedFile);
//     }
//   }

//   Future<void> _handleCreateCourse() async {
//     // Dismiss keyboard first
//     FocusScope.of(context).unfocus();

//     // Add a small delay to ensure keyboard is dismissed
//     await Future.delayed(const Duration(milliseconds: 100));

//     final isCourseAdded = await courseController.createCourse();
//     log('Course creation result: $isCourseAdded');

//     if (isCourseAdded) {
//       Navigator.pop(context);
//     } else {
//       // Show error message
//       Get.snackbar(
//         'Error',
//         'Failed to create course',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         margin: const EdgeInsets.all(16),
//         borderRadius: 8,
//       );
//     }
//   }

//   void _handleClose() {
//     // Check if any operation is in progress
//     if (courseController.isCreating ||
//         courseController.isImageUploading.value) {
//       Get.snackbar(
//         'Please Wait',
//         'Please wait for the current operation to complete',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.orange,
//         colorText: Colors.white,
//         margin: const EdgeInsets.all(16),
//         borderRadius: 8,
//       );
//       return;
//     }

//     // Clear form data before closing
//     courseController.setSelectedImage(null);
//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false, // Prevent back button during creation
//       child: GestureDetector(
//         onTap: () => FocusScope.of(context).unfocus(),
//         child: DraggableScrollableSheet(
//           initialChildSize: 0.9,
//           minChildSize: 0.5,
//           maxChildSize: 0.95,
//           expand: false,
//           builder: (context, scrollController) {
//             return Container(
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(20),
//                   topRight: Radius.circular(20),
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   // Handle bar
//                   Container(
//                     margin: const EdgeInsets.symmetric(vertical: 12),
//                     height: 4,
//                     width: 40,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       borderRadius: BorderRadius.circular(2),
//                     ),
//                   ),
//                   // Header
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Row(
//                       children: [
//                         const Text(
//                           'Add New Course',
//                           style: TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF111827),
//                           ),
//                         ),
//                         const Spacer(),
//                         Obx(
//                           () => IconButton(
//                             onPressed:
//                                 courseController.isCreating ||
//                                     courseController.isImageUploading.value
//                                 ? null
//                                 : _handleClose,
//                             icon: const Icon(Icons.close),
//                             color:
//                                 courseController.isCreating ||
//                                     courseController.isImageUploading.value
//                                 ? Colors.grey
//                                 : Colors.black,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Divider(),
//                   // Scrollable content
//                   Expanded(
//                     child: SingleChildScrollView(
//                       controller: scrollController,
//                       padding: const EdgeInsets.all(20),
//                       child: Form(
//                         key: courseController.createCourseFormKey,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Title field
//                             const Text(
//                               'Course Title *',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: Color(0xFF111827),
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             TextFormField(
//                               controller: courseController.titleController,
//                               validator: courseController.validateTitle,
//                               enabled: !courseController.isCreating,
//                               decoration: InputDecoration(
//                                 hintText: 'Enter course title',
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                   borderSide: const BorderSide(
//                                     color: Color(0xFF6366F1),
//                                     width: 2,
//                                   ),
//                                 ),
//                                 filled: courseController.isCreating,
//                                 fillColor: courseController.isCreating
//                                     ? Colors.grey.shade100
//                                     : null,
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                             // Description field
//                             const Text(
//                               'Description *',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: Color(0xFF111827),
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             TextFormField(
//                               controller:
//                                   courseController.descriptionController,
//                               maxLines: 4,
//                               validator: courseController.validateDescription,
//                               enabled: !courseController.isCreating,
//                               decoration: InputDecoration(
//                                 hintText: 'Enter course description',
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                   borderSide: const BorderSide(
//                                     color: Color(0xFF6366F1),
//                                     width: 2,
//                                   ),
//                                 ),
//                                 filled: courseController.isCreating,
//                                 fillColor: courseController.isCreating
//                                     ? Colors.grey.shade100
//                                     : null,
//                               ),
//                             ),
//                             const SizedBox(height: 20),

//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 // Image upload section
//                                 const Center(
//                                   child: Text(
//                                     'Course Image',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600,
//                                       color: Color(0xFF111827),
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 // Image Preview and Upload Section
//                                 Obx(
//                                   () => Column(
//                                     children: [
//                                       if (courseController
//                                               .selectedImage
//                                               .value !=
//                                           null)
//                                         Container(
//                                           margin: const EdgeInsets.only(
//                                             bottom: 16,
//                                           ),
//                                           child: Column(
//                                             children: [
//                                               Container(
//                                                 width: 200,
//                                                 height: 120,
//                                                 decoration: BoxDecoration(
//                                                   borderRadius:
//                                                       BorderRadius.circular(8),
//                                                   border: Border.all(
//                                                     color: Colors.grey.shade300,
//                                                   ),
//                                                 ),
//                                                 child: ClipRRect(
//                                                   borderRadius:
//                                                       BorderRadius.circular(8),
//                                                   child: Image.file(
//                                                     courseController
//                                                         .selectedImage
//                                                         .value!,
//                                                     fit: BoxFit.cover,
//                                                   ),
//                                                 ),
//                                               ),
//                                               const SizedBox(height: 8),
//                                               Text(
//                                                 'Selected Image',
//                                                 style: TextStyle(
//                                                   fontSize: 12,
//                                                   color: Colors.grey.shade600,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),

//                                       // Image Upload Button
//                                       SizedBox(
//                                         height: 60,
//                                         width: 250,
//                                         child: ElevatedButton.icon(
//                                           onPressed:
//                                               courseController
//                                                       .isImageUploading
//                                                       .value ||
//                                                   courseController.isCreating
//                                               ? null
//                                               : _pickImage,
//                                           icon:
//                                               courseController
//                                                   .isImageUploading
//                                                   .value
//                                               ? const SizedBox(
//                                                   width: 20,
//                                                   height: 20,
//                                                   child: CircularProgressIndicator(
//                                                     strokeWidth: 2,
//                                                     valueColor:
//                                                         AlwaysStoppedAnimation<
//                                                           Color
//                                                         >(Colors.white),
//                                                   ),
//                                                 )
//                                               : const Icon(Icons.cloud_upload),
//                                           label: Text(
//                                             courseController
//                                                     .isImageUploading
//                                                     .value
//                                                 ? 'Uploading...'
//                                                 : courseController
//                                                           .selectedImage
//                                                           .value !=
//                                                       null
//                                                 ? 'Change Image'
//                                                 : 'Upload Image',
//                                           ),
//                                           style: ElevatedButton.styleFrom(
//                                             padding: const EdgeInsets.symmetric(
//                                               vertical: 12,
//                                             ),
//                                             backgroundColor: primaryColor,
//                                             foregroundColor: Colors.white,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             // Add some bottom padding for the submit button area
//                             const SizedBox(height: 100),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   // Submit button - fixed at bottom
//                   Container(
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.1),
//                           blurRadius: 4,
//                           offset: const Offset(0, -2),
//                         ),
//                       ],
//                     ),
//                     child: SizedBox(
//                       width: double.infinity,
//                       child: Obx(
//                         () => ElevatedButton(
//                           onPressed:
//                               courseController.isCreating ||
//                                   courseController.isImageUploading.value
//                               ? null
//                               : _handleCreateCourse,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: primaryColor,
//                             foregroundColor: Colors.white,
//                             elevation: 3,
//                             shadowColor: const Color(
//                               0xFF6366F1,
//                             ).withOpacity(0.4),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                           ),
//                           child: courseController.isCreating
//                               ? const Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     SizedBox(
//                                       width: 20,
//                                       height: 20,
//                                       child: CircularProgressIndicator(
//                                         strokeWidth: 2,
//                                         valueColor:
//                                             AlwaysStoppedAnimation<Color>(
//                                               Colors.white,
//                                             ),
//                                       ),
//                                     ),
//                                     SizedBox(width: 12),
//                                     Text(
//                                       'Creating Course...',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ],
//                                 )
//                               : const Text(
//                                   'Create Course',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
