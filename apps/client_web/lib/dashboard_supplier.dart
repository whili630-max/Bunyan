import 'package:flutter/material.dart';
import 'product_form.dart';
import 'quote_requests.dart';
import 'products_list.dart';
import 'l10n/app_localizations.dart';
import 'language_switcher.dart';

class SupplierDashboard extends StatelessWidget {
  const SupplierDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(localizations.supplierDashboard),
        centerTitle: true,
        actions: const [
          LanguageSwitcher(),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.green),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.store, size: 48, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(localizations.supplier,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 20)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.inventory, color: Colors.green),
              title: Text(localizations.myProducts),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProductsListPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_box, color: Colors.green),
              title: Text(localizations.addProduct),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProductFormPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.request_quote, color: Colors.green),
              title: const Text('طلبات الأسعار'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const QuoteRequestsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.green),
              title: const Text('الإعدادات'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('الإعدادات قيد التطوير')),
                );
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('مرحباً بك في لوحة تحكم المورد!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
