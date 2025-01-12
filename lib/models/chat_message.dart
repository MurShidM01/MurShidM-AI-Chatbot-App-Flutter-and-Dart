import 'package:intl/intl.dart';

class ChatMessage {
  final int? id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isFavorite;
  final String? category;
  final bool isError;
  final String? chatTitle;  // Added for grouping messages
  final String? conversationId;  // Added to group messages together

  ChatMessage({
    this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isFavorite = false,
    this.category,
    this.isError = false,
    this.chatTitle,
    this.conversationId,
  });

  ChatMessage copyWith({
    int? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    bool? isFavorite,
    String? category,
    bool? isError,
    String? chatTitle,
    String? conversationId,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      isFavorite: isFavorite ?? this.isFavorite,
      category: category ?? this.category,
      isError: isError ?? this.isError,
      chatTitle: chatTitle ?? this.chatTitle,
      conversationId: conversationId ?? this.conversationId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
      'isFavorite': isFavorite ? 1 : 0,
      'category': category,
      'isError': isError ? 1 : 0,
      'chatTitle': chatTitle,
      'conversationId': conversationId,
    };
  }

  static ChatMessage fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as int?,
      text: map['text'] as String,
      isUser: map['isUser'] == 1,
      timestamp: DateTime.parse(map['timestamp'] as String),
      isFavorite: map['isFavorite'] == 1,
      category: map['category'] as String?,
      isError: map['isError'] == 1,
      chatTitle: map['chatTitle'] as String?,
      conversationId: map['conversationId'] as String?,
    );
  }

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return DateFormat('HH:mm').format(timestamp);
    } else if (difference.inDays < 7) {
      return DateFormat('E HH:mm').format(timestamp);
    } else {
      return DateFormat('MMM d, HH:mm').format(timestamp);
    }
  }

  String get formattedDate {
    final now = DateTime.now();
    if (timestamp.year == now.year && 
        timestamp.month == now.month && 
        timestamp.day == now.day) {
      return 'Today';
    } else if (timestamp.year == now.year && 
               timestamp.month == now.month && 
               timestamp.day == now.day - 1) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d, yyyy').format(timestamp);
    }
  }
}
