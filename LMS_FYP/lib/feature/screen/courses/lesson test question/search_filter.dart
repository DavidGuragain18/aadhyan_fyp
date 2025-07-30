  // Widget _buildSearchField() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: const Color(0xFFF1F5F9),
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: const Color(0xFFE2E8F0)),
  //     ),
  //     child: TextField(
  //       onChanged: controller.updateSearchQuery,
  //       decoration: InputDecoration(
  //         hintText: 'Search questions or options...',
  //         hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
  //         prefixIcon: const Icon(
  //           Icons.search_rounded,
  //           color: Color(0xFF64748B),
  //         ),
  //         suffixIcon: Obx(
  //           () => controller.searchQuery.value.isNotEmpty
  //               ? IconButton(
  //                   icon: const Icon(
  //                     Icons.clear_rounded,
  //                     color: Color(0xFF64748B),
  //                   ),
  //                   onPressed: () => controller.updateSearchQuery(''),
  //                 )
  //               : const SizedBox.shrink(),
  //         ),
  //         border: InputBorder.none,
  //         contentPadding: const EdgeInsets.symmetric(
  //           horizontal: 16,
  //           vertical: 16,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildLessonFilter() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: const Color(0xFFF1F5F9),
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: const Color(0xFFE2E8F0)),
  //     ),
  //     child: TextField(
  //       onChanged: controller.updateSearchQuery,
  //       decoration: InputDecoration(
  //         hintText: 'Filter by Lesson ID...',
  //         hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
  //         prefixIcon: const Icon(Icons.book_rounded, color: Color(0xFF64748B)),
  //         suffixIcon: Obx(
  //           () => controller.selectedLessonId.value.isNotEmpty
  //               ? IconButton(
  //                   icon: const Icon(
  //                     Icons.clear_rounded,
  //                     color: Color(0xFF64748B),
  //                   ),
  //                   onPressed: () => controller.updateSearchQuery(''),
  //                 )
  //               : const SizedBox.shrink(),
  //         ),
  //         border: InputBorder.none,
  //         contentPadding: const EdgeInsets.symmetric(
  //           horizontal: 16,
  //           vertical: 16,
  //         ),
  //       ),
  //     ),
  //   );
  // }
