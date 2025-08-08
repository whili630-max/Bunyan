import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'bunyan_models.dart';

class BunyanDatabaseHelper {
  static final BunyanDatabaseHelper _instance = BunyanDatabaseHelper._internal();
  factory BunyanDatabaseHelper() => _instance;
  BunyanDatabaseHelper._internal();

  void _log(String message) {
    if (kDebugMode) {
      print(message);
    }
  }

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
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    // جدول المستخدمين
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone TEXT NOT NULL,
        role TEXT NOT NULL,
        company_name TEXT,
        address TEXT,
        city TEXT,
        profile_image TEXT,
        specializations TEXT,
        rating REAL DEFAULT 0.0,
        reviews_count INTEGER DEFAULT 0,
        is_verified INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        last_login TEXT
      )
    ''');

    // جدول المنتجات
    await db.execute('''
      CREATE TABLE products(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        category TEXT NOT NULL,
        unit TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        is_available INTEGER DEFAULT 1,
        supplier_id TEXT NOT NULL,
        image_url TEXT,
        requires_transport INTEGER DEFAULT 0,
        weight REAL,
        specifications TEXT,
        brand TEXT,
        commission_rate REAL DEFAULT 0.05,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (supplier_id) REFERENCES users (id)
      )
    ''');

    // جدول الطلبات
    await db.execute('''
      CREATE TABLE orders(
        id TEXT PRIMARY KEY,
        client_id TEXT NOT NULL,
        supplier_id TEXT NOT NULL,
        transporter_id TEXT,
        items TEXT NOT NULL,
        total_amount REAL NOT NULL,
        commission_amount REAL NOT NULL,
        status TEXT NOT NULL,
        delivery_address TEXT NOT NULL,
        notes TEXT,
        requested_delivery_date TEXT NOT NULL,
        needs_transport INTEGER DEFAULT 0,
        transport_fee REAL,
        payment_method TEXT,
        is_paid INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        accepted_at TEXT,
        completed_at TEXT,
        FOREIGN KEY (client_id) REFERENCES users (id),
        FOREIGN KEY (supplier_id) REFERENCES users (id),
        FOREIGN KEY (transporter_id) REFERENCES users (id)
      )
    ''');

    // جدول طلبات النقل
    await db.execute('''
      CREATE TABLE transport_requests(
        id TEXT PRIMARY KEY,
        order_id TEXT NOT NULL,
        client_id TEXT NOT NULL,
        transporter_id TEXT,
        pickup_address TEXT NOT NULL,
        delivery_address TEXT NOT NULL,
        estimated_weight REAL NOT NULL,
        vehicle_type TEXT NOT NULL,
        quoted_price REAL,
        status TEXT NOT NULL,
        requested_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders (id),
        FOREIGN KEY (client_id) REFERENCES users (id),
        FOREIGN KEY (transporter_id) REFERENCES users (id)
      )
    ''');

    // جدول التقييمات
    await db.execute('''
      CREATE TABLE ratings(
        id TEXT PRIMARY KEY,
        order_id TEXT NOT NULL,
        client_id TEXT NOT NULL,
        supplier_id TEXT NOT NULL,
        rating INTEGER NOT NULL,
        comment TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders (id),
        FOREIGN KEY (client_id) REFERENCES users (id),
        FOREIGN KEY (supplier_id) REFERENCES users (id)
      )
    ''');

    // جدول الجلسات
    await db.execute('''
      CREATE TABLE sessions(
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        token TEXT NOT NULL,
        created_at TEXT NOT NULL,
        expires_at TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // جدول السجلات
    await db.execute('''
      CREATE TABLE audit_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        action TEXT NOT NULL,
        table_name TEXT,
        record_id TEXT,
        old_values TEXT,
        new_values TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // إضافة مستخدمين تجريبيين
    await _insertSampleData(db);
  }

  Future<void> _insertSampleData(Database db) async {
    // مستخدم مدير
    await db.insert('users', {
      'id': 'admin_001',
      'name': 'مدير النظام',
      'email': 'admin@bunyan.com',
      'phone': '+966501234567',
      'role': 'admin',
      'company_name': 'بنيان للإنشاءات',
      'address': 'الرياض، المملكة العربية السعودية',
      'city': 'الرياض',
      'is_verified': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // مورد سباكة
    await db.insert('users', {
      'id': 'supplier_001',
      'name': 'محمد أحمد',
      'email': 'mohammed@plumbing.com',
      'phone': '+966502345678',
      'role': 'supplier',
      'company_name': 'مؤسسة الأحمد للسباكة',
      'address': 'جدة، المملكة العربية السعودية',
      'city': 'جدة',
      'specializations': '["plumbing"]',
      'rating': 4.5,
      'reviews_count': 25,
      'is_verified': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // مورد كهرباء
    await db.insert('users', {
      'id': 'supplier_002',
      'name': 'أحمد محمد',
      'email': 'ahmed@electrical.com',
      'phone': '+966503456789',
      'role': 'supplier',
      'company_name': 'محمد للكهرباء',
      'address': 'الدمام، المملكة العربية السعودية',
      'city': 'الدمام',
      'specializations': '["electrical"]',
      'rating': 4.8,
      'reviews_count': 18,
      'is_verified': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // عميل
    await db.insert('users', {
      'id': 'client_001',
      'name': 'فهد العتيبي',
      'email': 'fahd@example.com',
      'phone': '+966504567890',
      'role': 'client',
      'address': 'الرياض، المملكة العربية السعودية',
      'city': 'الرياض',
      'created_at': DateTime.now().toIso8601String(),
    });

    // ناقل
    await db.insert('users', {
      'id': 'transporter_001',
      'name': 'سالم النقل',
      'email': 'salem@transport.com',
      'phone': '+966505678901',
      'role': 'transporter',
      'company_name': 'سالم للنقل والشحن',
      'address': 'الرياض، المملكة العربية السعودية',
      'city': 'الرياض',
      'specializations': '["transport"]',
      'rating': 4.2,
      'reviews_count': 32,
      'is_verified': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // منتجات تجريبية
    final now = DateTime.now();
    
    // منتجات سباكة
    await db.insert('products', {
      'id': 'prod_001',
      'name': 'مواسير PVC 4 بوصة',
      'description': 'مواسير بي في سي عالية الجودة للصرف الصحي',
      'price': 25.0,
      'category': 'plumbing',
      'unit': 'متر',
      'quantity': 500,
      'supplier_id': 'supplier_001',
      'brand': 'الاتحاد',
      'specifications': 'مقاس 4 بوصة، مقاوم للضغط',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });

    await db.insert('products', {
      'id': 'prod_002',
      'name': 'خلاط مطبخ',
      'description': 'خلاط مطبخ من النحاس المطلي بالكروم',
      'price': 180.0,
      'category': 'plumbing',
      'unit': 'قطعة',
      'quantity': 50,
      'supplier_id': 'supplier_001',
      'brand': 'جروهي',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });

    // منتجات كهرباء
    await db.insert('products', {
      'id': 'prod_003',
      'name': 'كابل كهرباء 2.5 ملم',
      'description': 'كابل كهرباء معزول عالي الجودة',
      'price': 8.5,
      'category': 'electrical',
      'unit': 'متر',
      'quantity': 1000,
      'supplier_id': 'supplier_002',
      'brand': 'الكابل السعودي',
      'specifications': 'مقطع 2.5 ملم، معزول PVC',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });

    // منتجات خرسانة (تحتاج نقل)
    await db.insert('products', {
      'id': 'prod_004',
      'name': 'أسمنت بورتلاندي',
      'description': 'أسمنت بورتلاندي عالي الجودة للخرسانة',
      'price': 28.0,
      'category': 'concrete',
      'unit': 'كيس',
      'quantity': 200,
      'supplier_id': 'supplier_001',
      'requires_transport': 1,
      'weight': 50.0,
      'brand': 'أسمنت العربية',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
  }

  // عمليات المستخدمين
  Future<int> insertUser(BunyanUser user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<BunyanUser?> getUserById(String id) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return BunyanUser.fromMap(maps.first);
  }

  Future<BunyanUser?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (maps.isEmpty) return null;
    return BunyanUser.fromMap(maps.first);
  }

  Future<List<BunyanUser>> getUsersByRole(UserRole role) async {
    final db = await database;
    final maps = await db.query('users', where: 'role = ?', whereArgs: [role.name]);
    return List.generate(maps.length, (i) => BunyanUser.fromMap(maps[i]));
  }

  // عمليات المنتجات
  Future<int> insertProduct(BuildingProduct product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<List<BuildingProduct>> getProductsByCategory(BuildingCategory category) async {
    final db = await database;
    final maps = await db.query(
      'products', 
      where: 'category = ? AND is_available = 1', 
      whereArgs: [category.name]
    );
    return List.generate(maps.length, (i) => BuildingProduct.fromMap(maps[i]));
  }

  Future<List<BuildingProduct>> getProductsBySupplier(String supplierId) async {
    final db = await database;
    final maps = await db.query(
      'products', 
      where: 'supplier_id = ?', 
      whereArgs: [supplierId]
    );
    return List.generate(maps.length, (i) => BuildingProduct.fromMap(maps[i]));
  }

  Future<List<BuildingProduct>> getAllProducts() async {
    final db = await database;
    final maps = await db.query('products', where: 'is_available = 1');
    return List.generate(maps.length, (i) => BuildingProduct.fromMap(maps[i]));
  }

  Future<int> updateProduct(BuildingProduct product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(String id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
  
  // الحصول على طلبات عروض الأسعار
  Future<List<Map<String, dynamic>>> getQuoteRequests() async {
    try {
      // في الإصدار الحقيقي، سنستخدم قاعدة البيانات
      // حالياً نستخدم بيانات وهمية للعرض
      final mockQuotes = [
        {
          'id': '1',
          'productName': 'أسمنت أبيض',
          'clientName': 'أحمد محمد',
          'quantity': '10 أكياس',
          'message': 'نحتاج أسمنت أبيض عالي الجودة',
          'supplierId': '1' // يجب أن يكون معرف المورد الحقيقي
        },
        {
          'id': '2',
          'productName': 'حديد تسليح',
          'clientName': 'شركة البناء المتقدم',
          'quantity': '5 طن',
          'message': 'مطلوب حديد تسليح قطر 12 مم',
          'supplierId': '2'
        }
      ];
      
      return mockQuotes;
    } catch (e) {
      _log('خطأ في الحصول على طلبات العروض: $e');
      return [];
    }
  }

  // عمليات الطلبات
  Future<int> insertOrder(BuildingOrder order) async {
    final db = await database;
    return await db.insert('orders', order.toMap());
  }

  Future<List<BuildingOrder>> getOrdersByClient(String clientId) async {
    final db = await database;
    final maps = await db.query(
      'orders', 
      where: 'client_id = ?', 
      whereArgs: [clientId],
      orderBy: 'created_at DESC'
    );
    return List.generate(maps.length, (i) => BuildingOrder.fromMap(maps[i]));
  }

  Future<List<BuildingOrder>> getOrdersBySupplier(String supplierId) async {
    final db = await database;
    final maps = await db.query(
      'orders', 
      where: 'supplier_id = ?', 
      whereArgs: [supplierId],
      orderBy: 'created_at DESC'
    );
    return List.generate(maps.length, (i) => BuildingOrder.fromMap(maps[i]));
  }

  Future<List<BuildingOrder>> getAllOrders() async {
    final db = await database;
    final maps = await db.query('orders', orderBy: 'created_at DESC');
    return List.generate(maps.length, (i) => BuildingOrder.fromMap(maps[i]));
  }

  Future<int> updateOrderStatus(String orderId, OrderStatus status) async {
    final db = await database;
    final updates = {
      'status': status.name,
      'updated_at': DateTime.now().toIso8601String(),
    };
    
    if (status == OrderStatus.accepted) {
      updates['accepted_at'] = DateTime.now().toIso8601String();
    } else if (status == OrderStatus.completed) {
      updates['completed_at'] = DateTime.now().toIso8601String();
    }
    
    return await db.update(
      'orders',
      updates,
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  // عمليات طلبات النقل
  Future<int> insertTransportRequest(TransportRequest request) async {
    final db = await database;
    return await db.insert('transport_requests', request.toMap());
  }

  Future<List<TransportRequest>> getTransportRequestsByTransporter(String transporterId) async {
    final db = await database;
    final maps = await db.query(
      'transport_requests', 
      where: 'transporter_id = ? OR transporter_id IS NULL', 
      whereArgs: [transporterId],
      orderBy: 'created_at DESC'
    );
    return List.generate(maps.length, (i) => TransportRequest.fromMap(maps[i]));
  }

  // عمليات التقييمات
  Future<int> insertRating(Rating rating) async {
    final db = await database;
    
    // تحديث تقييم المورد
    await _updateSupplierRating(rating.supplierId);
    
    return await db.insert('ratings', rating.toMap());
  }

  Future<void> _updateSupplierRating(String supplierId) async {
    final db = await database;
    
    // حساب متوسط التقييم
    final result = await db.rawQuery('''
      SELECT AVG(rating) as avg_rating, COUNT(*) as count 
      FROM ratings 
      WHERE supplier_id = ?
    ''', [supplierId]);
    
    if (result.isNotEmpty) {
      final avgRating = (result.first['avg_rating'] as num?)?.toDouble() ?? 0.0;
      final count = result.first['count'] as int;
      
      await db.update(
        'users',
        {'rating': avgRating, 'reviews_count': count},
        where: 'id = ?',
        whereArgs: [supplierId],
      );
    }
  }

  // إحصائيات للمدير
  Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;
    
    final usersCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM users WHERE is_active = 1')
    ) ?? 0;
    
    final ordersCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM orders')
    ) ?? 0;
    
    final productsCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM products WHERE is_available = 1')
    ) ?? 0;
    
    final totalRevenue = Sqflite.firstIntValue(
      await db.rawQuery('SELECT SUM(commission_amount) FROM orders WHERE status = ?', ['completed'])
    )?.toDouble() ?? 0.0;
    
    return {
      'usersCount': usersCount,
      'ordersCount': ordersCount,
      'productsCount': productsCount,
      'totalRevenue': totalRevenue,
    };
  }

  // تنظيف قاعدة البيانات
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('audit_logs');
    await db.delete('sessions');
    await db.delete('ratings');
    await db.delete('transport_requests');
    await db.delete('orders');
    await db.delete('products');
    await db.delete('users');
  }

  // إغلاق قاعدة البيانات
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
