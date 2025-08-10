import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';

class SupplierSignupPage extends StatefulWidget {
  const SupplierSignupPage({super.key});

  @override
  State<SupplierSignupPage> createState() => _SupplierSignupPageState();
}

class _SupplierSignupPageState extends State<SupplierSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  String _category = serviceCategories.first;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _sendViaWhatsapp() async {
    if (!_formKey.currentState!.validate()) return;
    const phoneWa = '9665XXXXXXXX'; // ← رقم واتساب لاستلام بيانات المورد
    final msg = '''
تسجيل مورد - تطبيق بنيان
المنشأة: ${_name.text}
الجوال/واتساب: ${_phone.text}
التخصص: $_category
''';
    final uri =
        Uri.parse('https://wa.me/$phoneWa?text=${Uri.encodeComponent(msg)}');
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تسجيل مورد')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _name,
                      decoration:
                          const InputDecoration(labelText: 'اسم المنشأة'),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'أدخل الاسم' : null,
                    ),
                    TextFormField(
                      controller: _phone,
                      decoration:
                          const InputDecoration(labelText: 'الجوال/واتساب'),
                      keyboardType: TextInputType.phone,
                      validator: (v) => (v == null || v.length < 9)
                          ? 'أدخل رقمًا صحيحًا'
                          : null,
                    ),
                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: const InputDecoration(labelText: 'التخصص'),
                      items: [
                        for (final s in serviceCategories)
                          DropdownMenuItem(value: s, child: Text(s)),
                      ],
                      onChanged: (v) => setState(() => _category = v ?? _category),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _sendViaWhatsapp,
                      child: const Text('إرسال عبر واتساب'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
