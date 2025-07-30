// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import '../../controller/chat/AI_controller.dart';

// class ChatWithAIScreen extends StatelessWidget {
//   final ChatAIController controller = Get.put(ChatAIController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: _buildAppBar(),
//       body: Column(
//         children: [
//           _buildAIProviderSelector(),
//           Expanded(child: _buildChatArea()),
//           _buildMessageInput(),
//         ],
//       ),
//     );
//   }

//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       elevation: 0,
//       // backgroundColor: Colors.white,
//       // foregroundColor: Colors.black87,
//       title: Obx(
//         () => Row(
//           children: [
//             Container(
//               width: 10,
//               height: 10,
//               decoration: BoxDecoration(
//                 color: controller.currentProviderColor,
//                 shape: BoxShape.circle,
//               ),
//             ),
//             SizedBox(width: 8),
//             Text(
//               'AI Assistant',
//               style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         PopupMenuButton<String>(
//           onSelected: (value) {
//             switch (value) {
//               case 'clear':
//                 _showClearChatDialog();
//                 break;
//               case 'help':
//                 _showHelpDialog();
//                 break;
//             }
//           },
//           itemBuilder: (context) => [
//             PopupMenuItem(
//               value: 'clear',
//               child: Row(
//                 children: [
//                   Icon(Icons.clear_all, size: 20),
//                   SizedBox(width: 8),
//                   Text('Clear Chat'),
//                 ],
//               ),
//             ),
//             PopupMenuItem(
//               value: 'help',
//               child: Row(
//                 children: [
//                   Icon(Icons.help_outline, size: 20),
//                   SizedBox(width: 8),
//                   Text('Help'),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildAIProviderSelector() {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
//       ),
//       child: Row(
//         children: [
//           Text(
//             'AI Provider:',
//             style: TextStyle(
//               fontWeight: FontWeight.w500,
//               color: Colors.grey[700],
//             ),
//           ),
//           SizedBox(width: 12),
//           Expanded(
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Obx(
//                 () => Row(
//                   children: AIProvider.values.map((provider) {
//                     final isSelected =
//                         controller.selectedProvider.value == provider;
//                     return Padding(
//                       padding: EdgeInsets.only(right: 8),
//                       child: GestureDetector(
//                         onTap: () => controller.changeAIProvider(provider),
//                         child: Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 8,
//                           ),
//                           decoration: BoxDecoration(
//                             color: isSelected
//                                 ? controller.currentProviderColor
//                                 : Colors.white,
//                             borderRadius: BorderRadius.circular(20),
//                             border: Border.all(
//                               color: controller.currentProviderColor,
//                               width: 1.5,
//                             ),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 _getProviderIcon(provider),
//                                 size: 16,
//                                 color: isSelected
//                                     ? Colors.white
//                                     : controller.currentProviderColor,
//                               ),
//                               SizedBox(width: 6),
//                               Text(
//                                 controller.currentProviderName,
//                                 style: TextStyle(
//                                   color: isSelected
//                                       ? Colors.white
//                                       : controller.currentProviderColor,
//                                   fontWeight: FontWeight.w500,
//                                   fontSize: 13,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   IconData _getProviderIcon(AIProvider provider) {
//     switch (provider) {
//       case AIProvider.chatGPT:
//         return Icons.chat;
//       case AIProvider.claude:
//         return Icons.psychology;
//       case AIProvider.gemini:
//         return Icons.auto_awesome;
//     }
//   }

//   Widget _buildChatArea() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [Colors.grey[50]!, Colors.white],
//         ),
//       ),
//       child: Obx(
//         () => ListView.builder(
//           controller: controller.scrollController,
//           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           itemCount:
//               controller.messages.length + (controller.isLoading.value ? 1 : 0),
//           itemBuilder: (context, index) {
//             if (index == controller.messages.length &&
//                 controller.isLoading.value) {
//               return _buildTypingIndicator();
//             }

//             final message = controller.messages[index];
//             return _buildMessageBubble(message, index);
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildMessageBubble(ChatMessage message, int index) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: message.isUser
//             ? MainAxisAlignment.end
//             : MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (!message.isUser) _buildAIAvatar(message.aiProvider),
//           if (!message.isUser) SizedBox(width: 8),
//           Flexible(
//             child: GestureDetector(
//               onLongPress: () => _showMessageOptions(message, index),
//               child: Container(
//                 constraints: BoxConstraints(maxWidth: Get.width * 0.75),
//                 padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 decoration: BoxDecoration(
//                   color: message.isUser
//                       ? controller.currentProviderColor
//                       : Colors.white,
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(20),
//                     topRight: Radius.circular(20),
//                     bottomLeft: Radius.circular(message.isUser ? 20 : 4),
//                     bottomRight: Radius.circular(message.isUser ? 4 : 20),
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 5,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       message.content,
//                       style: TextStyle(
//                         color: message.isUser ? Colors.white : Colors.black87,
//                         fontSize: 15,
//                         height: 1.4,
//                       ),
//                     ),
//                     SizedBox(height: 4),
//                     Text(
//                       DateFormat('HH:mm').format(message.timestamp),
//                       style: TextStyle(
//                         color: message.isUser
//                             ? Colors.white.withOpacity(0.8)
//                             : Colors.grey[500],
//                         fontSize: 11,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           if (message.isUser) SizedBox(width: 8),
//           if (message.isUser) _buildUserAvatar(),
//         ],
//       ),
//     );
//   }

//   Widget _buildAIAvatar(AIProvider? provider) {
//     final color = provider != null
//         ? controller.currentProviderColor
//         : Colors.grey;
//     final icon = provider != null
//         ? _getProviderIcon(provider)
//         : Icons.smart_toy;

//     return Container(
//       width: 32,
//       height: 32,
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         shape: BoxShape.circle,
//         border: Border.all(color: color.withOpacity(0.3), width: 1),
//       ),
//       child: Icon(icon, size: 18, color: color),
//     );
//   }

//   Widget _buildUserAvatar() {
//     return Container(
//       width: 32,
//       height: 32,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
//         shape: BoxShape.circle,
//       ),
//       child: Icon(Icons.person, size: 18, color: Colors.white),
//     );
//   }

//   Widget _buildTypingIndicator() {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           _buildAIAvatar(controller.selectedProvider.value),
//           SizedBox(width: 8),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 5,
//                   offset: Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildTypingDot(0),
//                 SizedBox(width: 4),
//                 _buildTypingDot(1),
//                 SizedBox(width: 4),
//                 _buildTypingDot(2),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTypingDot(int index) {
//     return TweenAnimationBuilder(
//       duration: Duration(milliseconds: 600),
//       tween: Tween(begin: 0.0, end: 1.0),
//       builder: (context, double value, child) {
//         return Transform.translate(
//           offset: Offset(
//             0,
//             -10 * (0.5 - (value - index * 0.2).abs().clamp(0.0, 0.5)),
//           ),
//           child: Container(
//             width: 8,
//             height: 8,
//             decoration: BoxDecoration(
//               color: controller.currentProviderColor.withOpacity(0.7),
//               shape: BoxShape.circle,
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildMessageInput() {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
//       ),
//       child: SafeArea(
//         child: Row(
//           children: [
//             Expanded(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(25),
//                 ),
//                 child: TextField(
//                   controller: controller.messageController,
//                   decoration: InputDecoration(
//                     hintText: 'Ask me anything...',
//                     hintStyle: TextStyle(color: Colors.grey[500]),
//                     border: InputBorder.none,
//                     contentPadding: EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 12,
//                     ),
//                   ),
//                   maxLines: null,
//                   textCapitalization: TextCapitalization.sentences,
//                   onSubmitted: (_) => controller.sendMessage(),
//                 ),
//               ),
//             ),
//             SizedBox(width: 12),
//             Obx(
//               () => GestureDetector(
//                 onTap: controller.isLoading.value
//                     ? null
//                     : controller.sendMessage,
//                 child: Container(
//                   width: 48,
//                   height: 48,
//                   decoration: BoxDecoration(
//                     color: controller.isLoading.value
//                         ? Colors.grey[300]
//                         : controller.currentProviderColor,
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     controller.isLoading.value ? Icons.more_horiz : Icons.send,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showMessageOptions(ChatMessage message, int index) {
//     Get.bottomSheet(
//       Container(
//         padding: EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             SizedBox(height: 20),
//             ListTile(
//               leading: Icon(Icons.copy, color: Colors.blue),
//               title: Text('Copy Message'),
//               onTap: () {
//                 // Implement copy functionality
//                 Get.back();
//                 Get.snackbar('Copied', 'Message copied to clipboard');
//               },
//             ),
//             if (!message.isUser)
//               ListTile(
//                 leading: Icon(Icons.refresh, color: Colors.green),
//                 title: Text('Regenerate Response'),
//                 onTap: () {
//                   Get.back();
//                   // Implement regenerate functionality
//                 },
//               ),
//             ListTile(
//               leading: Icon(Icons.delete, color: Colors.red),
//               title: Text('Delete Message'),
//               onTap: () {
//                 Get.back();
//                 controller.deleteMessage(index);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showClearChatDialog() {
//     Get.dialog(
//       AlertDialog(
//         title: Text('Clear Chat'),
//         content: Text('Are you sure you want to clear all messages?'),
//         actions: [
//           TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
//           TextButton(
//             onPressed: () {
//               Get.back();
//               controller.clearChat();
//             },
//             child: Text('Clear', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showHelpDialog() {
//     Get.dialog(
//       AlertDialog(
//         title: Text('AI Assistant Help'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('How to use:', style: TextStyle(fontWeight: FontWeight.bold)),
//             SizedBox(height: 8),
//             Text('• Choose an AI provider from the top'),
//             Text('• Type your question or message'),
//             Text('• Press send or hit enter'),
//             Text('• Long press messages for options'),
//             SizedBox(height: 12),
//             Text('Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
//             SizedBox(height: 8),
//             Text('• Be specific with your questions'),
//             Text('• Try different AI providers for variety'),
//             Text('• Use the menu to clear chat history'),
//           ],
//         ),
//         actions: [
//           TextButton(onPressed: () => Get.back(), child: Text('Got it')),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controller/chat/AI_controller.dart';

class ChatWithAIScreen extends StatelessWidget {
  final ChatAIController controller = Get.put(ChatAIController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Obx(() {
        // Show loading if no API keys are set up yet
        if (!controller.hasAnyApiKey.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Setting up AI providers...'),
              ],
            ),
          );
        }

        return Column(
          children: [
            _buildAIProviderSelector(),
            Expanded(child: _buildChatArea()),
            _buildMessageInput(),
          ],
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      title: Obx(
        () => Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: controller.hasAnyApiKey.value
                    ? controller.currentProviderColor
                    : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'AI Assistant',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
          ],
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'clear':
                _showClearChatDialog();
                break;
              case 'settings':
                controller.showUpdateKeysDialog();
                break;
              case 'help':
                _showHelpDialog();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.clear_all, size: 20),
                  SizedBox(width: 8),
                  Text('Clear Chat'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, size: 20),
                  SizedBox(width: 8),
                  Text('API Settings'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'help',
              child: Row(
                children: [
                  Icon(Icons.help_outline, size: 20),
                  SizedBox(width: 8),
                  Text('Help'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAIProviderSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'AI Provider:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(width: 8),
              Obx(
                () => Text(
                  '(${controller.availableProviders.length} available)',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(
              () => Row(
                children: AIProvider.values.map((provider) {
                  final isSelected =
                      controller.selectedProvider.value == provider;
                  final isAvailable = controller.isProviderAvailable(provider);
                  final providerColor = _getProviderColor(provider);

                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: isAvailable
                          ? () => controller.changeAIProvider(provider)
                          : null,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected && isAvailable
                              ? providerColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isAvailable
                                ? providerColor
                                : Colors.grey[300]!,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getProviderIcon(provider),
                              size: 16,
                              color: isAvailable
                                  ? (isSelected ? Colors.white : providerColor)
                                  : Colors.grey[400],
                            ),
                            SizedBox(width: 6),
                            Text(
                              _getProviderName(provider),
                              style: TextStyle(
                                color: isAvailable
                                    ? (isSelected
                                          ? Colors.white
                                          : providerColor)
                                    : Colors.grey[400],
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                            if (!isAvailable) ...[
                              SizedBox(width: 4),
                              Icon(
                                Icons.lock,
                                size: 12,
                                color: Colors.grey[400],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getProviderName(AIProvider provider) {
    switch (provider) {
      case AIProvider.chatGPT:
        return 'ChatGPT';
      case AIProvider.claude:
        return 'Claude';
      case AIProvider.gemini:
        return 'Gemini';
    }
  }

  Color _getProviderColor(AIProvider provider) {
    switch (provider) {
      case AIProvider.chatGPT:
        return Colors.green;
      case AIProvider.claude:
        return Colors.orange;
      case AIProvider.gemini:
        return Colors.blue;
    }
  }

  IconData _getProviderIcon(AIProvider provider) {
    switch (provider) {
      case AIProvider.chatGPT:
        return Icons.chat;
      case AIProvider.claude:
        return Icons.psychology;
      case AIProvider.gemini:
        return Icons.auto_awesome;
    }
  }

  Widget _buildChatArea() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.grey[50]!, Colors.white],
        ),
      ),
      child: Obx(
        () => ListView.builder(
          controller: controller.scrollController,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount:
              controller.messages.length + (controller.isLoading.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.messages.length &&
                controller.isLoading.value) {
              return _buildTypingIndicator();
            }

            final message = controller.messages[index];
            return _buildMessageBubble(message, index);
          },
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) _buildAIAvatar(message.aiProvider),
          if (!message.isUser) SizedBox(width: 8),
          Flexible(
            child: GestureDetector(
              onLongPress: () => _showMessageOptions(message, index),
              child: Container(
                constraints: BoxConstraints(maxWidth: Get.width * 0.75),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: message.isUser
                      ? controller.currentProviderColor
                      : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(message.isUser ? 20 : 4),
                    bottomRight: Radius.circular(message.isUser ? 4 : 20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.content,
                      style: TextStyle(
                        color: message.isUser ? Colors.white : Colors.black87,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      DateFormat('HH:mm').format(message.timestamp),
                      style: TextStyle(
                        color: message.isUser
                            ? Colors.white.withOpacity(0.8)
                            : Colors.grey[500],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (message.isUser) SizedBox(width: 8),
          if (message.isUser) _buildUserAvatar(),
        ],
      ),
    );
  }

  Widget _buildAIAvatar(AIProvider? provider) {
    final color = provider != null ? _getProviderColor(provider) : Colors.grey;
    final icon = provider != null
        ? _getProviderIcon(provider)
        : Icons.smart_toy;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, size: 18, color: Colors.white),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _buildAIAvatar(controller.selectedProvider.value),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                SizedBox(width: 4),
                _buildTypingDot(1),
                SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(
            0,
            -10 * (0.5 - (value - index * 0.2).abs().clamp(0.0, 0.5)),
          ),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: controller.currentProviderColor.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: controller.messageController,
                  decoration: InputDecoration(
                    hintText: 'Ask me anything...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => controller.sendMessage(),
                ),
              ),
            ),
            SizedBox(width: 12),
            Obx(
              () => GestureDetector(
                onTap: controller.isLoading.value
                    ? null
                    : controller.sendMessage,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: controller.isLoading.value
                        ? Colors.grey[300]
                        : controller.currentProviderColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    controller.isLoading.value ? Icons.more_horiz : Icons.send,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessageOptions(ChatMessage message, int index) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.copy, color: Colors.blue),
              title: Text('Copy Message'),
              onTap: () {
                // Implement copy functionality
                Get.back();
                Get.snackbar('Copied', 'Message copied to clipboard');
              },
            ),
            if (!message.isUser)
              ListTile(
                leading: Icon(Icons.refresh, color: Colors.green),
                title: Text('Regenerate Response'),
                onTap: () {
                  Get.back();
                  // Implement regenerate functionality
                },
              ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete Message'),
              onTap: () {
                Get.back();
                controller.deleteMessage(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearChatDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Clear Chat'),
        content: Text('Are you sure you want to clear all messages?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.clearChat();
            },
            child: Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('AI Assistant Help'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How to use:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Choose an AI provider from the top'),
              Text('• Type your question or message'),
              Text('• Press send or hit enter'),
              Text('• Long press messages for options'),
              SizedBox(height: 12),
              Text(
                'Provider Setup:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Only one API key is required to start'),
              Text('• Add more providers in API Settings'),
              Text('• Locked providers need API keys'),
              SizedBox(height: 12),
              Text('Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Be specific with your questions'),
              Text('• Try different AI providers for variety'),
              Text('• Use the menu to clear chat history'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Got it')),
        ],
      ),
    );
  }
}
