// // test_question_screen.dart

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../controller/course/test_question_controller.dart';
// import '../../../model/course/test_question_model.dart';

// class TestQuestionScreen extends StatelessWidget {
//   final TestQuestionController controller = Get.put(TestQuestionController());

//   TestQuestionScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       body: CustomScrollView(
//         slivers: [
  
//           SliverPadding(
//             padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
//             sliver: _buildQuestionsList(),
//           ),
//         ],
//       ),
//       floatingActionButton: _buildFloatingActionButton(),
//     );
//   }


//   Widget _buildFloatingActionButton() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
//         ),
//         borderRadius: BorderRadius.circular(28),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF667EEA).withOpacity(0.4),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: FloatingActionButton.extended(
//         onPressed: () => _showCreateQuestionDialog(Get.context!),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         icon: const Icon(Icons.add_rounded, color: Colors.white),
//         label: const Text(
//           'New Question',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }

//   void _showCreateQuestionDialog(BuildContext context) {
//     controller.clearForm();
//     _showQuestionDialog(context, 'Create New Question', isEdit: false);
//   }

//   void _showEditQuestionDialog(
//     BuildContext context,
//     TestQuestionModel question,
//   ) {
//     controller.populateFormWithQuestion(question);
//     _showQuestionDialog(
//       context,
//       'Edit Question',
//       isEdit: true,
//       question: question,
//     );
//   }

//   void _showQuestionDialog(
//     BuildContext context,
//     String title, {
//     required bool isEdit,
//     TestQuestionModel? question,
//   }) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: Container(
//           width: MediaQuery.of(context).size.width * 0.9,
//           height: MediaQuery.of(context).size.height * 0.85,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(24),
//           ),
//           child: Column(
//             children: [
//               // Header
//               Container(
//                 padding: const EdgeInsets.all(24),
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
//                   ),
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(24),
//                     topRight: Radius.circular(24),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Icon(
//                         isEdit ? Icons.edit_rounded : Icons.add_rounded,
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         title,
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: () => Get.back(),
//                       icon: const Icon(Icons.close_rounded, color: Colors.white),
//                     ),
//                   ],
//                 ),
//               ),
              
//               // Content
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.all(24),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Question Input
//                       const Text(
//                         'Question',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF1E293B),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Container(
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFF8FAFC),
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: const Color(0xFFE2E8F0)),
//                         ),
//                         child: TextField(
//                           controller: controller.questionController,
//                           maxLines: 3,
//                           decoration: const InputDecoration(
//                             hintText: 'Enter your question here...',
//                             border: InputBorder.none,
//                             contentPadding: EdgeInsets.all(16),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
                      
//                       // Lesson ID Input
//                       const Text(
//                         'Lesson ID',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF1E293B),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Container(
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFF8FAFC),
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: const Color(0xFFE2E8F0)),
//                         ),
//                         child: TextField(
//                           controller: controller.lessonIdController,
//                           decoration: const InputDecoration(
//                             hintText: 'Enter lesson ID...',
//                             border: InputBorder.none,
//                             contentPadding: EdgeInsets.all(16),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 24),
                      
//                       // Options Section
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             'Answer Options',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: Color(0xFF1E293B),
//                             ),
//                           ),
//                           Container(
//                             decoration: BoxDecoration(
//                               color: const Color(0xFF667EEA).withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: IconButton(
//                               onPressed: controller.addOption,
//                               icon: const Icon(Icons.add_rounded, color: Color(0xFF667EEA)),
//                               tooltip: 'Add Option',
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
                      
//                       // Options List
//                       Obx(
//                         () => Column(
//                           children: controller.optionControllers
//                               .asMap()
//                               .entries
//                               .map((entry) {
//                                 final index = entry.key;
//                                 final optionController = entry.value;

//                                 return Container(
//                                   margin: const EdgeInsets.only(bottom: 12),
//                                   padding: const EdgeInsets.all(16),
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFFF8FAFC),
//                                     borderRadius: BorderRadius.circular(12),
//                                     border: Border.all(
//                                       color: controller.selectedCorrectAnswer.value == index
//                                           ? const Color(0xFF10B981)
//                                           : const Color(0xFFE2E8F0),
//                                       width: controller.selectedCorrectAnswer.value == index ? 2 : 1,
//                                     ),
//                                   ),
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Row(
//                                         children: [
//                                           Container(
//                                             width: 24,
//                                             height: 24,
//                                             decoration: BoxDecoration(
//                                               color: controller.selectedCorrectAnswer.value == index
//                                                   ? const Color(0xFF10B981)
//                                                   : const Color(0xFF94A3B8),
//                                               borderRadius: BorderRadius.circular(12),
//                                             ),
//                                             child: Center(
//                                               child: Text(
//                                                 String.fromCharCode(65 + index),
//                                                 style: const TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: 12,
//                                                   fontWeight: FontWeight.w700,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                           const SizedBox(width: 12),
//                                           Expanded(
//                                             child: Text(
//                                               'Option ${String.fromCharCode(65 + index)}',
//                                               style: const TextStyle(
//                                                 fontSize: 14,
//                                                 fontWeight: FontWeight.w600,
//                                                 color: Color(0xFF374151),
//                                               ),
//                                             ),
//                                           ),
//                                           // Correct Answer Toggle
//                                           GestureDetector(
//                                             onTap: () {
//                                               controller.selectedCorrectAnswer.value = index;
//                                             },
//                                             child: Container(
//                                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                               decoration: BoxDecoration(
//                                                 color: controller.selectedCorrectAnswer.value == index
//                                                     ? const Color(0xFF10B981)
//                                                     : const Color(0xFFE2E8F0),
//                                                 borderRadius: BorderRadius.circular(6),
//                                               ),
//                                               child: Text(
//                                                 controller.selectedCorrectAnswer.value == index
//                                                     ? 'Correct'
//                                                     : 'Select',
//                                                 style: TextStyle(
//                                                   fontSize: 10,
//                                                   fontWeight: FontWeight.w600,
//                                                   color: controller.selectedCorrectAnswer.value == index
//                                                       ? Colors.white
//                                                       : const Color(0xFF64748B),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                           if (controller.optionControllers.length > 2) ...[
//                                             const SizedBox(width: 8),
//                                             GestureDetector(
//                                               onTap: () => controller.removeOption(index),
//                                               child: Container(
//                                                 padding: const EdgeInsets.all(4),
//                                                 decoration: BoxDecoration(
//                                                   color: Colors.red.withOpacity(0.1),
//                                                   borderRadius: BorderRadius.circular(6),
//                                                 ),
//                                                 child: const Icon(
//                                                   Icons.remove_rounded,
//                                                   color: Colors.red,
//                                                   size: 16,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ],
//                                       ),
//                                       const SizedBox(height: 12),
//                                       TextField(
//                                         controller: optionController,
//                                         decoration: const InputDecoration(
//                                           hintText: 'Enter option text...',
//                                           border: InputBorder.none,
//                                           contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                                           filled: true,
//                                           fillColor: Colors.white,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               })
//                               .toList(),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
              
//               // Action Buttons
//               Container(
//                 padding: const EdgeInsets.all(24),
//                 decoration: const BoxDecoration(
//                   color: Color(0xFFF8FAFC),
//                   borderRadius: BorderRadius.only(
//                     bottomLeft: Radius.circular(24),
//                     bottomRight: Radius.circular(24),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton(
//                         onPressed: () => Get.back(),
//                         style: OutlinedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           side: const BorderSide(color: Color(0xFFE2E8F0)),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: const Text(
//                           'Cancel',
//                           style: TextStyle(
//                             color: Color(0xFF64748B),
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Obx(
//                         () => Container(
//                           decoration: BoxDecoration(
//                             gradient: const LinearGradient(
//                               colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
//                             ),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: ElevatedButton(
//                             onPressed: (isEdit
//                                     ? controller.isUpdating.value
//                                     : controller.isCreating.value)
//                                 ? null
//                                 : () async {
//                                     bool success;
//                                     if (isEdit) {
//                                       success = await controller.updateTestQuestion(
//                                         question!.id!,
//                                       );
//                                     } else {
//                                       success = await controller.createTestQuestion();
//                                     }
//                                     if (success) {
//                                       Get.back();
//                                     }
//                                   },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.transparent,
//                               foregroundColor: Colors.white,
//                               elevation: 0,
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             child: (isEdit
//                                     ? controller.isUpdating.value
//                                     : controller.isCreating.value)
//                                 ? const SizedBox(
//                                     width: 20,
//                                     height: 20,
//                                     child: CircularProgressIndicator(
//                                       strokeWidth: 2,
//                                       color: Colors.white,
//                                     ),
//                                   )
//                                 : Text(
//                                     isEdit ? 'Update Question' : 'Create Question',
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   String _formatDateTime(DateTime dateTime) {
//     return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
//   }
// }