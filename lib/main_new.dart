import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const BunyanApp());
}

class BunyanApp extends StatelessWidget {
  const BunyanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'بنيان - نظام إدارة الأعمال',
      locale: const Locale('ar'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Arial',
        textTheme: const TextTheme().apply(fontSizeFactor: 1.1),
      ),
      home: const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appTitle),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue[50]!, Colors.white],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // الشعار
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue[700],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.business_center,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // العنوان الرئيسي
                  Text(
                    localizations.appTitle,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                  ),
                  const SizedBox(height: 12),

                  // الوصف
                  Text(
                    'منصة إدارة الأعمال الشاملة\nللعملاء والموردين والمديرين',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // الميزات
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A9E9E9E), // 0x1A is 10% opacity
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'المميزات الرئيسية',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                  ),
                        ),
                        const SizedBox(height: 20),
                        _buildFeatureItem('🔐', 'نظام مصادقة آمن'),
                        _buildFeatureItem('📊', 'إدارة المنتجات والخدمات'),
                        _buildFeatureItem(
                            '👥', 'تفصيل الصلاحيات حسب نوع المستخدم'),
                        _buildFeatureItem('🌐', 'دعم اللغة العربية الكامل'),
                        _buildFeatureItem('💾', 'قاعدة بيانات محلية آمنة'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // أزرار الانتقال
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UserTypeSelection(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'بدء الاستخدام',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            _showInfoDialog(context);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue[700],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.blue[700]!),
                          ),
                          child: const Text(
                            'معلومات حول النظام',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('حول نظام بنيان'),
            content: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('نظام بنيان هو منصة شاملة لإدارة الأعمال تهدف إلى:'),
                  SizedBox(height: 12),
                  Text('• ربط العملاء بالموردين'),
                  Text('• تسهيل عمليات البيع والشراء'),
                  Text('• إدارة المخزون والمنتجات'),
                  Text('• تقديم تقارير مفصلة للإدارة'),
                  Text('• دعم كامل للغة العربية'),
                  SizedBox(height: 12),
                  Text('جميع الأكواد المستخدمة أصلية ومفتوحة المصدر.'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('حسناً'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class UserTypeSelection extends StatelessWidget {
  const UserTypeSelection({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.selectAccountType),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                localizations.pleaseSelectAccount,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Column(
                  children: [
                    _buildUserTypeCard(
                      context: context,
                      icon: Icons.person,
                      title: localizations.client,
                      description: localizations.clientDesc,
                      color: Colors.green,
                      onTap: () => _navigateToDemo(context, 'client'),
                    ),
                    const SizedBox(height: 20),
                    _buildUserTypeCard(
                      context: context,
                      icon: Icons.business,
                      title: localizations.supplier,
                      description: localizations.supplierDesc,
                      color: Colors.orange,
                      onTap: () => _navigateToDemo(context, 'supplier'),
                    ),
                    const SizedBox(height: 20),
                    _buildUserTypeCard(
                      context: context,
                      icon: Icons.admin_panel_settings,
                      title: localizations.admin,
                      description: localizations.adminDesc,
                      color: Colors.red,
                      onTap: () => _navigateToDemo(context, 'admin'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withAlpha(26), Colors.white],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: Colors.white),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDemo(BuildContext context, String userType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardDemo(userType: userType),
      ),
    );
  }
}

class DashboardDemo extends StatelessWidget {
  final String userType;

  const DashboardDemo({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    String title;
    IconData icon;
    Color color;

    switch (userType) {
      case 'client':
        title = localizations.clientDashboard;
        icon = Icons.person;
        color = Colors.green;
        break;
      case 'supplier':
        title = localizations.supplierDashboard;
        icon = Icons.business;
        color = Colors.orange;
        break;
      case 'admin':
        title = localizations.adminDashboard;
        icon = Icons.admin_panel_settings;
        color = Colors.red;
        break;
      default:
        title = 'لوحة التحكم';
        icon = Icons.dashboard;
        color = Colors.blue;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: color,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('نظام الإشعارات قيد التطوير')),
              );
            },
            icon: const Icon(Icons.notifications),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ترحيب
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withAlpha(179)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, color: Colors.white, size: 32),
                        const SizedBox(width: 12),
                        Text(
                          localizations.welcome,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'مرحباً بك في $title',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withAlpha(230),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // الخدمات المتاحة
              Text(
                localizations.availableServices,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // شبكة الخدمات
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: _getServicesForUserType(context, userType, color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _getServicesForUserType(
      BuildContext context, String userType, Color color) {
    switch (userType) {
      case 'client':
        return [
          _buildServiceCard(
              'المنتجات', Icons.inventory, 'تصفح المنتجات المتاحة', color),
          _buildServiceCard('طلبات الأسعار', Icons.request_quote,
              'إدارة طلبات الأسعار', color),
          _buildServiceCard(
              'الطلبات', Icons.shopping_cart, 'متابعة طلباتك', color),
          _buildServiceCard(
              'الدعم الفني', Icons.support_agent, 'تواصل مع الدعم', color),
        ];
      case 'supplier':
        return [
          _buildServiceCard(
              'منتجاتي', Icons.inventory_2, 'إدارة منتجاتي', color),
          _buildServiceCard(
              'الطلبات الواردة', Icons.mail, 'معالجة الطلبات', color),
          _buildServiceCard('المخزون', Icons.warehouse, 'إدارة المخزون', color),
          _buildServiceCard(
              'التقارير', Icons.analytics, 'تقارير المبيعات', color),
        ];
      case 'admin':
        return [
          _buildServiceCard('إدارة المستخدمين', Icons.people,
              'إدارة العملاء والموردين', color),
          _buildServiceCard('النظام', Icons.settings, 'إعدادات النظام', color),
          _buildServiceCard(
              'الإحصائيات', Icons.bar_chart, 'إحصائيات شاملة', color),
          _buildServiceCard('السجلات', Icons.history, 'سجل العمليات', color),
        ];
      default:
        return [];
    }
  }

  Widget _buildServiceCard(
      String title, IconData icon, String description, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
