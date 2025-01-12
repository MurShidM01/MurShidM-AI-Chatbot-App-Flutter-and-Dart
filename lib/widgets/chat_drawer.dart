import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/chat_message.dart';
import 'package:intl/intl.dart';

class ChatDrawer extends StatefulWidget {
  const ChatDrawer({super.key});

  @override
  State<ChatDrawer> createState() => _ChatDrawerState();
}

class _ChatDrawerState extends State<ChatDrawer> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _conversations = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final conversations = await chatProvider.getConversations();
    setState(() {
      _conversations = conversations;
    });
  }

  String _generatePreview(String? aiResponses) {
    if (aiResponses == null || aiResponses.isEmpty) return 'No messages';
    final responses = aiResponses.split(',');
    if (responses.isEmpty) return 'No messages';
    final lastResponse = responses.last;
    return lastResponse.length > 60 
        ? '${lastResponse.substring(0, 60)}...' 
        : lastResponse;
  }

  @override
  Widget build(BuildContext context) {
    final filteredConversations = _conversations.where((conv) {
      final title = conv['chatTitle'] as String? ?? '';
      final preview = _generatePreview(conv['aiResponses'] as String?);
      return title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          preview.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Drawer(
      backgroundColor: const Color(0xFF1E293B),
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF2C3E50),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🤖 ',
                        style: TextStyle(fontSize: 24, color: Colors.white)),
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
                const SizedBox(height: 16),
                Consumer<ChatProvider>(
                  builder: (context, chatProvider, child) {
                    return ElevatedButton.icon(
                      onPressed: () async {
                        await chatProvider.startNewChat();
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.add, color: Colors.black),
                      label: Text('New Chat',
                          style: GoogleFonts.poppins(
                              color: Colors.black, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                hintStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.search, color: Colors.white60),
                filled: true,
                fillColor: const Color(0xFF2C3E50),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: filteredConversations.length,
              itemBuilder: (context, index) {
                final conversation = filteredConversations[index];
                final title = conversation['chatTitle'] as String? ?? 'Untitled Chat';
                final preview = _generatePreview(conversation['aiResponses'] as String?);
                final messageCount = conversation['messageCount'] as int;
                final timestamp = DateTime.parse(conversation['lastMessageTimestamp'] as String);
                final formattedDate = DateFormat('MMM d, y').format(timestamp);

                return ListTile(
                  title: Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        preview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '$messageCount messages • $formattedDate',
                        style: GoogleFonts.poppins(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  onTap: () async {
                    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
                    await chatProvider.loadConversation(conversation['conversationId'] as String);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
