import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../models/user_stats.dart';
import '../services/database_service.dart';
import '../services/gemini_service.dart';
import 'package:intl/intl.dart'; // Import the intl package for DateFormat

class ChatProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final GeminiService _geminiService = GeminiService();
  List<ChatMessage> _messages = [];
  UserStats? _userStats;
  bool _isLoading = false;
  bool _isTyping = false;
  String? _currentConversationId;
  String? _currentChatTitle;
  String _currentCategory = 'all';
  final Map<String, List<ChatMessage>> _messagesByDate = {};

  List<ChatMessage> get messages => _filterMessages();
  UserStats? get userStats => _userStats;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;
  String? get currentConversationId => _currentConversationId;
  String? get currentChatTitle => _currentChatTitle;
  String get currentCategory => _currentCategory;
  Map<String, List<ChatMessage>> get messagesByDate => _messagesByDate;

  ChatProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadMessages();
    await _loadUserStats();
    await _databaseService.resetDailyStats();
  }

  Future<void> _loadMessages() async {
    _messages = await _databaseService.getMessages();
    _organizeMessagesByDate();
    notifyListeners();
  }

  Future<void> _loadUserStats() async {
    _userStats = await _databaseService.getUserStats();
    notifyListeners();
  }

  List<ChatMessage> _filterMessages() {
    if (_currentCategory == 'favorites') {
      return _messages.where((m) => m.isFavorite).toList();
    }
    return _messages;
  }

  void _organizeMessagesByDate() {
    _messagesByDate.clear();
    for (var message in _messages) {
      final date = DateFormat('MMMM d, yyyy').format(message.timestamp);
      if (!_messagesByDate.containsKey(date)) {
        _messagesByDate[date] = [];
      }
      _messagesByDate[date]!.add(message);
    }
    notifyListeners();
  }

  Future<void> _generateChatTitle(String firstMessage) async {
    if (_currentChatTitle != null) return;
    
    try {
      _currentChatTitle = await _geminiService.generateTitle(firstMessage);
    } catch (e) {
      _currentChatTitle = 'Chat ${DateTime.now().toString().substring(0, 16)}';
    }
    notifyListeners();
  }

  Future<void> startNewChat() async {
    _messages.clear();
    _currentConversationId = DateTime.now().millisecondsSinceEpoch.toString();
    _currentChatTitle = null;
    notifyListeners();
  }

  Future<void> loadConversation(String conversationId) async {
    _currentConversationId = conversationId;
    _messages = await _databaseService.getConversationMessages(conversationId);
    if (_messages.isNotEmpty) {
      _currentChatTitle = _messages.first.chatTitle;
    }
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getConversations() async {
    return _databaseService.getConversations();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Check user stats before proceeding
    if (_userStats == null || _userStats!.points <= 0 || 
        _userStats!.messagesCount >= _userStats!.dailyLimit) {
      _messages.add(ChatMessage(
        text: 'You have reached your daily message limit or have insufficient points.',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
        conversationId: _currentConversationId,
        chatTitle: _currentChatTitle,
      ));
      notifyListeners();
      return;
    }

    _isTyping = true;
    notifyListeners();

    // Start new conversation if needed
    if (_currentConversationId == null) {
      _currentConversationId = DateTime.now().millisecondsSinceEpoch.toString();
    }

    // Add user message
    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      conversationId: _currentConversationId,
      chatTitle: _currentChatTitle,
    );
    
    _messages.add(userMessage);
    await _databaseService.insertMessage(userMessage);

    // Generate title if this is the first message
    if (_currentChatTitle == null) {
      try {
        _currentChatTitle = await _geminiService.generateTitle(text);
        _currentChatTitle = _currentChatTitle?.trim() ?? 'New Chat';
      } catch (e) {
        _currentChatTitle = 'Chat ${DateTime.now().toString().substring(0, 16)}';
      }
    }

    try {
      // Get AI response
      final response = await _geminiService.getResponse(text);
      
      // Update user stats first
      await _updateUserStats();

      final aiMessage = ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
        conversationId: _currentConversationId,
        chatTitle: _currentChatTitle,
      );

      _messages.add(aiMessage);
      await _databaseService.insertMessage(aiMessage);
      
    } catch (e) {
      final errorMessage = ChatMessage(
        text: 'Sorry, I encountered an error: ${e.toString()}. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
        conversationId: _currentConversationId,
        chatTitle: _currentChatTitle,
      );
      _messages.add(errorMessage);
      await _databaseService.insertMessage(errorMessage);
    } finally {
      _isTyping = false;
      _organizeMessagesByDate();
      notifyListeners();
    }
  }

  Future<void> deleteMessage(ChatMessage message) async {
    await _databaseService.deleteMessage(message.id!);
    _messages.removeWhere((m) => m.id == message.id);
    _organizeMessagesByDate();
    notifyListeners();
  }

  Future<void> regenerateResponse(ChatMessage message) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _geminiService.getResponse(message.text);
      final newBotMessage = ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
        conversationId: message.conversationId,
        chatTitle: message.chatTitle,
      );
      await _databaseService.insertMessage(newBotMessage);
      _messages.add(newBotMessage);
      _organizeMessagesByDate();

      // Update user stats
      _userStats = _userStats!.copyWith(
        points: _userStats!.points - 1,
        messagesCount: _userStats!.messagesCount + 1,
      );
      await _databaseService.updateUserStats(_userStats!);
    } catch (e) {
      final errorMessage = ChatMessage(
        text: 'Sorry, I encountered an error. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
        conversationId: message.conversationId,
        chatTitle: message.chatTitle,
      );
      await _databaseService.insertMessage(errorMessage);
      _messages.add(errorMessage);
      _organizeMessagesByDate();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(int messageId) async {
    await _databaseService.toggleFavorite(messageId);
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      _messages[index] = _messages[index].copyWith(
        isFavorite: !_messages[index].isFavorite,
      );
      _organizeMessagesByDate();
      notifyListeners();
    }
  }

  void clearHistory() async {
    _messages.clear();
    _messagesByDate.clear();
    await _databaseService.clearAllMessages();
    notifyListeners();
  }

  Future<void> deleteMessageById(int messageId) async {
    await _databaseService.deleteMessage(messageId);
    _messages.removeWhere((m) => m.id == messageId);
    _organizeMessagesByDate();
    notifyListeners();
  }

  Future<void> resetDaily() async {
    await _databaseService.resetDailyStats();
    await _loadUserStats();
  }

  void setCategory(String category) {
    _currentCategory = category;
    notifyListeners();
  }

  Future<void> _updateUserStats() async {
    _userStats = _userStats!.copyWith(
      points: _userStats!.points - 1,
      messagesCount: _userStats!.messagesCount + 1,
    );
    await _databaseService.updateUserStats(_userStats!);
  }
}
