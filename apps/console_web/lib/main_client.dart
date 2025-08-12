import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart';
import 'language_manager.dart';
import 'membership_requests.dart';
import 'permissions.dart';
import 'auth.dart';

// نقطة دخول موقع العملاء الرئيسي
void main() {
  runApp(const BunyanClientSite());
}

class BunyanClientSite extends StatelessWidget {
  const BunyanClientSite({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LanguageManager()),
        ChangeNotifierProvider(
            create: (context) => MembershipRequestsManager()),
        ChangeNotifierProvider(create: (context) => PermissionManager()),
      ],
      child: Consumer<LanguageManager>(
        builder: (context, languageManager, child) {
          return MaterialApp(
            title: 'بنيان - منصة البناء والإنشاءات',
            debugShowCheckedModeBanner: false,
            locale: languageManager.currentLocale,
            supportedLocales: const [
              Locale('ar', ''),
              Locale('en', ''),
              Locale('ur', ''),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              primarySwatch: Colors.blue,
              primaryColor: const Color(0xFF1565C0),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1565C0),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              fontFamily: 'Arial',
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1565C0),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
            home: const ClientSiteHomePage(),
            routes: {
              '/client/register': (context) =>
                  const AuthPage(userType: 'client'),
              '/admin_portal': (context) => const AdminPortalRedirectPage(),
            },
          );
        },
      ),
    );
  }
}

// صفحة الموقع الرئيسي للعملاء
class ClientSiteHomePage extends StatelessWidget {
  const ClientSiteHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بنيان - منصة البناء والإنشاءات'),
        centerTitle: true,
        actions: [
          // زر الانتقال للبوابة الإدارية
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'البوابة الإدارية',
            onPressed: () {
              Navigator.pushNamed(context, '/admin_portal');
            },
          ),
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: 'تغيير اللغة',
            onPressed: () {
              // عرض خيارات تغيير اللغة
              _showLanguageOptions(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // قسم الترحيب
            Container(
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade700,
                    Colors.blue.shade500,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'أهلاً بك في بنيان',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'المنصة الأولى للتواصل بين العملاء ومزودي خدمات البناء',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // التوجيه إلى صفحة تسجيل العميل
                          Navigator.pushNamed(context, '/client/register');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                        child: const Text(
                          'التسجيل كعميل',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton(
                        onPressed: () {
                          // التوجيه إلى صفحة تسجيل الدخول
                          _showLoginDialog(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                        child: const Text(
                          'تسجيل الدخول',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // قسم المميزات
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'خدماتنا المميزة',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildFeatureCard(
                        Icons.shopping_cart,
                        'موردي مواد البناء',
                        'تواصل مباشرة مع موردي مواد البناء الموثوقين',
                        Colors.green,
                      ),
                      _buildFeatureCard(
                        Icons.engineering,
                        'مقاولي البناء',
                        'احصل على خدمات مقاولي البناء المعتمدين',
                        Colors.orange,
                      ),
                      _buildFeatureCard(
                        Icons.local_shipping,
                        'خدمات النقل',
                        'خدمات نقل مواد البناء بأفضل الأسعار',
                        Colors.pink,
                      ),
                      _buildFeatureCard(
                        Icons.payments,
                        'أسعار تنافسية',
                        'مقارنة الأسعار بين مختلف الموردين والمقاولين',
                        Colors.purple,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // قسم مواد البناء
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.grey[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'استكشف مواد البناء',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'تصفح مجموعة واسعة من مواد البناء من الموردين المعتمدين',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildMaterialCard('أسمنت', 'assets/cement.png'),
                      _buildMaterialCard('حديد', 'assets/steel.png'),
                      _buildMaterialCard('بلك', 'assets/blocks.png'),
                      _buildMaterialCard('خرسانة', 'assets/concrete.png'),
                      _buildMaterialCard('كهرباء', 'assets/electrical.png'),
                      _buildMaterialCard('سباكة', 'assets/plumbing.png'),
                      _buildMaterialCard('أبواب ونوافذ', 'assets/doors.png'),
                      _buildMaterialCard('دهانات', 'assets/paint.png'),
                    ],
                  ),
                ],
              ),
            ),

            // قسم كيفية عمل المنصة
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'كيف تعمل منصتنا',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStepCard(
                          '1',
                          'سجل كعميل',
                          'أنشئ حساب على المنصة واستفد من جميع الخدمات',
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStepCard(
                          '2',
                          'تصفح الخدمات',
                          'استعرض موردي ومقاولي البناء المعتمدين',
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStepCard(
                          '3',
                          'اطلب عروض الأسعار',
                          'اطلب عروض أسعار لمشروع البناء الخاص بك',
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStepCard(
                          '4',
                          'اختر العرض المناسب',
                          'قارن العروض واختر العرض المناسب لميزانيتك',
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // تذييل الصفحة
            Container(
              padding: const EdgeInsets.all(32),
              color: Colors.blue[900],
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'بنيان',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'منصة بنيان هي منصة إلكترونية تربط بين الأشخاص الراغبين في بناء منازل أو تنفيذ مشاريع إنشائية، وجميع مزودي الخدمات والمواد الأساسية في قطاع البناء.',
                              style: TextStyle(
                                color: Colors.white70,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'تواصل معنا',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildContactItem(
                              Icons.email,
                              'البريد الإلكتروني',
                              'info@bunyan.com',
                            ),
                            const SizedBox(height: 12),
                            _buildContactItem(
                              Icons.phone,
                              'رقم الهاتف',
                              '+966 12 345 6789',
                            ),
                            const SizedBox(height: 12),
                            _buildContactItem(
                              Icons.location_on,
                              'العنوان',
                              'الرياض، المملكة العربية السعودية',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'روابط سريعة',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildFooterLink('الرئيسية'),
                            _buildFooterLink('عن المنصة'),
                            _buildFooterLink('اتصل بنا'),
                            _buildFooterLink('الشروط والأحكام'),
                            _buildFooterLink('سياسة الخصوصية'),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/admin_portal');
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text(
                                'البوابة الإدارية',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 24),
                  const Text(
                    'جميع الحقوق محفوظة © 2025 بنيان - منصة البناء والإنشاءات',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // إنشاء بطاقة ميزة
  Widget _buildFeatureCard(
      IconData icon, String title, String description, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withAlpha(51),
              child: Icon(
                icon,
                size: 28,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // إنشاء بطاقة مادة بناء
  Widget _buildMaterialCard(String name, String imagePath) {
    // يمكن استبدال هذا لاحقاً بصور حقيقية
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category,
              size: 36,
              color: Colors.blue[700],
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // إنشاء بطاقة خطوة
  Widget _buildStepCard(
      String number, String title, String description, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color,
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // إنشاء عنصر اتصال في التذييل
  Widget _buildContactItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.white70,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // إنشاء رابط في التذييل
  Widget _buildFooterLink(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextButton(
        onPressed: () {
          // تنفيذ الانتقال للصفحة المطلوبة
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

  // عرض خيارات اللغة
  void _showLanguageOptions(BuildContext context) {
    final languageManager =
        Provider.of<LanguageManager>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'اختر اللغة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Text('ع', style: TextStyle(color: Colors.white)),
                ),
                title: const Text('العربية'),
                onTap: () {
                  languageManager.setLocale(const Locale('ar'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text('E', style: TextStyle(color: Colors.white)),
                ),
                title: const Text('English'),
                onTap: () {
                  languageManager.setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.amber,
                  child: Text('ا', style: TextStyle(color: Colors.white)),
                ),
                title: const Text('اردو'),
                onTap: () {
                  languageManager.setLocale(const Locale('ur'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // عرض نافذة تسجيل الدخول
  void _showLoginDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String email = '';
    String password = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تسجيل دخول العميل'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'يرجى إدخال البريد الإلكتروني'
                      : null,
                  onSaved: (value) => email = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'كلمة المرور',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) => value == null || value.isEmpty
                      ? 'يرجى إدخال كلمة المرور'
                      : null,
                  onSaved: (value) => password = value ?? '',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  // هنا سيتم تنفيذ عملية تسجيل الدخول
                  if (kDebugMode) {
                    debugPrint('Email: $email, Password: $password');
                  }
                  Navigator.of(context).pop();
                }
              },
              child: const Text('دخول'),
            ),
          ],
        );
      },
    );
  }
}

// صفحة إعادة التوجيه للبوابة الإدارية
class AdminPortalRedirectPage extends StatelessWidget {
  const AdminPortalRedirectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('البوابة الإدارية'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.admin_panel_settings,
                size: 64,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'البوابة الإدارية',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'هذه البوابة مخصصة للموردين والمقاولين والناقلين ومدراء النظام.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () async {
                  // حفظ تفضيل المستخدم للبوابة الإدارية
                  // في التطبيق الحقيقي سيتم إعادة تشغيل التطبيق للانتقال للبوابة الإدارية
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('جاري الانتقال للبوابة الإدارية...')),
                  );

                  // يمكن استخدام وسيلة أخرى مثل تغيير الصفحة الحالية
                  // أو إعادة تشغيل التطبيق لكن للتبسيط نستخدم المحاكاة
                  Future.delayed(const Duration(seconds: 2), () {
                    // هنا يمكن استدعاء الدالة التي تحفظ تفضيل المستخدم وإعادة التشغيل
                    Navigator.pop(context);
                  });
                },
                icon: const Icon(Icons.launch),
                label: const Text('الانتقال للبوابة الإدارية'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('العودة للموقع الرئيسي'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
