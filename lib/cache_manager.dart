import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class CacheManager {
  static const int _maxCacheAge = 7; // أيام
  static const int _maxCacheSize = 100 * 1024 * 1024; // 100 ميجابايت

  static Future<String> getCachePath() async {
    final dir = await getTemporaryDirectory();
    final cachePath = path.join(dir.path, 'bunyan_cache');
    await Directory(cachePath).create(recursive: true);
    return cachePath;
  }

  // حفظ ملف في التخزين المؤقت
  static Future<String> cacheFile(String key, List<int> bytes) async {
    final cachePath = await getCachePath();
    final hash = _generateHash(key);
    final filePath = path.join(cachePath, hash);

    final file = File(filePath);
    await file.writeAsBytes(bytes);

    // تحديث وقت آخر استخدام
    await _updateLastAccessed(hash);

    // تنظيف التخزين المؤقت إذا تجاوز الحجم الأقصى
    await _cleanupIfNeeded();

    return filePath;
  }

  // استرجاع ملف من التخزين المؤقت
  static Future<File?> getCachedFile(String key) async {
    final cachePath = await getCachePath();
    final hash = _generateHash(key);
    final filePath = path.join(cachePath, hash);

    final file = File(filePath);
    if (await file.exists()) {
      // تحديث وقت آخر استخدام
      await _updateLastAccessed(hash);
      return file;
    }
    return null;
  }

  // حذف ملف من التخزين المؤقت
  static Future<void> removeFromCache(String key) async {
    final cachePath = await getCachePath();
    final hash = _generateHash(key);
    final filePath = path.join(cachePath, hash);

    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      await _removeLastAccessed(hash);
    }
  }

  // مسح التخزين المؤقت بالكامل
  static Future<void> clearCache() async {
    final cachePath = await getCachePath();
    final dir = Directory(cachePath);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  // تنظيف الملفات القديمة أو الزائدة عن الحجم المسموح
  static Future<void> _cleanupIfNeeded() async {
    final cachePath = await getCachePath();
    final dir = Directory(cachePath);

    // حساب حجم التخزين المؤقت الحالي
    int totalSize = 0;
    final List<FileSystemEntity> files = await dir.list().toList();
    for (var file in files) {
      if (file is File) {
        totalSize += await file.length();
      }
    }

    // إذا تجاوز الحجم الأقصى، احذف الملفات القديمة
    if (totalSize > _maxCacheSize) {
      final lastAccessedMap = await _getLastAccessedTimes();
      final sortedFiles = lastAccessedMap.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));

      for (var entry in sortedFiles) {
        if (totalSize <= _maxCacheSize) break;

        final file = File(path.join(cachePath, entry.key));
        if (await file.exists()) {
          totalSize -= await file.length();
          await file.delete();
          await _removeLastAccessed(entry.key);
        }
      }
    }

    // حذف الملفات القديمة
    final now = DateTime.now();
    final lastAccessedMap = await _getLastAccessedTimes();
    for (var entry in lastAccessedMap.entries) {
      if (now.difference(entry.value).inDays > _maxCacheAge) {
        final file = File(path.join(cachePath, entry.key));
        if (await file.exists()) {
          await file.delete();
          await _removeLastAccessed(entry.key);
        }
      }
    }
  }

  // توليد هاش للمفتاح
  static String _generateHash(String key) {
    final bytes = utf8.encode(key);
    return sha256.convert(bytes).toString();
  }

  // تحديث وقت آخر استخدام للملف
  static Future<void> _updateLastAccessed(String hash) async {
    final lastAccessedFile = await _getLastAccessedFile();
    final Map<String, dynamic> lastAccessed = await _getLastAccessedTimes();
    lastAccessed[hash] = DateTime.now().toIso8601String();
    await lastAccessedFile.writeAsString(jsonEncode(lastAccessed));
  }

  // حذف سجل آخر استخدام للملف
  static Future<void> _removeLastAccessed(String hash) async {
    final lastAccessedFile = await _getLastAccessedFile();
    final Map<String, dynamic> lastAccessed = await _getLastAccessedTimes();
    lastAccessed.remove(hash);
    await lastAccessedFile.writeAsString(jsonEncode(lastAccessed));
  }

  // الحصول على ملف سجل أوقات آخر استخدام
  static Future<File> _getLastAccessedFile() async {
    final cachePath = await getCachePath();
    return File(path.join(cachePath, 'last_accessed.json'));
  }

  // الحصول على قائمة أوقات آخر استخدام
  static Future<Map<String, DateTime>> _getLastAccessedTimes() async {
    final file = await _getLastAccessedFile();
    if (!await file.exists()) {
      return {};
    }

    final content = await file.readAsString();
    final Map<String, dynamic> data = jsonDecode(content);
    return data
        .map((key, value) => MapEntry(key, DateTime.parse(value.toString())));
  }
}
