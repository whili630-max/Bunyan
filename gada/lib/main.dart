import 'package:flutter/material.dart';
import 'pages/request_service_page.dart';
import 'pages/supplier_signup_page.dart';
import 'constants.dart';

void main() => runApp(const BunyanApp());

class BunyanApp extends StatelessWidget {
  const BunyanApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF2E7D32),
      fontFamily: 'Segoe UI',
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MaterialApp(
        title: 'بنيان',
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        theme: theme,
        routes: {
          '/': (context) => const HomeScreen(),
          '/request': (context) => const RequestServicePage(),
          '/supplier': (context) => const SupplierSignupPage(),
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بنيان - خدمات البناء 2025'),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/supplier'),
            icon: const Icon(Icons.storefront_outlined),
            label: const Text('تسجيل مورد'),
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(20),
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        children: [
          for (final cat in serviceCategories)
            _buildServiceCard(context, cat, _iconForCategory(cat)),
          _buildServiceCard(context, 'أخرى', Icons.more_horiz),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          children: [
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/request'),
              child: const Text('طلب خدمة'),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/supplier'),
              child: const Text('تسجيل مورد'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, String title, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RequestServicePage(serviceType: title),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 44, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForCategory(String cat) {
    switch (cat) {
      case 'سباكة':
        return Icons.plumbing;
      case 'كهرباء':
        return Icons.electrical_services;
      case 'أسمنت':
        return Icons.construction;
      case 'بلك':
        return Icons.grid_view;
      case 'مقاول':
        return Icons.engineering;
      case 'مشرف':
        return Icons.supervised_user_circle;
      default:
        return Icons.build;
    }
  }
}
