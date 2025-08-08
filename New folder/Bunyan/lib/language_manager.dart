import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  Locale _currentLocale = const Locale('ar'); // Default to Arabic

  Locale get currentLocale => _currentLocale;

  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? 'ar';
    _currentLocale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    if (languageCode == _currentLocale.languageCode) return;
    
    _currentLocale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    notifyListeners();
  }
  
  // طريقة لتعيين اللغة مباشرة (مطلوبة للتوافق مع واجهات أخرى)
  void setLocale(Locale locale) {
    if (locale.languageCode == _currentLocale.languageCode) return;
    
    _currentLocale = locale;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_languageKey, locale.languageCode);
    });
    notifyListeners();
  }

  String getLanguageName(String code) {
    switch (code) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      case 'ur':
        return 'اردو';
      default:
        return code;
    }
  }

  // الحصول على اسم اللغة بنفس اللغة
  String getNativeLanguageName(String code) {
    switch (code) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      case 'ur':
        return 'اُردُو';
      default:
        return code;
    }
  }

  // التحقق من اتجاه النص
  bool isRTL(String code) {
    return code == 'ar' || code == 'ur';
  }

  // الحصول على اتجاه النص
  TextDirection getTextDirection(String code) {
    return isRTL(code) ? TextDirection.rtl : TextDirection.ltr;
  }

  IconData getLanguageIcon(String code) {
    switch (code) {
      case 'ar':
        return Icons.translate;
      case 'en':
        return Icons.language;
      case 'ur':
        return Icons.translate_outlined;
      default:
        return Icons.language;
    }
  }
}
