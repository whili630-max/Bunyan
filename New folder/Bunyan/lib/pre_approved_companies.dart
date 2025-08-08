import 'bunyan_models.dart';

// قائمة الشركات المعتمدة للتسجيل (يمكن تحميلها من قاعدة بيانات لاحقاً)
class PreApprovedCompanies {
  static final List<PreApprovedCompany> _companies = [
    // موردي السباكة
    PreApprovedCompany(
      id: 'PLB001',
      name: 'مؤسسة الأحمد للسباكة',
      commercialRegister: '1010123456',
      category: BuildingCategory.plumbing,
      type: UserRole.supplier,
      city: 'جدة',
      contactEmail: 'info@ahmed-plumbing.com',
      contactPhone: '+966502345678',
    ),
    PreApprovedCompany(
      id: 'PLB002', 
      name: 'شركة النجاح للسباكة',
      commercialRegister: '1010234567',
      category: BuildingCategory.plumbing,
      type: UserRole.supplier,
      city: 'الرياض',
      contactEmail: 'contact@najah-plumbing.com',
      contactPhone: '+966501234567',
    ),
    
    // موردي الكهرباء
    PreApprovedCompany(
      id: 'ELC001',
      name: 'محمد للكهرباء',
      commercialRegister: '1010345678',
      category: BuildingCategory.electrical,
      type: UserRole.supplier,
      city: 'الدمام',
      contactEmail: 'info@mohammed-electric.com',
      contactPhone: '+966503456789',
    ),
    PreApprovedCompany(
      id: 'ELC002',
      name: 'مؤسسة الكهرباء المتقدمة',
      commercialRegister: '1010456789',
      category: BuildingCategory.electrical,
      type: UserRole.supplier,
      city: 'المدينة المنورة',
      contactEmail: 'admin@advanced-electric.com',
      contactPhone: '+966504567890',
    ),
    
    // شركات النقل
    PreApprovedCompany(
      id: 'TRP001',
      name: 'سالم للنقل والشحن',
      commercialRegister: '1010567890',
      category: BuildingCategory.transport,
      type: UserRole.transporter,
      city: 'الرياض',
      contactEmail: 'salem@transport.com',
      contactPhone: '+966505678901',
    ),
    PreApprovedCompany(
      id: 'TRP002',
      name: 'شركة التريلات السريعة',
      commercialRegister: '1010678901',
      category: BuildingCategory.transport,
      type: UserRole.transporter,
      city: 'جدة',
      contactEmail: 'info@fast-trailers.com',
      contactPhone: '+966506789012',
    ),
    
    // المقاولين
    PreApprovedCompany(
      id: 'CTR001',
      name: 'مؤسسة البناء المتميز',
      commercialRegister: '1010789012',
      category: BuildingCategory.concrete,
      type: UserRole.contractor,
      city: 'الرياض',
      contactEmail: 'info@excellence-construction.com',
      contactPhone: '+966507890123',
    ),
    PreApprovedCompany(
      id: 'CTR002',
      name: 'شركة المشاريع الحديثة',
      commercialRegister: '1010890123',
      category: BuildingCategory.steel,
      type: UserRole.contractor,
      city: 'جدة',
      contactEmail: 'contact@modern-projects.com',
      contactPhone: '+966508901234',
    ),
  ];

  static List<PreApprovedCompany> getCompaniesByType(UserRole type) {
    return _companies.where((company) => company.type == type).toList();
  }

  static PreApprovedCompany? findCompany(String commercialRegister, UserRole type) {
    try {
      return _companies.firstWhere(
        (company) => 
          company.commercialRegister == commercialRegister && 
          company.type == type,
      );
    } catch (e) {
      return null;
    }
  }

  static bool isCompanyApproved(String commercialRegister, UserRole type) {
    return findCompany(commercialRegister, type) != null;
  }

  static List<PreApprovedCompany> searchCompanies(String query, UserRole? type) {
    var companies = type != null ? getCompaniesByType(type) : _companies;
    
    return companies.where((company) =>
      company.name.toLowerCase().contains(query.toLowerCase()) ||
      company.commercialRegister.contains(query) ||
      company.city.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // إضافة شركة جديدة
  static void addCompany(PreApprovedCompany company) {
    _companies.add(company);
  }

  // تحديث شركة موجودة
  static void updateCompany(PreApprovedCompany updatedCompany) {
    final index = _companies.indexWhere((c) => c.id == updatedCompany.id);
    if (index != -1) {
      _companies[index] = updatedCompany;
    }
  }

  // حذف شركة
  static void removeCompany(String companyId) {
    _companies.removeWhere((c) => c.id == companyId);
  }

  // الحصول على جميع الشركات
  static List<PreApprovedCompany> getAllCompanies() {
    return List.from(_companies);
  }
}

class PreApprovedCompany {
  final String id;
  final String name;
  final String commercialRegister;
  final BuildingCategory category;
  final UserRole type;
  final String city;
  final String contactEmail;
  final String contactPhone;
  final bool isActive;
  
  // خصائص بسيطة للاستخدام في الإدارة
  String get code => commercialRegister;
  String get typeString => type.name;

  PreApprovedCompany({
    required this.id,
    required this.name,
    required this.commercialRegister,
    required this.category,
    required this.type,
    required this.city,
    required this.contactEmail,
    required this.contactPhone,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'commercial_register': commercialRegister,
      'category': category.name,
      'type': type.name,
      'city': city,
      'contact_email': contactEmail,
      'contact_phone': contactPhone,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory PreApprovedCompany.fromMap(Map<String, dynamic> map) {
    return PreApprovedCompany(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      commercialRegister: map['commercial_register'] ?? '',
      category: BuildingCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => BuildingCategory.tools,
      ),
      type: UserRole.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => UserRole.supplier,
      ),
      city: map['city'] ?? '',
      contactEmail: map['contact_email'] ?? '',
      contactPhone: map['contact_phone'] ?? '',
      isActive: (map['is_active'] ?? 1) == 1,
    );
  }
}
