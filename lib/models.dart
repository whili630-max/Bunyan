class User {
  final String id;
  final String name;
  final String email;
  final String? phone; // رقم الهاتف
  final String type; // 'client', 'supplier', 'admin'
  final String? institution;
  final DateTime createdAt;
  final bool isActive;
  final bool verified; // حالة التحقق من البريد الإلكتروني
  final bool phoneVerified; // حالة التحقق من رقم الهاتف
  final DateTime? lastLogin;
  final String? profileImage;
  final Map<String, String>? encryptedData; // بيانات مشفرة إضافية
  final String? accessToken; // توكن الوصول للواجهات الخارجية
  final Map<String, dynamic>? permissions; // صلاحيات المستخدم

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.type,
    this.institution,
    required this.createdAt,
    this.isActive = true,
    this.verified = false,
    this.phoneVerified = false,
    this.lastLogin,
    this.profileImage,
    this.encryptedData,
    this.accessToken,
    this.permissions,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      type: json['type']?.toString() ?? '',
      institution: json['institution']?.toString(),
      verified: json['verified'] ?? false,
      phoneVerified: json['phoneVerified'] ?? false,
      encryptedData: json['encryptedData'] != null
          ? Map<String, String>.from(json['encryptedData'])
          : null,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      isActive: json['isActive'] ?? true,
      lastLogin: json['lastLogin'] != null
          ? DateTime.tryParse(json['lastLogin'])
          : null,
      profileImage: json['profileImage'],
      accessToken: json['accessToken'],
      permissions: json['permissions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'type': type,
      'institution': institution,
      'verified': verified,
      'phoneVerified': phoneVerified,
      'encryptedData': encryptedData,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'lastLogin': lastLogin?.toIso8601String(),
      'profileImage': profileImage,
      'accessToken': accessToken,
      'permissions': permissions,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString(),
      type: map['user_type']?.toString() ?? '',
      institution: map['institution']?.toString(),
      verified: map['verified'] ?? false,
      phoneVerified: map['phone_verified'] ?? false,
      encryptedData: map['encrypted_data'] != null
          ? Map<String, String>.from(map['encrypted_data'])
          : null,
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now(),
      isActive: (map['is_active'] as int?) == 1,
      lastLogin: map['last_login'] != null
          ? DateTime.tryParse(map['last_login'].toString())
          : null,
      profileImage: map['profile_image']?.toString(),
      accessToken: map['access_token']?.toString(),
      permissions: map['permissions'] != null
          ? Map<String, dynamic>.from(map['permissions'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'user_type': type,
      'institution': institution,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'verified': verified,
      'phone_verified': phoneVerified,
      'last_login': lastLogin?.toIso8601String(),
      'profile_image': profileImage,
      'encrypted_data': encryptedData,
      'access_token': accessToken,
      'permissions': permissions,
    };
  }
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imagePath;
  final String? category;
  final int quantity;
  final bool isAvailable;
  final String supplierId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imagePath,
    this.category,
    this.quantity = 0,
    this.isAvailable = true,
    required this.supplierId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imagePath: map['image_path']?.toString() ?? '',
      category: map['category']?.toString(),
      quantity: (map['quantity'] as int?) ?? 0,
      isAvailable: (map['is_available'] as int?) == 1,
      supplierId: map['supplier_id']?.toString() ?? '',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_path': imagePath,
      'category': category,
      'quantity': quantity,
      'is_available': isAvailable ? 1 : 0,
      'supplier_id': supplierId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imagePath,
    String? category,
    int? quantity,
    bool? isAvailable,
    String? supplierId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      isAvailable: isAvailable ?? this.isAvailable,
      supplierId: supplierId ?? this.supplierId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class QuoteRequest {
  final String id;
  final String clientId;
  final String supplierId;
  final String? productId; // يمكن أن يكون الطلب لمنتج محدد أو طلب عام
  final String details;
  final int quantity;
  final DateTime date;
  final String status; // 'pending', 'approved', 'rejected'
  final double? quotedPrice;
  final String? response;
  final String? attachmentPath; // مسار الملف المرفق مع الطلب

  QuoteRequest({
    required this.id,
    required this.clientId,
    required this.supplierId,
    this.productId,
    required this.details,
    required this.quantity,
    required this.date,
    this.status = 'pending',
    this.quotedPrice,
    this.response,
    this.attachmentPath,
  });

  factory QuoteRequest.fromMap(Map<String, dynamic> map) {
    return QuoteRequest(
      id: map['id']?.toString() ?? '',
      clientId: map['client_id']?.toString() ?? '',
      supplierId: map['supplier_id']?.toString() ?? '',
      productId: map['product_id']?.toString(),
      details: map['details']?.toString() ?? '',
      quantity: (map['quantity'] as int?) ?? 1,
      date: DateTime.tryParse(map['date']?.toString() ?? '') ?? DateTime.now(),
      status: map['status']?.toString() ?? 'pending',
      quotedPrice: (map['quoted_price'] as num?)?.toDouble(),
      attachmentPath: map['attachment_path']?.toString(),
      response: map['response']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'client_id': clientId,
      'supplier_id': supplierId,
      'product_id': productId,
      'details': details,
      'quantity': quantity,
      'date': date.toIso8601String(),
      'status': status,
      'quoted_price': quotedPrice,
      'response': response,
      'attachment_path': attachmentPath,
    };
  }
}

class UserSession {
  final String id;
  final String userId;
  final String token;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isActive;

  UserSession({
    required this.id,
    required this.userId,
    required this.token,
    required this.createdAt,
    required this.expiresAt,
    this.isActive = true,
  });

  factory UserSession.fromMap(Map<String, dynamic> map) {
    return UserSession(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      token: map['token']?.toString() ?? '',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now(),
      expiresAt: DateTime.tryParse(map['expires_at']?.toString() ?? '') ??
          DateTime.now(),
      isActive: (map['is_active'] as int?) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'token': token,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
