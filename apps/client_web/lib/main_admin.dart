import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'language_manager.dart';
import 'membership_requests.dart';
import 'permissions.dart';
import 'auth.dart';
import 'admin_service_page.dart';

// نقطة دخول البوابة الإدارية للموردين والمقاولين والناقلين والمدراء
void main() {
  runApp(const BunyanAdminPortal());
}

class BunyanAdminPortal extends StatefulWidget {
  const BunyanAdminPortal({super.key});

  @override
  State<BunyanAdminPortal> createState() => _BunyanAdminPortalState();
}

class _BunyanAdminPortalState extends State<BunyanAdminPortal> {
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
            title: 'بنيان - البوابة الإدارية',
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
              primarySwatch: Colors.green,
              primaryColor: const Color(0xFF2E7D32),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2E7D32),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              fontFamily: 'Arial',
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
            home: const AdminPortalHomePage(),
            routes: {
              '/admin': (context) => const AdminServicePage(),
              '/supplier/register': (context) =>
                  const AuthPage(userType: 'supplier'),
              '/contractor/register': (context) =>
                  const AuthPage(userType: 'contractor'),
              '/transporter/register': (context) =>
                  const AuthPage(userType: 'transporter'),
            },
          );
        },
      ),
    );
  }
}

// صفحة البوابة الإدارية الرئيسية
class AdminPortalHomePage extends StatefulWidget {
  const AdminPortalHomePage({super.key});

  @override
  State<AdminPortalHomePage> createState() => _AdminPortalHomePageState();
}

class _AdminPortalHomePageState extends State<AdminPortalHomePage> {
  final Map<String, String> adminOptions = {
    'admin': 'مدير النظام',
    'supplier': 'مورد',
    'contractor': 'مقاول',
    'transporter': 'ناقل',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بنيان - البوابة الإدارية'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Text(
                'مرحباً بك في البوابة الإدارية',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'يرجى اختيار نوع الحساب للدخول أو التسجيل',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 48),

            // عرض خيارات الدخول/التسجيل لكل نوع
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: adminOptions.length,
                itemBuilder: (context, index) {
                  final userType = adminOptions.keys.elementAt(index);
                  final title = adminOptions.values.elementAt(index);

                  // تحديد لون وأيقونة لكل نوع
                  Color cardColor;
                  IconData cardIcon;

                  switch (userType) {
                    case 'admin':
                      cardColor = Colors.purple;
                      cardIcon = Icons.admin_panel_settings;
                      break;
                    case 'supplier':
                      cardColor = Colors.green;
                      cardIcon = Icons.store;
                      break;
                    case 'contractor':
                      cardColor = Colors.orange;
                      cardIcon = Icons.engineering;
                      break;
                    case 'transporter':
                      cardColor = Colors.pink;
                      cardIcon = Icons.local_shipping;
                      break;
                    default:
                      cardColor = Colors.blue;
                      cardIcon = Icons.person;
                  }

                  return InkWell(
                    onTap: () => _handleUserTypeSelection(context, userType),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: cardColor.withAlpha(51),
                            child: Icon(
                              cardIcon,
                              size: 36,
                              color: cardColor,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OutlinedButton(
                                onPressed: () =>
                                    _handleLogin(context, userType),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: cardColor,
                                ),
                                child: const Text('دخول'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () =>
                                    _handleRegister(context, userType),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: cardColor,
                                ),
                                child: const Text(
                                  'تسجيل',
                                  style: TextStyle(color: Colors.white),
                                ),
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

            // رابط للعودة للموقع الرئيسي
            TextButton(
              onPressed: () async {
                // حفظ تفضيل المستخدم للموقع الرئيسي
                // في التطبيق الحقيقي سيتم إعادة تشغيل التطبيق للانتقال للموقع الرئيسي
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('جاري الانتقال للموقع الرئيسي...')),
                );

                // يمكن استخدام وسيلة أخرى مثل تغيير الصفحة الحالية
                Future.delayed(const Duration(seconds: 1), () {
                  // سيتم تنفيذ الانتقال للموقع الرئيسي
                  Navigator.pushReplacementNamed(context, '/client_site');
                });
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back),
                  SizedBox(width: 8),
                  Text('الذهاب إلى الموقع الرئيسي للعملاء'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // معالجة اختيار نوع المستخدم
  void _handleUserTypeSelection(BuildContext context, String userType) {
    if (userType == 'admin') {
      // انتقال لصفحة تسجيل الدخول للمدير
      _handleLogin(context, userType);
    } else {
      // عرض خيارات الدخول أو التسجيل
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
                Text(
                  'خيارات ${_getUserTypeText(userType)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('تسجيل الدخول'),
                  subtitle: const Text('للحسابات الموجودة مسبقاً'),
                  onTap: () {
                    Navigator.pop(context);
                    _handleLogin(context, userType);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_add),
                  title: const Text('تسجيل حساب جديد'),
                  subtitle: const Text('إنشاء طلب عضوية جديد'),
                  onTap: () {
                    Navigator.pop(context);
                    _handleRegister(context, userType);
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }

  // معالجة عملية تسجيل الدخول
  void _handleLogin(BuildContext context, String userType) {
    // سيتم توجيه المستخدم لصفحة تسجيل الدخول المناسبة لنوعه
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(userType: userType),
      ),
    );
  }

  // معالجة عملية التسجيل
  void _handleRegister(BuildContext context, String userType) {
    // توجيه لصفحة التسجيل المناسبة
    switch (userType) {
      case 'admin':
        // عادة تسجيل المدراء يتم بطريقة خاصة
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تسجيل المدراء غير متاح من خلال البوابة العامة')),
        );
        break;
      case 'supplier':
        Navigator.pushNamed(context, '/supplier/register');
        break;
      case 'contractor':
        Navigator.pushNamed(context, '/contractor/register');
        break;
      case 'transporter':
        Navigator.pushNamed(context, '/transporter/register');
        break;
    }
  }

  // الحصول على النص المناسب لنوع المستخدم
  String _getUserTypeText(String userType) {
    switch (userType) {
      case 'admin':
        return 'المدير';
      case 'supplier':
        return 'المورد';
      case 'contractor':
        return 'المقاول';
      case 'transporter':
        return 'الناقل';
      default:
        return userType;
    }
  }
}

// صفحة تسجيل الدخول
class LoginPage extends StatefulWidget {
  final String userType;

  const LoginPage({required this.userType, super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color appBarColor;
    String appBarTitle;

    // تحديد عنوان ولون الشاشة بناءً على نوع المستخدم
    switch (widget.userType) {
      case 'supplier':
        appBarColor = Colors.green;
        appBarTitle = 'دخول مورد';
        break;
      case 'contractor':
        appBarColor = Colors.orange;
        appBarTitle = 'دخول مقاول';
        break;
      case 'transporter':
        appBarColor = Colors.pink;
        appBarTitle = 'دخول ناقل';
        break;
      case 'admin':
        appBarColor = Colors.purple;
        appBarTitle = 'دخول مدير النظام';
        break;
      default:
        appBarColor = Colors.blue;
        appBarTitle = 'تسجيل الدخول';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: appBarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // أيقونة تسجيل الدخول
              Icon(
                Icons.login_rounded,
                size: 64,
                color: appBarColor,
              ),

              const SizedBox(height: 32),

              // حقل البريد الإلكتروني
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || value.isEmpty
                    ? 'يرجى إدخال البريد الإلكتروني'
                    : null,
              ),

              const SizedBox(height: 16),

              // حقل كلمة المرور
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) => value == null || value.isEmpty
                    ? 'يرجى إدخال كلمة المرور'
                    : null,
              ),

              const SizedBox(height: 24),

              // زر تسجيل الدخول
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: appBarColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'تسجيل الدخول',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),

              const SizedBox(height: 16),

              // رابط نسيت كلمة المرور
              TextButton(
                onPressed: () {
                  // TODO: تنفيذ وظيفة نسيت كلمة المرور
                },
                child: const Text('نسيت كلمة المرور؟'),
              ),

              const Spacer(),

              // رابط إنشاء حساب جديد
              if (widget.userType != 'admin')
                TextButton(
                  onPressed: () => _navigateToRegister(),
                  child: const Text('ليس لديك حساب؟ أنشئ طلب عضوية جديد'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // معالجة تسجيل الدخول
  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // استخراج قيم البريد الإلكتروني وكلمة المرور من المتحكمات
      final String email = _emailController.text;
      final String password = _passwordController.text;

      // محاكاة عملية تسجيل الدخول
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });

        // هنا سيتم التحقق من صحة بيانات المستخدم والتوجيه للوحة التحكم المناسبة
        // حالياً نفترض نجاح تسجيل الدخول إذا تم إدخال أي قيم
        if (email.isNotEmpty && password.isNotEmpty) {
          _navigateToDashboard();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('خطأ في البريد الإلكتروني أو كلمة المرور')),
          );
        }
      });
    }
  }

  // الانتقال للوحة التحكم المناسبة
  void _navigateToDashboard() {
    switch (widget.userType) {
      case 'admin':
        Navigator.pushReplacementNamed(context, '/admin');
        break;
      case 'supplier':
        // التوجيه للوحة تحكم المورد
        break;
      case 'contractor':
        // التوجيه للوحة تحكم المقاول
        break;
      case 'transporter':
        // التوجيه للوحة تحكم الناقل
        break;
    }
  }

  // الانتقال لصفحة التسجيل المناسبة
  void _navigateToRegister() {
    Navigator.pushReplacementNamed(context, '/${widget.userType}/register');
  }
}
