import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

class PointsIndicator extends StatelessWidget {
  const PointsIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final stats = chatProvider.userStats;
        if (stats == null) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: const Color(0xFF2C3E50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat(
                icon: Icons.stars_rounded,
                label: 'Points',
                value: '${stats.points}',
                color: Colors.amber,
              ),
              Container(
                height: 30,
                width: 1,
                color: Colors.white24,
              ),
              _buildStat(
                icon: Icons.message_rounded,
                label: 'Messages',
                value: '${stats.messagesCount}/${stats.dailyLimit}',
                color: Colors.greenAccent,
              ),
              Container(
                height: 30,
                width: 1,
                color: Colors.white24,
              ),
              _buildStat(
                icon: Icons.timer_rounded,
                label: 'Reset In',
                value: _getTimeUntilReset(DateTime.parse(stats.lastReset)),
                color: Colors.lightBlueAccent,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  String _getTimeUntilReset(DateTime lastReset) {
    final now = DateTime.now();
    final nextReset = lastReset.add(const Duration(hours: 24));
    final difference = nextReset.difference(now);

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    if (hours < 0 || minutes < 0) {
      return '0:00';
    }

    return '$hours:${minutes.toString().padLeft(2, '0')}';
  }
}
