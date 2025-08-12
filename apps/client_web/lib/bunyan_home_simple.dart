import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_manager.dart';
import 'bunyan_models.dart';
import 'bunyan_database.dart';

class BunyanHomePage extends StatefulWidget {
  const BunyanHomePage({super.key});

  @override
  State<BunyanHomePage> createState() => _BunyanHomePageState();
}

class _BunyanHomePageState extends State<BunyanHomePage> {
  UserRole? selectedRole;
  bool isLoading = false;
  late Map<String, String> texts;

  @override
  void initState() {
    super.initState();
    _loadTexts();
  }

  void _loadTexts() {
    final languageManager =
        Provider.of<LanguageManager>(context, listen: false);
    final isArabic = languageManager.currentLocale.languageCode == 'ar';

    texts = {
      'appTitle': isArabic ? 'بنيان' : 'Bunyan',
      'appDescription': isArabic
          ? 'تطبيق إلكتروني يربط بين الأشخاص الراغبين في بناء منازل أو تنفيذ مشاريع إنشائية، وجميع مزودي الخدمات والمواد الأساسية في قطاع البناء'
          : 'Electronic application that connects people who want to build houses or implement construction projects, and all service providers and basic materials in the construction sector',
      'selectAccountType': isArabic ? 'اختر نوع الحساب' : 'Select Account Type',
      'pleaseSelectAccount':
          isArabic ? 'يرجى اختيار نوع الحساب:' : 'Please select account type:',
      'client': isArabic ? 'عميل' : 'Client',
      'supplier': isArabic ? 'مورد' : 'Supplier',
      'transporter': isArabic ? 'ناقل' : 'Transporter',
      'contractor': isArabic ? 'مقاول' : 'Contractor',
      'admin': isArabic ? 'مدير' : 'Admin',
      'clientDesc': isArabic
          ? 'واجهة بسيطة، وصول سريع للخدمات، دعم مخصص'
          : 'Simple interface, quick access to services, dedicated support',
      'supplierDesc': isArabic
          ? 'أدوات إدارة، معالجة الطلبات، إدارة المخزون'
          : 'Management tools, order processing, inventory management',
      'transporterDesc': isArabic
          ? 'خدمات النقل والتريلات، إدارة الشحنات'
          : 'Transportation and trailer services, shipment management',
      'contractorDesc': isArabic
          ? 'إدارة المشاريع والإشراف على التنفيذ'
          : 'Project management and implementation supervision',
      'adminDesc': isArabic
          ? 'تحكم كامل، إدارة المستخدمين، تحليلات'
          : 'Full control, user management, analytics',
      'getStarted': isArabic ? 'ابدأ الآن' : 'Get Started',
      'mainFeatures': isArabic ? 'المميزات الرئيسية' : 'Main Features',
      'securitySystem':
          isArabic ? 'نظام حماية آمن' : 'Secure Protection System',
      'productManagement':
          isArabic ? 'إدارة المنتجات والخدمات' : 'Product & Service Management',
      'userPreferences': isArabic
          ? 'تفصيل الصلاحيات حسب نوع المستخدم'
          : 'User type specific permissions',
      'loading': isArabic ? 'جاري التحميل...' : 'Loading...',
      'clientDashboard': isArabic ? 'لوحة تحكم العميل' : 'Client Dashboard',
      'supplierDashboard': isArabic ? 'لوحة تحكم المورد' : 'Supplier Dashboard',
      'transporterDashboard':
          isArabic ? 'لوحة تحكم الناقل' : 'Transporter Dashboard',
      'contractorDashboard':
          isArabic ? 'لوحة تحكم المقاول' : 'Contractor Dashboard',
      'adminDashboard': isArabic ? 'لوحة تحكم المشرف' : 'Admin Dashboard',
    };
  }

  @override
  Widget build(BuildContext context) {
    final languageManager = Provider.of<LanguageManager>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          texts['appTitle'] ?? 'بنيان',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // زر تغيير اللغة
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Colors.white),
            onSelected: (language) {
              languageManager.changeLanguage(language);
              setState(() {
                _loadTexts();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'ar',
                child: Row(
                  children: [
                    Text('🇸🇦'),
                    SizedBox(width: 8),
                    Text('العربية'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'en',
                child: Row(
                  children: [
                    Text('🇺🇸'),
                    SizedBox(width: 8),
                    Text('English'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'ur',
                child: Row(
                  children: [
                    Text('🇵🇰'),
                    SizedBox(width: 8),
                    Text('اردو'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2E7D32),
                    Color(0xFF388E3C),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    // Logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(60),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.business,
                        size: 60,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // App Title & Description
                    Text(
                      texts['appTitle'] ?? 'بنيان',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      texts['appDescription'] ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Account Selection Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    texts['selectAccountType'] ?? 'اختر نوع الحساب',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    texts['pleaseSelectAccount'] ?? 'يرجى اختيار نوع الحساب:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Account Type Cards
                  _buildAccountTypeCard(
                    texts['client'] ?? 'عميل',
                    texts['clientDesc'] ??
                        'واجهة بسيطة، وصول سريع للخدمات، دعم مخصص',
                    Icons.person,
                    UserRole.client,
                    const Color(0xFF1976D2),
                  ),
                  const SizedBox(height: 16),

                  _buildAccountTypeCard(
                    texts['supplier'] ?? 'مورد',
                    texts['supplierDesc'] ??
                        'أدوات إدارة، معالجة الطلبات، إدارة المخزون',
                    Icons.store,
                    UserRole.supplier,
                    const Color(0xFF388E3C),
                  ),
                  const SizedBox(height: 16),

                  _buildAccountTypeCard(
                    texts['transporter'] ?? 'ناقل',
                    texts['transporterDesc'] ??
                        'خدمات النقل والتريلات، إدارة الشحنات',
                    Icons.local_shipping,
                    UserRole.transporter,
                    const Color(0xFFFF8F00),
                  ),
                  const SizedBox(height: 16),

                  _buildAccountTypeCard(
                    texts['contractor'] ?? 'مقاول',
                    texts['contractorDesc'] ??
                        'إدارة المشاريع والإشراف على التنفيذ',
                    Icons.engineering,
                    UserRole.contractor,
                    const Color(0xFF7B1FA2),
                  ),
                  const SizedBox(height: 16),

                  _buildAccountTypeCard(
                    texts['admin'] ?? 'مدير',
                    texts['adminDesc'] ??
                        'تحكم كامل، إدارة المستخدمين، تحليلات',
                    Icons.admin_panel_settings,
                    UserRole.admin,
                    const Color(0xFFD32F2F),
                  ),
                ],
              ),
            ),

            // Continue Button
            if (selectedRole != null) ...[
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: ElevatedButton(
                  onPressed: isLoading ? null : _continueWithSelectedRole,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(texts['loading'] ?? 'جاري التحميل...'),
                          ],
                        )
                      : Text(
                          texts['getStarted'] ?? 'ابدأ الآن',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],

            // Features Section
            Container(
              width: double.infinity,
              color: Colors.grey[100],
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Text(
                    texts['mainFeatures'] ?? 'المميزات الرئيسية',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFeatureCard(
                          Icons.security,
                          texts['securitySystem'] ?? 'نظام حماية آمن',
                          const Color(0xFF1976D2),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFeatureCard(
                          Icons.inventory_2,
                          texts['productManagement'] ??
                              'إدارة المنتجات والخدمات',
                          const Color(0xFF388E3C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureCard(
                    Icons.people,
                    texts['userPreferences'] ??
                        'تفصيل الصلاحيات حسب نوع المستخدم',
                    const Color(0xFFFF8F00),
                  ),
                ],
              ),
            ),

            // Bottom Notice
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.yellow[100],
                border: Border(
                  top: BorderSide(color: Colors.yellow[300]!),
                  bottom: BorderSide(color: Colors.yellow[300]!),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'جميع الأكواد المستخدمة في هذا التطبيق أصلية ومفتوحة المصدر',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTypeCard(String title, String description, IconData icon,
      UserRole role, Color color) {
    final isSelected = selectedRole == role;

    return Card(
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? color : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedRole = role;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? color : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected) Icon(Icons.check_circle, color: color, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _continueWithSelectedRole() async {
    setState(() {
      isLoading = true;
    });

    try {
      // محاكاة تحميل البيانات
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      // التوجه لواجهة المستخدم المحددة
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => BunyanDashboard(userRole: selectedRole!),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}

// لوحة التحكم الموحدة
class BunyanDashboard extends StatefulWidget {
  final UserRole userRole;

  const BunyanDashboard({super.key, required this.userRole});

  @override
  State<BunyanDashboard> createState() => _BunyanDashboardState();
}

class _BunyanDashboardState extends State<BunyanDashboard> {
  final BunyanDatabaseHelper _database = BunyanDatabaseHelper();
  List<BuildingProduct> products = [];
  List<BuildingOrder> orders = [];
  Map<String, dynamic> statistics = {};
  bool isLoading = true;
  late Map<String, String> texts;

  @override
  void initState() {
    super.initState();
    _loadTexts();
    _loadData();
  }

  void _loadTexts() {
    final languageManager =
        Provider.of<LanguageManager>(context, listen: false);
    final isArabic = languageManager.currentLocale.languageCode == 'ar';

    texts = {
      'clientDashboard': isArabic ? 'لوحة تحكم العميل' : 'Client Dashboard',
      'supplierDashboard': isArabic ? 'لوحة تحكم المورد' : 'Supplier Dashboard',
      'transporterDashboard':
          isArabic ? 'لوحة تحكم الناقل' : 'Transporter Dashboard',
      'contractorDashboard':
          isArabic ? 'لوحة تحكم المقاول' : 'Contractor Dashboard',
      'adminDashboard': isArabic ? 'لوحة تحكم المشرف' : 'Admin Dashboard',
      'buildingCategories': isArabic ? 'فئات البناء' : 'Building Categories',
      'plumbing': isArabic ? 'سباكة' : 'Plumbing',
      'electrical': isArabic ? 'كهرباء' : 'Electrical',
      'steel': isArabic ? 'حديد' : 'Steel',
      'blocks': isArabic ? 'بلك' : 'Blocks',
      'tools': isArabic ? 'أدوات' : 'Tools',
      'featuredProducts': isArabic ? 'المنتجات المميزة' : 'Featured Products',
      'myProducts': isArabic ? 'منتجاتي' : 'My Products',
      'orders': isArabic ? 'الطلبات' : 'Orders',
      'statistics': isArabic ? 'الإحصائيات' : 'Statistics',
      'users': isArabic ? 'المستخدمين' : 'Users',
      'products': isArabic ? 'المنتجات' : 'Products',
      'revenue': isArabic ? 'الإيرادات' : 'Revenue',
      'sar': isArabic ? 'ريال' : 'SAR',
    };
  }

  Future<void> _loadData() async {
    try {
      switch (widget.userRole) {
        case UserRole.client:
          products = await _database.getAllProducts();
          break;
        case UserRole.supplier:
          products = await _database.getProductsBySupplier('supplier_001');
          orders = await _database.getOrdersBySupplier('supplier_001');
          break;
        case UserRole.admin:
          products = await _database.getAllProducts();
          orders = await _database.getAllOrders();
          statistics = await _database.getStatistics();
          break;
        case UserRole.transporter:
        case UserRole.contractor:
          break;
      }
    } catch (e) {
      debugPrint('خطأ في تحميل البيانات: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: Text(_getDashboardTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const BunyanHomePage()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDashboardContent(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  String _getDashboardTitle() {
    switch (widget.userRole) {
      case UserRole.client:
        return texts['clientDashboard'] ?? 'لوحة تحكم العميل';
      case UserRole.supplier:
        return texts['supplierDashboard'] ?? 'لوحة تحكم المورد';
      case UserRole.transporter:
        return texts['transporterDashboard'] ?? 'لوحة تحكم الناقل';
      case UserRole.contractor:
        return texts['contractorDashboard'] ?? 'لوحة تحكم المقاول';
      case UserRole.admin:
        return texts['adminDashboard'] ?? 'لوحة تحكم المشرف';
    }
  }

  Widget _buildDashboardContent() {
    switch (widget.userRole) {
      case UserRole.client:
        return _buildClientDashboard();
      case UserRole.supplier:
        return _buildSupplierDashboard();
      case UserRole.admin:
        return _buildAdminDashboard();
      case UserRole.transporter:
        return _buildTransporterDashboard();
      case UserRole.contractor:
        return _buildContractorDashboard();
    }
  }

  Widget _buildClientDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    texts['buildingCategories'] ?? 'فئات البناء',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    children: [
                      _buildCategoryCard(texts['plumbing'] ?? 'سباكة',
                          Icons.plumbing, BuildingCategory.plumbing),
                      _buildCategoryCard(
                          texts['electrical'] ?? 'كهرباء',
                          Icons.electrical_services,
                          BuildingCategory.electrical),
                      _buildCategoryCard('خرسانة', Icons.foundation,
                          BuildingCategory.concrete),
                      _buildCategoryCard(texts['blocks'] ?? 'بلك',
                          Icons.view_module, BuildingCategory.blocks),
                      _buildCategoryCard(texts['steel'] ?? 'حديد',
                          Icons.construction, BuildingCategory.steel),
                      _buildCategoryCard(texts['tools'] ?? 'أدوات', Icons.build,
                          BuildingCategory.tools),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            texts['featuredProducts'] ?? 'المنتجات المميزة',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...products.take(5).map((product) => _buildProductCard(product)),
        ],
      ),
    );
  }

  Widget _buildSupplierDashboard() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: texts['myProducts'] ?? 'منتجاتي'),
              Tab(text: texts['orders'] ?? 'الطلبات'),
              Tab(text: texts['statistics'] ?? 'الإحصائيات'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // منتجاتي
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (context, index) =>
                      _buildProductCard(products[index]),
                ),
                // الطلبات
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) =>
                      _buildOrderCard(orders[index]),
                ),
                // الإحصائيات
                const Center(child: Text('الإحصائيات قيد التطوير')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  texts['users'] ?? 'المستخدمين',
                  statistics['usersCount']?.toString() ?? '0',
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  texts['orders'] ?? 'الطلبات',
                  statistics['ordersCount']?.toString() ?? '0',
                  Icons.shopping_cart,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  texts['products'] ?? 'المنتجات',
                  statistics['productsCount']?.toString() ?? '0',
                  Icons.inventory,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  texts['revenue'] ?? 'الإيرادات',
                  '${statistics['totalRevenue']?.toStringAsFixed(0) ?? '0'} ${texts['sar'] ?? 'ريال'}',
                  Icons.monetization_on,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransporterDashboard() {
    return const Center(child: Text('لوحة تحكم الناقل قيد التطوير'));
  }

  Widget _buildContractorDashboard() {
    return const Center(child: Text('لوحة تحكم المقاول قيد التطوير'));
  }

  Widget _buildCategoryCard(
      String name, IconData icon, BuildingCategory category) {
    return Card(
      child: InkWell(
        onTap: () {
          // التوجه لصفحة المنتجات بالفئة المحددة
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم اختيار فئة: $name')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: const Color(0xFF2E7D32)),
              const SizedBox(height: 8),
              Text(name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildingProduct product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF2E7D32),
          child: Text(product.name.substring(0, 1),
              style: const TextStyle(color: Colors.white)),
        ),
        title: Text(product.name),
        subtitle:
            Text('${product.price} ${texts['sar'] ?? 'ريال'}/${product.unit}'),
        trailing: Text(buildingCategoryNames[product.category] ?? ''),
      ),
    );
  }

  Widget _buildOrderCard(BuildingOrder order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(order.status),
          child: const Icon(Icons.shopping_cart, color: Colors.white),
        ),
        title: Text('طلب #${order.id.substring(0, 8)}'),
        subtitle: Text(
            '${order.totalAmount} ${texts['sar'] ?? 'ريال'} - ${orderStatusNames[order.status]}'),
        trailing: Text(order.createdAt.day.toString()),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(value,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.accepted:
        return Colors.blue;
      case OrderStatus.inProgress:
        return Colors.purple;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  Widget? _buildFloatingActionButton() {
    if (widget.userRole == UserRole.supplier) {
      return FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('سيتم فتح نموذج إضافة منتج')),
          );
        },
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add),
      );
    }
    return null;
  }
}
