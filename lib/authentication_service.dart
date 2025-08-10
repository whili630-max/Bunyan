import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_manager.dart';
import 'session_manager.dart';
import 'notification_manager.dart';
import 'models.dart';

class AuthenticationService extends ChangeNotifier {
  final AuthManager _authManager;
  final SessionManager _sessionManager;
  final NotificationManager _notificationManager;
  final FlutterSecureStorage _secureStorage;
  final encrypt.Key _encryptionKey;
  final encrypt.IV _iv;

  AuthenticationService({
    required AuthManager authManager,
    required SessionManager sessionManager,
    required NotificationManager notificationManager,
  })  : _authManager = authManager,
        _sessionManager = sessionManager,
        _notificationManager = notificationManager,
        _secureStorage = const FlutterSecureStorage(),
        _encryptionKey = encrypt.Key.fromSecureRandom(32),
        _iv = encrypt.IV.fromSecureRandom(16);

  bool get isAuthenticated => _sessionManager.isLoggedIn;
  bool get isLocked => _sessionManager.isLocked;
  User? get currentUser => _sessionManager.currentUser;

  // تسجيل الدخول
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // محاولة تسجيل الدخول باستخدام AuthManager
      final result = await _authManager.login(email, password);

      if (result['success']) {
        final user = result['user'] as User;

        // تشفير وحفظ بيانات المصادقة
        await _saveAuthData(email, password);

        // حفظ جلسة المستخدم
        await _sessionManager.saveUserSession(user);

        // إضافة إشعار نجاح تسجيل الدخول
        _notificationManager.addNotification(
          BunyanNotification.createSuccess(
            title: 'تم تسجيل الدخول بنجاح',
            message: 'مرحباً ${user.name}',
          ),
        );

        notifyListeners();
        return {'success': true, 'user': user};
      }

      return result;
    } catch (e) {
      _notificationManager.addNotification(
        BunyanNotification.createError(
          title: 'خطأ في تسجيل الدخول',
          message: e.toString(),
        ),
      );
      return {'success': false, 'message': e.toString()};
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    try {
      final user = _sessionManager.currentUser;
      await _sessionManager.logout();
      await _clearAuthData();

      if (user != null) {
        _notificationManager.addNotification(
          BunyanNotification.createInfo(
            title: 'تم تسجيل الخروج',
            message: 'نراك قريباً ${user.name}',
          ),
        );
      }

      notifyListeners();
    } catch (e) {
      _notificationManager.addNotification(
        BunyanNotification.createError(
          title: 'خطأ في تسجيل الخروج',
          message: e.toString(),
        ),
      );
    }
  }

  // قفل التطبيق
  void lockApp() {
    _sessionManager.lockApp();
    notifyListeners();
  }

  // فتح قفل التطبيق
  Future<bool> unlockApp(String password) async {
    try {
      final savedPassword = await _getSavedPassword();
      if (savedPassword == password) {
        _sessionManager.unlockApp();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // تجديد الجلسة
  void refreshSession() {
    _sessionManager.refreshSession();
  }

  // حفظ بيانات المصادقة بشكل آمن
  Future<void> _saveAuthData(String email, String password) async {
    final encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey));

    // تشفير البيانات
    final encryptedEmail = encrypter.encrypt(email, iv: _iv);
    final encryptedPassword = encrypter.encrypt(password, iv: _iv);

    // حفظ البيانات المشفرة
    await _secureStorage.write(key: 'auth_email', value: encryptedEmail.base64);
    await _secureStorage.write(
        key: 'auth_password', value: encryptedPassword.base64);

    // حفظ IV بشكل آمن
    await _secureStorage.write(key: 'auth_iv', value: _iv.base64);
  }

  // استرجاع كلمة المرور المحفوظة
  Future<String?> _getSavedPassword() async {
    try {
      final encryptedPassword = await _secureStorage.read(key: 'auth_password');
      final savedIV = await _secureStorage.read(key: 'auth_iv');

      if (encryptedPassword != null && savedIV != null) {
        final encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey));
        final iv = encrypt.IV.fromBase64(savedIV);

        return encrypter.decrypt64(encryptedPassword, iv: iv);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // مسح بيانات المصادقة
  Future<void> _clearAuthData() async {
    await _secureStorage.deleteAll();
  }

  // استعادة الجلسة السابقة
  Future<bool> restoreSession() async {
    try {
      await _sessionManager.loadSession();

      if (_sessionManager.isLoggedIn) {
        _notificationManager.addNotification(
          BunyanNotification.createInfo(
            title: 'تم استعادة الجلسة',
            message: 'مرحباً مجدداً ${_sessionManager.currentUser?.name}',
          ),
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
