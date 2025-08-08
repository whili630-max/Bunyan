import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'dashboard_client.dart';
import 'dashboard_supplier.dart';
import 'dashboard_admin.dart';
import 'l10n/app_localizations.dart';
import 'language_manager.dart';
import 'language_switcher.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageManager()..loadSavedLanguage(),
      child: const BunyanApp(),
    ),
  );
}

class BunyanApp extends StatelessWidget {
  const BunyanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageManager>(
      builder: (context, languageManager, child) {
        return MaterialApp(
          title: 'Bunyan',
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
          ),
          home: const AccountTypeSelectionPage(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class AccountTypeSelectionPage extends StatelessWidget {
  const AccountTypeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.selectAccountType),
        centerTitle: true,
        actions: const [
          LanguageSwitcher(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              localizations.pleaseSelectAccount,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _AccountTypeCard(
                  title: localizations.client,
                  description: localizations.clientDesc,
                  color: Colors.blue,
                  icon: Icons.person,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ClientDashboard()),
                    );
                  },
                ),
                _AccountTypeCard(
                  title: localizations.supplier,
                  description: localizations.supplierDesc,
                  color: Colors.green,
                  icon: Icons.business,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SupplierDashboard()),
                    );
                  },
                ),
                _AccountTypeCard(
                  title: localizations.admin,
                  description: localizations.adminDesc,
                  color: Colors.purple,
                  icon: Icons.admin_panel_settings,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminDashboard()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountTypeCard extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _AccountTypeCard({
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 200,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(77),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 12),
              Text(title,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 8),
              Text(description,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
