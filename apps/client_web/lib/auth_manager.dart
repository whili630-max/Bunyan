import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'models.dart';

// تسجيل الأحداث الأمنية
class SecurityEvent {
  final String type;
  final String email;
  final String description;
  final DateTime timestamp;
  final String? ipAddress;
  final String? deviceInfo;

  SecurityEvent({
    required this.type,
    required this.email,
    required this.description,
    required this.timestamp,
    this.ipAddress,
    this.deviceInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'email': email,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'ipAddress': ipAddress,
      'deviceInfo': deviceInfo,
    };
  }

  factory SecurityEvent.fromJson(Map<String, dynamic> json) {
    return SecurityEvent(
      type: json['type'],
      email: json['email'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      ipAddress: json['ipAddress'],
      deviceInfo: json['deviceInfo'],
    );
  }
}

// هيكل لتخزين معلومات OTP
class OTPInfo {
  final String code;
  final DateTime generatedAt;
  int attempts;
  static const int maxVerificationAttempts = 3;
  static const int otpExpiryMinutes = 15;

  OTPInfo(this.code, this.generatedAt) : attempts = 0;

  bool isExpired() {
    final now = DateTime.now();
    return now.difference(generatedAt).inMinutes > otpExpiryMinutes;
  }

  bool tooManyAttempts() {
    return attempts >= maxVerificationAttempts;
  }

  int incrementAndGetAttempts() {
    return ++attempts;
  }
}

class AuthManager extends ChangeNotifier {
  static const String _sessionTokenKey = 'session_token';
  static const String _userDataKey = 'user_data';
  static const String _failedLoginsKey = 'failed_logins';
  static const String _lockoutTimeKey = 'lockout_time';
  static const String _securityEventsKey = 'security_events';

  User? _currentUser;
  String? _sessionToken;
  bool _isLoading = false;

  // تتبع محاولات تسجيل الدخول الفاشلة
  final Map<String, int> _failedLoginAttempts = {};
  final Map<String, DateTime> _accountLockoutUntil = {};

  // تخزين أحداث الأمان
  final List<SecurityEvent> _securityEvents = [];

  // إعدادات الحماية من هجمات القوة الغاشمة
  static const int _maxLoginAttempts = 5; // أقصى عدد محاولات فاشلة قبل القفل
  static const int _initialLockoutMinutes = 5; // مدة القفل الأولية بالدقائق

  // إعدادات تحليل الأنماط المشبوهة
  static const int _maxDevicesPerAccount =
      3; // الحد الأقصى لعدد الأجهزة المسموح بها لكل حساب
  static const int _maxDailyLoginAttempts =
      20; // الحد الأقصى لعدد محاولات تسجيل الدخول اليومية
  static const int _maxSMSAttemptsPerHour =
      5; // الحد الأقصى لعدد محاولات إرسال SMS في الساعة

  // تخزين محاولات إرسال SMS لكل رقم هاتف
  final Map<String, List<DateTime>> _smsAttempts = {};

  // الحصول على عدد محاولات إرسال SMS في الساعة الأخيرة
  Future<int> getSMSAttempts(String phoneNumber) async {
    if (!_smsAttempts.containsKey(phoneNumber)) {
      return 0;
    }

    final attempts = _smsAttempts[phoneNumber]!;
    final now = DateTime.now();

    // حذف المحاولات القديمة (أكثر من ساعة)
    attempts.removeWhere((attempt) => now.difference(attempt).inHours >= 1);

    // التحقق من تجاوز الحد الأقصى
    if (attempts.length >= _maxSMSAttemptsPerHour) {
      logSecurityEvent('sms_attempt_limit_exceeded', {
        'phone': phoneNumber,
        'attempts': attempts.length,
        'timeframe': '1 hour'
      });
    }

    return attempts.length;
  }

  // تسجيل محاولة إرسال SMS جديدة
  Future<void> incrementSMSAttempts(String phoneNumber) async {
    if (!_smsAttempts.containsKey(phoneNumber)) {
      _smsAttempts[phoneNumber] = [];
    }

    _smsAttempts[phoneNumber]!.add(DateTime.now());

    // تنظيف المحاولات القديمة
    final now = DateTime.now();
    _smsAttempts[phoneNumber]!
        .removeWhere((attempt) => now.difference(attempt).inHours >= 1);
  }

  // الحصول على الوقت المتبقي قبل السماح بمحاولة جديدة
  Future<Duration> getTimeUntilNextSMS(String phoneNumber) async {
    if (!_smsAttempts.containsKey(phoneNumber) ||
        _smsAttempts[phoneNumber]!.isEmpty) {
      return Duration.zero;
    }

    final oldestAttempt =
        _smsAttempts[phoneNumber]!.reduce((a, b) => a.isBefore(b) ? a : b);

    final now = DateTime.now();
    final hourSince = now.difference(oldestAttempt);

    if (hourSince >= const Duration(hours: 1)) {
      return Duration.zero;
    }

    return const Duration(hours: 1) - hourSince;
  }

  // تسجيل أحداث الأمان
  void logSecurityEvent(String type, Map<String, dynamic> details) {
    final event = SecurityEvent(
      type: type,
      email: details['email'] ?? details['phone'] ?? 'unknown',
      description: json.encode(details),
      timestamp: DateTime.now(),
      ipAddress: details['ipAddress'],
      deviceInfo: details['deviceInfo'],
    );

    _securityEvents.add(event);
    _saveSecurityEvents();

    // تحليل الحدث للكشف عن الأنماط المشبوهة
    _analyzeSecurityEvent(event);

    notifyListeners();
  }

  // تحليل الأحداث الأمنية للكشف عن الأنماط المشبوهة
  void _analyzeSecurityEvent(SecurityEvent event) {
    // تحليل تكرار الأحداث
    final recentEvents = _securityEvents
        .where((e) => e.email == event.email)
        .where((e) => DateTime.now().difference(e.timestamp).inHours < 24);

    // التحقق من تجاوز الحد اليومي
    if (recentEvents.length > _maxDailyLoginAttempts) {
      // تسجيل محاولة مشبوهة
      logSecurityEvent('suspicious_activity', {
        'email': event.email,
        'reason': 'exceeded_daily_limit',
        'count': recentEvents.length
      });
    }

    // التحقق من تعدد الأجهزة
    if (event.deviceInfo != null) {
      final uniqueDevices = recentEvents
          .where((e) => e.deviceInfo != null)
          .map((e) => e.deviceInfo)
          .toSet();

      if (uniqueDevices.length > _maxDevicesPerAccount) {
        // تسجيل نشاط مشبوه لتعدد الأجهزة
        logSecurityEvent('suspicious_activity', {
          'email': event.email,
          'reason': 'multiple_devices',
          'devices_count': uniqueDevices.length
        });
      }
    }
  }

  // حفظ سجل الأحداث الأمنية
  Future<void> _saveSecurityEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = _securityEvents.map((e) => e.toJson()).toList();
    await prefs.setString(_securityEventsKey, json.encode(eventsJson));
  }

  // معلومات إضافية للأمان
  final Random _secureRandom = Random.secure();

  User? get currentUser => _currentUser;
  String? get sessionToken => _sessionToken;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null && _sessionToken != null;

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // تحميل بيانات الجلسة المحفوظة
  Future<void> loadSavedSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _sessionToken = prefs.getString(_sessionTokenKey);

      if (_sessionToken != null) {
        _currentUser = await _databaseHelper.validateSession(_sessionToken!);
        if (_currentUser == null) {
          // الجلسة غير صالحة، قم بمسحها
          await clearSession();
        }
      }

      // تحميل بيانات محاولات تسجيل الدخول الفاشلة
      await _loadFailedLoginData();
    } catch (e) {
      debugPrint('خطأ في تحميل الجلسة المحفوظة: ${e.toString()}');
      await clearSession();
    }

    _isLoading = false;
    notifyListeners();
  }

  // تخزين رموز OTP المؤقتة (email -> OTP info)
  final Map<String, OTPInfo> _otpMap = {};

  // إنشاء رمز OTP جديد وتخزينه مؤقتًا
  String generateOTP(String email) {
    // إنشاء رمز مكون من 6 أرقام باستخدام مولد أرقام آمن
    String otp = '';
    for (int i = 0; i < 6; i++) {
      otp += _secureRandom.nextInt(10).toString();
    }

    // تخزين OTP مع وقت الإنشاء
    _otpMap[email] = OTPInfo(otp, DateTime.now());

    return otp;
  }

  // إعادة إرسال OTP
  Future<Map<String, dynamic>> resendOTP(String email) async {
    _isLoading = true;
    notifyListeners();

    // محاكاة معلومات الجهاز والعنوان IP
    final deviceInfo = _getCurrentDeviceInfo();
    final ipAddress =
        '192.168.1.${DateTime.now().millisecondsSinceEpoch % 255}'; // محاكاة لأغراض العرض

    try {
      await _logSecurityEvent(
        type: 'otp_resend_attempt',
        email: email,
        description: 'محاولة إعادة إرسال رمز OTP',
        ipAddress: ipAddress,
        deviceInfo: deviceInfo,
      );

      // التحقق من وجود المستخدم
      final user = await _databaseHelper.getUserByEmail(email);
      if (user == null) {
        await _logSecurityEvent(
          type: 'otp_resend_failure',
          email: email,
          description:
              'فشل إعادة إرسال OTP: لا يوجد مستخدم بهذا البريد الإلكتروني',
          ipAddress: ipAddress,
          deviceInfo: deviceInfo,
        );

        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': 'لا يوجد مستخدم بهذا البريد الإلكتروني'
        };
      }

      // التحقق من وجود OTP سابق وما إذا كان قد مر وقت كافٍ لإعادة الإرسال
      final now = DateTime.now();
      if (_otpMap.containsKey(email) &&
          now.difference(_otpMap[email]!.generatedAt).inMinutes < 1) {
        final remainingSeconds =
            60 - now.difference(_otpMap[email]!.generatedAt).inSeconds;

        await _logSecurityEvent(
          type: 'otp_resend_rate_limited',
          email: email,
          description:
              'تم رفض إعادة إرسال OTP بسبب التكرار المفرط (الوقت المتبقي: $remainingSeconds ثانية)',
          ipAddress: ipAddress,
          deviceInfo: deviceInfo,
        );

        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': 'الرجاء الانتظار دقيقة واحدة على الأقل قبل طلب رمز جديد',
          'remainingSeconds': remainingSeconds
        };
      }

      // إنشاء وإرسال رمز جديد
      final otp = generateOTP(email);

      // محاكاة إرسال بريد إلكتروني (في بيئة الإنتاج، استخدم خدمة بريد حقيقية)
      debugPrint('إعادة إرسال رمز التحقق إلى: $email');
      debugPrint('رمز التحقق الجديد: $otp');

      await _logSecurityEvent(
        type: 'otp_resend_success',
        email: email,
        description: 'تم إعادة إرسال رمز OTP بنجاح',
        ipAddress: ipAddress,
        deviceInfo: deviceInfo,
      );

      _isLoading = false;
      notifyListeners();

      return {
        'success': true,
        'message': 'تم إرسال رمز تحقق جديد إلى بريدك الإلكتروني'
      };
    } catch (e) {
      await _logSecurityEvent(
        type: 'otp_resend_error',
        email: email,
        description: 'حدث خطأ أثناء إعادة إرسال رمز OTP: ${e.toString()}',
        ipAddress: ipAddress,
        deviceInfo: deviceInfo,
      );

      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'حدث خطأ أثناء إعادة إرسال رمز التحقق: ${e.toString()}'
      };
    }
  }

  // التحقق من رمز OTP
  Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    _isLoading = true;
    notifyListeners();

    // محاكاة معلومات الجهاز والعنوان IP
    final deviceInfo = _getCurrentDeviceInfo();
    final ipAddress =
        '192.168.1.${DateTime.now().millisecondsSinceEpoch % 255}'; // محاكاة لأغراض العرض

    try {
      await _logSecurityEvent(
        type: 'otp_verification_attempt',
        email: email,
        description: 'محاولة التحقق من رمز OTP',
        ipAddress: ipAddress,
        deviceInfo: deviceInfo,
      );

      // التحقق من وجود رمز OTP لهذا البريد الإلكتروني
      if (!_otpMap.containsKey(email)) {
        await _logSecurityEvent(
          type: 'otp_verification_failure',
          email: email,
          description:
              'فشل التحقق: لم يتم العثور على رمز OTP للبريد الإلكتروني',
          ipAddress: ipAddress,
          deviceInfo: deviceInfo,
        );

        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message':
              'لم يتم طلب رمز تحقق لهذا البريد الإلكتروني أو انتهت صلاحيته'
        };
      }

      final otpInfo = _otpMap[email]!;

      // التحقق من عدم انتهاء صلاحية الرمز
      if (otpInfo.isExpired()) {
        await _logSecurityEvent(
          type: 'otp_verification_failure',
          email: email,
          description: 'فشل التحقق: انتهت صلاحية رمز OTP',
          ipAddress: ipAddress,
          deviceInfo: deviceInfo,
        );

        _otpMap.remove(email);
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': 'انتهت صلاحية رمز التحقق. الرجاء طلب رمز جديد',
          'expired': true
        };
      }

      // التحقق من عدم تجاوز الحد الأقصى لمحاولات التحقق
      if (otpInfo.tooManyAttempts()) {
        await _logSecurityEvent(
          type: 'multiple_verification_failures',
          email: email,
          description: 'تم تجاوز الحد الأقصى لمحاولات التحقق من رمز OTP',
          ipAddress: ipAddress,
          deviceInfo: deviceInfo,
        );

        _otpMap.remove(email);
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message':
              'تم تجاوز الحد الأقصى لمحاولات التحقق. الرجاء طلب رمز جديد',
          'tooManyAttempts': true
        };
      }

      // التحقق من تطابق الرمز
      if (otpInfo.code != otp) {
        // زيادة عدد المحاولات الفاشلة
        final remainingAttempts =
            OTPInfo.maxVerificationAttempts - otpInfo.incrementAndGetAttempts();

        await _logSecurityEvent(
          type: 'otp_verification_failure',
          email: email,
          description:
              'فشل التحقق: رمز OTP غير صحيح (محاولات متبقية: $remainingAttempts)',
          ipAddress: ipAddress,
          deviceInfo: deviceInfo,
        );

        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': 'رمز التحقق غير صحيح. محاولات متبقية: $remainingAttempts',
          'remainingAttempts': remainingAttempts
        };
      }

      // نجاح التحقق - تحديث حالة المستخدم وإنشاء جلسة
      final user = await _databaseHelper.getUserByEmail(email);
      if (user == null) {
        await _logSecurityEvent(
          type: 'otp_verification_failure',
          email: email,
          description: 'فشل التحقق: لا يوجد مستخدم بهذا البريد الإلكتروني',
          ipAddress: ipAddress,
          deviceInfo: deviceInfo,
        );

        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': 'لا يوجد مستخدم بهذا البريد الإلكتروني'
        };
      }

      // تحديث حالة التحقق للمستخدم
      await _databaseHelper.updateUserVerification(user.id, true, 'email');

      // إنشاء جلسة جديدة
      _sessionToken = _generateSessionToken();
      _currentUser = user;

      // حفظ بيانات الجلسة
      await _saveSession();

      // إزالة رمز OTP المستخدم
      _otpMap.remove(email);

      await _logSecurityEvent(
        type: 'otp_verification_success',
        email: email,
        description: 'تم التحقق من الحساب بنجاح',
        ipAddress: ipAddress,
        deviceInfo: deviceInfo,
      );

      _isLoading = false;
      notifyListeners();

      return {
        'success': true,
        'message': 'تم التحقق من الحساب بنجاح',
        'userType': user.type,
      };
    } catch (e) {
      await _logSecurityEvent(
        type: 'otp_verification_error',
        email: email,
        description: 'حدث خطأ أثناء التحقق: ${e.toString()}',
        ipAddress: ipAddress,
        deviceInfo: deviceInfo,
      );

      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'حدث خطأ أثناء التحقق: ${e.toString()}'
      };
    }
  }

  // التحقق من حالة القفل للحساب
  bool _isAccountLocked(String email) {
    if (!_accountLockoutUntil.containsKey(email)) {
      return false;
    }

    final lockoutUntil = _accountLockoutUntil[email]!;
    if (DateTime.now().isAfter(lockoutUntil)) {
      // انتهت مدة القفل، إزالة القفل
      _accountLockoutUntil.remove(email);
      return false;
    }

    return true;
  }

  // حساب مدة القفل الجديدة (تزداد مع كل محاولة فاشلة)
  Duration _calculateLockoutDuration(String email) {
    final attempts = _failedLoginAttempts[email] ?? 0;
    final minutes = _initialLockoutMinutes *
        pow(2, min(attempts - _maxLoginAttempts, 5)).toInt();
    return Duration(minutes: minutes);
  }

  // إضافة محاولة تسجيل دخول فاشلة وتطبيق القفل إذا لزم الأمر
  void _recordFailedLoginAttempt(String email) async {
    _failedLoginAttempts[email] = (_failedLoginAttempts[email] ?? 0) + 1;

    // حفظ محاولات تسجيل الدخول الفاشلة في التخزين المحلي
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        '${_failedLoginsKey}_$email', _failedLoginAttempts[email]!);

    // إذا تجاوزت المحاولات الفاشلة الحد الأقصى، قم بقفل الحساب
    if (_failedLoginAttempts[email]! >= _maxLoginAttempts) {
      final lockoutDuration = _calculateLockoutDuration(email);
      final lockoutUntil = DateTime.now().add(lockoutDuration);
      _accountLockoutUntil[email] = lockoutUntil;

      // حفظ وقت القفل في التخزين المحلي
      await prefs.setString(
          '${_lockoutTimeKey}_$email', lockoutUntil.toIso8601String());
    }
  }

  // إعادة تعيين محاولات تسجيل الدخول الفاشلة
  void _resetFailedLoginAttempts(String email) async {
    _failedLoginAttempts.remove(email);
    _accountLockoutUntil.remove(email);

    // حذف البيانات من التخزين المحلي
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_failedLoginsKey}_$email');
    await prefs.remove('${_lockoutTimeKey}_$email');
  }

  // استعادة بيانات محاولات تسجيل الدخول من التخزين المحلي
  Future<void> _loadFailedLoginData() async {
    final prefs = await SharedPreferences.getInstance();

    // استعادة جميع مفاتيح SharedPreferences
    final keys = prefs.getKeys();

    // استعادة محاولات تسجيل الدخول الفاشلة
    for (final key in keys) {
      if (key.startsWith(_failedLoginsKey)) {
        final email =
            key.substring(_failedLoginsKey.length + 1); // +1 for the underscore
        _failedLoginAttempts[email] = prefs.getInt(key) ?? 0;
      }

      if (key.startsWith(_lockoutTimeKey)) {
        final email =
            key.substring(_lockoutTimeKey.length + 1); // +1 for the underscore
        final lockoutTimeStr = prefs.getString(key);
        if (lockoutTimeStr != null) {
          _accountLockoutUntil[email] = DateTime.parse(lockoutTimeStr);
        }
      }
    }
  }

  // تسجيل دخول
  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    // محاكاة معلومات الجهاز والعنوان IP
    final deviceInfo = _getCurrentDeviceInfo();
    final ipAddress =
        '192.168.1.${DateTime.now().millisecondsSinceEpoch % 255}'; // محاكاة لأغراض العرض

    // تسجيل محاولة تسجيل الدخول
    await _logSecurityEvent(
      type: 'login_attempt',
      email: email,
      description: 'محاولة تسجيل دخول',
      ipAddress: ipAddress,
      deviceInfo: deviceInfo,
    );

    // التأكد من تحميل بيانات محاولات تسجيل الدخول الفاشلة
    await _loadFailedLoginData();

    try {
      // التحقق من حالة قفل الحساب
      if (_isAccountLocked(email)) {
        final remainingTime =
            _accountLockoutUntil[email]!.difference(DateTime.now());
        final remainingMinutes = remainingTime.inMinutes + 1;

        await _logSecurityEvent(
          type: 'account_lockout_rejected',
          email: email,
          description:
              'تم رفض محاولة تسجيل الدخول بسبب قفل الحساب. الوقت المتبقي: $remainingMinutes دقيقة',
          ipAddress: ipAddress,
          deviceInfo: deviceInfo,
        );

        _isLoading = false;
        notifyListeners();

        return {
          'success': false,
          'message':
              'تم قفل الحساب مؤقتًا. الرجاء المحاولة مرة أخرى بعد $remainingMinutes دقيقة',
          'accountLocked': true,
          'remainingMinutes': remainingMinutes,
        };
      }

      // التحقق من النشاط المشبوه
      final isSuspicious = await _isAccountActivitySuspicious(email);
      if (isSuspicious) {
        await _logSecurityEvent(
          type: 'suspicious_activity_rejection',
          email: email,
          description: 'تم رفض محاولة تسجيل الدخول بسبب النشاط المشبوه',
          ipAddress: ipAddress,
          deviceInfo: deviceInfo,
        );

        // قفل الحساب مؤقتًا في حالة النشاط المشبوه
        _recordFailedLoginAttempt(email);
        _recordFailedLoginAttempt(email);

        _isLoading = false;
        notifyListeners();

        return {
          'success': false,
          'message':
              'تم رصد نشاط مشبوه على حسابك. يرجى المحاولة مرة أخرى لاحقًا أو الاتصال بالدعم.',
          'suspiciousActivity': true,
        };
      }

      // محاولة تسجيل الدخول
      final result = await _databaseHelper.loginUser(email, password);

      if (result['success'] == true) {
        // نجاح تسجيل الدخول، إعادة تعيين محاولات تسجيل الدخول الفاشلة
        _resetFailedLoginAttempts(email);

        _currentUser = result['user'] as User;

        await _logSecurityEvent(
          type: 'login_success',
          email: email,
          description: 'تم تسجيل الدخول بنجاح',
          ipAddress: ipAddress,
          deviceInfo: deviceInfo,
        );

        // التحقق مما إذا كان المستخدم يحتاج إلى التحقق من هويته
        if (_currentUser != null && !_currentUser!.verified) {
          // إنشاء وإرسال رمز OTP
          final otp = generateOTP(email);

          // محاكاة إرسال بريد إلكتروني (في بيئة الإنتاج، استخدم خدمة بريد حقيقية)
          debugPrint('إرسال رمز التحقق إلى: $email');
          debugPrint('رمز التحقق: $otp');

          await _logSecurityEvent(
            type: 'otp_sent',
            email: email,
            description: 'تم إرسال رمز التحقق',
            ipAddress: ipAddress,
            deviceInfo: deviceInfo,
          );

          _isLoading = false;
          notifyListeners();

          return {
            'success': true,
            'requiresVerification': true,
            'message': 'يرجى إدخال رمز التحقق المرسل إلى بريدك الإلكتروني',
            'userEmail': email,
          };
        }

        // المستخدم متحقق بالفعل، إنشاء جلسة جديدة
        _sessionToken = _generateSessionToken();

        // حفظ بيانات الجلسة
        await _saveSession();
      } else {
        // فشل تسجيل الدخول، تسجيل محاولة فاشلة
        _recordFailedLoginAttempt(email);

        await _logSecurityEvent(
          type: 'login_failure',
          email: email,
          description: 'فشل تسجيل الدخول: ${result['message']}',
          ipAddress: ipAddress,
          deviceInfo: deviceInfo,
        );

        // التحقق مما إذا تم قفل الحساب بعد هذه المحاولة
        if (_failedLoginAttempts[email] != null &&
            _failedLoginAttempts[email]! >= _maxLoginAttempts) {
          await _logSecurityEvent(
            type: 'account_lockout',
            email: email,
            description:
                'تم قفل الحساب بعد ${_failedLoginAttempts[email]} محاولة فاشلة',
            ipAddress: ipAddress,
            deviceInfo: deviceInfo,
          );
        }

        // تعديل رسالة الخطأ لتتضمن عدد المحاولات المتبقية
        final remainingAttempts =
            _maxLoginAttempts - (_failedLoginAttempts[email] ?? 0);
        if (remainingAttempts > 0) {
          result['message'] =
              '${result['message']} (محاولات متبقية: $remainingAttempts)';
        }
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      await _logSecurityEvent(
        type: 'login_error',
        email: email,
        description: 'حدث خطأ أثناء تسجيل الدخول: ${e.toString()}',
        ipAddress: ipAddress,
        deviceInfo: deviceInfo,
      );

      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'حدث خطأ غير متوقع: ${e.toString()}',
      };
    }
  }

  // تسجيل مستخدم جديد
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String userType,
    String? institution,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _databaseHelper.registerUser(
        name: name,
        email: email,
        password: password,
        userType: userType,
        institution: institution,
      );

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'حدث خطأ أثناء التسجيل: ${e.toString()}',
      };
    }
  }

  // تسجيل خروج
  Future<void> logout() async {
    if (_sessionToken != null) {
      await _databaseHelper.logout(_sessionToken!);
    }
    await clearSession();
  }

  // مسح الجلسة
  Future<void> clearSession() async {
    _currentUser = null;
    _sessionToken = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionTokenKey);
    await prefs.remove(_userDataKey);

    // لا تمسح معلومات قفل الحساب لأننا نريد أن تستمر أثناء محاولات تسجيل الدخول المتعددة

    notifyListeners();
  }

  // مسح كافة بيانات الجلسة والأمان (للاستخدام في وظائف الإدارة فقط)
  Future<void> clearAllSessionAndSecurityData() async {
    _currentUser = null;
    _sessionToken = null;
    _failedLoginAttempts.clear();
    _accountLockoutUntil.clear();
    _otpMap.clear();

    final prefs = await SharedPreferences.getInstance();
    // حذف بيانات الجلسة
    await prefs.remove(_sessionTokenKey);
    await prefs.remove(_userDataKey);

    // حذف جميع بيانات محاولات تسجيل الدخول الفاشلة وقفل الحساب
    final allKeys = prefs.getKeys();
    for (final key in allKeys) {
      if (key.startsWith(_failedLoginsKey) || key.startsWith(_lockoutTimeKey)) {
        await prefs.remove(key);
      }
    }

    notifyListeners();
  }

  // تسجيل حدث أمني
  Future<void> _logSecurityEvent({
    required String type,
    required String email,
    required String description,
    String? ipAddress,
    String? deviceInfo,
  }) async {
    final now = DateTime.now();

    // إنشاء حدث أمني جديد
    final event = SecurityEvent(
      type: type,
      email: email,
      description: description,
      timestamp: now,
      ipAddress: ipAddress,
      deviceInfo: deviceInfo,
    );

    _securityEvents.add(event);

    // حفظ الأحداث الأمنية في التخزين المحلي
    final prefs = await SharedPreferences.getInstance();
    final existingEventsJson = prefs.getStringList(_securityEventsKey) ?? [];

    // تحويل الحدث الجديد إلى سلسلة JSON
    final eventJson = jsonEncode(event.toJson());
    existingEventsJson.add(eventJson);

    // حفظ أحدث 100 حدث فقط لمنع تضخم البيانات
    if (existingEventsJson.length > 100) {
      existingEventsJson.removeRange(0, existingEventsJson.length - 100);
    }

    await prefs.setStringList(_securityEventsKey, existingEventsJson);

    // تنبيه المسؤول في حالة الأحداث الخطيرة
    if (type == 'account_lockout' ||
        type == 'multiple_verification_failures' ||
        type == 'suspicious_activity') {
      _alertAdminOfSecurityEvent(event);
    }
  }

  // تحميل أحداث الأمان من التخزين المحلي
  Future<void> _loadSecurityEvents() async {
    _securityEvents.clear();

    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getStringList(_securityEventsKey) ?? [];

    for (final eventJson in eventsJson) {
      try {
        final event = SecurityEvent.fromJson(jsonDecode(eventJson));
        _securityEvents.add(event);
      } catch (e) {
        debugPrint('خطأ في تحميل حدث أمني: $e');
      }
    }
  }

  // تحليل نشاط الحساب بحثًا عن أنماط مشبوهة
  Future<bool> _isAccountActivitySuspicious(String email) async {
    // تحميل أحداث الأمان للتحليل
    await _loadSecurityEvents();

    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));

    // الأحداث المرتبطة بهذا الحساب في آخر 24 ساعة
    final accountEvents = _securityEvents
        .where((event) =>
            event.email == email && event.timestamp.isAfter(last24Hours))
        .toList();

    // فحص عدد محاولات تسجيل الدخول اليومية
    final loginAttempts = accountEvents
        .where((event) =>
            event.type == 'login_attempt' ||
            event.type == 'login_success' ||
            event.type == 'login_failure')
        .length;

    if (loginAttempts >= _maxDailyLoginAttempts) {
      await _logSecurityEvent(
        type: 'suspicious_activity',
        email: email,
        description:
            'تم تجاوز الحد الأقصى لعدد محاولات تسجيل الدخول اليومية ($loginAttempts)',
      );
      return true;
    }

    // فحص عدد الأجهزة المختلفة
    final uniqueDevices = accountEvents
        .where((event) => event.deviceInfo != null)
        .map((event) => event.deviceInfo)
        .toSet()
        .length;

    if (uniqueDevices > _maxDevicesPerAccount) {
      await _logSecurityEvent(
        type: 'suspicious_activity',
        email: email,
        description:
            'تم استخدام عدد كبير من الأجهزة المختلفة للوصول إلى الحساب ($uniqueDevices)',
      );
      return true;
    }

    return false;
  }

  // إرسال تنبيه للمسؤول عن حدث أمني
  void _alertAdminOfSecurityEvent(SecurityEvent event) {
    // في بيئة الإنتاج، يمكن استخدام خدمة إشعارات أو بريد إلكتروني
    final formattedTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(event.timestamp);
    debugPrint(
        'تنبيه أمني! $formattedTime - ${event.type}: ${event.description} (${event.email})');
  }

  // الحصول على معلومات الجهاز الحالي (محاكاة)
  String _getCurrentDeviceInfo() {
    // في التطبيق الفعلي، استخدم حزمة device_info_plus للحصول على معلومات الجهاز الحقيقية
    return 'simulator_device_${DateTime.now().millisecondsSinceEpoch % 1000}';
  }

  // الحصول على سجل الأحداث الأمنية (للمسؤولين فقط)
  Future<List<SecurityEvent>> getSecurityLogs(
      {String? email,
      String? type,
      DateTime? startDate,
      DateTime? endDate}) async {
    // التأكد من أن المستخدم الحالي هو مسؤول
    if (!isAdmin()) {
      return [];
    }

    // تحميل أحداث الأمان
    await _loadSecurityEvents();

    // تطبيق المرشحات
    return _securityEvents.where((event) {
      if (email != null && event.email != email) return false;
      if (type != null && event.type != type) return false;
      if (startDate != null && event.timestamp.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && event.timestamp.isAfter(endDate)) {
        return false;
      }
      return true;
    }).toList();
  }

  // مسح سجل الأحداث الأمنية القديمة (للمسؤولين فقط)
  Future<bool> purgeOldSecurityLogs({required int daysToKeep}) async {
    // التأكد من أن المستخدم الحالي هو مسؤول
    if (!isAdmin()) {
      return false;
    }

    try {
      // تحميل أحداث الأمان
      await _loadSecurityEvents();

      final now = DateTime.now();
      final cutoffDate = now.subtract(Duration(days: daysToKeep));

      // الاحتفاظ فقط بالأحداث الأحدث من تاريخ القطع
      final filteredEvents = _securityEvents
          .where((event) => event.timestamp.isAfter(cutoffDate))
          .toList();

      // تحديث قائمة الأحداث
      _securityEvents.clear();
      _securityEvents.addAll(filteredEvents);

      // حفظ القائمة المحدثة
      final prefs = await SharedPreferences.getInstance();
      final eventsJson =
          _securityEvents.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList(_securityEventsKey, eventsJson);

      return true;
    } catch (e) {
      debugPrint('خطأ في مسح سجلات الأحداث القديمة: ${e.toString()}');
      return false;
    }
  }

  // الحصول على إحصائيات الأمان (للمسؤولين فقط)
  Future<Map<String, dynamic>> getSecurityStats() async {
    // التأكد من أن المستخدم الحالي هو مسؤول
    if (!isAdmin()) {
      return {};
    }

    // تحميل أحداث الأمان
    await _loadSecurityEvents();

    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));
    final last7Days = now.subtract(const Duration(days: 7));
    final last30Days = now.subtract(const Duration(days: 30));

    // تصنيف الأحداث حسب النوع
    final eventsByType = <String, int>{};
    for (final event in _securityEvents) {
      eventsByType[event.type] = (eventsByType[event.type] ?? 0) + 1;
    }

    // إحصاءات الفترات الزمنية المختلفة
    final events24h =
        _securityEvents.where((e) => e.timestamp.isAfter(last24Hours)).length;
    final events7d =
        _securityEvents.where((e) => e.timestamp.isAfter(last7Days)).length;
    final events30d =
        _securityEvents.where((e) => e.timestamp.isAfter(last30Days)).length;

    // الحسابات التي تم قفلها
    final lockedAccounts = _securityEvents
        .where((e) =>
            e.type == 'account_lockout' && e.timestamp.isAfter(last7Days))
        .map((e) => e.email)
        .toSet()
        .length;

    // الأجهزة الفريدة
    final uniqueDevices = _securityEvents
        .where((e) => e.deviceInfo != null && e.timestamp.isAfter(last30Days))
        .map((e) => e.deviceInfo)
        .toSet()
        .length;

    return {
      'total_events': _securityEvents.length,
      'events_24h': events24h,
      'events_7d': events7d,
      'events_30d': events30d,
      'events_by_type': eventsByType,
      'locked_accounts_7d': lockedAccounts,
      'unique_devices_30d': uniqueDevices,
    };
  }

  // حفظ الجلسة
  Future<void> _saveSession() async {
    if (_sessionToken == null || _currentUser == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionTokenKey, _sessionToken!);
  }

  // التحقق من صلاحية الجلسة
  Future<bool> validateCurrentSession() async {
    if (_sessionToken == null) return false;

    try {
      final user = await _databaseHelper.validateSession(_sessionToken!);
      if (user == null) {
        await clearSession();
        return false;
      }

      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      await clearSession();
      return false;
    }
  }

  // التحقق من نوع المستخدم
  bool isClient() => _currentUser?.type == 'client';
  bool isSupplier() => _currentUser?.type == 'supplier';
  bool isAdmin() => _currentUser?.type == 'admin';

  // الحصول على اسم المستخدم للعرض
  String get displayName => _currentUser?.name ?? 'مستخدم';

  // الحصول على معرف المستخدم
  String get userId => _currentUser?.id ?? '';

  // توليد توكن جلسة آمن
  String _generateSessionToken() {
    // إنشاء توكن جلسة أكثر أماناً باستخدام مولد الأرقام العشوائية الآمن
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    // إنشاء 32 حرفاً عشوائياً آمناً
    const characters =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    String randomPart = '';
    for (int i = 0; i < 32; i++) {
      randomPart += characters[_secureRandom.nextInt(characters.length)];
    }

    // دمج المعلومات مع معرف المستخدم الحالي لزيادة الأمان
    final userFingerprint = _currentUser?.id.hashCode.toString() ?? '';

    return 'session_${timestamp}_${randomPart}_$userFingerprint';
  }
}
