// نماذج البيانات الخاصة بتطبيق بنيان - قطاع البناء والإنشاءات
import 'dart:convert';

enum UserRole {
  client, // عميل
  supplier, // مورد
  transporter, // مقدم خدمة نقل
  contractor, // مقاول/مشرف
  admin // مدير
}

enum OrderStatus {
  pending, // معلق
  accepted, // مقبول
  inProgress, // جاري التنفيذ
  completed, // مكتمل
  cancelled // ملغي
}

enum BuildingCategory {
  plumbing, // سباكة
  electrical, // كهرباء
  concrete, // خرسانة
  blocks, // بلك
  steel, // حديد
  tiles, // بلاط
  paint, // دهانات
  doors, // أبواب ونوافذ
  heavyEquipment, // معدات ثقيلة
  tools, // أدوات
  transport // نقل
}

class BunyanUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? companyName;
  final String? address;
  final String? city;
  final String? profileImage;
  final List<BuildingCategory> specializations; // للموردين
  final double rating;
  final int reviewsCount;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLogin;

  BunyanUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.companyName,
    this.address,
    this.city,
    this.profileImage,
    this.specializations = const [],
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.isVerified = false,
    this.isActive = true,
    required this.createdAt,
    this.lastLogin,
  });

  factory BunyanUser.fromMap(Map<String, dynamic> map) {
    return BunyanUser(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.client,
      ),
      companyName: map['company_name']?.toString(),
      address: map['address']?.toString(),
      city: map['city']?.toString(),
      profileImage: map['profile_image']?.toString(),
      specializations: map['specializations'] != null
          ? (jsonDecode(map['specializations']) as List)
              .map((e) => BuildingCategory.values.firstWhere(
                    (cat) => cat.name == e,
                    orElse: () => BuildingCategory.tools,
                  ))
              .toList()
          : [],
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: map['reviews_count']?.toInt() ?? 0,
      isVerified: (map['is_verified'] ?? 0) == 1,
      isActive: (map['is_active'] ?? 1) == 1,
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now(),
      lastLogin: map['last_login'] != null
          ? DateTime.tryParse(map['last_login'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'company_name': companyName,
      'address': address,
      'city': city,
      'profile_image': profileImage,
      'specializations':
          jsonEncode(specializations.map((e) => e.name).toList()),
      'rating': rating,
      'reviews_count': reviewsCount,
      'is_verified': isVerified ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }
}

class BuildingProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final BuildingCategory category;
  final String unit; // كيس، متر، طن، قطعة، متر مربع...
  final int quantity;
  final bool isAvailable;
  final String supplierId;
  final String? imageUrl;
  final bool requiresTransport;
  final double? weight; // الوزن بالكيلو
  final String? specifications;
  final String? brand; // الماركة
  final double commissionRate; // نسبة العمولة
  final DateTime createdAt;
  final DateTime updatedAt;

  BuildingProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.unit,
    required this.quantity,
    required this.isAvailable,
    required this.supplierId,
    this.imageUrl,
    this.requiresTransport = false,
    this.weight,
    this.specifications,
    this.brand,
    this.commissionRate = 0.05, // 5% افتراضي
    required this.createdAt,
    required this.updatedAt,
  });

  factory BuildingProduct.fromMap(Map<String, dynamic> map) {
    return BuildingProduct(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      category: BuildingCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => BuildingCategory.tools,
      ),
      unit: map['unit']?.toString() ?? 'قطعة',
      quantity: map['quantity']?.toInt() ?? 0,
      isAvailable: (map['is_available'] ?? 1) == 1,
      supplierId: map['supplier_id']?.toString() ?? '',
      imageUrl: map['image_url']?.toString(),
      requiresTransport: (map['requires_transport'] ?? 0) == 1,
      weight: (map['weight'] as num?)?.toDouble(),
      specifications: map['specifications']?.toString(),
      brand: map['brand']?.toString(),
      commissionRate: (map['commission_rate'] as num?)?.toDouble() ?? 0.05,
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
      'category': category.name,
      'unit': unit,
      'quantity': quantity,
      'is_available': isAvailable ? 1 : 0,
      'supplier_id': supplierId,
      'image_url': imageUrl,
      'requires_transport': requiresTransport ? 1 : 0,
      'weight': weight,
      'specifications': specifications,
      'brand': brand,
      'commission_rate': commissionRate,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class BuildingOrder {
  final String id;
  final String clientId;
  final String supplierId;
  final String? transporterId; // مقدم خدمة النقل إن وجد
  final List<OrderItem> items;
  final double totalAmount;
  final double commissionAmount;
  final OrderStatus status;
  final String deliveryAddress;
  final String? notes;
  final DateTime requestedDeliveryDate;
  final bool needsTransport;
  final double? transportFee;
  final String? paymentMethod;
  final bool isPaid;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;

  BuildingOrder({
    required this.id,
    required this.clientId,
    required this.supplierId,
    this.transporterId,
    required this.items,
    required this.totalAmount,
    required this.commissionAmount,
    required this.status,
    required this.deliveryAddress,
    this.notes,
    required this.requestedDeliveryDate,
    this.needsTransport = false,
    this.transportFee,
    this.paymentMethod,
    this.isPaid = false,
    required this.createdAt,
    this.acceptedAt,
    this.completedAt,
  });

  factory BuildingOrder.fromMap(Map<String, dynamic> map) {
    return BuildingOrder(
      id: map['id']?.toString() ?? '',
      clientId: map['client_id']?.toString() ?? '',
      supplierId: map['supplier_id']?.toString() ?? '',
      transporterId: map['transporter_id']?.toString(),
      items: map['items'] != null
          ? (jsonDecode(map['items']) as List)
              .map((item) => OrderItem.fromMap(item))
              .toList()
          : [],
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0.0,
      commissionAmount: (map['commission_amount'] as num?)?.toDouble() ?? 0.0,
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      deliveryAddress: map['delivery_address']?.toString() ?? '',
      notes: map['notes']?.toString(),
      requestedDeliveryDate:
          DateTime.tryParse(map['requested_delivery_date']?.toString() ?? '') ??
              DateTime.now(),
      needsTransport: (map['needs_transport'] ?? 0) == 1,
      transportFee: (map['transport_fee'] as num?)?.toDouble(),
      paymentMethod: map['payment_method']?.toString(),
      isPaid: (map['is_paid'] ?? 0) == 1,
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now(),
      acceptedAt: map['accepted_at'] != null
          ? DateTime.tryParse(map['accepted_at'].toString())
          : null,
      completedAt: map['completed_at'] != null
          ? DateTime.tryParse(map['completed_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'client_id': clientId,
      'supplier_id': supplierId,
      'transporter_id': transporterId,
      'items': jsonEncode(items.map((item) => item.toMap()).toList()),
      'total_amount': totalAmount,
      'commission_amount': commissionAmount,
      'status': status.name,
      'delivery_address': deliveryAddress,
      'notes': notes,
      'requested_delivery_date': requestedDeliveryDate.toIso8601String(),
      'needs_transport': needsTransport ? 1 : 0,
      'transport_fee': transportFee,
      'payment_method': paymentMethod,
      'is_paid': isPaid ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final String unit;
  final double totalPrice;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.unit,
    required this.totalPrice,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['product_id']?.toString() ?? '',
      productName: map['product_name']?.toString() ?? '',
      unitPrice: (map['unit_price'] as num?)?.toDouble() ?? 0.0,
      quantity: map['quantity']?.toInt() ?? 0,
      unit: map['unit']?.toString() ?? '',
      totalPrice: (map['total_price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'unit_price': unitPrice,
      'quantity': quantity,
      'unit': unit,
      'total_price': totalPrice,
    };
  }
}

class Rating {
  final String id;
  final String orderId;
  final String clientId;
  final String supplierId;
  final int rating; // 1-5
  final String? comment;
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.orderId,
    required this.clientId,
    required this.supplierId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      id: map['id']?.toString() ?? '',
      orderId: map['order_id']?.toString() ?? '',
      clientId: map['client_id']?.toString() ?? '',
      supplierId: map['supplier_id']?.toString() ?? '',
      rating: map['rating']?.toInt() ?? 0,
      comment: map['comment']?.toString(),
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'client_id': clientId,
      'supplier_id': supplierId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class TransportRequest {
  final String id;
  final String orderId;
  final String clientId;
  final String? transporterId;
  final String pickupAddress;
  final String deliveryAddress;
  final double estimatedWeight;
  final String vehicleType; // تريلة، قلاب، نقل عادي
  final double? quotedPrice;
  final OrderStatus status;
  final DateTime requestedDate;
  final DateTime createdAt;

  TransportRequest({
    required this.id,
    required this.orderId,
    required this.clientId,
    this.transporterId,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.estimatedWeight,
    required this.vehicleType,
    this.quotedPrice,
    required this.status,
    required this.requestedDate,
    required this.createdAt,
  });

  factory TransportRequest.fromMap(Map<String, dynamic> map) {
    return TransportRequest(
      id: map['id']?.toString() ?? '',
      orderId: map['order_id']?.toString() ?? '',
      clientId: map['client_id']?.toString() ?? '',
      transporterId: map['transporter_id']?.toString(),
      pickupAddress: map['pickup_address']?.toString() ?? '',
      deliveryAddress: map['delivery_address']?.toString() ?? '',
      estimatedWeight: (map['estimated_weight'] as num?)?.toDouble() ?? 0.0,
      vehicleType: map['vehicle_type']?.toString() ?? '',
      quotedPrice: (map['quoted_price'] as num?)?.toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      requestedDate:
          DateTime.tryParse(map['requested_date']?.toString() ?? '') ??
              DateTime.now(),
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'client_id': clientId,
      'transporter_id': transporterId,
      'pickup_address': pickupAddress,
      'delivery_address': deliveryAddress,
      'estimated_weight': estimatedWeight,
      'vehicle_type': vehicleType,
      'quoted_price': quotedPrice,
      'status': status.name,
      'requested_date': requestedDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// فئات البناء مع أسمائها بالعربية
Map<BuildingCategory, String> buildingCategoryNames = {
  BuildingCategory.plumbing: 'سباكة',
  BuildingCategory.electrical: 'كهرباء',
  BuildingCategory.concrete: 'خرسانة',
  BuildingCategory.blocks: 'بلك',
  BuildingCategory.steel: 'حديد',
  BuildingCategory.tiles: 'بلاط',
  BuildingCategory.paint: 'دهانات',
  BuildingCategory.doors: 'أبواب ونوافذ',
  BuildingCategory.heavyEquipment: 'معدات ثقيلة',
  BuildingCategory.tools: 'أدوات',
  BuildingCategory.transport: 'نقل',
};

// أسماء حالات الطلبات بالعربية
Map<OrderStatus, String> orderStatusNames = {
  OrderStatus.pending: 'معلق',
  OrderStatus.accepted: 'مقبول',
  OrderStatus.inProgress: 'جاري التنفيذ',
  OrderStatus.completed: 'مكتمل',
  OrderStatus.cancelled: 'ملغي',
};

// أسماء أدوار المستخدمين بالعربية
Map<UserRole, String> userRoleNames = {
  UserRole.client: 'عميل',
  UserRole.supplier: 'مورد',
  UserRole.transporter: 'ناقل',
  UserRole.contractor: 'مقاول',
  UserRole.admin: 'مدير',
};
