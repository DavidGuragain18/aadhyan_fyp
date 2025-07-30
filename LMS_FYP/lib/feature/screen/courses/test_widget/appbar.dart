  // Widget _buildSliverAppBar() {
  //   return SliverAppBar(
  //     expandedHeight: 300,
  //     pinned: true,
  //     backgroundColor: const Color(0xFF6366F1),
  //     flexibleSpace: FlexibleSpaceBar(
  //       background: Stack(
  //         fit: StackFit.expand,
  //         children: [
  //           // Background Image
  //           Container(
  //             decoration: BoxDecoration(
  //               gradient: const LinearGradient(
  //                 begin: Alignment.topLeft,
  //                 end: Alignment.bottomRight,
  //                 colors: [
  //                   Color(0xFF6366F1),
  //                   Color(0xFF8B5CF6),
  //                   Color(0xFF06B6D4),
  //                 ],
  //               ),
  //             ),
  //             child: widget.course.coverImage != null
  //                 ? Image.network(
  //                     widget.course.coverImage!,
  //                     fit: BoxFit.cover,
  //                     errorBuilder: (context, error, stackTrace) {
  //                       return Image.asset(
  //                         "assets/logo.png",
  //                         fit: BoxFit.cover,
  //                       );
  //                     },
  //                   )
  //                 : Image.asset("assets/logo.png", fit: BoxFit.cover),
  //           ),
  //           // Gradient Overlay
  //           Container(
  //             decoration: BoxDecoration(
  //               gradient: LinearGradient(
  //                 begin: Alignment.topCenter,
  //                 end: Alignment.bottomCenter,
  //                 colors: [
  //                   Colors.transparent,
  //                   Colors.black.withValues(alpha: 0.7),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           // Course Title at Bottom
  //           Positioned(
  //             bottom: 60,
  //             left: 20,
  //             right: 20,
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Container(
  //                   padding: const EdgeInsets.symmetric(
  //                     horizontal: 12,
  //                     vertical: 6,
  //                   ),
  //                   decoration: BoxDecoration(
  //                     color: Colors.white.withValues(alpha: 0.2),
  //                     borderRadius: BorderRadius.circular(20),
  //                   ),
  //                   child: Obx(() {
  //                     return Text(
  //                       '${courseLessonController.lessons.length} Lessons',
  //                       style: const TextStyle(
  //                         color: Colors.white,
  //                         fontSize: 12,
  //                         fontWeight: FontWeight.w500,
  //                       ),
  //                     );
  //                   }),
  //                 ),
  //                 const SizedBox(height: 12),
  //                 Text(
  //                   widget.course.title,
  //                   style: const TextStyle(
  //                     color: Colors.white,
  //                     fontSize: 28,
  //                     fontWeight: FontWeight.bold,
  //                     shadows: [
  //                       Shadow(
  //                         offset: Offset(0, 2),
  //                         blurRadius: 4,
  //                         color: Colors.black45,
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //     leading: Container(
  //       margin: const EdgeInsets.all(8),
  //       decoration: BoxDecoration(
  //         color: Colors.black.withValues(alpha: 0.3),
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       child: IconButton(
  //         icon: const Icon(Icons.arrow_back, color: Colors.white),
  //         onPressed: () => Get.back(),
  //       ),
  //     ),
  //     actions: [
  //       Container(
  //         margin: const EdgeInsets.all(8),
  //         decoration: BoxDecoration(
  //           color: Colors.black.withValues(alpha: 0.3),
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         child: IconButton(
  //           icon: const Icon(Icons.share, color: Colors.white),
  //           onPressed: () {
  //             // Implement share functionality
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }
