import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';

// Add this function to your code to generate simple icons
Future<void> generateSimpleIcons() async {
  // Create a 192x192 icon
  final recorder192 = ui.PictureRecorder();
  final canvas192 = Canvas(recorder192);
  final paint = Paint()..color = Colors.blue;
  
  // Draw a blue square
  canvas192.drawRect(Rect.fromLTWH(0, 0, 192, 192), paint);
  
  // Add text
  final textPainter = TextPainter(
    text: TextSpan(
      text: 'Icon\n192',
      style: TextStyle(color: Colors.white, fontSize: 40),
    ),
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.center,
  );
  textPainter.layout(minWidth: 192);
  textPainter.paint(canvas192, Offset(0, 70));
  
  // Convert to image
  final picture192 = recorder192.endRecording();
  final img192 = await picture192.toImage(192, 192);
  final pngData192 = await img192.toByteData(format: ui.ImageByteFormat.png);
  
  // Save to file
  final directory = await getApplicationDocumentsDirectory();
  File('${directory.path}/Icon-192.png')
    .writeAsBytesSync(pngData192!.buffer.asUint8List());
  
  // Similarly create a 512x512 icon
  // ...

  print('Icons generated at: ${directory.path}');
}
