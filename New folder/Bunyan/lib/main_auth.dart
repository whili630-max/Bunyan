import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'language_manager.dart';
import 'auth_manager.dart';
import 'login_page.dart';
import 'dashboard_client.dart';
import 'dashboard_supplier.dart';
import 'dashboard_admin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LanguageManager()..loadSavedLanguage(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthManager()..loadSavedSession(),
        ),
      ],
      child: const BunyanApp(),
    ),
  );
}

class BunyanApp extends StatelessWidget {
  const BunyanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageManager, AuthManager>(
      builder: (context, languageManager, authManager, child) {
        return MaterialApp(
          title: 'بنيان',
          locale: languageManager.currentLocale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          // دعم أفضل للغة العربية مع RTL
          builder: (context, child) {
            final locale = Localizations.localeOf(context);
            final isRTL = locale.languageCode == 'ar' || locale.languageCode == 'ur';
            return Directionality(
              textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
              child: child!,
            );
          },
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            // تحسين الخطوط للغة العربية
            fontFamily: 'Arial',
            textTheme: const TextTheme().apply(
              fontSizeFactor: 1.1, // زيادة حجم الخط قليلاً للعربية
            ),
            // تحسين الألوان والتصميم
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          // التحكم في الشاشة الأولى بناءً على حالة تسجيل الدخول
          home: authManager.isLoading 
              ? const SplashScreen() 
              : authManager.isLoggedIn 
                  ? _getDashboardForUser(authManager) 
                  : const LoginPage(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }

  Widget _getDashboardForUser(AuthManager authManager) {
    if (authManager.isClient()) {
      return const ClientDashboard();
    } else if (authManager.isSupplier()) {
      return const SupplierDashboard();
    } else if (authManager.isAdmin()) {
      return const AdminDashboard();
    } else {
      return const LoginPage(); // في حالة نوع مستخدم غير معروف
    }
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_center,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'بنيان',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'منصة إدارة الأعمال الشاملة',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
