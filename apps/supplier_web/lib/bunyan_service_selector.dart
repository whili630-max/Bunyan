import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_manager.dart';
import 'bunyan_models.dart';
import 'bunyan_auth.dart';

class BunyanServiceSelector extends StatefulWidget {
  const BunyanServiceSelector({super.key});

  @override
  State<BunyanServiceSelector> createState() => _BunyanServiceSelectorState();
}

class _BunyanServiceSelectorState extends State<BunyanServiceSelector> {
  Map<String, String> texts = {
    // قيم افتراضية باللغة العربية
    'title': 'بنيان',
    'subtitle': 'منصة شاملة للخدمات الإنشائية',
    'chooseService': 'اختر نوع الخدمة',
    'client': 'عميل',
    'clientDesc': 'طلب الخدمات والمنتجات الإنشائية',
    'supplier': 'مورد',
    'supplierDesc': 'عرض وبيع المواد والمنتجات الإنشائية',
    'contractor': 'مقاول',
    'contractorDesc': 'تقديم خدمات التشييد والبناء',
    'transporter': 'نقل',
    'transporterDesc': 'خدمات النقل والتوصيل',
    'admin': 'مدير النظام',
    'adminDesc': 'إدارة المنصة والمستخدمين',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTexts();
    });
  }

  void _loadTexts() {
    final languageManager =
        Provider.of<LanguageManager>(context, listen: false);
    final isArabic = languageManager.currentLocale.languageCode == 'ar';

    setState(() {
      texts = {
        'appTitle': isArabic ? 'بنيان' : 'Bunyan',
        'selectService': isArabic ? 'اختر الخدمة' : 'Select Service',
        'chooseService': isArabic
            ? 'اختر الخدمة التي تريد الوصول إليها:'
            : 'Choose the service you want to access:',
        'client': isArabic ? 'عميل' : 'Client',
        'supplier': isArabic ? 'مورد' : 'Supplier',
        'transporter': isArabic ? 'ناقل' : 'Transporter',
        'contractor': isArabic ? 'مقاول' : 'Contractor',
        'admin': isArabic ? 'مدير' : 'Admin',
        'clientDesc': isArabic
            ? 'البحث عن مواد البناء وطلب الخدمات وإدارة المشاريع'
            : 'Search for building materials, request services and manage projects',
        'supplierDesc': isArabic
            ? 'إدارة المنتجات والمخزون، معالجة الطلبات، والتفاعل مع العملاء'
            : 'Manage products and inventory, process orders, and interact with customers',
        'transporterDesc': isArabic
            ? 'توفير خدمات النقل والتريلات للمواد الثقيلة والشحنات'
            : 'Provide transportation and trailer services for heavy materials and shipments',
        'contractorDesc': isArabic
            ? 'إدارة المشاريع الإنشائية والإشراف على التنفيذ'
            : 'Manage construction projects and supervise implementation',
        'adminDesc': isArabic
            ? 'إدارة المنصة والمستخدمين ومراقبة الأداء والإحصائيات'
            : 'Manage platform, users, monitor performance and statistics',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    if (texts.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Colors.white),
            onSelected: (language) {
              languageManager.changeLanguage(language);
              _loadTexts();
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
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000), // 0x1A is 10% opacity
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.business,
                        size: 50,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      texts['selectService'] ?? 'اختر الخدمة',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      texts['chooseService'] ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Services Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildServiceCard(
                    texts['client'] ?? 'عميل',
                    texts['clientDesc'] ?? '',
                    Icons.person,
                    UserRole.client,
                    const Color(0xFF1976D2),
                    '/client',
                  ),
                  const SizedBox(height: 16),
                  _buildServiceCard(
                    texts['supplier'] ?? 'مورد',
                    texts['supplierDesc'] ?? '',
                    Icons.store,
                    UserRole.supplier,
                    const Color(0xFF388E3C),
                    '/supplier',
                  ),
                  const SizedBox(height: 16),
                  _buildServiceCard(
                    texts['transporter'] ?? 'ناقل',
                    texts['transporterDesc'] ?? '',
                    Icons.local_shipping,
                    UserRole.transporter,
                    const Color(0xFFFF8F00),
                    '/transporter',
                  ),
                  const SizedBox(height: 16),
                  _buildServiceCard(
                    texts['contractor'] ?? 'مقاول',
                    texts['contractorDesc'] ?? '',
                    Icons.engineering,
                    UserRole.contractor,
                    const Color(0xFF7B1FA2),
                    '/contractor',
                  ),
                  const SizedBox(height: 16),
                  _buildServiceCard(
                    texts['admin'] ?? 'مدير',
                    texts['adminDesc'] ?? '',
                    Icons.admin_panel_settings,
                    UserRole.admin,
                    const Color(0xFFD32F2F),
                    '/admin',
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'جميع الخدمات آمنة ومعتمدة',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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

  Widget _buildServiceCard(
    String title,
    String description,
    IconData icon,
    UserRole role,
    Color color,
    String route,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToService(role),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToService(UserRole role) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AuthPage(userRole: role),
      ),
    );
  }
}
