// توليد أيقونات PWA بحرف "ب" باستخدام حزمة image (لا يعتمد على Flutter UI)
// التشغيل: dart run lib/generate_icons.dart

import 'dart:io';
import 'package:image/image.dart' as img;

// ألوان بنمط ARGB (int)
final primaryColor = img.ColorInt16.rgba(0x2E, 0x7D, 0x32, 0xFF); // أخضر
final backgroundColor = img.ColorInt16.rgba(0xFF, 0xFF, 0xFF, 0xFF); // أبيض
final textColor = img.ColorInt16.rgba(0xFF, 0xFF, 0xFF, 0xFF); // أبيض للنص داخل الدائرة

Future<void> main() async {
  for (final size in [192, 512]) {
    final i = _buildIcon(size);
    final file = File('web/icons/Icon-$size.png');
    await file.writeAsBytes(img.encodePng(i));
    stdout.writeln('Generated ${file.path} (${file.lengthSync()} bytes)');
  }
  stdout.writeln('Icons regenerated successfully.');
}

img.Image _buildIcon(int size) {
  final canvas = img.Image(width: size, height: size);
  // خلفية
  img.fill(canvas, color: backgroundColor);

  // دائرة ملونة مع ظل خفيف
  final radius = (size * 0.38).toInt();
  final cx = size ~/ 2;
  final cy = size ~/ 2;
  // ظل
  img.drawCircle(canvas,
      x: cx + (size * 0.03).toInt(),
      y: cy + (size * 0.03).toInt(),
      radius: radius,
  color: img.ColorInt16.rgba(0x00, 0x00, 0x00, 0x22)); // ظل شفاف
  // دائرة أصلية
  img.drawCircle(canvas,
  x: cx, y: cy, radius: radius, color: primaryColor, antialias: true);

  // حرف "ب" باستخدام فونت system fallback (حزمة image لا ترسم نصاً عربياً معقداً؛ نستخدم مساراً بدائياً) => سنرسم شكل بسيط
  // بديل: رسم شكل هندسي يمثل الحرف.
  final letterSize = (radius * 1.2).toInt();
  _drawArabicB(canvas, cx, cy, letterSize);
  return canvas;
}

void _drawArabicB(img.Image dst, int cx, int cy, int size) {
  // رسم شكل تقريبي لحرف "ب": نصف دائرة + نقطة
  final stroke = (size * 0.12).toInt();
  final r = size ~/ 2;
  // لا حاجة لمتغير لون إضافي
  // إطار نصف دائرة (نستخدم عدة دوائر متراكبة لمحاكاة سمك الخط)
  for (int s = 0; s < stroke; s++) {
  img.drawCircle(dst,
    x: cx, y: cy, radius: r - s, color: textColor, antialias: true);
  }
  // مسح النصف العلوي تقريباً لخلق شكل نصف دائرة
  final cutHeight = (r * 0.6).toInt();
  for (int y = cy - r; y < cy - r + cutHeight; y++) {
    if (y < 0 || y >= dst.height) continue;
    for (int x = cx - r; x <= cx + r; x++) {
      if (x < 0 || x >= dst.width) continue;
  dst.setPixel(x, y, backgroundColor);
    }
  }
  // نقطة الحرف أسفل اليمين
  final dotR = (stroke * 0.9).toInt();
  img.drawCircle(dst,
      x: cx + r ~/ 3,
      y: cy + r ~/ 2,
      radius: dotR,
  color: textColor,
      antialias: true);
}
