import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/points_indicator.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/chat_drawer.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2C3E50),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🤖 '), // Robot emoji
            Text(
              'MurShidM AI',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color(0xFF2C3E50),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.all_inbox, color: Colors.white),
                    SizedBox(width: 8),
                    Text('📥 All Messages', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'favorites',
                child: Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.white),
                    SizedBox(width: 8),
                    Text('⭐ Favorites', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.white),
                    SizedBox(width: 8),
                    Text('🗑️ Clear History', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'about',
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.white),
                    SizedBox(width: 8),
                    Text('ℹ️ About', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              final chatProvider = context.read<ChatProvider>();
              switch (value) {
                case 'favorites':
                  chatProvider.setCategory('favorites');
                  break;
                case 'all':
                  chatProvider.setCategory('all');
                  break;
                case 'clear':
                  await _showClearHistoryDialog();
                  break;
                case 'about':
                  await _showAboutDialog();
                  break;
              }
            },
          ),
        ],
      ),
      drawer: const ChatDrawer(),
      backgroundColor: const Color(0xFF1E293B),
      body: Column(
        children: [
          const PointsIndicator(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
                ),
              ),
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  if (chatProvider.messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '👋',
                            style: TextStyle(fontSize: 48),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Start a conversation!',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true, // Show newest messages at the bottom
                    itemCount: chatProvider.messages.length + (chatProvider.isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (chatProvider.isTyping && index == 0) {
                        return const TypingIndicator();
                      }
                      final adjustedIndex = chatProvider.isTyping ? index - 1 : index;
                      final reversedIndex = chatProvider.messages.length - 1 - adjustedIndex;
                      final message = chatProvider.messages[reversedIndex];
                      final showDate = reversedIndex == 0 ||
                          message.formattedDate !=
                              chatProvider.messages[reversedIndex - 1].formattedDate;
                      return MessageBubble(
                        message: message,
                        showDate: showDate,
                      );
                    },
                  );
                },
              ),
            ),
          ),
          _buildTextComposer(),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2C3E50),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type a message... 💭',
                hintStyle: GoogleFonts.poppins(color: Colors.white70),
                border: InputBorder.none,
              ),
              onSubmitted: _handleSubmitted,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: () => _handleSubmitted(_textController.text),
          ),
        ],
      ),
    );
  }

  Future<void> _showClearHistoryDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C3E50),
        title: const Text('🗑️ Clear History', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to clear all chat history?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              context.read<ChatProvider>().clearHistory();
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _showAboutDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C3E50),
        title: const Row(
          children: [
            Text('🤖 About', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAboutSection(
                '🎯 Purpose',
                'Your personal AI assistant for coding, learning, and problem-solving.',
              ),
              const SizedBox(height: 16),
              _buildAboutSection(
                '🔋 Daily Points',
                'Start with 100 points each day. Each message costs points.',
              ),
              const SizedBox(height: 16),
              _buildAboutSection(
                '⭐ Features',
                '• Favorite messages for quick access\n'
                '• Copy and regenerate responses\n'
                '• Daily message limits\n'
                '• Smart conversation history',
              ),
              const SizedBox(height: 16),
              _buildAboutSection(
                '🛠️ Powered By',
                'Google Gemini AI\n'
                'Flutter & Dart',
              ),
              const SizedBox(height: 16),
              _buildAboutSection(
                '👨‍💻 Developer',
                'Developed by Ali Khan Jalbani \n'
                'Version 1.0.0',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    _textController.clear();
    context.read<ChatProvider>().sendMessage(text);
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
}
