import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Animation<double>> _animations = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Create three dot animations with different delays
    for (int i = 0; i < 3; i++) {
      _animations.add(
        Tween<double>(begin: 0, end: 6).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              i * 0.2,
              0.6 + i * 0.2,
              curve: Curves.easeInOut,
            ),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 16.0, right: 8.0),
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
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            margin: const EdgeInsets.only(right: 50.0, bottom: 4.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Thinking',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                ...List.generate(3, (index) => _buildDot(_animations[index])),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDot(Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(2),
          ),
          transform: Matrix4.translationValues(0, -animation.value, 0),
        );
      },
    );
  }
}
