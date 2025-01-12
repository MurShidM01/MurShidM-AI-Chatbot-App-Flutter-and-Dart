import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

Future<void> generateAppIcon() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = const Size(1024, 1024);
  
  // Draw background
  final paint = Paint()..color = const Color(0xFF2C3E50);
  canvas.drawRect(Offset.zero & size, paint);
  
  // Draw text
  const text = '🤖\nMurShidM\nAI';
  final textPainter = TextPainter(
    text: TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 120,
        fontWeight: FontWeight.bold,
      ),
    ),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  );
  
  textPainter.layout(maxWidth: size.width);
  textPainter.paint(
    canvas,
    Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    ),
  );
  
  final picture = recorder.endRecording();
  final img = await picture.toImage(size.width.toInt(), size.height.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  final buffer = byteData!.buffer.asUint8List();
  
  // Save the image
  final iconFile = File('assets/images/app_icon.png');
  await iconFile.parent.create(recursive: true);
  await iconFile.writeAsBytes(buffer);
  
  // Copy for foreground
  final foregroundFile = File('assets/images/app_icon_foreground.png');
  await foregroundFile.writeAsBytes(buffer);
}
