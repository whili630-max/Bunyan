import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_manager.dart';
import 'bunyan_models.dart';
import 'pre_approved_companies.dart';
import 'permissions.dart' as perm; // إضافة مدير الصلاحيات مع prefix
import 'membership_requests.dart';
import 'auth_manager.dart'; // إضافة مدير المصادقة

class AdminServicePage extends StatefulWidget {
  final BunyanUser? adminUser;

  const AdminServicePage({super.key, this.adminUser});

  @override
  State<AdminServicePage> createState() => _AdminServicePageState();
}

class _AdminServicePageState extends State<AdminServicePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<PreApprovedCompany> approvedCompanies = [];
  List<Map<String, dynamic>> systemUsers = [];
  List<Map<String, dynamic>> systemReports = [];
  bool isLoading = true;
  late Map<String, String> texts;

  // التحقق من صلاحيات الوصول للوحة التحكم
  void _enforceAdminAccess() {
    final authManager = Provider.of<AuthManager>(context, listen: false);
    if (authManager.currentUser == null ||
        authManager.currentUser!.type != 'admin') {
      // لا يوجد مستخدم مسجل الدخول أو المستخدم ليس مدير
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // إظهار رسالة تحذير
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('غير مصرح لك بالوصول إلى لوحة تحكم الإدارة'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );

        // إعادة التوجيه إلى الصفحة الرئيسية
        Navigator.of(context).pushReplacementNamed('/home');
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 6, vsync: this); // زيادة عدد التبويبات إلى 6

    // التحقق من صلاحيات الوصول للوحة التحكم
    _enforceAdminAccess();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTexts();
      _loadAdminData();
    });

    // استماع إلى تغييرات علامة التبويب لتحديث الشاشة إذا كانت تحتوي على بيانات متغيرة
    _tabController.addListener(() {
      setState(() {}); // تحديث الشاشة عند تغيير علامة التبويب
    });
  }

  void _loadTexts() {
    final languageManager =
        Provider.of<LanguageManager>(context, listen: false);
    final isArabic = languageManager.currentLocale.languageCode == 'ar';

    setState(() {
      texts = {
        'adminPanel': isArabic ? 'لوحة الإدارة' : 'Admin Panel',
        'companies': isArabic ? 'الشركات المعتمدة' : 'Approved Companies',
        'users': isArabic ? 'المستخدمين' : 'Users',
        'reports': isArabic ? 'التقارير' : 'Reports',
        'analytics': isArabic ? 'الإحصائيات' : 'Analytics',
        'addCompany': isArabic ? 'إضافة شركة' : 'Add Company',
        'editCompany': isArabic ? 'تعديل شركة' : 'Edit Company',
        'deleteCompany': isArabic ? 'حذف شركة' : 'Delete Company',
        'companyName': isArabic ? 'اسم الشركة' : 'Company Name',
        'companyType': isArabic ? 'نوع الشركة' : 'Company Type',
        'crNumber': isArabic ? 'رقم السجل التجاري' : 'CR Number',
        'licenseNumber': isArabic ? 'رقم الرخصة' : 'License Number',
        'contactEmail': isArabic ? 'البريد الإلكتروني' : 'Contact Email',
        'contactPhone': isArabic ? 'رقم الهاتف' : 'Contact Phone',
        'address': isArabic ? 'العنوان' : 'Address',
        'supplier': isArabic ? 'مورد' : 'Supplier',
        'contractor': isArabic ? 'مقاول' : 'Contractor',
        'transporter': isArabic ? 'ناقل' : 'Transporter',
        'active': isArabic ? 'نشط' : 'Active',
        'inactive': isArabic ? 'غير نشط' : 'Inactive',
        'status': isArabic ? 'الحالة' : 'Status',
        'save': isArabic ? 'حفظ' : 'Save',
        'cancel': isArabic ? 'إلغاء' : 'Cancel',
        'delete': isArabic ? 'حذف' : 'Delete',
        'confirm': isArabic ? 'تأكيد' : 'Confirm',
        'confirmDelete': isArabic
            ? 'هل تريد حذف هذه الشركة؟'
            : 'Do you want to delete this company?',
        'noCompanies':
            isArabic ? 'لا توجد شركات معتمدة' : 'No approved companies',
        'addFirstCompany':
            isArabic ? 'أضف أول شركة معتمدة' : 'Add first approved company',
        'totalUsers': isArabic ? 'إجمالي المستخدمين' : 'Total Users',
        'totalCompanies': isArabic ? 'إجمالي الشركات' : 'Total Companies',
        'totalTransactions':
            isArabic ? 'إجمالي المعاملات' : 'Total Transactions',
        'systemHealth': isArabic ? 'حالة النظام' : 'System Health',
        'userRole': isArabic ? 'دور المستخدم' : 'User Role',
        'joinDate': isArabic ? 'تاريخ التسجيل' : 'Join Date',
        'lastActivity': isArabic ? 'آخر نشاط' : 'Last Activity',
        'client': isArabic ? 'عميل' : 'Client',
        'admin': isArabic ? 'مدير' : 'Admin',
        'welcome': isArabic ? 'مرحباً' : 'Welcome',
        'reportType': isArabic ? 'نوع التقرير' : 'Report Type',
        'generatedDate': isArabic ? 'تاريخ الإنشاء' : 'Generated Date',
        'viewReport': isArabic ? 'عرض التقرير' : 'View Report',
        'downloadReport': isArabic ? 'تحميل التقرير' : 'Download Report',
        'userActivity': isArabic ? 'نشاط المستخدمين' : 'User Activity',
        'salesReport': isArabic ? 'تقرير المبيعات' : 'Sales Report',
        'systemUsage': isArabic ? 'استخدام النظام' : 'System Usage',
        // إضافة ترجمات لإدارة الصلاحيات
        'permissions': isArabic ? 'الصلاحيات' : 'Permissions',
        'permissionManagementDesc': isArabic
            ? 'تحكم في صلاحيات المستخدمين حسب أدوارهم'
            : 'Manage user permissions based on their roles',
      };
    });
  }

  Future<void> _loadAdminData() async {
    if (!mounted) return;
    try {
      // Load pre-approved companies
      final companies = PreApprovedCompanies.getAllCompanies();

      // Mock system users data
      final mockUsers = <Map<String, dynamic>>[
        {
          'id': '1',
          'email': 'ahmed@client.com',
          'role': 'client',
          'joinDate': '2024-01-15',
          'lastActivity': '2024-01-20',
          'status': 'active'
        },
        {
          'id': '2',
          'email': 'supplier@company.com',
          'role': 'supplier',
          'joinDate': '2024-01-10',
          'lastActivity': '2024-01-19',
          'status': 'active'
        },
        {
          'id': '3',
          'email': 'contractor@build.com',
          'role': 'contractor',
          'joinDate': '2024-01-12',
          'lastActivity': '2024-01-18',
          'status': 'active'
        },
      ];

      // Mock reports data
      final mockReports = <Map<String, dynamic>>[
        {
          'id': '1',
          'type': 'userActivity',
          'title': 'تقرير نشاط المستخدمين - يناير 2024',
          'generatedDate': '2024-01-20',
          'status': 'ready'
        },
        {
          'id': '2',
          'type': 'salesReport',
          'title': 'تقرير المبيعات الشهري',
          'generatedDate': '2024-01-19',
          'status': 'ready'
        },
      ];

      await Future.delayed(
          const Duration(milliseconds: 500)); // Simulate loading

      setState(() {
        approvedCompanies = companies;
        systemUsers = mockUsers;
        systemReports = mockReports;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل البيانات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (texts.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(texts['adminPanel'] ?? 'Admin Panel'),
            if (widget.adminUser != null)
              Text(
                '${texts['welcome'] ?? 'Welcome'} ${widget.adminUser!.email}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable:
              true, // للسماح بالتمرير إذا كانت هناك علامات تبويب كثيرة
          tabs: [
            Tab(
              icon: const Icon(Icons.business),
              text: texts['companies'],
            ),
            Tab(
              icon: const Icon(Icons.people),
              text: texts['users'],
            ),
            Tab(
              icon: const Icon(Icons.assessment),
              text: texts['reports'],
            ),
            Tab(
              icon: const Icon(Icons.analytics),
              text: texts['analytics'],
            ),
            Tab(
              icon: const Icon(Icons.security),
              text: texts['permissions'] ?? 'الصلاحيات',
            ),
            Tab(
              icon: const Icon(Icons.how_to_reg),
              text: texts['membershipRequests'] ?? 'طلبات العضوية',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCompaniesTab(),
          _buildUsersTab(),
          _buildReportsTab(),
          _buildAnalyticsTab(),
          _buildPermissionsTab(), // إضافة تبويب الصلاحيات
          _buildMembershipRequestsTab(), // إضافة تبويب طلبات العضوية
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF9C27B0),
              onPressed: () => _showAddCompanyDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildCompaniesTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (approvedCompanies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              texts['noCompanies'] ?? 'No approved companies',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              texts['addFirstCompany'] ?? 'Add first approved company',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddCompanyDialog(context),
              icon: const Icon(Icons.add),
              label: Text(texts['addCompany'] ?? 'Add Company'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: approvedCompanies.length,
      itemBuilder: (context, index) {
        final company = approvedCompanies[index];
        return _buildCompanyCard(company);
      },
    );
  }

  Widget _buildCompanyCard(PreApprovedCompany company) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getUserRoleColor(company.typeString),
          child: Icon(
            _getUserRoleIcon(company.typeString),
            color: Colors.white,
          ),
        ),
        title: Text(company.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${texts['crNumber']}: ${company.commercialRegister}'),
            Text('${texts['contactEmail']}: ${company.contactEmail}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getUserRoleColor(company.type.toString().split('.').last).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getUserRoleText(company.type.toString().split('.').last),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getUserRoleColor(
                          company.type.toString().split('.').last),
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: company.isActive
                        ? Colors.green.withAlpha(26)
                        : Colors.red.withAlpha(26),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    company.isActive
                        ? (texts['active'] ?? 'Active')
                        : (texts['inactive'] ?? 'Inactive'),
                    style: TextStyle(
                      fontSize: 12,
                      color: company.isActive ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Row(
                children: [
                  const Icon(Icons.edit),
                  const SizedBox(width: 8),
                  Text(texts['editCompany'] ?? 'Edit'),
                ],
              ),
              onTap: () => _showEditCompanyDialog(context, company),
            ),
            PopupMenuItem(
              child: Row(
                children: [
                  const Icon(Icons.delete, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(texts['deleteCompany'] ?? 'Delete',
                      style: const TextStyle(color: Colors.red)),
                ],
              ),
              onTap: () => _showDeleteCompanyDialog(context, company),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildUsersTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: systemUsers.length,
      itemBuilder: (context, index) {
        final user = systemUsers[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final role = user['role'] ?? 'client';
    final roleColor = _getUserRoleColor(role);
    final roleText = _getUserRoleText(role);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: roleColor,
          child: Icon(
            _getUserRoleIcon(role),
            color: Colors.white,
          ),
        ),
        title: Text(user['email'] ?? ''),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${texts['joinDate']}: ${user['joinDate']}'),
            Text('${texts['lastActivity']}: ${user['lastActivity']}'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: roleColor.withAlpha(26),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                roleText,
                style: TextStyle(
                  fontSize: 12,
                  color: roleColor,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('عرض التفاصيل'),
                ],
              ),
            ),
            const PopupMenuItem(
              child: Row(
                children: [
                  Icon(Icons.block, color: Colors.red),
                  SizedBox(width: 8),
                  Text('حظر المستخدم', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildReportsTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: systemReports.length,
      itemBuilder: (context, index) {
        final report = systemReports[index];
        return _buildReportCard(report);
      },
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.assessment, color: Colors.white),
        ),
        title: Text(report['title'] ?? ''),
        subtitle: Text('${texts['generatedDate']}: ${report['generatedDate']}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _viewReport(),
              icon: const Icon(Icons.visibility),
            ),
            IconButton(
              onPressed: () => _downloadReport(),
              icon: const Icon(Icons.download),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    final totalUsers = systemUsers.length;
    final totalCompanies = approvedCompanies.length;
    final activeCompanies = approvedCompanies.where((c) => c.isActive).length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '$totalUsers',
                  texts['totalUsers'] ?? 'Total Users',
                  Icons.people,
                  const Color(0xFF2196F3),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  '$totalCompanies',
                  texts['totalCompanies'] ?? 'Total Companies',
                  Icons.business,
                  const Color(0xFF9C27B0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '0', // placeholder
                  texts['totalTransactions'] ?? 'Total Transactions',
                  Icons.receipt,
                  const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  '$activeCompanies',
                  'الشركات النشطة',
                  Icons.check_circle,
                  const Color(0xFFFF9800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // System Health Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    texts['systemHealth'] ?? 'System Health',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildHealthIndicator(
                      'خدمة قاعدة البيانات', 99.8, Colors.green),
                  const SizedBox(height: 8),
                  _buildHealthIndicator('خدمة المصادقة', 100.0, Colors.green),
                  const SizedBox(height: 8),
                  _buildHealthIndicator(
                      'الذاكرة المستخدمة', 67.5, Colors.orange),
                  const SizedBox(height: 8),
                  _buildHealthIndicator('مساحة القرص', 45.2, Colors.green),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String value, String label, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // دالة إنشاء تبويب الصلاحيات
  Widget _buildPermissionsTab() {
    return ChangeNotifierProvider<perm.PermissionManager>(
      create: (_) => perm.PermissionManager(),
      child: Builder(
        builder: (context) {
          // استخدام PermissionManager من داخل Provider
          final permissionManager =
              Provider.of<perm.PermissionManager>(context);

          // الحصول على جميع الأدوار
          const roles = perm.UserRole.values;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  texts['permissions'] ?? 'إدارة الصلاحيات',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
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
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.5,
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
                              builder: (context) => perm.RolePermissionsEditor(
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
                                    Icon(roleIcon, size: 32, color: roleColor),
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

  // دالة إنشاء تبويب طلبات العضوية
  Widget _buildMembershipRequestsTab() {
    return ChangeNotifierProvider<MembershipRequestsManager>(
      create: (_) => MembershipRequestsManager(),
      child: Builder(
        builder: (context) {
          // استخدام MembershipRequestsManager من داخل Provider
          final requestsManager =
              Provider.of<MembershipRequestsManager>(context);

          // الحصول على الطلبات المعلقة
          final pendingRequests = requestsManager.pendingRequests;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  texts['membershipRequests'] ?? 'طلبات العضوية',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  texts['membershipRequestsDesc'] ??
                      'مراجعة وإدارة طلبات العضوية الجديدة',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),

                // إحصائيات طلبات العضوية
                Row(
                  children: [
                    _buildRequestStatCard(
                        context,
                        texts['pending'] ?? 'قيد الانتظار',
                        requestsManager.pendingRequests.length.toString(),
                        Colors.orange,
                        Icons.hourglass_empty),
                    const SizedBox(width: 16),
                    _buildRequestStatCard(
                        context,
                        texts['approved'] ?? 'تمت الموافقة',
                        requestsManager.approvedRequests.length.toString(),
                        Colors.green,
                        Icons.check_circle),
                    const SizedBox(width: 16),
                    _buildRequestStatCard(
                        context,
                        texts['rejected'] ?? 'مرفوض',
                        requestsManager.rejectedRequests.length.toString(),
                        Colors.red,
                        Icons.cancel),
                  ],
                ),

                const SizedBox(height: 24),

                // عنوان قسم الطلبات المعلقة
                Text(
                  texts['pendingRequests'] ?? 'طلبات العضوية المعلقة',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // أزرار العمليات الجماعية
                if (pendingRequests.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle),
                          label:
                              Text(texts['approveAll'] ?? 'الموافقة على الكل'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _showBatchActionConfirmation(
                            context,
                            texts['confirmApproveAll'] ??
                                'هل أنت متأكد من الموافقة على جميع الطلبات المعلقة؟',
                            () => _processBatchAction(requestsManager, true),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.cancel),
                          label: Text(texts['rejectAll'] ?? 'رفض الكل'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _showBatchActionConfirmation(
                            context,
                            texts['confirmRejectAll'] ??
                                'هل أنت متأكد من رفض جميع الطلبات المعلقة؟',
                            () => _processBatchAction(requestsManager, false),
                          ),
                        ),
                      ],
                    ),
                  ),

                // قائمة الطلبات المعلقة
                Expanded(
                  child: pendingRequests.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.mark_email_read,
                                  size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                texts['noRequestsPending'] ??
                                    'لا توجد طلبات عضوية معلقة',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: pendingRequests.length,
                          itemBuilder: (context, index) {
                            final request = pendingRequests[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: _getColorForUserType(
                                              request.userType),
                                          child: Icon(
                                            _getIconForUserType(
                                                request.userType),
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                request.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _getUserTypeText(
                                                    request.userType),
                                                style: TextStyle(
                                                  color: _getColorForUserType(
                                                      request.userType),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'البريد الإلكتروني: ${request.email}',
                                                style: TextStyle(
                                                    color: Colors.grey[700]),
                                              ),
                                              if (request.companyName !=
                                                  null) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  'اسم الشركة: ${request.companyName}',
                                                  style: TextStyle(
                                                      color: Colors.grey[700]),
                                                ),
                                              ],
                                              if (request.phoneNumber !=
                                                  null) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  'رقم الجوال: ${request.phoneNumber}',
                                                  style: TextStyle(
                                                      color: Colors.grey[700]),
                                                ),
                                              ],
                                              const SizedBox(height: 8),
                                              Text(
                                                'تاريخ الطلب: ${_formatDate(request.requestDate)}',
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    const Divider(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () => _showRejectDialog(
                                              context,
                                              requestsManager,
                                              request),
                                          child: Text(
                                            texts['reject'] ?? 'رفض',
                                            style: const TextStyle(
                                                color: Colors.red),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        ElevatedButton(
                                          onPressed: () => _approveRequest(
                                              context,
                                              requestsManager,
                                              request),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                          ),
                                          child: Text(
                                              texts['approve'] ?? 'موافقة'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // بطاقة إحصائيات طلبات العضوية
  Widget _buildRequestStatCard(BuildContext context, String title, String count,
      Color color, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // الحصول على أيقونة نوع المستخدم
  IconData _getIconForUserType(String userType) {
    switch (userType) {
      case 'supplier':
        return Icons.store;
      case 'contractor':
        return Icons.engineering;
      case 'transporter':
        return Icons.local_shipping;
      default:
        return Icons.person;
    }
  }

  // الحصول على لون نوع المستخدم
  Color _getColorForUserType(String userType) {
    switch (userType) {
      case 'supplier':
        return const Color(0xFF4CAF50);
      case 'contractor':
        return const Color(0xFFFF9800);
      case 'transporter':
        return const Color(0xFFE91E63);
      default:
        return Colors.blueGrey;
    }
  }

  // الحصول على نص نوع المستخدم
  String _getUserTypeText(String userType) {
    switch (userType) {
      case 'supplier':
        return texts['supplier'] ?? 'مورد';
      case 'contractor':
        return texts['contractor'] ?? 'مقاول';
      case 'transporter':
        return texts['transporter'] ?? 'ناقل';
      default:
        return userType;
    }
  }

  // تنسيق التاريخ
  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }

  // عرض حوار الرفض
  void _showRejectDialog(BuildContext context,
      MembershipRequestsManager manager, MembershipRequest request) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(texts['rejectRequest'] ?? 'رفض طلب العضوية'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(texts['rejectRequestDesc'] ??
                'يرجى تقديم سبب لرفض طلب العضوية:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: texts['reason'] ?? 'السبب',
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(texts['cancel'] ?? 'إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                manager.rejectRequest(request.id, reasonController.text.trim());
                Navigator.of(ctx).pop();
                _showSnackBar(
                    context, texts['requestRejected'] ?? 'تم رفض الطلب');
              } else {
                _showSnackBar(context,
                    texts['enterRejectionReason'] ?? 'يرجى إدخال سبب الرفض');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(texts['reject'] ?? 'رفض'),
          ),
        ],
      ),
    );
  }

  // الموافقة على طلب العضوية
  void _approveRequest(BuildContext context, MembershipRequestsManager manager,
      MembershipRequest request) {
    manager.approveRequest(request.id);
    _showSnackBar(
        context, texts['requestApproved'] ?? 'تمت الموافقة على الطلب');
    // هنا يجب إضافة منطق إنشاء حساب للمستخدم وإرسال بيانات الدخول له
  }

  // عرض رسالة منبثقة
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildHealthIndicator(String label, double percentage, Color color) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label),
        ),
        Expanded(
          flex: 3,
          child: LinearProgressIndicator(
            value: percentage / 100.0,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddCompanyDialog(BuildContext context) {
    _showCompanyDialog(context, 'إضافة شركة جديدة', null);
  }

  void _showEditCompanyDialog(
      BuildContext context, PreApprovedCompany company) {
    _showCompanyDialog(context, 'تحرير الشركة', company);
  }

  void _showCompanyDialog(
      BuildContext context, String title, PreApprovedCompany? company) {
    final nameController = TextEditingController(text: company?.name ?? '');
    final codeController = TextEditingController(text: company?.code ?? '');
    String selectedType = company?.typeString ?? 'supplier';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'اسم الشركة'),
                  ),
                  TextField(
                    controller: codeController,
                    decoration: const InputDecoration(labelText: 'كود الشركة'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    items: const [
                      DropdownMenuItem(value: 'supplier', child: Text('مورد')),
                      DropdownMenuItem(
                          value: 'contractor', child: Text('مقاول')),
                      DropdownMenuItem(value: 'transport', child: Text('نقل')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedType = value!;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'نوع الشركة'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('إلغاء'),
                ),
                TextButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        codeController.text.isNotEmpty) {
                      UserRole userRole;
                      switch (selectedType) {
                        case 'supplier':
                          userRole = UserRole.supplier;
                          break;
                        case 'contractor':
                          userRole = UserRole.contractor;
                          break;
                        case 'transport':
                          userRole = UserRole.transporter;
                          break;
                        default:
                          userRole = UserRole.supplier;
                      }

                      final newCompany = PreApprovedCompany(
                        id: company?.id ??
                            DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text,
                        commercialRegister: codeController.text,
                        category: BuildingCategory.tools, // قيمة افتراضية
                        type: userRole,
                        city: 'الرياض', // قيمة افتراضية
                        contactEmail: 'info@company.com', // قيمة افتراضية
                        contactPhone: '+966501234567', // قيمة افتراضية
                      );

                      if (company == null) {
                        PreApprovedCompanies.addCompany(newCompany);
                      } else {
                        PreApprovedCompanies.updateCompany(newCompany);
                      }

                      Navigator.of(context).pop();
                      // تحديث الواجهة
                      this.setState(() {});
                    }
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteCompanyDialog(
      BuildContext context, PreApprovedCompany company) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من حذف شركة ${company.name}؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                PreApprovedCompanies.removeCompany(company.id);
                Navigator.of(context).pop();
                // تحديث الواجهة
                setState(() {});
              },
              child: const Text('حذف', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Color _getUserRoleColor(String type) {
    switch (type) {
      case 'supplier':
        return Colors.green;
      case 'contractor':
        return Colors.blue;
      case 'transporter':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getUserRoleText(String type) {
    switch (type) {
      case 'supplier':
        return 'مورد';
      case 'contractor':
        return 'مقاول';
      case 'transporter':
        return 'نقل';
      default:
        return 'غير محدد';
    }
  }

  IconData _getUserRoleIcon(String type) {
    switch (type) {
      case 'supplier':
        return Icons.store;
      case 'contractor':
        return Icons.construction;
      case 'transporter':
        return Icons.local_shipping;
      default:
        return Icons.help;
    }
  }

  void _viewReport() {
    // هنا يمكن إضافة منطق عرض التقارير
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('عرض التقرير - قريباً')),
    );
  }

  void _downloadReport() {
    // هنا يمكن إضافة منطق تحميل التقارير
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تحميل التقرير - قريباً')),
    );
  }

  // عرض مربع حوار تأكيد للعمليات الجماعية
  void _showBatchActionConfirmation(
      BuildContext context, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(texts['confirmation'] ?? 'تأكيد'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(texts['cancel'] ?? 'إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(texts['confirm'] ?? 'تأكيد'),
          ),
        ],
      ),
    );
  }

  // تنفيذ العمليات الجماعية على طلبات العضوية
  void _processBatchAction(
      MembershipRequestsManager requestsManager, bool approve) {
    final pendingRequests = requestsManager.pendingRequests;

    // عرض مؤشر التحميل أثناء المعالجة
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري معالجة الطلبات...'),
          ],
        ),
      ),
    );

    // تأخير صغير لمحاكاة العملية (في التطبيق الحقيقي سيكون هناك اتصال بقاعدة البيانات)
    if (!mounted) return;
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      // معالجة جميع الطلبات المعلقة
      for (var request in List.from(pendingRequests)) {
        if (approve) {
          requestsManager.approveRequest(request['id']);
        } else {
          requestsManager.rejectRequest(
              request['id'], 'تم الرفض بواسطة إجراء جماعي');
        }
      }

      // إغلاق مربع حوار التحميل
      Navigator.of(context).pop();

      // عرض رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(approve
              ? (texts['batchApproveSuccess'] ??
                  'تمت الموافقة على جميع الطلبات بنجاح')
              : (texts['batchRejectSuccess'] ?? 'تم رفض جميع الطلبات بنجاح')),
          backgroundColor: approve ? Colors.green : Colors.red,
        ),
      );

      // تحديث واجهة المستخدم
      setState(() {});
    });
  }
}
