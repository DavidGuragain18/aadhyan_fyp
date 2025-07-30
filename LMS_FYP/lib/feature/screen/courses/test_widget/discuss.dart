  // Widget _buildGroupChatTab() {
  //   if (enrollStatus == 'pending' ||
  //       enrollStatus == 'rejected' ||
  //       enrollStatus == 'cancelled') {
  //     return Center(
  //       child: Padding(
  //         padding: const EdgeInsets.all(16),
  //         child: Text(
  //           'You cannot access the discussion until your enrollment is approved.',
  //           style: const TextStyle(fontSize: 16, color: Color(0xFFEF4444)),
  //           textAlign: TextAlign.center,
  //         ),
  //       ),
  //     );
  //   }
  //   return Column(
  //     children: [
  //       // Chat Header
  //       Container(
  //         padding: const EdgeInsets.all(16),
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           border: Border(
  //             bottom: BorderSide(color: const Color(0xFFF3F4F6), width: 1),
  //           ),
  //         ),
  //         child: Row(
  //           children: [
  //             Icon(Icons.group, color: const Color(0xFF6366F1), size: 24),
  //             const SizedBox(width: 12),
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     'Course Discussion',
  //                     style: const TextStyle(
  //                       fontSize: 18,
  //                       fontWeight: FontWeight.bold,
  //                       color: Color(0xFF111827),
  //                     ),
  //                   ),
  //                   Obx(
  //                     () => Text(
  //                       '${groupChatController.messageCount} messages',
  //                       style: const TextStyle(
  //                         fontSize: 12,
  //                         color: Color(0xFF6B7280),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             IconButton(
  //               onPressed: () => groupChatController.refreshMessages(),
  //               icon: Icon(Icons.refresh, color: const Color(0xFF6366F1)),
  //             ),
  //           ],
  //         ),
  //       ),

  //       // Messages Area
  //       Expanded(
  //         child: Obx(() {
  //           if (groupChatController.isLoading) {
  //             return const Center(
  //               child: CircularProgressIndicator(
  //                 valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
  //               ),
  //             );
  //           }

  //           if (groupChatController.errorMessage.isNotEmpty) {
  //             return Center(
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Icon(
  //                     Icons.error_outline,
  //                     size: 48,
  //                     color: const Color(0xFFEF4444),
  //                   ),
  //                   const SizedBox(height: 16),
  //                   Text(
  //                     'Error loading messages',
  //                     style: const TextStyle(
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.w600,
  //                       color: Color(0xFF111827),
  //                     ),
  //                   ),
  //                   const SizedBox(height: 8),
  //                   Text(
  //                     groupChatController.errorMessage,
  //                     style: const TextStyle(
  //                       fontSize: 14,
  //                       color: Color(0xFF6B7280),
  //                     ),
  //                     textAlign: TextAlign.center,
  //                   ),
  //                   const SizedBox(height: 16),
  //                   ElevatedButton(
  //                     onPressed: () => groupChatController.loadMessages(),
  //                     child: const Text('Retry'),
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: const Color(0xFF6366F1),
  //                       foregroundColor: Colors.white,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             );
  //           }

  //           if (groupChatController.messages.isEmpty) {
  //             return _buildEmptyMessageState();
  //           }

  //           return ListView.builder(
  //             controller: groupChatController.scrollController,
  //             padding: const EdgeInsets.all(16),
  //             itemCount: groupChatController.messages.length,
  //             itemBuilder: (context, index) {
  //               final message = groupChatController.messages[index];
  //               return _buildMessageItem(message, index);
  //             },
  //           );
  //         }),
  //       ),

  //       // Message Input Area
  //       Container(
  //         padding: const EdgeInsets.all(16),
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           border: Border(
  //             top: BorderSide(color: const Color(0xFFF3F4F6), width: 1),
  //           ),
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.black.withValues(alpha: 0.05),
  //               blurRadius: 10,
  //               offset: const Offset(0, -2),
  //             ),
  //           ],
  //         ),
  //         child: Row(
  //           children: [
  //             Expanded(
  //               child: Container(
  //                 decoration: BoxDecoration(
  //                   color: const Color(0xFFF8FAFF),
  //                   borderRadius: BorderRadius.circular(24),
  //                   border: Border.all(
  //                     color: const Color(0xFFF3F4F6),
  //                     width: 1,
  //                   ),
  //                 ),
  //                 child: TextField(
  //                   controller: groupChatController.messageController,
  //                   decoration: const InputDecoration(
  //                     hintText: 'Type your message...',
  //                     hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
  //                     border: InputBorder.none,
  //                     contentPadding: EdgeInsets.symmetric(
  //                       horizontal: 20,
  //                       vertical: 12,
  //                     ),
  //                   ),
  //                   maxLines: null,
  //                   textInputAction: TextInputAction.send,
  //                   onSubmitted: (_) => groupChatController.sendMessage(),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(width: 12),
  //             Obx(
  //               () => Container(
  //                 decoration: BoxDecoration(
  //                   gradient: const LinearGradient(
  //                     begin: Alignment.topLeft,
  //                     end: Alignment.bottomRight,
  //                     colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  //                   ),
  //                   borderRadius: BorderRadius.circular(24),
  //                 ),
  //                 child: Material(
  //                   color: Colors.transparent,
  //                   child: InkWell(
  //                     onTap: groupChatController.canSendMessage
  //                         ? () => groupChatController.sendMessage()
  //                         : null,
  //                     borderRadius: BorderRadius.circular(24),
  //                     child: Container(
  //                       width: 48,
  //                       height: 48,
  //                       child: groupChatController.isSending
  //                           ? const Center(
  //                               child: SizedBox(
  //                                 width: 20,
  //                                 height: 20,
  //                                 child: CircularProgressIndicator(
  //                                   strokeWidth: 2,
  //                                   valueColor: AlwaysStoppedAnimation<Color>(
  //                                     Colors.white,
  //                                   ),
  //                                 ),
  //                               ),
  //                             )
  //                           : const Icon(
  //                               Icons.send,
  //                               color: Colors.white,
  //                               size: 24,
  //                             ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildEmptyMessageState() {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Container(
  //           width: 80,
  //           height: 80,
  //           decoration: BoxDecoration(
  //             color: const Color(0xFFF3F4F6),
  //             borderRadius: BorderRadius.circular(40),
  //           ),
  //           child: const Icon(
  //             Icons.chat_bubble_outline,
  //             size: 40,
  //             color: Color(0xFF9CA3AF),
  //           ),
  //         ),
  //         const SizedBox(height: 20),
  //         const Text(
  //           'No messages yet',
  //           style: TextStyle(
  //             fontSize: 18,
  //             fontWeight: FontWeight.w600,
  //             color: Color(0xFF111827),
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //         const Text(
  //           'Start the conversation by sending the first message',
  //           style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
  //           textAlign: TextAlign.center,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildMessageItem(GroupChatModel message, int index) {
  //   final isCurrentUser =
  //       message.user.id ==
  //       'current_user_id'; // Replace with actual current user ID logic
  //   final showDateHeader = _shouldShowDateHeader(message, index);

  //   return Column(
  //     children: [
  //       // Date Header
  //       if (showDateHeader) _buildDateHeader(message.createdAt),

  //       // Message Bubble
  //       Container(
  //         margin: const EdgeInsets.only(bottom: 12),
  //         child: Row(
  //           mainAxisAlignment: isCurrentUser
  //               ? MainAxisAlignment.end
  //               : MainAxisAlignment.start,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             if (!isCurrentUser) ...[
  //               // User Avatar
  //               Container(
  //                 width: 32,
  //                 height: 32,
  //                 decoration: BoxDecoration(
  //                   gradient: const LinearGradient(
  //                     begin: Alignment.topLeft,
  //                     end: Alignment.bottomRight,
  //                     colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  //                   ),
  //                   borderRadius: BorderRadius.circular(16),
  //                 ),
  //                 child: Center(
  //                   child: Text(
  //                     message.user.name.isNotEmpty
  //                         ? message.user.name[0].toUpperCase()
  //                         : 'U',
  //                     style: const TextStyle(
  //                       color: Colors.white,
  //                       fontSize: 12,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(width: 8),
  //             ],

  //             // Message Content
  //             Flexible(
  //               child: Container(
  //                 constraints: BoxConstraints(
  //                   maxWidth: MediaQuery.of(context).size.width * 0.7,
  //                 ),
  //                 padding: const EdgeInsets.symmetric(
  //                   horizontal: 16,
  //                   vertical: 12,
  //                 ),
  //                 decoration: BoxDecoration(
  //                   color: isCurrentUser
  //                       ? const Color(0xFF6366F1)
  //                       : Colors.white,
  //                   borderRadius: BorderRadius.only(
  //                     topLeft: const Radius.circular(16),
  //                     topRight: const Radius.circular(16),
  //                     bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
  //                     bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
  //                   ),
  //                   boxShadow: [
  //                     BoxShadow(
  //                       color: Colors.black.withValues(alpha: 0.05),
  //                       blurRadius: 8,
  //                       offset: const Offset(0, 2),
  //                     ),
  //                   ],
  //                   border: isCurrentUser
  //                       ? null
  //                       : Border.all(color: const Color(0xFFF3F4F6), width: 1),
  //                 ),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     if (!isCurrentUser)
  //                       Padding(
  //                         padding: const EdgeInsets.only(bottom: 4),
  //                         child: Text(
  //                           message.user.name.isNotEmpty
  //                               ? message.user.name
  //                               : 'Anonymous User',
  //                           style: const TextStyle(
  //                             fontSize: 12,
  //                             fontWeight: FontWeight.w600,
  //                             color: Color(0xFF6366F1),
  //                           ),
  //                         ),
  //                       ),
  //                     Text(
  //                       message.message,
  //                       style: TextStyle(
  //                         fontSize: 14,
  //                         color: isCurrentUser
  //                             ? Colors.white
  //                             : const Color(0xFF374151),
  //                         height: 1.4,
  //                       ),
  //                     ),
  //                     const SizedBox(height: 4),
  //                     Text(
  //                       formatDate(message.createdAt),
  //                       style: TextStyle(
  //                         fontSize: 11,
  //                         color: isCurrentUser
  //                             ? Colors.white.withValues(alpha: 0.8)
  //                             : const Color(0xFF9CA3AF),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),

  //             if (isCurrentUser) ...[
  //               const SizedBox(width: 8),
  //               // Current user avatar (optional)
  //               Container(
  //                 width: 32,
  //                 height: 32,
  //                 decoration: BoxDecoration(
  //                   gradient: const LinearGradient(
  //                     begin: Alignment.topLeft,
  //                     end: Alignment.bottomRight,
  //                     colors: [Color(0xFF10B981), Color(0xFF059669)],
  //                   ),
  //                   borderRadius: BorderRadius.circular(16),
  //                 ),
  //                 child: const Center(
  //                   child: Icon(Icons.person, color: Colors.white, size: 16),
  //                 ),
  //               ),
  //             ],
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildDateHeader(DateTime date) {
  //   final now = DateTime.now();
  //   final today = DateTime(now.year, now.month, now.day);
  //   final messageDate = DateTime(date.year, date.month, date.day);

  //   String dateText;
  //   if (messageDate == today) {
  //     dateText = 'Today';
  //   } else if (messageDate == today.subtract(const Duration(days: 1))) {
  //     dateText = 'Yesterday';
  //   } else {
  //     dateText = '${date.day}/${date.month}/${date.year}';
  //   }

  //   return Container(
  //     margin: const EdgeInsets.symmetric(vertical: 16),
  //     child: Center(
  //       child: Container(
  //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //         decoration: BoxDecoration(
  //           color: const Color(0xFFF3F4F6),
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         child: Text(
  //           dateText,
  //           style: const TextStyle(
  //             fontSize: 12,
  //             fontWeight: FontWeight.w500,
  //             color: Color(0xFF6B7280),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // bool _shouldShowDateHeader(GroupChatModel message, int index) {
  //   if (index == 0) return true;

  //   final previousMessage = groupChatController.messages[index - 1];
  //   final currentDate = DateTime(
  //     message.createdAt.year,
  //     message.createdAt.month,
  //     message.createdAt.day,
  //   );
  //   final previousDate = DateTime(
  //     previousMessage.createdAt.year,
  //     previousMessage.createdAt.month,
  //     previousMessage.createdAt.day,
  //   );

  //   return currentDate != previousDate;
  // }
