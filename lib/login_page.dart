import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'auth_manager.dart';
import 'l10n/app_localizations.dart';
import 'language_switcher.dart';
import 'register_page.dart';
import 'dashboard_client.dart';
import 'dashboard_supplier.dart';
import 'admin_service_page.dart' as admin;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authManager = context.read<AuthManager>();

    // أولاً، تحقق من صحة بيانات الاعتماد
    final result = await authManager.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      // تحقق من حالة التحقق للمستخدم
      if (result['requiresVerification'] == true) {
        // عرض شاشة إدخال رمز OTP
        _showOTPVerificationDialog(
            result['userEmail'] ?? _emailController.text.trim());
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'تم تسجيل الدخول بنجاح'),
          backgroundColor: Colors.green,
        ),
      );

      // التوجيه إلى لوحة التحكم المناسبة بعد نجاح تسجيل الدخول
      _navigateToDashboard();
    } else {
      // التعامل مع حالات الفشل المختلفة
      Color errorColor = Colors.red;
      String message =
          result['message'] ?? 'فشل تسجيل الدخول. يرجى المحاولة مرة أخرى.';

      // التعامل مع حالة قفل الحساب
      if (result['accountLocked'] == true) {
        errorColor = Colors.orange.shade700;

        // عرض رسالة مع العد التنازلي للوقت المتبقي للقفل
        final remainingMinutes = result['remainingMinutes'] as int? ?? 0;
        message =
            'تم قفل الحساب مؤقتًا. الرجاء المحاولة مرة أخرى بعد $remainingMinutes دقيقة.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: errorColor,
          duration:
              const Duration(seconds: 5), // زيادة وقت العرض للرسائل المهمة
        ),
      );
    }
  }

  void _navigateToDashboard() {
    final authManager = context.read<AuthManager>();
    Widget dashboard;

    if (authManager.isClient()) {
      dashboard = const ClientDashboard();
    } else if (authManager.isSupplier()) {
      dashboard = const SupplierDashboard();
    } else if (authManager.isAdmin()) {
      dashboard = const admin.AdminServicePage();
    } else {
      return; // نوع مستخدم غير معروف
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => dashboard),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appTitle),
        actions: const [LanguageSwitcher()],
        elevation: 0,
      ),
      body: Consumer<AuthManager>(
        builder: (context, authManager, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // الشعار/العنوان
                  Icon(
                    Icons.business_center,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.appTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'منصة إدارة الأعمال الشاملة',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // حقل البريد الإلكتروني
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      hintText: 'أدخل بريدك الإلكتروني',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال البريد الإلكتروني';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'يرجى إدخال بريد إلكتروني صحيح';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // حقل كلمة المرور
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      hintText: 'أدخل كلمة المرور',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال كلمة المرور';
                      }
                      if (value.length < 6) {
                        return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // تذكرني
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                      ),
                      const Text('تذكرني'),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          // إعادة تعيين كلمة المرور
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('هذه الميزة قيد التطوير'),
                            ),
                          );
                        },
                        child: const Text('نسيت كلمة المرور؟'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // زر تسجيل الدخول
                  ElevatedButton(
                    onPressed: authManager.isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: authManager.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'تسجيل الدخول',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // رابط إنشاء حساب جديد
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('لا تملك حساب؟ '),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'إنشاء حساب جديد',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // معلومات المدير الافتراضي
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Text(
                              'حساب المدير الافتراضي',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('البريد الإلكتروني: admin@bunyan.com'),
                        const Text('كلمة المرور: admin123'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // عرض حوار التحقق بواسطة OTP
  void _showOTPVerificationDialog(String email) {
    final otpController = TextEditingController();
    bool isLoading = false;
    bool isError = false;
    String errorMessage = '';

    // تعريف متغير لعدد الثواني المتبقية للعد التنازلي
    int remainingSeconds = 60;
    Timer? resendTimer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // بدء العد التنازلي
        resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (remainingSeconds > 0) {
            // استخدام setState من StatefulBuilder لتحديث العد التنازلي
            if (dialogContext.mounted) {
              (dialogContext as Element).markNeedsBuild();
            }
            remainingSeconds--;
          } else {
            timer.cancel();
          }
        });

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'التحقق من الحساب',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'تم إرسال رمز التحقق إلى بريدك الإلكتروني. يرجى إدخاله أدناه للمتابعة.',
                    textAlign: TextAlign.center,
                    style: TextStyle(height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: otpController,
                    decoration: InputDecoration(
                      labelText: 'رمز التحقق',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.security),
                      errorText: isError ? errorMessage : null,
                      hintText: '000000',
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 8),
                    autofocus: true,
                  ),
                  const SizedBox(height: 10),

                  // خيار إعادة الإرسال مع عداد تنازلي
                  TextButton(
                    onPressed: remainingSeconds == 0
                        ? () async {
                            setState(() {
                              remainingSeconds = 60;
                              resendTimer?.cancel();
                              resendTimer = Timer.periodic(
                                  const Duration(seconds: 1), (timer) {
                                setState(() {
                                  if (remainingSeconds > 0) {
                                    remainingSeconds--;
                                  } else {
                                    timer.cancel();
                                  }
                                });
                              });
                            });

                            final authManager = context.read<AuthManager>();
                            final otp = authManager.generateOTP(email);

                            // محاكاة إرسال بريد إلكتروني (في بيئة الإنتاج، استخدم خدمة بريد حقيقية)
                            debugPrint('إعادة إرسال رمز التحقق إلى: $email');
                            debugPrint('رمز التحقق الجديد: $otp');

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم إعادة إرسال رمز التحقق'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        : null,
                    child: Text(
                      remainingSeconds > 0
                          ? 'إعادة الإرسال بعد ${remainingSeconds}s'
                          : 'إعادة إرسال الرمز',
                      style: TextStyle(
                        color: remainingSeconds > 0
                            ? Colors.grey
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                  ),

                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          resendTimer?.cancel();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'يمكنك التحقق من حسابك لاحقًا عند تسجيل الدخول'),
                            ),
                          );
                        },
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                            isError = false;
                          });

                          final authManager = context.read<AuthManager>();
                          final result = await authManager.verifyOTP(
                              email, otpController.text);

                          if (!mounted) return;

                          if (result['success'] == true) {
                            // إلغاء المؤقت عند الخروج من الحوار
                            resendTimer?.cancel();
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم التحقق من الحساب بنجاح!'),
                                backgroundColor: Colors.green,
                              ),
                            );

                            // الانتقال إلى الشاشة المناسبة بعد التحقق
                            _navigateToUserDashboard(result['userType']);
                          } else {
                            setState(() {
                              isLoading = false;
                              isError = true;

                              // عرض رسائل خطأ محددة
                              if (result['expired'] == true) {
                                errorMessage =
                                    'انتهت صلاحية رمز التحقق. الرجاء طلب رمز جديد.';
                                // تنشيط خيار إعادة الإرسال
                                remainingSeconds = 0;
                              } else if (result['tooManyAttempts'] == true) {
                                errorMessage =
                                    'تم تجاوز الحد الأقصى لمحاولات التحقق. الرجاء طلب رمز جديد.';
                                // تنشيط خيار إعادة الإرسال
                                remainingSeconds = 0;
                              } else {
                                errorMessage =
                                    result['message'] ?? 'رمز التحقق غير صحيح';
                              }
                            });
                          }
                        },
                  child: const Text('تحقق'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // الانتقال إلى لوحة التحكم المناسبة بناءً على نوع المستخدم
  void _navigateToUserDashboard(String? userType) {
    Widget dashboard;

    switch (userType) {
      case 'admin':
        dashboard = const admin.AdminServicePage();
        break;
      case 'supplier':
      case 'contractor':
      case 'transporter':
        dashboard = const SupplierDashboard();
        break;
      case 'client':
      default:
        dashboard = const ClientDashboard();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => dashboard),
    );
  }
}
