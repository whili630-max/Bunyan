import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';

class RequestServicePage extends StatefulWidget {
  final String? serviceType;
  const RequestServicePage({super.key, this.serviceType});

  @override
  State<RequestServicePage> createState() => _RequestServicePageState();
}

class _RequestServicePageState extends State<RequestServicePage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _city = TextEditingController();
  final _details = TextEditingController();
  late String _service;

  @override
  void initState() {
    super.initState();
  _service = widget.serviceType ?? serviceCategories.first;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _city.dispose();
    _details.dispose();
    super.dispose();
  }

  Future<void> _submitViaWhatsapp() async {
    if (!_formKey.currentState!.validate()) return;
    const phoneWa = '966548891929'; // ← رقم واتساب لاستقبال الطلبات
    final msg = '''
طلب خدمة من تطبيق بنيان
الخدمة: $_service
الاسم: ${_name.text}
الجوال: ${_phone.text}
المدينة/الموقع: ${_city.text}
التفاصيل: ${_details.text}
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
        appBar: AppBar(title: const Text('طلب خدمة')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _service,
                      decoration: const InputDecoration(labelText: 'نوع الخدمة'),
                      items: [
                        for (final s in serviceCategories)
                          DropdownMenuItem(value: s, child: Text(s)),
                      ],
                      onChanged: (v) => setState(() => _service = v ?? _service),
                    ),
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'الاسم'),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'أدخل الاسم' : null,
                    ),
                    TextFormField(
                      controller: _phone,
                      decoration: const InputDecoration(labelText: 'الجوال'),
                      keyboardType: TextInputType.phone,
                      validator: (v) => (v == null || v.length < 9)
                          ? 'أدخل رقمًا صحيحًا'
                          : null,
                    ),
                    TextFormField(
                      controller: _city,
                      decoration:
                          const InputDecoration(labelText: 'المدينة/الموقع'),
                    ),
                    TextFormField(
                      controller: _details,
                      decoration:
                          const InputDecoration(labelText: 'تفاصيل إضافية'),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _submitViaWhatsapp,
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
