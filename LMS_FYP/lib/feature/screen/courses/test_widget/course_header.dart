
  // Widget _buildCourseHeader() {
  //   return Container(
  //     color: Colors.white,
  //     padding: const EdgeInsets.all(16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Expanded(
  //               child: Text(
  //                 widget.course.description,
  //                 style: const TextStyle(
  //                   fontSize: 16,
  //                   color: Color(0xFF6B7280),
  //                   height: 1.6,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 20),
  //         _buildStatsRow(),
  //         const SizedBox(height: 20),
  //         _buildActionButtons(),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildStatsRow() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceAround,
  //     children: [
  //       Obx(() {
  //         return _buildStatItem(
  //           icon: Icons.play_circle_outline,
  //           label: 'Lessons',
  //           value: '${courseLessonController.lessons.length}',
  //           color: const Color(0xFF10B981),
  //         );
  //       }),

  //       _buildStatItem(
  //         icon: Icons.people_outline,
  //         label: 'Students',
  //         value: '0',
  //         color: const Color(0xFF3B82F6),
  //       ),
  //       _buildStatItem(
  //         icon: Icons.star_outline,
  //         label: 'Rating',
  //         value: courseReviewController.courseReviews.ratingAverage
  //             .toStringAsFixed(2),

  //         color: const Color(0xFFF59E0B),
  //       ),
  //       _buildStatItem(
  //         icon: Icons.access_time,
  //         label: 'Duration',
  //         value: CourseLessonModel.formattedTotalReadingDuration(
  //           courseLessonController.lessons,
  //         ),
  //         color: const Color(0xFF8B5CF6),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildStatItem({
  //   required IconData icon,
  //   required String label,
  //   required String value,
  //   required Color color,
  // }) {
  //   return Column(
  //     children: [
  //       Container(
  //         padding: const EdgeInsets.all(12),
  //         decoration: BoxDecoration(
  //           color: color.withValues(alpha: 0.1),
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         child: Icon(icon, color: color, size: 24),
  //       ),
  //       const SizedBox(height: 8),
  //       Text(
  //         value,
  //         style: const TextStyle(
  //           fontSize: 18,
  //           fontWeight: FontWeight.bold,
  //           color: Color(0xFF111827),
  //         ),
  //       ),
  //       Text(
  //         label,
  //         style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildActionButtons() {
  //   return Row(
  //     children: [
  //       Expanded(
  //         flex: 2,
  //         child: ElevatedButton.icon(
  //           onPressed: () {
  //             // Start course functionality
  //           },
  //           icon: const Icon(Icons.play_arrow, size: 24),
  //           label: const Text('Start Learning'),
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: const Color(0xFF6366F1),
  //             foregroundColor: Colors.white,
  //             elevation: 3,
  //             shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.4),
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(16),
  //             ),
  //             padding: const EdgeInsets.symmetric(vertical: 16),
  //           ),
  //         ),
  //       ),
  //       const SizedBox(width: 12),
  //       Expanded(
  //         child: OutlinedButton.icon(
  //           onPressed: () {
  //             // Bookmark functionality
  //           },
  //           icon: const Icon(Icons.bookmark_border, size: 20),
  //           label: const Text('Save'),
  //           style: OutlinedButton.styleFrom(
  //             foregroundColor: const Color(0xFF6366F1),
  //             side: const BorderSide(color: Color(0xFF6366F1), width: 2),
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(16),
  //             ),
  //             padding: const EdgeInsets.symmetric(vertical: 16),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
