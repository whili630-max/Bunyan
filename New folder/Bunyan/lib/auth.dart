import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'models.dart';
import 'mock_database.dart';
import 'package:provider/provider.dart';
import 'membership_requests.dart';
import 'auth_manager.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class AuthPage extends StatefulWidget {
  final String
      userType; // 'client', 'supplier', 'contractor', 'transporter', 'admin'
  const AuthPage({required this.userType, super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String password = '';
  String institution = '';
  String? _crNumber;
  String? _phoneNumber;
  String? _address;
  int _passwordStrength = 0; // قوة كلمة المرور (0-5)

  @override
  Widget build(BuildContext context) {
    Color appBarColor;
    String appBarTitle;

    // تحديد عنوان ولون الشاشة بناءً على نوع المستخدم
    switch (widget.userType) {
      case 'supplier':
        appBarColor = Colors.green;
        appBarTitle = 'تسجيل مورد';
        break;
      case 'contractor':
        appBarColor = Colors.orange;
        appBarTitle = 'تسجيل مقاول';
        break;
      case 'transporter':
        appBarColor = Colors.pink;
        appBarTitle = 'تسجيل ناقل';
        break;
      case 'admin':
        appBarColor = Colors.purple;
        appBarTitle = 'تسجيل مدير';
        break;
      default:
        appBarColor = Colors.blue;
        appBarTitle = 'تسجيل عميل';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: appBarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // معلومات الحساب الأساسية
              TextFormField(
                decoration: const InputDecoration(labelText: 'الاسم الكامل'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'يرجى إدخال الاسم' : null,
                onSaved: (value) => name = value ?? '',
              ),
              const SizedBox(height: 16),

              // حقول خاصة للموردين/المقاولين/الناقلين
              if (widget.userType != 'client')
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'اسم المؤسسة/الشركة'),
                  validator: (value) => widget.userType != 'client' &&
                          (value == null || value.isEmpty)
                      ? 'اسم المؤسسة/الشركة مطلوب'
                      : null,
                  onSaved: (value) => institution = value ?? '',
                ),

              if (widget.userType != 'client')
                Column(
                  children: [
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'رقم السجل التجاري'),
                      onSaved: (value) => _crNumber = value,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'رقم الهاتف'),
                      onSaved: (value) => _phoneNumber = value,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'العنوان'),
                      onSaved: (value) => _address = value,
                    ),
                  ],
                ),

              const SizedBox(height: 16),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'البريد الإلكتروني'),
                validator: (value) => value == null || value.isEmpty
                    ? 'يرجى إدخال البريد الإلكتروني'
                    : null,
                onSaved: (value) => email = value ?? '',
              ),
              const SizedBox(height: 16),

              // كلمة المرور (متاحة فقط للعملاء)
              if (widget.userType == 'client')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'كلمة المرور',
                        helperText:
                            'يجب أن تحتوي على حروف كبيرة وصغيرة وأرقام ورموز خاصة',
                      ),
                      obscureText: true,
                      validator: (value) => value == null || value.length < 8
                          ? 'كلمة المرور يجب أن تكون 8 أحرف على الأقل'
                          : null,
                      onChanged: (value) {
                        setState(() {
                          password = value;
                          // إعادة حساب قوة كلمة المرور
                          bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
                          bool hasLowercase = value.contains(RegExp(r'[a-z]'));
                          bool hasDigits = value.contains(RegExp(r'[0-9]'));
                          bool hasSpecialChars =
                              value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
                          bool hasMinLength = value.length >= 12;

                          _passwordStrength = 0;
                          if (hasUppercase) _passwordStrength++;
                          if (hasLowercase) _passwordStrength++;
                          if (hasDigits) _passwordStrength++;
                          if (hasSpecialChars) _passwordStrength++;
                          if (hasMinLength) _passwordStrength++;
                        });
                      },
                      onSaved: (value) => password = value ?? '',
                    ),
                    const SizedBox(height: 8),
                    // مؤشر قوة كلمة المرور
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _passwordStrength / 5,
                              backgroundColor: Colors.grey[200],
                              color: _passwordStrength <= 2
                                  ? Colors.red
                                  : _passwordStrength <= 3
                                      ? Colors.orange
                                      : Colors.green,
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _passwordStrength <= 2
                              ? 'ضعيفة'
                              : _passwordStrength <= 3
                                  ? 'متوسطة'
                                  : 'قوية',
                          style: TextStyle(
                            color: _passwordStrength <= 2
                                ? Colors.red
                                : _passwordStrength <= 3
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

              if (widget.userType == 'client') const SizedBox(height: 16),

              // إضافة رقم الهاتف للتحقق للعملاء أيضًا
              if (widget.userType == 'client')
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف (للتحقق)',
                    hintText: '+966XXXXXXXXX',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'يرجى إدخال رقم هاتف صالح للتحقق'
                      : null,
                  onSaved: (value) => _phoneNumber = value,
                ),

              if (widget.userType == 'client') const SizedBox(height: 16),

              // عبارة توضيحية للموردين/المقاولين/الناقلين
              if (widget.userType != 'client')
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade700),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ملاحظة هامة:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'سيتم مراجعة طلبك من قبل المدير. عند الموافقة، ستتلقى بريدًا إلكترونيًا يحتوي على بيانات الدخول الخاصة بك.',
                        style: TextStyle(height: 1.4),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: appBarColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // تنظيف وتحقق من صحة البيانات المدخلة
                    final validationResult = _validateAndSanitizeInputs();
                    if (!validationResult['isValid']) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(validationResult['message']),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (MockDatabase.userExists(email)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('هذا البريد الإلكتروني مسجل بالفعل!')),
                      );
                      return;
                    }

                    // معالجة التسجيل حسب نوع المستخدم
                    if (widget.userType == 'client' ||
                        widget.userType == 'admin') {
                      // تسجيل فوري للعملاء والمدير مع إرسال رمز التحقق
                      // إنشاء معرف فريد للمستخدم
                      final userId =
                          DateTime.now().millisecondsSinceEpoch.toString();

                      // توليد رمز OTP للتحقق بالبريد الإلكتروني
                      final emailOtp = _generateOTP(email);

                      // توليد رمز OTP للتحقق برقم الهاتف (للعملاء فقط)
                      String? smsOtp;
                      if (widget.userType == 'client' &&
                          _phoneNumber != null &&
                          _phoneNumber!.isNotEmpty) {
                        smsOtp = _generateSmsOTP();
                      }

                      // إنشاء كائن المستخدم مع إضافة رقم الهاتف للعملاء
                      final user = User(
                        id: userId,
                        name: name,
                        email: email,
                        phone:
                            widget.userType == 'client' ? _phoneNumber : null,
                        type: widget.userType,
                        createdAt: DateTime.now(),
                        institution:
                            widget.userType == 'admin' ? institution : null,
                        // تشفير البيانات الحساسة (هنا محاكاة فقط، في بيئة الإنتاج نستخدم تشفير حقيقي)
                        verified: false, // يتطلب تحقق بالبريد الإلكتروني
                        phoneVerified: false, // يتطلب تحقق برقم الهاتف
                      );

                      // إضافة المستخدم مع حالة "غير متحقق"
                      MockDatabase.addUser(user);

                      // محاكاة إرسال رمز التحقق بالبريد الإلكتروني
                      _sendVerificationEmail(email, emailOtp);

                      // محاكاة إرسال رمز التحقق برسالة SMS (للعملاء فقط)
                      if (smsOtp != null && _phoneNumber != null) {
                        _sendVerificationSMS(_phoneNumber!, smsOtp);
                      }

                      // عرض نافذة منبثقة للتحقق من البريد الإلكتروني أولاً
                      _showOTPVerificationDialog(context, emailOtp, user,
                          isEmailVerification: true);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'تم إرسال رمز التحقق إلى بريدك الإلكتروني')),
                      );
                    } else {
                      // إرسال طلب عضوية للموردين/المقاولين/الناقلين
                      _submitMembershipRequest(context);
                    }
                  }
                },
                child: Text(widget.userType == 'client'
                    ? 'تسجيل'
                    : 'إرسال طلب العضوية'),
              ),
              const SizedBox(height: 8),

              // خيار الرجوع للصفحة الرئيسية
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('رجوع'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة إرسال طلب عضوية
  // التحقق من صحة وتنظيف البيانات المدخلة
  Map<String, dynamic> _validateAndSanitizeInputs() {
    bool isValid = true;
    String message = '';

    // تنظيف البريد الإلكتروني
    email = email.trim();

    // التحقق من صحة البريد الإلكتروني
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      isValid = false;
      message = 'الرجاء إدخال بريد إلكتروني صالح';
      return {'isValid': isValid, 'message': message};
    }

    // تنظيف الاسم (إزالة المسافات الزائدة)
    name = name.trim();
    name = name.replaceAll(RegExp(r'\s+'), ' ');

    // التحقق من طول الاسم
    if (name.length < 3) {
      isValid = false;
      message = 'الاسم قصير جداً. يجب أن يكون على الأقل 3 أحرف';
      return {'isValid': isValid, 'message': message};
    }

    // تنظيف اسم المؤسسة
    if (widget.userType != 'client') {
      institution = institution.trim();

      // التحقق من طول اسم المؤسسة
      if (institution.length < 2) {
        isValid = false;
        message = 'اسم المؤسسة قصير جداً';
        return {'isValid': isValid, 'message': message};
      }
    }

    // التحقق من كلمة المرور للعملاء
    if (widget.userType == 'client') {
      // كلمة المرور آمنة
      if (password.length < 8) {
        isValid = false;
        message = 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
        return {'isValid': isValid, 'message': message};
      }

      // التحقق من تعقيد كلمة المرور
      bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
      bool hasLowercase = password.contains(RegExp(r'[a-z]'));
      bool hasDigits = password.contains(RegExp(r'[0-9]'));
      bool hasSpecialChars =
          password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      bool hasMinLength = password.length >= 12;

      // حساب قوة كلمة المرور
      int strength = 0;
      if (hasUppercase) strength++;
      if (hasLowercase) strength++;
      if (hasDigits) strength++;
      if (hasSpecialChars) strength++;
      if (hasMinLength) strength++;

      if (strength < 3) {
        isValid = false;
        message = 'كلمة المرور ضعيفة جداً. يجب أن تحتوي على:\n'
            '- حروف كبيرة وصغيرة\n'
            '- أرقام\n'
            '- رموز خاصة (!@#\$%^&*)\n'
            '- 12 حرف على الأقل';
        return {'isValid': isValid, 'message': message};
      }

      // حفظ قوة كلمة المرور لعرضها في الواجهة
      _passwordStrength = strength;
    }

    // للموردين والمقاولين والناقلين، تحقق من البيانات الإضافية
    if (widget.userType != 'client') {
      // تنظيف رقم السجل التجاري
      if (_crNumber != null) {
        _crNumber = _crNumber!.trim();
      }

      // تنظيف رقم الهاتف
      if (_phoneNumber != null) {
        _phoneNumber = _phoneNumber!.trim();
        _phoneNumber = _phoneNumber!.replaceAll(RegExp(r'[^\d+]'), '');

        // التحقق من تنسيق رقم الهاتف
        if (_phoneNumber!.isNotEmpty &&
            !RegExp(r'^\+?\d{8,15}$').hasMatch(_phoneNumber!)) {
          isValid = false;
          message = 'الرجاء إدخال رقم هاتف صالح';
          return {'isValid': isValid, 'message': message};
        }
      }

      // تنظيف العنوان
      if (_address != null) {
        _address = _address!.trim();
      }
    }

    return {'isValid': isValid, 'message': message};
  }

  void _submitMembershipRequest(BuildContext context) {
    // إنشاء معرف فريد للطلب
    final requestId = 'REQ-${DateTime.now().millisecondsSinceEpoch}';

    // تشفير البيانات الحساسة قبل تخزينها
    // إنشاء قاموس للبيانات المشفرة
    Map<String, String> encrypted = {};

    // تشفير رقم الهاتف إذا كان موجوداً
    if (_phoneNumber != null && _phoneNumber!.isNotEmpty) {
      encrypted['phone'] = _encryptSensitiveData(_phoneNumber!);
    }

    // تشفير العنوان إذا كان موجوداً
    if (_address != null && _address!.isNotEmpty) {
      encrypted['address'] = _encryptSensitiveData(_address!);
    }

    // تشفير رقم السجل التجاري إذا كان موجوداً
    if (_crNumber != null && _crNumber!.isNotEmpty) {
      encrypted['crNumber'] = _encryptSensitiveData(_crNumber!);
    }

    // إنشاء طلب العضوية مع البيانات المشفرة
    final membershipRequest = MembershipRequest(
      id: requestId,
      name: name,
      email: email,
      userType: widget.userType,
      companyName: institution,
      crNumber: _crNumber,
      phoneNumber: _phoneNumber,
      address: _address,
      requestDate: DateTime.now(),
      status: 'pending',
      encryptedData: encrypted.isNotEmpty ? encrypted : null,
    );

    // إضافة الطلب إلى مدير طلبات العضوية
    final requestsManager =
        Provider.of<MembershipRequestsManager>(context, listen: false);
    requestsManager.addRequest(membershipRequest);

    // إظهار رسالة نجاح
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'تم إرسال طلب العضوية بنجاح. سيتم مراجعته والتواصل معك عبر البريد الإلكتروني.'),
        duration: Duration(seconds: 5),
      ),
    );

    // العودة للصفحة الرئيسية بعد فترة قصيرة
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!context.mounted) return;
      Navigator.pop(context);
    });
  }

  // توليد رمز التحقق OTP باستخدام AuthManager
  String _generateOTP(String email) {
    final authManager = Provider.of<AuthManager>(context, listen: false);
    return authManager.generateOTP(email);
  }

  // توليد رمز التحقق OTP للهاتف
  String _generateSmsOTP() {
    // إنشاء رمز عشوائي من 6 أرقام
    final random = Random();
    String otp = '';
    for (int i = 0; i < 6; i++) {
      otp += random.nextInt(10).toString();
    }
    return otp;
  }

  // محاكاة إرسال رمز التحقق بالبريد الإلكتروني
  void _sendVerificationEmail(String email, String otp) {
    // في بيئة الإنتاج، هذه الدالة ستستخدم واجهة برمجة تطبيقات لإرسال بريد إلكتروني حقيقي
    debugPrint('إرسال رمز التحقق إلى: $email');
    debugPrint('رمز التحقق: $otp');

    // هنا يمكن استخدام خدمات مثل SendGrid, Amazon SES, أو Firebase Authentication
    // للإرسال الفعلي للبريد الإلكتروني

    // يمكن أيضًا تسجيل هذا الحدث كجزء من سجل الأمان
    // authManager.logSecurityEvent(...) - سيتم تنفيذه في AuthManager
  }

  // محاكاة إرسال رمز التحقق عبر رسالة SMS
  Future<Map<String, dynamic>> _sendVerificationSMS(
      String phoneNumber, String otp) async {
    // في بيئة الإنتاج، استخدم خدمة رسائل SMS مثل Twilio, MessageBird, أو Vonage
    debugPrint('إرسال رمز التحقق إلى الهاتف: $phoneNumber');
    debugPrint('رمز التحقق للهاتف: $otp');

    // التحقق من عدد المحاولات لهذا الرقم
    final authManager = Provider.of<AuthManager>(context, listen: false);
    final attempts = await authManager.getSMSAttempts(phoneNumber);

    // حد أقصى 5 محاولات في الساعة
    if (attempts >= 5) {
      return {
        'success': false,
        'message': 'تم تجاوز الحد الأقصى للمحاولات. يرجى المحاولة بعد ساعة.',
        'remainingTime': await authManager.getTimeUntilNextSMS(phoneNumber),
      };
    }

    // تحديث عداد المحاولات
    await authManager.incrementSMSAttempts(phoneNumber);

    // محاولة إرسال الرسالة عبر WhatsApp أولاً
    try {
      final whatsappUrl =
          'https://wa.me/$phoneNumber/?text=رمز التحقق الخاص بك هو: $otp';
      if (await url_launcher.canLaunchUrl(Uri.parse(whatsappUrl))) {
        await url_launcher.launchUrl(Uri.parse(whatsappUrl));
        return {
          'success': true,
          'message': 'تم إرسال رمز التحقق عبر WhatsApp',
          'channel': 'whatsapp'
        };
      }
    } catch (e) {
      debugPrint('فشل إرسال WhatsApp: $e');
    }

    // في حالة فشل WhatsApp، إرسال SMS
    try {
      // محاكاة إرسال SMS (في بيئة الإنتاج، استخدم خدمة SMS حقيقية)
      await Future.delayed(const Duration(seconds: 1));

      // تسجيل نجاح الإرسال في سجل الأمان
      authManager.logSecurityEvent(
          'sms_verification_sent', {'phone': phoneNumber, 'success': true});

      return {
        'success': true,
        'message': 'تم إرسال رمز التحقق عبر SMS',
        'channel': 'sms'
      };
    } catch (e) {
      // تسجيل الفشل في سجل الأمان
      authManager.logSecurityEvent('sms_verification_failed',
          {'phone': phoneNumber, 'error': e.toString()});

      return {
        'success': false,
        'message': 'فشل إرسال رمز التحقق. يرجى المحاولة مرة أخرى.',
        'error': e.toString()
      };
    }
  }

  // تشفير البيانات الحساسة (محسن)
  String _encryptSensitiveData(String data) {
    // في بيئة الإنتاج، استخدم خوارزميات تشفير قوية مثل AES مع مكتبة encrypt
    // هذه نسخة محسنة من المحاكاة البسيطة للتشفير

    // توليد "salt" عشوائي أكثر أمانًا
    final random = DateTime.now().millisecondsSinceEpoch ^
        DateTime.now().microsecondsSinceEpoch;
    final salt = (random % 100000000).toString().padLeft(8, '0');

    // تنفيذ "محاكاة" أكثر تعقيدًا للتشفير (في الإنتاج، استخدم خوارزمية تشفير حقيقية)
    final chars = data.split('');
    for (var i = 0; i < chars.length; i++) {
      // تشفير بسيط مع إزاحة الأحرف
      final codeUnit = chars[i].codeUnitAt(0);
      final shifted = String.fromCharCode((codeUnit + 7) % 65536);
      chars[i] = shifted;
    }

    // دمج البيانات المشفرة مع الـ salt
    final encoded = chars.join('');
    return '$encoded:$salt:${encoded.length}';
  }

  // فك تشفير البيانات الحساسة (محاكاة)
  // ملاحظة: هذه الدالة مستخدمة في المكان المناسب عند الحاجة لفك التشفير
  // حالياً، يتم استخدامها فقط في الواجهة الخلفية لإدارة البيانات المشفرة

  // عرض نافذة منبثقة للتحقق من رمز OTP
  void _showOTPVerificationDialog(
      BuildContext context, String correctOTP, User user,
      {bool isEmailVerification = true}) {
    final TextEditingController otpController = TextEditingController();
    bool isLoading = false;
    bool isError = false;
    String errorMsg = '';
    int remainingSeconds = 60; // عداد تنازلي لإعادة إرسال الرمز
    Timer? resendTimer;

    // الحصول على مدير المصادقة
    final authManager = Provider.of<AuthManager>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // بدء المؤقت لإعادة الإرسال
        resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (remainingSeconds > 0) {
            setState(() {
              remainingSeconds--;
            });
          } else {
            timer.cancel();
          }
        });

        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(
              isEmailVerification
                  ? 'التحقق من البريد الإلكتروني'
                  : 'التحقق من رقم الهاتف',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEmailVerification
                      ? 'تم إرسال رمز تحقق إلى بريدك الإلكتروني. يرجى إدخاله أدناه للتحقق من حسابك.'
                      : 'تم إرسال رمز تحقق إلى رقم هاتفك. يرجى إدخاله أدناه للتحقق من حسابك.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(height: 1.4),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 8),
                  decoration: InputDecoration(
                    hintText: '000000',
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorText: isError ? errorMsg : null,
                  ),
                ),
                const SizedBox(height: 8),

                // إضافة خيار إعادة إرسال رمز التحقق مع عداد تنازلي
                TextButton(
                  onPressed: remainingSeconds <= 0
                      ? () async {
                          setState(() {
                            isLoading = true;
                          });

                          // استخدام طريقة إعادة الإرسال المحسنة من AuthManager
                          final result =
                              await authManager.resendOTP(user.email);

                          setState(() {
                            isLoading = false;
                            if (result['success']) {
                              // إعادة ضبط المؤقت
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

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result['message'] ??
                                      'تم إعادة إرسال رمز التحقق'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              // في حالة وجود خطأ في إعادة الإرسال
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result['message'] ??
                                      'فشل إعادة إرسال رمز التحقق'),
                                  backgroundColor: Colors.red,
                                ),
                              );

                              // إذا كان هناك وقت متبقي محدد في الاستجابة
                              if (result['remainingSeconds'] != null) {
                                remainingSeconds = result['remainingSeconds'];
                              }
                            }
                          });
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
                onPressed: () {
                  // إلغاء المؤقت عند الإغلاق
                  resendTimer?.cancel();
                  Navigator.of(context).pop();
                  // إظهار رسالة تذكير للمستخدم
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'لم يتم التحقق من حسابك. يمكنك تسجيل الدخول لاحقاً وإكمال عملية التحقق.'),
                      duration: Duration(seconds: 6),
                    ),
                  );
                },
                child: const Text('لاحقاً'),
              ),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() {
                          isLoading = true;
                          isError = false;
                        });

                        // استخدام AuthManager للتحقق من رمز OTP
                        final result = await authManager.verifyOTP(
                            user.email, otpController.text);

                        if (result['success'] == true) {
                          // إلغاء المؤقت عند النجاح
                          resendTimer?.cancel();

                          // إغلاق النافذة المنبثقة
                          Navigator.of(context).pop();

                          if (isEmailVerification) {
                            // تحديث حالة التحقق من البريد الإلكتروني
                            MockDatabase.updateUserVerificationStatus(
                                user.id, true, 'email');

                            // إذا كان العميل ويحتاج للتحقق من الهاتف أيضًا
                            if (user.type == 'client' &&
                                user.phone != null &&
                                !user.phoneVerified) {
                              // عرض نافذة منبثقة للتحقق من رقم الهاتف
                              // إعادة توليد رمز التحقق للهاتف
                              final smsOtp = _generateSmsOTP();
                              _sendVerificationSMS(user.phone!, smsOtp);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'تم التحقق من البريد الإلكتروني. يرجى التحقق من رقم الهاتف الآن.'),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              // إظهار نافذة التحقق من رقم الهاتف بعد فترة قصيرة
                              if (!context.mounted) return;
                              Future.delayed(const Duration(milliseconds: 1000),
                                  () {
                                if (!context.mounted) return;
                                _showOTPVerificationDialog(
                                    context, smsOtp, user,
                                    isEmailVerification: false);
                              });

                              return;
                            }
                          } else {
                            // تحديث حالة التحقق من رقم الهاتف
                            MockDatabase.updateUserVerificationStatus(
                                user.id, true, 'phone');
                          }

                          // عرض رسالة نجاح
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isEmailVerification
                                  ? 'تم التحقق من بريدك الإلكتروني بنجاح!'
                                  : 'تم التحقق من رقم هاتفك بنجاح!'),
                              backgroundColor: Colors.green,
                            ),
                          );

                          // التوجيه إلى لوحة التحكم المناسبة
                          if (!context.mounted) return;
                          Navigator.pushReplacementNamed(
                            context,
                            user.type == 'client'
                                ? '/client_dashboard'
                                : '/supplier_dashboard',
                          );
                        } else {
                          // إدارة الأخطاء المختلفة
                          setState(() {
                            isLoading = false;
                            isError = true;

                            if (result['expired'] == true) {
                              errorMsg =
                                  'انتهت صلاحية رمز التحقق. يرجى طلب رمز جديد.';
                              // إتاحة زر إعادة الإرسال على الفور
                              remainingSeconds = 0;
                            } else if (result['tooManyAttempts'] == true) {
                              errorMsg =
                                  'تم تجاوز الحد الأقصى لمحاولات التحقق. يرجى طلب رمز جديد.';
                              // إتاحة زر إعادة الإرسال على الفور
                              remainingSeconds = 0;
                            } else {
                              errorMsg =
                                  result['message'] ?? 'رمز التحقق غير صحيح.';
                              if (result['remainingAttempts'] != null) {
                                errorMsg +=
                                    ' (محاولات متبقية: ${result['remainingAttempts']})';
                              }
                            }
                          });
                        }
                      },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: const Text('تحقق'),
              ),
            ],
          );
        });
      },
    ).then((_) {
      // التأكد من إلغاء المؤقت عند إغلاق النافذة المنبثقة
      resendTimer?.cancel();
    });
  }
}
