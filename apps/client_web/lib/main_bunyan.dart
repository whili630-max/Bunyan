import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'language_manager.dart';
import 'bunyan_service_selector.dart';
import 'membership_requests.dart';

void main() {
  runApp(const BunyanApp());
}

class BunyanApp extends StatelessWidget {
  const BunyanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LanguageManager()),
        ChangeNotifierProvider(
            create: (context) => MembershipRequestsManager()),
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
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            home: const BunyanServiceSelector(),
          );
        },
      ),
    );
  }
}
