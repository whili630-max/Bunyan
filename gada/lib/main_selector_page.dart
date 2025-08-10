import 'package:flutter/material.dart';
import 'pages/request_service_page.dart';
import 'pages/supplier_signup_page.dart';

void main() {
  runApp(const BunyanApp());
}

class BunyanApp extends StatelessWidget {
  const BunyanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bunyan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Arial',
      ),
      home: const HomeScreen(),
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
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          // زر للتسجيل كمزود خدمة
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'تسجيل كمزود خدمة',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SupplierSignupPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(20),
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          children: [
            _buildServiceCard(context, 'سباكة', Icons.plumbing),
            _buildServiceCard(context, 'كهرباء', Icons.electrical_services),
            _buildServiceCard(context, 'أسمنت', Icons.construction),
            _buildServiceCard(context, 'مقاولين', Icons.engineering),
            _buildServiceCard(context, 'مشرفين', Icons.supervised_user_circle),
            _buildServiceCard(context, 'خدمات أخرى', Icons.home_repair_service),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, String title, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RequestServicePage(serviceType: title),
            ),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.green.shade700),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }
}
