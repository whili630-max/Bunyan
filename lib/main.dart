import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


import 'auth_manager.dart';
import 'session_manager.dart';
import 'notification_manager.dart';
import 'reporting_service.dart';
import 'database_sync_service.dart';
import 'authentication_service.dart';

import 'package:bunyan/main_selector_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

// نقطة الدخول الرئيسية للتطبيق
void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  // تهيئة إدارة الإشعارات المحلية
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // إنشاء جميع المدراء والخدمات
  final authManager = AuthManager();
  final sessionManager = SessionManager();
  final notificationManager = NotificationManager();
  final reportingService = ReportingService();
  final databaseSyncService = DatabaseSyncService(
    notificationManager: notificationManager,
  );

  // تهيئة خدمة المصادقة
  final authenticationService = AuthenticationService(
    authManager: authManager,
    sessionManager: sessionManager,
    notificationManager: notificationManager,
  );

  // تهيئة قاعدة البيانات المحلية
  await databaseSyncService.initialize();

  // تغليف التطبيق بمزودي الخدمات
  final app = MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => authManager),
      ChangeNotifierProvider(create: (_) => sessionManager),
      ChangeNotifierProvider(create: (_) => notificationManager),
      ChangeNotifierProvider(create: (_) => reportingService),
      ChangeNotifierProvider(create: (_) => databaseSyncService),
      ChangeNotifierProvider(create: (_) => authenticationService),
    ],
    child: const MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('ar'), // Arabic
        Locale('en'), // English
        Locale('ur'), // Urdu
      ],
      locale: Locale('ar'),
      home: MainSelectorPage(),
    ),
  );

  // محاولة استعادة الجلسة السابقة
  await authenticationService.restoreSession();

  // تشغيل التطبيق
  runApp(app);
}
