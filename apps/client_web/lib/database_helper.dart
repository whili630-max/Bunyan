import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'models.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  void _log(String message) {
    if (kDebugMode) {
      print(message);
    }
  }

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'bunyan.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // جدول المستخدمين
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone TEXT,
        password TEXT NOT NULL,
        user_type TEXT NOT NULL CHECK (user_type IN ('client', 'supplier', 'admin')),
        institution TEXT,
        created_at TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        verified INTEGER DEFAULT 0,
        phone_verified INTEGER DEFAULT 0,
        last_login TEXT,
        profile_image TEXT,
        encrypted_data TEXT,
        access_token TEXT,
        permissions TEXT
      )
    ''');

    // جدول المنتجات
    await db.execute('''
      CREATE TABLE products(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        category TEXT,
        quantity INTEGER DEFAULT 0,
        is_available INTEGER DEFAULT 1,
        supplier_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        image_path TEXT,
        FOREIGN KEY (supplier_id) REFERENCES users (id)
      )
    ''');

    // جدول الجلسات
    await db.execute('''
      CREATE TABLE sessions(
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        token TEXT UNIQUE NOT NULL,
        created_at TEXT NOT NULL,
        expires_at TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // جدول السجلات (للمراجعة)
    await db.execute('''
      CREATE TABLE audit_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        action TEXT NOT NULL,
        table_name TEXT NOT NULL,
        record_id TEXT,
        old_values TEXT,
        new_values TEXT,
        timestamp TEXT NOT NULL,
        ip_address TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // إنشاء مدير افتراضي
    await _createDefaultAdmin(db);
  }

  Future<void> _createDefaultAdmin(Database db) async {
    final adminExists = await db.query(
      'users',
      where: 'user_type = ? AND email = ?',
      whereArgs: ['admin', 'admin@bunyan.com'],
    );

    if (adminExists.isEmpty) {
      final adminId = DateTime.now().millisecondsSinceEpoch.toString();
      final hashedPassword = _hashPassword('admin123');

      await db.insert('users', {
        'id': adminId,
        'name': 'مدير النظام',
        'email': 'admin@bunyan.com',
        'password': hashedPassword,
        'user_type': 'admin',
        'created_at': DateTime.now().toIso8601String(),
        'is_active': 1,
      });

      debugPrint('تم إنشاء حساب المدير الافتراضي:');
      debugPrint('البريد الإلكتروني: admin@bunyan.com');
      debugPrint('كلمة المرور: admin123');
    }
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode('${password}bunyan_salt');
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // تسجيل المستخدمين
  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    required String userType,
    String? institution,
  }) async {
    try {
      final db = await database;

      // التحقق من وجود البريد الإلكتروني
      final existingUser = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (existingUser.isNotEmpty) {
        return {
          'success': false,
          'message': 'هذا البريد الإلكتروني مستخدم بالفعل',
        };
      }

      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      final hashedPassword = _hashPassword(password);

      await db.insert('users', {
        'id': userId,
        'name': name,
        'email': email,
        'password': hashedPassword,
        'user_type': userType,
        'institution': institution,
        'created_at': DateTime.now().toIso8601String(),
        'is_active': 1,
      });

      // تسجيل العملية في السجل
      await _logAction(userId, 'CREATE', 'users', userId, null, {
        'name': name,
        'email': email,
        'user_type': userType,
      });

      return {
        'success': true,
        'message': 'تم التسجيل بنجاح',
        'user_id': userId,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ أثناء التسجيل: ${e.toString()}',
      };
    }
  }

  // الحصول على مستخدم بواسطة البريد الإلكتروني
  Future<User?> getUserByEmail(String email) async {
    try {
      final db = await database;
      final results = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (results.isEmpty) {
        return null;
      }

      return User.fromMap(results.first);
    } catch (e) {
      debugPrint('خطأ في الحصول على المستخدم بالبريد الإلكتروني: $e');
      return null;
    }
  }

  // تحديث حالة التحقق للمستخدم (الطريقة القديمة للتوافق)
  Future<bool> updateUserVerificationStatus(
      String userId, bool verified) async {
    return await updateUserVerification(userId, verified, 'email');
  }

  // تحديث حالة التحقق للمستخدم (طريقة محسنة تدعم البريد الإلكتروني والهاتف)
  Future<bool> updateUserVerification(
      String userId, bool verified, String verificationType) async {
    try {
      final db = await database;

      // تحديد العمود المطلوب تحديثه بناءً على نوع التحقق
      String column =
          verificationType == 'email' ? 'verified' : 'phone_verified';

      await db.update(
        'users',
        {column: verified ? 1 : 0},
        where: 'id = ?',
        whereArgs: [userId],
      );

      // تسجيل العملية في السجل
      await _logAction(
        userId,
        'UPDATE',
        'users',
        userId,
        {
          'verification_type': verificationType,
          'status': verified ? 'verified' : 'unverified'
        },
        {
          'verification_type': verificationType,
          'status': verified ? 'verified' : 'unverified'
        },
      );

      return true;
    } catch (e) {
      _log('خطأ في تحديث حالة التحقق: $e');
      return false;
    }
  }

  // تسجيل الدخول
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final db = await database;
      final hashedPassword = _hashPassword(password);

      final users = await db.query(
        'users',
        where: 'email = ? AND password = ? AND is_active = 1',
        whereArgs: [email, hashedPassword],
      );

      if (users.isEmpty) {
        return {
          'success': false,
          'message': 'بيانات الدخول غير صحيحة',
        };
      }

      final user = users.first;
      final sessionToken = _generateToken();
      final sessionId = DateTime.now().millisecondsSinceEpoch.toString();

      // إنشاء جلسة جديدة
      await db.insert('sessions', {
        'id': sessionId,
        'user_id': user['id'],
        'token': sessionToken,
        'created_at': DateTime.now().toIso8601String(),
        'expires_at':
            DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        'is_active': 1,
      });

      // تحديث آخر تسجيل دخول
      await db.update(
        'users',
        {'last_login': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [user['id']],
      );

      // تسجيل العملية
      await _logAction(
          user['id'].toString(), 'LOGIN', 'sessions', sessionId, null, {
        'session_token': sessionToken,
      });

      return {
        'success': true,
        'message': 'تم تسجيل الدخول بنجاح',
        'user': User.fromMap(user),
        'session_token': sessionToken,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ أثناء تسجيل الدخول: ${e.toString()}',
      };
    }
  }

  String _generateToken() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final random = (now * 1000 + (now % 1000)).toString();
    var bytes = utf8.encode('${random}bunyan_session');
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // التحقق من صحة الجلسة
  Future<User?> validateSession(String token) async {
    try {
      final db = await database;
      final sessions = await db.rawQuery('''
        SELECT u.* FROM users u
        INNER JOIN sessions s ON u.id = s.user_id
        WHERE s.token = ? AND s.is_active = 1 AND s.expires_at > ?
      ''', [token, DateTime.now().toIso8601String()]);

      if (sessions.isNotEmpty) {
        return User.fromMap(sessions.first);
      }
      return null;
    } catch (e) {
      debugPrint('خطأ في التحقق من الجلسة: ${e.toString()}');
      return null;
    }
  }

  // تسجيل الخروج
  Future<bool> logout(String token) async {
    try {
      final db = await database;
      await db.update(
        'sessions',
        {'is_active': 0},
        where: 'token = ?',
        whereArgs: [token],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // إدارة المنتجات
  Future<String> addProduct(Product product) async {
    final db = await database;
    final productId = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now().toIso8601String();

    await db.insert('products', {
      'id': productId,
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'category': product.category,
      'quantity': product.quantity,
      'is_available': product.isAvailable ? 1 : 0,
      'supplier_id': product.supplierId,
      'created_at': now,
      'updated_at': now,
      'image_path': product.imagePath,
    });

    // تسجيل العملية
    await _logAction(
        product.supplierId, 'CREATE', 'products', productId, null, {
      'name': product.name,
      'price': product.price,
    });

    return productId;
  }

  Future<List<Product>> getProductsBySupplier(String supplierId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'supplier_id = ?',
      whereArgs: [supplierId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'is_available = 1',
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<void> updateProduct(Product product) async {
    final db = await database;
    await db.update(
      'products',
      {
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'category': product.category,
        'quantity': product.quantity,
        'is_available': product.isAvailable ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
        'image_path': product.imagePath,
      },
      where: 'id = ?',
      whereArgs: [product.id],
    );

    // تسجيل العملية
    await _logAction(
        product.supplierId, 'UPDATE', 'products', product.id, null, {
      'name': product.name,
      'price': product.price,
    });
  }

  Future<void> deleteProduct(String productId, String supplierId) async {
    final db = await database;
    await db.delete(
      'products',
      where: 'id = ? AND supplier_id = ?',
      whereArgs: [productId, supplierId],
    );

    // تسجيل العملية
    await _logAction(supplierId, 'DELETE', 'products', productId, null, null);
  }

  // تسجيل العمليات
  Future<void> _logAction(
    String userId,
    String action,
    String tableName,
    String? recordId,
    Map<String, dynamic>? oldValues,
    Map<String, dynamic>? newValues,
  ) async {
    try {
      final db = await database;
      await db.insert('audit_logs', {
        'user_id': userId,
        'action': action,
        'table_name': tableName,
        'record_id': recordId,
        'old_values': oldValues != null ? jsonEncode(oldValues) : null,
        'new_values': newValues != null ? jsonEncode(newValues) : null,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('خطأ في تسجيل العملية: ${e.toString()}');
    }
  }

  // إحصائيات للمدير
  Future<Map<String, int>> getStatistics() async {
    final db = await database;

    final userCounts = await db.rawQuery('''
      SELECT user_type, COUNT(*) as count 
      FROM users 
      WHERE is_active = 1 
      GROUP BY user_type
    ''');

    final productCount = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM products WHERE is_available = 1')) ??
        0;

    final activeSessionsCount = Sqflite.firstIntValue(await db.rawQuery('''
        SELECT COUNT(*) FROM sessions 
        WHERE is_active = 1 AND expires_at > ?
      ''', [DateTime.now().toIso8601String()])) ?? 0;

    Map<String, int> stats = {
      'products': productCount,
      'active_sessions': activeSessionsCount,
      'clients': 0,
      'suppliers': 0,
      'admins': 0,
    };

    for (var row in userCounts) {
      final userType = row['user_type']?.toString() ?? '';
      final count = row['count'] as int? ?? 0;
      stats['${userType}s'] = count;
    }

    return stats;
  }

  // إغلاق قاعدة البيانات
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
