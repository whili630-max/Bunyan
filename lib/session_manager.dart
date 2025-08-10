import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models.dart';

class SessionManager extends ChangeNotifier {
  SharedPreferences? _prefs;
  User? _currentUser;
  DateTime? _lastActivity;
  static const int _sessionTimeout =
      30; // الجلسة تنتهي بعد 30 دقيقة من عدم النشاط
  bool _isLocked = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLocked => _isLocked;

  // تحديث وقت آخر نشاط
  void updateLastActivity() {
    _lastActivity = DateTime.now();
    _saveLastActivity();
  }

  // التحقق من انتهاء صلاحية الجلسة
  bool _isSessionExpired() {
    if (_lastActivity == null) return true;
    final difference = DateTime.now().difference(_lastActivity!);
    return difference.inMinutes >= _sessionTimeout;
  }

  // تهيئة المدير
  Future<void> initialize() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
      await loadSession();
    }
  }

  // حفظ بيانات المستخدم
  Future<void> saveUserSession(User user) async {
    if (_prefs == null) await initialize();

    _currentUser = user;
    _lastActivity = DateTime.now();

    await _prefs!.setString('user', jsonEncode(user.toJson()));
    await _saveLastActivity();
    notifyListeners();
  }

  // تحميل بيانات المستخدم
  Future<void> loadSession() async {
    if (_prefs == null) await initialize();

    final userJson = _prefs!.getString('user');
    if (userJson != null) {
      _currentUser = User.fromJson(jsonDecode(userJson));
    }

    final lastActivityStr = _prefs!.getString('lastActivity');
    if (lastActivityStr != null) {
      _lastActivity = DateTime.parse(lastActivityStr);

      // التحقق من انتهاء صلاحية الجلسة
      if (_isSessionExpired()) {
        await logout();
        return;
      }
    }

    notifyListeners();
  }

  // حفظ وقت آخر نشاط
  Future<void> _saveLastActivity() async {
    if (_prefs == null) await initialize();
    await _prefs!.setString('lastActivity', _lastActivity!.toIso8601String());
  }

  // قفل التطبيق
  void lockApp() {
    _isLocked = true;
    notifyListeners();
  }

  // فتح قفل التطبيق
  void unlockApp() {
    _isLocked = false;
    updateLastActivity();
    notifyListeners();
  }

  // تسجيل الخروج
  Future<void> logout() async {
    if (_prefs == null) await initialize();

    _currentUser = null;
    _lastActivity = null;
    _isLocked = false;

    await _prefs!.remove('user');
    await _prefs!.remove('lastActivity');

    notifyListeners();
  }

  // تجديد الجلسة
  void refreshSession() {
    if (_currentUser != null && !_isSessionExpired()) {
      updateLastActivity();
    }
  }
}
