import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/chat_message.dart';
import '../providers/chat_provider.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showDate;

  const MessageBubble({
    super.key,
    required this.message,
    this.showDate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showDate)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              message.formattedDate,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment:
                message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!message.isUser)
                Container(
                  margin: const EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFF3498DB),
                    child: Icon(
                      Icons.assistant,
                      size: 18,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
              Flexible(
                child: GestureDetector(
                  onLongPress: () => _showMessageOptions(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    margin: EdgeInsets.only(
                      left: message.isUser ? 50.0 : 0.0,
                      right: message.isUser ? 0.0 : 50.0,
                    ),
                    decoration: BoxDecoration(
                      color: message.isUser
                          ? const Color(0xFF3498DB)
                          : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.text,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              message.formattedTime,
                              style: GoogleFonts.poppins(
                                color: Colors.white60,
                                fontSize: 10,
                              ),
                            ),
                            if (message.isFavorite)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Icon(
                                  Icons.favorite,
                                  color: Colors.red.withOpacity(0.7),
                                  size: 12,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (message.isUser)
                Container(
                  margin: const EdgeInsets.only(left: 8.0),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFF3498DB),
                    child: Icon(
                      Icons.person,
                      size: 18,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _showMessageOptions(BuildContext context) {
    final chatProvider = context.read<ChatProvider>();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C3E50),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy, color: Colors.white),
              title: Text(
                'Copy Message',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              onTap: () {
                Clipboard.setData(ClipboardData(text: message.text));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Message copied to clipboard',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: const Color(0xFF3498DB),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                message.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.white,
              ),
              title: Text(
                message.isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              onTap: () {
                if (message.id != null) {
                  chatProvider.toggleFavorite(message.id!);
                }
                Navigator.pop(context);
              },
            ),
            if (!message.isUser)
              ListTile(
                leading: const Icon(Icons.refresh, color: Colors.white),
                title: Text(
                  'Regenerate Response',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                onTap: () {
                  chatProvider.regenerateResponse(message);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }
}
