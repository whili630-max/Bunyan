// Run: dart run tool/generate_icons_image.dart
// Generates proper PNG icons (192,512) into web/icons/

import 'dart:io';
import 'package:image/image.dart' as img;

const green = 0xFF2E7D32; // primary color

void main() {
  _gen(192);
  _gen(512);
  print('Icons generated.');
}

void _gen(int size) {
  final canvas = img.Image(width: size, height: size); // blank
  // Fill background white
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      canvas.setPixelRgba(x, y, 255, 255, 255, 255);
    }
  }
  // Draw green circle
  final radius = (size * 0.42).toInt();
  final r2 = radius * radius;
  final cx = size ~/ 2;
  final cy = size ~/ 2;
  for (int y = -radius; y <= radius; y++) {
    for (int x = -radius; x <= radius; x++) {
      if (x * x + y * y <= r2) {
        canvas.setPixelRgba(cx + x, cy + y, 0x2E, 0x7D, 0x32, 255);
      }
    }
  }
  // Placeholder glyph block (center white square)
  final glyphSize = (size * 0.28).toInt();
  for (int y = -glyphSize; y <= glyphSize; y++) {
    for (int x = -glyphSize; x <= glyphSize; x++) {
      canvas.setPixelRgba(cx + x, cy + y, 255, 255, 255, 255);
    }
  }
  print('Placed placeholder glyph block at size $size');
  final outDir = Directory('web/icons');
  outDir.createSync(recursive: true);
  final file = File('web/icons/Icon-$size.png');
  file.writeAsBytesSync(img.encodePng(canvas));
  print('Wrote ' + file.path + ' (' + file.lengthSync().toString() + ' bytes)');
}
