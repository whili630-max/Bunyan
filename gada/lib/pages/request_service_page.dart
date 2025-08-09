import 'package:flutter/material.dart';

class RequestServicePage extends StatefulWidget {
  final String serviceType;

  const RequestServicePage({Key? key, required this.serviceType}) : super(key: key);

  @override
  _RequestServicePageState createState() => _RequestServicePageState();
}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'بنيان - خدمات بناء المنازل',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6246EA),
        fontFamily: 'Segoe UI',
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _openWhatsApp() async {
    const phone = '9665XXXXXXXX'; // ← عدّل الرقم
    final text = Uri.encodeComponent('مرحبًا، أحتاج مساعدة في خدمة البناء عبر تطبيق بنيان');
    final uri = Uri.parse('https://wa.me/$phone?text=$text');
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDire
