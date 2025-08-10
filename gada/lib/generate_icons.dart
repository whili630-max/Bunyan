// Generate icons for Bunyan app
// Run with: flutter run -t lib/generate_icons.dart

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

void main() async {
  // Ensure we have a headless Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  // Create the icon colors
  const primaryColor = Color(0xFF2E7D32); // Green color from the theme
  const backgroundColor = Colors.white;
  const textColor = Colors.white;

  // Generate the icons
  await generateIcon(192, primaryColor, backgroundColor, textColor);
  await generateIcon(512, primaryColor, backgroundColor, textColor);

  print('Icons generated successfully!');
  exit(0);
}

Future<void> generateIcon(int size, Color primaryColor, Color backgroundColor,
    Color textColor) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // Draw background
  final bgPaint = Paint()..color = backgroundColor;
  canvas.drawRect(
      Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()), bgPaint);

  // Draw a colored circle
  final circlePaint = Paint()..color = primaryColor;
  canvas.drawCircle(Offset(size / 2, size / 2), size / 2.5, circlePaint);

  // Draw text "ب" (first letter of Bunyan in Arabic)
  final textPainter = TextPainter(
    text: TextSpan(
      text: 'ب',
      style: TextStyle(
        color: textColor,
        fontSize: size / 2,
        fontWeight: FontWeight.bold,
      ),
    ),
    textDirection: TextDirection.rtl,
  );

  textPainter.layout();
  textPainter.paint(
    canvas,
    Offset(
      (size - textPainter.width) / 2,
      (size - textPainter.height) / 2,
    ),
  );

  // Convert to image
  final picture = recorder.endRecording();
  final img = await picture.toImage(size, size);
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  final buffer = byteData!.buffer.asUint8List();

  // Save to file
  final file = File('web/icons/Icon-$size.png');
  await file.writeAsBytes(buffer);
  print('Generated icon: ${file.path}');
}
