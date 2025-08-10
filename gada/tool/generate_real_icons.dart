import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _makeIcon(192);
  await _makeIcon(512);
  print('Icons generated');
}

Future<void> _makeIcon(int size) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final rect = Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble());
  final bg = Paint()..color = const Color(0xFFFFFFFF);
  canvas.drawRect(rect, bg);
  final circle = Paint()..color = const Color(0xFF2E7D32);
  canvas.drawCircle(Offset(size / 2, size / 2), size * 0.42, circle);
  final paragraphBuilder = ui.ParagraphBuilder(
    ui.ParagraphStyle(
        textAlign: TextAlign.center,
        fontSize: size * 0.50,
        fontFamily: 'Arial'),
  )
    ..pushStyle(ui.TextStyle(
        color: const Color(0xFFFFFFFF), fontWeight: ui.FontWeight.w700))
    ..addText('ب');
  final paragraph = paragraphBuilder.build()
    ..layout(ui.ParagraphConstraints(width: size.toDouble()));
  canvas.drawParagraph(paragraph, Offset(0, (size - paragraph.height) / 2));
  final picture = recorder.endRecording();
  final image = await picture.toImage(size, size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final outPath = 'web/icons/Icon-$size.png';
  await File(outPath).writeAsBytes(bytes!.buffer.asUint8List());
  print('Wrote $outPath');
}
