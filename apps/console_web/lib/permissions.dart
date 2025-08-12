import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

/// تعريف الأدوار في النظام
enum UserRole {
  client,
  supplier,
  contractor,
  transporter,
  admin,
}

/// صلاحيات النظام المختلفة
class Permission {
  final String id;
  final String name;
  final String description;
  final String category;

  Permission({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
  });

  factory Permission.fromMap(Map<String, dynamic> map) {
    return Permission(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
    };
  }
}

/// مدير الصلاحيات - يتحقق من صلاحيات المستخدم ويديرها
class PermissionManager with ChangeNotifier {
  // جدول ربط بين الأدوار والصلاحيات
  Map<UserRole, List<String>> _rolePermissions = {};

  // قائمة الصلاحيات المتاحة في النظام
  final List<Permission> _availablePermissions = [
    // صلاحيات المنتجات
    Permission(
      id: 'product_view',
      name: 'عرض المنتجات',
      description: 'السماح بعرض المنتجات',
      category: 'منتجات',
    ),
    Permission(
      id: 'product_add',
      name: 'إضافة منتج',
      description: 'السماح بإضافة منتج جديد',
      category: 'منتجات',
    ),
    Permission(
      id: 'product_edit',
      name: 'تعديل منتج',
      description: 'السماح بتعديل منتج موجود',
      category: 'منتجات',
    ),
    Permission(
      id: 'product_delete',
      name: 'حذف منتج',
      description: 'السماح بحذف منتج',
      category: 'منتجات',
    ),

    // صلاحيات المستخدمين
    Permission(
      id: 'user_view',
      name: 'عرض المستخدمين',
      description: 'السماح بعرض قائمة المستخدمين',
      category: 'مستخدمين',
    ),
    Permission(
      id: 'user_add',
      name: 'إضافة مستخدم',
      description: 'السماح بإضافة مستخدم جديد',
      category: 'مستخدمين',
    ),
    Permission(
      id: 'user_edit',
      name: 'تعديل مستخدم',
      description: 'السماح بتعديل بيانات مستخدم',
      category: 'مستخدمين',
    ),
    Permission(
      id: 'user_delete',
      name: 'حذف مستخدم',
      description: 'السماح بحذف مستخدم',
      category: 'مستخدمين',
    ),

    // صلاحيات الشركات المعتمدة
    Permission(
      id: 'company_view',
      name: 'عرض الشركات',
      description: 'السماح بعرض الشركات المعتمدة',
      category: 'شركات',
    ),
    Permission(
      id: 'company_add',
      name: 'إضافة شركة',
      description: 'السماح بإضافة شركة معتمدة',
      category: 'شركات',
    ),
    Permission(
      id: 'company_edit',
      name: 'تعديل شركة',
      description: 'السماح بتعديل بيانات شركة معتمدة',
      category: 'شركات',
    ),
    Permission(
      id: 'company_delete',
      name: 'حذف شركة',
      description: 'السماح بحذف شركة معتمدة',
      category: 'شركات',
    ),

    // صلاحيات الطلبات
    Permission(
      id: 'order_view',
      name: 'عرض الطلبات',
      description: 'السماح بعرض الطلبات',
      category: 'طلبات',
    ),
    Permission(
      id: 'order_add',
      name: 'إضافة طلب',
      description: 'السماح بإنشاء طلب جديد',
      category: 'طلبات',
    ),
    Permission(
      id: 'order_update_status',
      name: 'تحديث حالة طلب',
      description: 'السماح بتغيير حالة الطلب',
      category: 'طلبات',
    ),
    Permission(
      id: 'order_delete',
      name: 'حذف طلب',
      description: 'السماح بحذف طلب',
      category: 'طلبات',
    ),

    // صلاحيات إدارية
    Permission(
      id: 'admin_dashboard',
      name: 'لوحة تحكم المدير',
      description: 'السماح بالوصول إلى لوحة تحكم المدير',
      category: 'إدارة',
    ),
    Permission(
      id: 'report_view',
      name: 'عرض التقارير',
      description: 'السماح بعرض التقارير',
      category: 'تقارير',
    ),
    Permission(
      id: 'permissions_manage',
      name: 'إدارة الصلاحيات',
      description: 'السماح بإدارة صلاحيات المستخدمين',
      category: 'إدارة',
    ),
  ];

  PermissionManager() {
    _initDefaultPermissions();
    _loadPersistedPermissions();
  }

  // تهيئة الصلاحيات الافتراضية لكل دور
  void _initDefaultPermissions() {
    _rolePermissions = {
      UserRole.admin: _availablePermissions.map((p) => p.id).toList(),
      UserRole.client: ['product_view', 'order_add', 'order_view'],
      UserRole.supplier: [
        'product_view',
        'product_add',
        'product_edit',
        'product_delete',
        'order_view',
        'order_update_status'
      ],
      UserRole.contractor: [
        'product_view',
        'order_view',
        'order_update_status'
      ],
      UserRole.transporter: [
        'product_view',
        'order_view',
        'order_update_status'
      ],
    };
  }

  // تحميل الصلاحيات المخزنة من ذاكرة التطبيق
  Future<void> _loadPersistedPermissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('role_permissions');

      if (jsonString != null) {
        final Map<String, dynamic> savedData = json.decode(jsonString);

        // تحويل البيانات المخزنة إلى النموذج المناسب
        final Map<UserRole, List<String>> loadedPermissions = {};
        savedData.forEach((key, value) {
          final roleKey = UserRole.values.firstWhere(
            (role) => role.toString() == 'UserRole.$key',
            orElse: () => UserRole.client,
          );
          loadedPermissions[roleKey] = List<String>.from(value);
        });

        _rolePermissions = loadedPermissions;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('خطأ في تحميل الصلاحيات: $e');
    }
  }

  // حفظ الصلاحيات في ذاكرة التطبيق
  Future<void> savePermissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // تحويل البيانات إلى صيغة مناسبة للتخزين
      final Map<String, dynamic> dataToSave = {};
      _rolePermissions.forEach((role, permissions) {
        // استخراج اسم الدور من التعداد (enum)
        final roleName = role.toString().split('.').last;
        dataToSave[roleName] = permissions;
      });

      final jsonString = json.encode(dataToSave);
      await prefs.setString('role_permissions', jsonString);
    } catch (e) {
      debugPrint('خطأ في حفظ الصلاحيات: $e');
    }
  }

  // الحصول على كافة الصلاحيات المتاحة
  List<Permission> get availablePermissions => _availablePermissions;

  // الحصول على صلاحيات دور محدد
  List<String> getPermissionsForRole(UserRole role) {
    return _rolePermissions[role] ?? [];
  }

  // ضبط صلاحيات دور محدد
  void setPermissionsForRole(UserRole role, List<String> permissions) {
    _rolePermissions[role] = permissions;
    savePermissions();
    notifyListeners();
  }

  // إضافة صلاحية لدور محدد
  void addPermissionToRole(UserRole role, String permissionId) {
    if (!_rolePermissions.containsKey(role)) {
      _rolePermissions[role] = [];
    }

    if (!_rolePermissions[role]!.contains(permissionId)) {
      _rolePermissions[role]!.add(permissionId);
      savePermissions();
      notifyListeners();
    }
  }

  // إزالة صلاحية من دور محدد
  void removePermissionFromRole(UserRole role, String permissionId) {
    if (_rolePermissions.containsKey(role)) {
      _rolePermissions[role]!.remove(permissionId);
      savePermissions();
      notifyListeners();
    }
  }

  // التحقق إذا كان الدور يملك الصلاحية المحددة
  bool hasPermission(UserRole role, String permissionId) {
    return _rolePermissions[role]?.contains(permissionId) ?? false;
  }

  // الحصول على صلاحيات حسب التصنيف
  Map<String, List<Permission>> getPermissionsByCategory() {
    Map<String, List<Permission>> categorizedPermissions = {};

    for (var permission in _availablePermissions) {
      if (!categorizedPermissions.containsKey(permission.category)) {
        categorizedPermissions[permission.category] = [];
      }
      categorizedPermissions[permission.category]!.add(permission);
    }

    return categorizedPermissions;
  }
}

/// واجهة تساعد في عرض وتعديل صلاحيات دور محدد
class RolePermissionsEditor extends StatefulWidget {
  final UserRole role;
  final PermissionManager permissionManager;

  const RolePermissionsEditor({
    super.key,
    required this.role,
    required this.permissionManager,
  });

  @override
  State<RolePermissionsEditor> createState() => _RolePermissionsEditorState();
}

class _RolePermissionsEditorState extends State<RolePermissionsEditor> {
  late List<String> selectedPermissions;

  @override
  void initState() {
    super.initState();
    selectedPermissions =
        List.from(widget.permissionManager.getPermissionsForRole(widget.role));
  }

  String getRoleNameInArabic(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'مدير';
      case UserRole.client:
        return 'عميل';
      case UserRole.supplier:
        return 'مورد';
      case UserRole.contractor:
        return 'مقاول';
      case UserRole.transporter:
        return 'ناقل';
    }
  }

  @override
  Widget build(BuildContext context) {
    // تصنيف الصلاحيات حسب الفئة
    final permissionsByCategory =
        widget.permissionManager.getPermissionsByCategory();

    return Scaffold(
      appBar: AppBar(
        title: Text('صلاحيات ${getRoleNameInArabic(widget.role)}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              widget.permissionManager.setPermissionsForRole(
                widget.role,
                selectedPermissions,
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'إدارة صلاحيات ${getRoleNameInArabic(widget.role)}',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // عرض الصلاحيات مصنفة حسب الفئات
          ...permissionsByCategory.entries.map((entry) {
            final category = entry.key;
            final permissions = entry.value;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Divider(),
                    ...permissions.map((permission) {
                      return CheckboxListTile(
                        title: Text(permission.name),
                        subtitle: Text(permission.description),
                        value: selectedPermissions.contains(permission.id),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              if (!selectedPermissions
                                  .contains(permission.id)) {
                                selectedPermissions.add(permission.id);
                              }
                            } else {
                              selectedPermissions.remove(permission.id);
                            }
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// واجهة تعرض شاشة إدارة الصلاحيات في لوحة المدير
class PermissionsManagementPage extends StatelessWidget {
  const PermissionsManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final permissionManager = Provider.of<PermissionManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الصلاحيات'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // عنوان الصفحة
          Text(
            'إدارة صلاحيات المستخدمين',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // قائمة بالأدوار للاختيار
          ...UserRole.values.map((role) {
            String roleName;
            IconData roleIcon;

            switch (role) {
              case UserRole.admin:
                roleName = 'مدير النظام';
                roleIcon = Icons.admin_panel_settings;
                break;
              case UserRole.client:
                roleName = 'عميل';
                roleIcon = Icons.person;
                break;
              case UserRole.supplier:
                roleName = 'مورد';
                roleIcon = Icons.store;
                break;
              case UserRole.contractor:
                roleName = 'مقاول';
                roleIcon = Icons.engineering;
                break;
              case UserRole.transporter:
                roleName = 'ناقل';
                roleIcon = Icons.local_shipping;
                break;
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: Icon(roleIcon, size: 32),
                title: Text(roleName),
                subtitle: Text(
                    'عدد الصلاحيات: ${permissionManager.getPermissionsForRole(role).length}'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RolePermissionsEditor(
                        role: role,
                        permissionManager: permissionManager,
                      ),
                    ),
                  );
                },
              ),
            );
          }),

          const SizedBox(height: 16),

          // معلومات حول الصلاحيات
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'معلومات حول نظام الصلاحيات',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                      'هنا يمكنك إدارة صلاحيات المستخدمين حسب دورهم في النظام. انقر على دور محدد لتعديل الصلاحيات المسموح بها لهذا الدور.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// طريقة سهلة للتحقق من وجود صلاحية معينة للمستخدم
extension PermissionChecker on BuildContext {
  /// تحقق إذا كان المستخدم لديه صلاحية محددة
  bool hasPermission(String permissionId, String userType) {
    final UserRole role;

    // تحويل نوع المستخدم النصي إلى تعداد UserRole
    switch (userType.toLowerCase()) {
      case 'admin':
        role = UserRole.admin;
        break;
      case 'supplier':
        role = UserRole.supplier;
        break;
      case 'contractor':
        role = UserRole.contractor;
        break;
      case 'transporter':
        role = UserRole.transporter;
        break;
      case 'client':
      default:
        role = UserRole.client;
        break;
    }

    // التحقق من الصلاحية باستخدام مدير الصلاحيات
    return Provider.of<PermissionManager>(this, listen: false)
        .hasPermission(role, permissionId);
  }
}
