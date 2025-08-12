import 'l10n/app_localizations.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageManager = Provider.of<LanguageManager>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.appTitle,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // زر تغيير اللغة
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language, color: Colors.white),
            onSelected: (locale) {
              languageManager.setLocale(locale);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: Locale('ar'),
                child: Row(
                  children: [
                    Text('🇸🇦'),
                    SizedBox(width: 8),
                    Text('العربية'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: Locale('en'),
                child: Row(
                  children: [
                    Text('🇺🇸'),
                    SizedBox(width: 8),
                    Text('English'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: Locale('ur'),
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
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
                      l10n.appTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.appDescription,
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
                    l10n.selectAccountType,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.pleaseSelectAccount,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Account Type Cards
                  _buildAccountTypeCard(
                    l10n.client,
                    l10n.clientDesc,
                    Icons.person,
                    UserRole.client,
                    const Color(0xFF1976D2),
                  ),
                  const SizedBox(height: 16),

                  _buildAccountTypeCard(
                    l10n.supplier,
                    l10n.supplierDesc,
                    Icons.store,
                    UserRole.supplier,
                    const Color(0xFF388E3C),
                  ),
                  const SizedBox(height: 16),

                  _buildAccountTypeCard(
                    l10n.transporter,
                    l10n.transporterDesc,
                    Icons.local_shipping,
                    UserRole.transporter,
                    const Color(0xFFFF8F00),
                  ),
                  const SizedBox(height: 16),

                  _buildAccountTypeCard(
                    l10n.contractor,
                    l10n.contractorDesc,
                    Icons.engineering,
                    UserRole.contractor,
                    const Color(0xFF7B1FA2),
                  ),
                  const SizedBox(height: 16),

                  _buildAccountTypeCard(
                    l10n.admin,
                    l10n.adminDesc,
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
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('جاري التحميل...'),
                          ],
                        )
                      : Text(
                          l10n.getStarted,
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
                    l10n.mainFeatures,
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
                          l10n.securitySystem,
                          const Color(0xFF1976D2),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFeatureCard(
                          Icons.inventory_2,
                          l10n.productManagement,
                          const Color(0xFF388E3C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureCard(
                    Icons.people,
                    l10n.userPreferences,
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
                  color: color.withAlpha(26),
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
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
          // تحميل طلبات النقل
          break;
        case UserRole.contractor:
          // تحميل المشاريع
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: Text(_getDashboardTitle(l10n)),
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
          : _buildDashboardContent(l10n),
      floatingActionButton: _buildFloatingActionButton(l10n),
    );
  }

  String _getDashboardTitle(AppLocalizations l10n) {
    switch (widget.userRole) {
      case UserRole.client:
        return l10n.clientDashboard;
      case UserRole.supplier:
        return l10n.supplierDashboard;
      case UserRole.transporter:
        return l10n.transporterDashboard;
      case UserRole.contractor:
        return l10n.contractorDashboard;
      case UserRole.admin:
        return l10n.adminDashboard;
    }
  }

  Widget _buildDashboardContent(AppLocalizations l10n) {
    switch (widget.userRole) {
      case UserRole.client:
        return _buildClientDashboard(l10n);
      case UserRole.supplier:
        return _buildSupplierDashboard(l10n);
      case UserRole.admin:
        return _buildAdminDashboard(l10n);
      case UserRole.transporter:
        return _buildTransporterDashboard(l10n);
      case UserRole.contractor:
        return _buildContractorDashboard(l10n);
    }
  }

  Widget _buildClientDashboard(AppLocalizations l10n) {
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
                    l10n.buildingCategories,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    children: [
                      _buildCategoryCard(l10n.plumbing, Icons.plumbing,
                          BuildingCategory.plumbing),
                      _buildCategoryCard(
                          l10n.electrical,
                          Icons.electrical_services,
                          BuildingCategory.electrical),
                      _buildCategoryCard(l10n.concrete, Icons.foundation,
                          BuildingCategory.concrete),
                      _buildCategoryCard(l10n.blocks, Icons.view_module,
                          BuildingCategory.blocks),
                      _buildCategoryCard(l10n.steel, Icons.construction,
                          BuildingCategory.steel),
                      _buildCategoryCard(
                          l10n.tools, Icons.build, BuildingCategory.tools),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.featuredProducts,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...products.take(5).map((product) => _buildProductCard(product)),
        ],
      ),
    );
  }

  Widget _buildSupplierDashboard(AppLocalizations l10n) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: l10n.myProducts),
              Tab(text: l10n.orders),
              Tab(text: l10n.statistics),
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
                      _buildOrderCard(orders[index], l10n),
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

  Widget _buildAdminDashboard(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'المستخدمين',
                  statistics['usersCount']?.toString() ?? '0',
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'الطلبات',
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
                  'المنتجات',
                  statistics['productsCount']?.toString() ?? '0',
                  Icons.inventory,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'الإيرادات',
                  '${statistics['totalRevenue']?.toStringAsFixed(0) ?? '0'} ريال',
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

  Widget _buildTransporterDashboard(AppLocalizations l10n) {
    return const Center(child: Text('لوحة تحكم الناقل قيد التطوير'));
  }

  Widget _buildContractorDashboard(AppLocalizations l10n) {
    return const Center(child: Text('لوحة تحكم المقاول قيد التطوير'));
  }

  Widget _buildCategoryCard(
      String name, IconData icon, BuildingCategory category) {
    return Card(
      child: InkWell(
        onTap: () {
          // التوجه لصفحة المنتجات بالفئة المحددة
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
        subtitle: Text('${product.price} ريال/${product.unit}'),
        trailing: Text(buildingCategoryNames[product.category] ?? ''),
      ),
    );
  }

  Widget _buildOrderCard(BuildingOrder order, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(order.status),
          child: const Icon(Icons.shopping_cart, color: Colors.white),
        ),
        title: Text('طلب #${order.id.substring(0, 8)}'),
        subtitle: Text(
            '${order.totalAmount} ريال - ${orderStatusNames[order.status]}'),
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

  Widget? _buildFloatingActionButton(AppLocalizations l10n) {
    if (widget.userRole == UserRole.supplier) {
      return FloatingActionButton(
        onPressed: () {
          // فتح نموذج إضافة منتج
        },
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add),
      );
    }
    return null;
  }
}
