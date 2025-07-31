import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';

// Enum to represent different AI providers
enum AIProvider { chatGPT, claude, gemini }

// Model for individual chat messages
class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final AIProvider? aiProvider;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.aiProvider,
  });
}

// Main controller for managing AI chat logic
class ChatAIController extends GetxController {
  final RxList<ChatMessage> messages = <ChatMessage>[].obs; // Chat messages
  final RxBool isLoading = false.obs; // Loading indicator
  final Rx<AIProvider> selectedProvider = AIProvider.chatGPT.obs; // Selected AI
  final TextEditingController messageController =
      TextEditingController(); // User input
  final ScrollController scrollController =
      ScrollController(); // Scroll behavior

  // Secure storage for API keys
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Variables to store API keys
  String? _openAIKey;
  String? _claudeKey;
  String? _geminiKey;

  // Reactive flags
  final RxList<AIProvider> availableProviders = <AIProvider>[].obs;
  final RxBool hasAnyApiKey = false.obs;
  final RxBool isInitializing = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeController(); // Initialize controller on start
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  // Initialization logic
  Future<void> _initializeController() async {
    try {
      isInitializing.value = true;
      await _loadApiKeys(); // Load stored keys
    } catch (e) {
      print('Error during initialization: $e');
      _handleStorageError(e);
    } finally {
      isInitializing.value = false;
    }
  }

  // Load API keys from secure storage
  Future<void> _loadApiKeys() async {
    try {
      _openAIKey = await _storage
          .read(key: 'openai_api_key')
          .timeout(Duration(seconds: 5), onTimeout: () => null);
      _claudeKey = await _storage
          .read(key: 'claude_api_key')
          .timeout(Duration(seconds: 5), onTimeout: () => null);
      _geminiKey = await _storage
          .read(key: 'gemini_api_key')
          .timeout(Duration(seconds: 5), onTimeout: () => null);

      _updateAvailableProviders();

      // Show key setup dialog if none are found
      if (!hasAnyApiKey.value) {
        Future.delayed(Duration(milliseconds: 500), () {
          _showApiKeySetupDialog();
        });
      } else {
        selectedProvider.value = availableProviders.first;
        _addWelcomeMessage(); // Show welcome message
      }
    } catch (e) {
      print('Error loading API keys: $e');
      _handleStorageError(e);
    }
  }

  // Handle errors with secure storage access
  void _handleStorageError(dynamic error) {
    print('Storage error: $error');

    _showSnackbar(
      'Storage Issue',
      'Unable to access secure storage. You can still enter API keys manually.',
      backgroundColor: Colors.orange,
    );

    Future.delayed(Duration(seconds: 2), () {
      _showApiKeySetupDialog();
    });
  }

  // Show snackbar for messages
  void _showSnackbar(String title, String message, {Color? backgroundColor}) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Future.delayed(Duration(milliseconds: 100), () {
      Get.snackbar(
        title,
        message,
        backgroundColor: backgroundColor ?? Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(16),
        borderRadius: 8,
      );
    });
  }

  // Update available AI providers based on stored keys
  void _updateAvailableProviders() {
    availableProviders.clear();

    if (_openAIKey?.isNotEmpty ?? false) {
      availableProviders.add(AIProvider.chatGPT);
    }
    if (_claudeKey?.isNotEmpty ?? false) {
      availableProviders.add(AIProvider.claude);
    }
    if (_geminiKey?.isNotEmpty ?? false) {
      availableProviders.add(AIProvider.gemini);
    }

    hasAnyApiKey.value = availableProviders.isNotEmpty;
  }

  // Save API keys securely
  Future<void> _storeApiKeys(
    String? openAI,
    String? claude,
    String? gemini,
  ) async {
    try {
      if (openAI?.isNotEmpty ?? false) {
        await _storage
            .write(key: 'openai_api_key', value: openAI)
            .timeout(Duration(seconds: 5));
        _openAIKey = openAI;
      }
      if (claude?.isNotEmpty ?? false) {
        await _storage
            .write(key: 'claude_api_key', value: claude)
            .timeout(Duration(seconds: 5));
        _claudeKey = claude;
      }
      if (gemini?.isNotEmpty ?? false) {
        await _storage
            .write(key: 'gemini_api_key', value: gemini)
            .timeout(Duration(seconds: 5));
        _geminiKey = gemini;
      }

      _updateAvailableProviders();
      if (availableProviders.isNotEmpty) {
        selectedProvider.value = availableProviders.first;
      }

      if (messages.isEmpty) _addWelcomeMessage();

      _showSnackbar(
        'Success',
        'API keys saved successfully! Available providers: ${availableProviders.length}',
      );
    } catch (e) {
      print('Error storing API keys: $e');
      _showSnackbar(
        'Error',
        'Failed to save API keys. Please try again.',
        backgroundColor: Colors.red,
      );
    }
  }

  // Show dialog to enter API keys
  void _showApiKeySetupDialog() {
    final openAIController = TextEditingController(text: _openAIKey);
    final claudeController = TextEditingController(text: _claudeKey);
    final geminiController = TextEditingController(text: _geminiKey);

    Get.dialog(
      WillPopScope(
        onWillPop: () async => hasAnyApiKey.value,
        child: AlertDialog(
          title: Text('Setup API Keys'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Enter at least one API key to enable AI chat functionality:',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '💡 You only need one API key to get started. You can add more later.',
                    style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: openAIController,
                  decoration: InputDecoration(
                    labelText: 'OpenAI API Key (Optional)',
                    hintText: 'sk-...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.chat, color: Colors.green),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 12),
                TextField(
                  controller: claudeController,
                  decoration: InputDecoration(
                    labelText: 'Claude API Key (Optional)',
                    hintText: 'sk-ant-...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.psychology, color: Colors.orange),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 12),
                TextField(
                  controller: geminiController,
                  decoration: InputDecoration(
                    labelText: 'Gemini API Key (Optional)',
                    hintText: 'AIza...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.auto_awesome, color: Colors.blue),
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _safeDialogClose,
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final openAI = openAIController.text.trim();
                    final claude = claudeController.text.trim();
                    final gemini = geminiController.text.trim();

                    if (openAI.isEmpty && claude.isEmpty && gemini.isEmpty) {
                      _showSnackbar(
                        'Error',
                        'Please provide at least one API key',
                        backgroundColor: Colors.red,
                      );
                      return;
                    }

                    _showLoadingDialog();
                    await _storeApiKeys(openAI, claude, gemini);
                    await _safeCloseAllDialogs();
                  },
                  child: Text('Save Keys'),
                ),
              ],
            ),
          ],
        ),
      ),
      barrierDismissible: hasAnyApiKey.value,
    );
  }

  // Dialog utilities
  void _showLoadingDialog() {
    Get.dialog(
      Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Saving API keys...'),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _safeDialogClose() {
    if (Get.isDialogOpen ?? false) Get.back();
  }

  Future<void> _safeCloseAllDialogs() async {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
      await Future.delayed(Duration(milliseconds: 100));
    }
    if (Get.isDialogOpen ?? false) {
      Get.back();
      await Future.delayed(Duration(milliseconds: 100));
    }
    if (Get.isDialogOpen ?? false) Get.back();
  }

  // Add initial greeting message
  void _addWelcomeMessage() {
    messages.clear();
    messages.add(
      ChatMessage(
        content:
            "Hello! I'm your AI assistant using ${_getProviderName(selectedProvider.value)}. How can I help you today?",
        isUser: false,
        timestamp: DateTime.now(),
        aiProvider: selectedProvider.value,
      ),
    );
  }

  // Change selected AI provider
  void changeAIProvider(AIProvider provider) {
    if (!availableProviders.contains(provider)) {
      _showSnackbar(
        'Provider Unavailable',
        'API key for ${_getProviderName(provider)} is not configured.',
        backgroundColor: Colors.orange,
      );
      return;
    }

    selectedProvider.value = provider;
    messages.add(
      ChatMessage(
        content:
            "Switched to ${_getProviderName(provider)}. How can I assist you?",
        isUser: false,
        timestamp: DateTime.now(),
        aiProvider: provider,
      ),
    );
    _scrollToBottom();
  }

  // Get provider name and color
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

  Color get currentProviderColor => _getProviderColor(selectedProvider.value);
  String get currentProviderName => _getProviderName(selectedProvider.value);

  // Send message to selected provider
  void sendMessage() async {
    final messageText = messageController.text.trim();
    if (messageText.isEmpty || isLoading.value) return;

    if (!availableProviders.contains(selectedProvider.value)) {
      _showSnackbar('Error', 'API key not found.', backgroundColor: Colors.red);
      return;
    }

    final apiKey = _getApiKeyForProvider(selectedProvider.value);
    if (apiKey?.isEmpty ?? true) {
      _showSnackbar('Error', 'API key missing.', backgroundColor: Colors.red);
      return;
    }

    messages.add(
      ChatMessage(
        content: messageText,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );
    messageController.clear();
    isLoading.value = true;
    _scrollToBottom();

    try {
      String response;
      switch (selectedProvider.value) {
        case AIProvider.chatGPT:
          response = await _sendToChatGPT(messageText, apiKey!);
          break;
        case AIProvider.claude:
          response = await _sendToClaude(messageText, apiKey!);
          break;
        case AIProvider.gemini:
          response = await _sendToGemini(messageText, apiKey!);
          break;
      }

      messages.add(
        ChatMessage(
          content: response,
          isUser: false,
          timestamp: DateTime.now(),
          aiProvider: selectedProvider.value,
        ),
      );
    } catch (e) {
      messages.add(
        ChatMessage(
          content: "Error: ${e.toString()}",
          isUser: false,
          timestamp: DateTime.now(),
          aiProvider: selectedProvider.value,
        ),
      );
    } finally {
      isLoading.value = false;
      _scrollToBottom();
    }
  }

  String? _getApiKeyForProvider(AIProvider provider) {
    switch (provider) {
      case AIProvider.chatGPT:
        return _openAIKey;
      case AIProvider.claude:
        return _claudeKey;
      case AIProvider.gemini:
        return _geminiKey;
    }
  }

  // API calls for each provider
  Future<String> _sendToChatGPT(String message, String apiKey) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': 'You are a helpful AI assistant...'},
          {'role': 'user', 'content': message},
        ],
        'max_tokens': 500,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['message']['content'].toString().trim();
    } else {
      throw Exception(
        'OpenAI Error: ${json.decode(response.body)['error']['message']}',
      );
    }
  }

  Future<String> _sendToClaude(String message, String apiKey) async {
    final response = await http.post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: json.encode({
        'model': 'claude-3-haiku-20240307',
        'max_tokens': 500,
        'messages': [
          {'role': 'user', 'content': '...User question: $message'},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['content'][0]['text'].toString().trim();
    } else {
      throw Exception(
        'Claude Error: ${json.decode(response.body)['error']['message']}',
      );
    }
  }

  Future<String> _sendToGemini(String message, String apiKey) async {
    final response = await http.post(
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey',
      ),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'contents': [
          {
            'parts': [
              {'text': '...User question: $message'},
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topK': 1,
          'topP': 1,
          'maxOutputTokens': 500,
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text']
          .toString()
          .trim();
    } else {
      throw Exception(
        'Gemini Error: ${json.decode(response.body)['error']['message']}',
      );
    }
  }

  // Scroll to bottom of chat
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Clear entire chat history
  void clearChat() {
    messages.clear();
    _addWelcomeMessage();
  }

  // Delete a specific message by index
  void deleteMessage(int index) {
    if (index >= 0 && index < messages.length) {
      messages.removeAt(index);
    }
  }

  // Show key update dialog
  void showUpdateKeysDialog() {
    _showApiKeySetupDialog();
  }

  // Check if provider is configured
  bool isProviderAvailable(AIProvider provider) {
    return availableProviders.contains(provider);
  }

  // Return available AI providers
  List<AIProvider> getAvailableProviders() {
    return availableProviders.toList();
  }
}
