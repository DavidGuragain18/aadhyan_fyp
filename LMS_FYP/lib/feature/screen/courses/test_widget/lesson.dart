  // Widget _buildLessonsTab() {
  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.all(12),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         _buildSectionHeader('Course Content'),
  //         const SizedBox(height: 16),
  //         // widget.course.lessons.isEmpty
  //         //     ? _buildEmptyLessonsState()
  //         //     : _buildLessonsList(),
  //         Obx(() {
  //           if (courseLessonController.isLoading.value) {
  //             return const Center(child: CircularProgressIndicator());
  //           }
  //           final lessons = courseLessonController.lessons;

  //           if (lessons.isEmpty) {
  //             return _buildEmptyLessonsState();
  //           } else {
  //             return _buildLessonsList(lessons);
  //           }
  //         }),
  //       ],
  //     ),
  //   );
  // }

 
 
  // Widget _buildEmptyLessonsState() {
  //   return Container(
  //     padding: const EdgeInsets.all(40),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withValues(alpha: 0.05),
  //           blurRadius: 10,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Center(
  //       child: Column(
  //         children: [
  //           Container(
  //             width: 80,
  //             height: 80,
  //             decoration: BoxDecoration(
  //               color: const Color(0xFFF3F4F6),
  //               borderRadius: BorderRadius.circular(40),
  //             ),
  //             child: const Icon(
  //               Icons.play_circle_outline,
  //               size: 40,
  //               color: Color(0xFF9CA3AF),
  //             ),
  //           ),
  //           const SizedBox(height: 20),
  //           const Text(
  //             'No lessons yet',
  //             style: TextStyle(
  //               fontSize: 18,
  //               fontWeight: FontWeight.w600,
  //               color: Color(0xFF111827),
  //             ),
  //           ),
  //           const SizedBox(height: 8),
  //           const Text(
  //             'Lessons will appear here once they are added to the course',
  //             style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
  //             textAlign: TextAlign.center,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildLessonsList(List<CourseLessonModel> lessons) {
  //   return Container(
  //     margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.4),
  //     decoration: BoxDecoration(
  //       color: Colors.transparent,
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withValues(alpha: 0.05),
  //           blurRadius: 10,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       children: List.generate(
  //         lessons.length,
  //         (index) => _buildLessonItem(index, lessons[index]),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildLessonItem(int index, CourseLessonModel lesson) {
  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 8),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withValues(alpha: 0.02),
  //           blurRadius: 4,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Material(
  //       color: Colors.transparent,
  //       child: InkWell(
  //         onTap: () {
  //           // Navigate to lesson detail or start lesson
  //           log('Tapped lesson: ${lesson.title}');
  //           Get.to(() => LessonTestQuestionScreen(), arguments: lesson);
  //         },
  //         borderRadius: BorderRadius.circular(12),
  //         child: Padding(
  //           padding: const EdgeInsets.all(16),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               // Header Row
  //               Row(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   // Lesson Number Badge
  //                   Container(
  //                     width: 25,
  //                     height: 25,
  //                     decoration: BoxDecoration(
  //                       gradient: const LinearGradient(
  //                         begin: Alignment.topLeft,
  //                         end: Alignment.bottomRight,
  //                         colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  //                       ),
  //                       borderRadius: BorderRadius.circular(22),
  //                       boxShadow: [
  //                         BoxShadow(
  //                           color: const Color(
  //                             0xFF6366F1,
  //                           ).withValues(alpha: 0.3),
  //                           blurRadius: 8,
  //                           offset: const Offset(0, 2),
  //                         ),
  //                       ],
  //                     ),
  //                     child: Center(
  //                       child: Text(
  //                         '${index + 1}',
  //                         style: const TextStyle(
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.white,
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                   const SizedBox(width: 16),

  //                   Expanded(
  //                     child: Text(
  //                       lesson.title,
  //                       style: const TextStyle(
  //                         fontSize: 16,
  //                         fontWeight: FontWeight.w700,
  //                         color: Color(0xFF111827),
  //                         height: 1.2,
  //                       ),
  //                       maxLines: 2,
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                   ),
  //                 ],
  //               ),

  //               SizedBox(height: 16),
  //               Wrap(
  //                 alignment: WrapAlignment.start,
  //                 crossAxisAlignment: WrapCrossAlignment.center,
  //                 children: [
  //                   Container(
  //                     padding: const EdgeInsets.symmetric(
  //                       horizontal: 8,
  //                       vertical: 4,
  //                     ),
  //                     decoration: BoxDecoration(
  //                       color: const Color(0xFF10B981).withValues(alpha: 0.1),
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),
  //                     child: Row(
  //                       mainAxisSize: MainAxisSize.min,
  //                       children: [
  //                         const Icon(
  //                           Icons.access_time,
  //                           size: 12,
  //                           color: Color(0xFF10B981),
  //                         ),
  //                         const SizedBox(width: 4),
  //                         Text(
  //                           lesson.formattedReadingDuration,
  //                           style: const TextStyle(
  //                             fontSize: 12,
  //                             fontWeight: FontWeight.w600,
  //                             color: Color(0xFF10B981),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   const SizedBox(width: 8),

  //                   // PDF Indicator
  //                   if (lesson.hasPdf)
  //                     Container(
  //                       padding: const EdgeInsets.symmetric(
  //                         horizontal: 8,
  //                         vertical: 4,
  //                       ),
  //                       decoration: BoxDecoration(
  //                         color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
  //                         borderRadius: BorderRadius.circular(8),
  //                       ),
  //                       child: Row(
  //                         mainAxisSize: MainAxisSize.min,
  //                         children: [
  //                           const Icon(
  //                             Icons.picture_as_pdf,
  //                             size: 12,
  //                             color: Color(0xFFF59E0B),
  //                           ),
  //                           const SizedBox(width: 4),
  //                           const Text(
  //                             'PDF',
  //                             style: TextStyle(
  //                               fontSize: 12,
  //                               fontWeight: FontWeight.w600,
  //                               color: Color(0xFFF59E0B),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),

  //                   // Tests Indicator
  //                   // if (lesson.tests.isNotEmpty )
  //                   GestureDetector(
  //                     onTap: () {
  //                       Get.to(
  //                         () => LessonTestQuestionScreen(),
  //                         arguments: lesson,
  //                       );
  //                     },
  //                     child: Container(
  //                       margin: const EdgeInsets.only(left: 8),
  //                       padding: const EdgeInsets.symmetric(
  //                         horizontal: 8,
  //                         vertical: 4,
  //                       ),
  //                       decoration: BoxDecoration(
  //                         color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
  //                         borderRadius: BorderRadius.circular(8),
  //                       ),
  //                       child: Row(
  //                         mainAxisSize: MainAxisSize.min,
  //                         children: [
  //                           const Icon(
  //                             Icons.quiz,
  //                             size: 12,
  //                             color: Color(0xFF8B5CF6),
  //                           ),
  //                           const SizedBox(width: 4),
  //                           Text(
  //                             '${lesson.tests.length} Test',
  //                             style: const TextStyle(
  //                               fontSize: 12,
  //                               fontWeight: FontWeight.w600,
  //                               color: Color(0xFF8B5CF6),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                   Spacer(),
  //                   IconButton(
  //                     padding: EdgeInsets.zero,
  //                     onPressed: () async {
  //                       log('delete lesson: ${lesson.title}');
  //                       final shouldEdit = await DialogUtils.showConfirmDialog(
  //                         title: 'Delete Lesson',
  //                         message:
  //                             'Are you sure you want to delete "${lesson.title}"? This action cannot be undone.',
  //                         confirmText: 'Delete',
  //                         cancelText: 'Cancel',
  //                         icon: Icons.delete,
  //                         isDangerous: true,
  //                       );

  //                       if (shouldEdit) {
  //                         // final CourseLessonController
  //                         // courseController =
  //                         //     Get.find<CourseLessonController>();

  //                         await courseLessonController.deleteCourseLesson(
  //                           lesson.id,
  //                           courseId: widget.course.id,
  //                         );
  //                       }
  //                     },
  //                     icon: const Icon(
  //                       Icons.delete_forever,
  //                       color: Color(0xFF6366F1),
  //                       size: 18,
  //                     ),
  //                   ),
  //                   IconButton(
  //                     padding: EdgeInsets.zero,
  //                     onPressed: () {
  //                       Get.to(
  //                         () => AddEditLessonScreen(
  //                           course: widget.course,
  //                           lesson: lesson,
  //                         ),
  //                       );
  //                     },
  //                     icon: const Icon(
  //                       Icons.edit,
  //                       color: Color(0xFF6366F1),
  //                       size: 18,
  //                     ),
  //                   ),
  //                 ],
  //               ),

  //               // Description
  //               if (lesson.description.isNotEmpty) ...[
  //                 const SizedBox(height: 12),
  //                 Text(
  //                   lesson.description,
  //                   style: const TextStyle(
  //                     fontSize: 14,
  //                     color: Color(0xFF6B7280),
  //                     height: 1.4,
  //                   ),
  //                   maxLines: 2,
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ],

  //               // Keywords
  //               if (lesson.hasKeywords) ...[
  //                 const SizedBox(height: 12),
  //                 Wrap(
  //                   spacing: 6,
  //                   runSpacing: 6,
  //                   children: lesson.keywords.take(3).map((keyword) {
  //                     return Container(
  //                       padding: const EdgeInsets.symmetric(
  //                         horizontal: 8,
  //                         vertical: 4,
  //                       ),
  //                       decoration: BoxDecoration(
  //                         color: const Color(
  //                           0xFF6366F1,
  //                         ).withValues(alpha: 0.08),
  //                         borderRadius: BorderRadius.circular(6),
  //                         border: Border.all(
  //                           color: const Color(
  //                             0xFF6366F1,
  //                           ).withValues(alpha: 0.2),
  //                           width: 1,
  //                         ),
  //                       ),
  //                       child: Text(
  //                         keyword,
  //                         style: const TextStyle(
  //                           fontSize: 11,
  //                           fontWeight: FontWeight.w500,
  //                           color: Color(0xFF6366F1),
  //                         ),
  //                       ),
  //                     );
  //                   }).toList(),
  //                 ),
  //                 if (lesson.keywords.length > 3)
  //                   Padding(
  //                     padding: const EdgeInsets.only(top: 6),
  //                     child: Text(
  //                       '+${lesson.keywords.length - 3} more topics',
  //                       style: TextStyle(
  //                         fontSize: 11,
  //                         color: const Color(0xFF6B7280).withValues(alpha: 0.8),
  //                         fontStyle: FontStyle.italic,
  //                       ),
  //                     ),
  //                   ),
  //               ],

  //               // Progress Bar (Optional - you can add progress tracking)
  //               const SizedBox(height: 12),
  //               Container(
  //                 height: 4,
  //                 decoration: BoxDecoration(
  //                   color: const Color(0xFFF3F4F6),
  //                   borderRadius: BorderRadius.circular(2),
  //                 ),
  //                 child: FractionallySizedBox(
  //                   alignment: Alignment.centerLeft,
  //                   widthFactor:
  //                       0.0, // Set to 0.0 for new lessons, update based on progress
  //                   child: Container(
  //                     decoration: BoxDecoration(
  //                       color: const Color(0xFF10B981),
  //                       borderRadius: BorderRadius.circular(2),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
