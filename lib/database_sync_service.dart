import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'notification_manager.dart';

class DatabaseSyncService extends ChangeNotifier {
  late Database _localDb;
  final NotificationManager _notificationManager;
  Timer? _syncTimer;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  DatabaseSyncService({required NotificationManager notificationManager})
      : _notificationManager = notificationManager;

  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;

  // تهيئة قاعدة البيانات المحلية
  Future<void> initialize() async {
    // فتح قاعدة البيانات المحلية
    _localDb = await openDatabase(
      join(await getDatabasesPath(), 'bunyan_local.db'),
      version: 1,
      onCreate: (db, version) async {
        // إنشاء الجداول اللازمة
        await _createTables(db);
      },
    );

    // بدء المزامنة التلقائية كل 15 دقيقة
    _startAutoSync();
  }

  // إنشاء جداول قاعدة البيانات
  Future<void> _createTables(Database db) async {
    // جدول المستخدمين
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone TEXT,
        type TEXT NOT NULL,
        institution TEXT,
        created_at TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        verified INTEGER NOT NULL DEFAULT 0,
        phone_verified INTEGER NOT NULL DEFAULT 0,
        last_sync TEXT
      )
    ''');

    // جدول البيانات المشفرة
    await db.execute('''
      CREATE TABLE encrypted_data (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        data_type TEXT NOT NULL,
        encrypted_value TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // جدول سجل المزامنة
    await db.execute('''
      CREATE TABLE sync_log (
        id TEXT PRIMARY KEY,
        operation TEXT NOT NULL,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        status TEXT NOT NULL,
        error TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // بدء المزامنة التلقائية
  void _startAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      synchronize();
    });
  }

  // إيقاف المزامنة التلقائية
  void stopAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  // مزامنة يدوية
  Future<void> synchronize() async {
    if (_isSyncing) return;

    try {
      _isSyncing = true;
      notifyListeners();

      // التحقق من الاتصال بالإنترنت
      if (!await _checkConnectivity()) {
        throw Exception('لا يوجد اتصال بالإنترنت');
      }

      // الحصول على التغييرات المحلية غير المتزامنة
      final unsynced = await _getUnsyncedChanges();

      // رفع التغييرات المحلية إلى الخادم
      if (unsynced.isNotEmpty) {
        await _pushLocalChanges(unsynced);
      }

      // جلب التغييرات من الخادم
      await _pullRemoteChanges();

      _lastSyncTime = DateTime.now();
      await _updateLastSyncTime();

      _notificationManager.addNotification(
        BunyanNotification.createSuccess(
          title: 'اكتملت المزامنة',
          message: 'تم مزامنة البيانات بنجاح',
        ),
      );
    } catch (e) {
      _notificationManager.addNotification(
        BunyanNotification.createError(
          title: 'خطأ في المزامنة',
          message: e.toString(),
        ),
      );
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // التحقق من الاتصال بالإنترنت
  Future<bool> _checkConnectivity() async {
    // TODO: تنفيذ التحقق من الاتصال
    return true;
  }

  // الحصول على التغييرات المحلية غير المتزامنة
  Future<List<Map<String, dynamic>>> _getUnsyncedChanges() async {
    final unsynced = await _localDb.query(
      'sync_log',
      where: 'status = ?',
      whereArgs: ['pending'],
    );
    return unsynced;
  }

  // رفع التغييرات المحلية إلى الخادم
  Future<void> _pushLocalChanges(List<Map<String, dynamic>> changes) async {
    for (final change in changes) {
      try {
        // TODO: تنفيذ رفع التغييرات إلى الخادم
        await _markChangeAsSynced(change['id']);
      } catch (e) {
        await _markChangeAsFailed(change['id'], e.toString());
        throw Exception('فشل في مزامنة بعض التغييرات');
      }
    }
  }

  // جلب التغييرات من الخادم
  Future<void> _pullRemoteChanges() async {
    // TODO: تنفيذ جلب التغييرات من الخادم
  }

  // تحديث وقت آخر مزامنة
  Future<void> _updateLastSyncTime() async {
    await _localDb.update(
      'users',
      {'last_sync': _lastSyncTime!.toIso8601String()},
      where: 'id = ?',
      whereArgs: [1], // TODO: استخدام معرف المستخدم الحالي
    );
  }

  // تحديث حالة التغيير إلى "متزامن"
  Future<void> _markChangeAsSynced(String changeId) async {
    await _localDb.update(
      'sync_log',
      {
        'status': 'synced',
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [changeId],
    );
  }

  // تحديث حالة التغيير إلى "فشل"
  Future<void> _markChangeAsFailed(String changeId, String error) async {
    await _localDb.update(
      'sync_log',
      {
        'status': 'failed',
        'error': error,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [changeId],
    );
  }

  // إغلاق قاعدة البيانات والمزامنة
  @override
  Future<void> dispose() async {
    _syncTimer?.cancel();
    await _localDb.close();
    super.dispose();
  }
}
