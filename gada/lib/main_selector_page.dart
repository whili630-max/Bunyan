import 'package:flutter/material.dart';

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
        title: const Text('خدمات بناء المنازل'),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(20),
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          children: [
            _buildServiceCard('سباكة', Icons.plumbing),
            _buildServiceCard('كهرباء', Icons.electrical_services),
            _buildServiceCard('أسمنت', Icons.construction),
            _buildServiceCard('مقاولين', Icons.engineering),
            _buildServiceCard('مشرفين', Icons.supervised_user_circle),
            _buildServiceCard('خدمات أخرى', Icons.home_repair_service),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(String title, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          // هنا تحدد الإجراء عند الضغط (فتح نموذج طلب مثلاً)
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
