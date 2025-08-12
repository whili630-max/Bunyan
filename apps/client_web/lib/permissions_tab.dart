import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'permissions.dart' as perm;

// ... (rest of the file)
// This is a placeholder for the rest of the file content.
// The actual file content is much longer.

// دالة إنشاء تبويب الصلاحيات
Widget buildPermissionsTab(Map<String, String> texts) {
  return ChangeNotifierProvider<perm.PermissionManager>(
    create: (_) => perm.PermissionManager(),
    child: Builder(
      builder: (context) {
        // استخدام PermissionManager من داخل Provider
        final permissionManager = Provider.of<perm.PermissionManager>(context);

        // الحصول على جميع الأدوار
        const roles = perm.UserRole.values;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                texts['permissions'] ?? 'إدارة الصلاحيات',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                texts['permissionManagementDesc'] ??
                    'تحكم في صلاحيات المستخدمين حسب أدوارهم',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),

              // عرض قائمة الأدوار للاختيار
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double width = constraints.maxWidth;
                    int crossAxisCount;
                    double childAspectRatio;

                    if (width > 1100) {
                      crossAxisCount = 4;
                      childAspectRatio = 2.2;
                    } else if (width > 750) {
                      crossAxisCount = 3;
                      childAspectRatio = 2.0;
                    } else if (width > 500) {
                      crossAxisCount = 2;
                      childAspectRatio = 2.5;
                    } else {
                      crossAxisCount = 1;
                      childAspectRatio = 4.5;
                    }

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: childAspectRatio,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: roles.length,
                      itemBuilder: (context, index) {
                        final role = roles[index];
                        String roleName;
                        IconData roleIcon;
                        Color roleColor;

                        // تعيين اسم ورمز ولون كل دور
                        switch (role) {
                          case perm.UserRole.admin:
                            roleName = texts['admin'] ?? 'مدير النظام';
                            roleIcon = Icons.admin_panel_settings;
                            roleColor = const Color(0xFF9C27B0);
                            break;
                          case perm.UserRole.client:
                            roleName = texts['client'] ?? 'عميل';
                            roleIcon = Icons.person;
                            roleColor = const Color(0xFF2196F3);
                            break;
                          case perm.UserRole.supplier:
                            roleName = texts['supplier'] ?? 'مورد';
                            roleIcon = Icons.store;
                            roleColor = const Color(0xFF4CAF50);
                            break;
                          case perm.UserRole.contractor:
                            roleName = texts['contractor'] ?? 'مقاول';
                            roleIcon = Icons.engineering;
                            roleColor = const Color(0xFFFF9800);
                            break;
                          case perm.UserRole.transporter:
                            roleName = texts['transporter'] ?? 'ناقل';
                            roleIcon = Icons.local_shipping;
                            roleColor = const Color(0xFFE91E63);
                            break;
                        }

                        return InkWell(
                          onTap: () {
                            // عرض صفحة تعديل صلاحيات الدور المحدد
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    perm.RolePermissionsEditor(
                                  role: role,
                                  permissionManager: permissionManager,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(roleIcon,
                                          size: 32, color: roleColor),
                                      Text(
                                        '${permissionManager.getPermissionsForRole(role).length}',
                                        style: TextStyle(
                                          color: roleColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    roleName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'كيفية استخدام إدارة الصلاحيات',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'انقر على أي دور لتعديل الصلاحيات المسموح بها لهذا الدور. سيتم تطبيق هذه الصلاحيات على جميع المستخدمين الذين لديهم هذا الدور.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
