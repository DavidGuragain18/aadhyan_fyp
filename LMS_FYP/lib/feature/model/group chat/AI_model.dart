// // Optional: If you want to separate the model into its own file
// // File: lib/model/ai_chat/message_model.dart

// enum AIProvider { chatGPT, claude, gemini }

// class ChatMessage {
//   final String content;
//   final bool isUser;
//   final DateTime timestamp;
//   final AIProvider? aiProvider;

//   ChatMessage({
//     required this.content,
//     required this.isUser,
//     required this.timestamp,
//     this.aiProvider,
//   });

//   // Convert to JSON for storage
//   Map<String, dynamic> toJson() {
//     return {
//       'content': content,
//       'isUser': isUser,
//       'timestamp': timestamp.toIso8601String(),
//       'aiProvider': aiProvider?.toString(),
//     };
//   }

//   // Create from JSON
//   factory ChatMessage.fromJson(Map<String, dynamic> json) {
//     return ChatMessage(
//       content: json['content'],
//       isUser: json['isUser'],
//       timestamp: DateTime.parse(json['timestamp']),
//       aiProvider: json['aiProvider'] != null 
//           ? AIProvider.values.firstWhere(
//               (e) => e.toString() == json['aiProvider'],
//             )
//           : null,
//     );
//   }
// }