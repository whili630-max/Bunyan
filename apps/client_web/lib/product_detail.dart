import 'package:flutter/material.dart';
import 'dart:io';
import 'models.dart';
import 'mock_database.dart';
import 'language_switcher.dart';
import 'auth_manager.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({required this.product, super.key});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final _formKey = GlobalKey<FormState>();
  String requestDetails = '';
  String? selectedFile;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final authManager = Provider.of<AuthManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        backgroundColor: Colors.blue,
        actions: const [
          LanguageSwitcher(),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المنتج
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey[200],
              child: widget.product.imagePath.isNotEmpty
                  ? Image.file(
                      File(widget.product.imagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.image_not_supported,
                              size: 64, color: Colors.grey),
                        );
                      },
                    )
                  : const Center(
                      child: Icon(Icons.inventory_2_outlined,
                          size: 64, color: Colors.grey),
                    ),
            ),

            // تفاصيل المنتج
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.product.price.toStringAsFixed(2)} ر.س',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'الوصف:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),

                  // نموذج طلب عرض سعر
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'طلب عرض سعر:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'تفاصيل الطلب',
                            border: OutlineInputBorder(),
                            hintText:
                                'اذكر التفاصيل المطلوبة للمنتج، الكمية، المواصفات الخاصة...',
                          ),
                          maxLines: 4,
                          validator: (value) => value == null || value.isEmpty
                              ? 'يرجى إدخال تفاصيل الطلب'
                              : null,
                          onSaved: (value) => requestDetails = value ?? '',
                        ),
                        const SizedBox(height: 16),

                        // زر رفع الملف
                        OutlinedButton.icon(
                          icon: const Icon(Icons.upload_file),
                          label: Text(selectedFile != null
                              ? 'تم اختيار الملف: ${selectedFile!.split('/').last}'
                              : 'رفع ملف إضافي (اختياري)'),
                          onPressed: () {
                            // TODO: تنفيذ اختيار الملف
                            setState(() {
                              selectedFile = 'مستند طلب.pdf'; // للتوضيح فقط
                            });
                          },
                        ),

                        const SizedBox(height: 24),

                        // زر إرسال الطلب
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: _isSubmitting
                                ? null
                                : () =>
                                    _submitQuoteRequest(context, authManager),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white),
                                  )
                                : const Text(
                                    'إرسال طلب عرض سعر',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // زر واتساب للتواصل المباشر
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.chat, color: Colors.white),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF25D366), // لون واتساب الأصلي
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () => _openWhatsAppChat(context),
                            label: const Text(
                              'تواصل عبر واتساب',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitQuoteRequest(BuildContext context, AuthManager authManager) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isSubmitting = true;
      });

      // إنشاء طلب عرض سعر جديد
      final quoteRequest = QuoteRequest(
        id: 'QR-${DateTime.now().millisecondsSinceEpoch}',
        clientId: authManager.currentUser?.id ?? 'guest',
        supplierId: widget.product.supplierId,
        productId: widget.product.id,
        quantity: 1, // كمية افتراضية
        details: requestDetails,
        date: DateTime.now(),
        status: 'pending',
        quotedPrice: null,
        response: null,
        attachmentPath: selectedFile,
      );

      // إضافة الطلب إلى قاعدة البيانات المؤقتة
      MockDatabase.addQuoteRequest(quoteRequest);

      // تأخير صغير للمحاكاة
      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('تم إرسال طلب عرض السعر بنجاح! سيتم التواصل معك قريباً'),
            duration: Duration(seconds: 3),
          ),
        );

        // إعادة توجيه إلى صفحة "تم الإرسال"
        Navigator.pushReplacementNamed(context, '/request_sent', arguments: {
          'productName': widget.product.name,
          'requestDetails': requestDetails,
        });

        // إعادة تعيين النموذج
        _formKey.currentState!.reset();
        setState(() {
          requestDetails = '';
          selectedFile = null;
        });
      });
    }
  }

  // فتح محادثة واتساب مع المورد
  void _openWhatsAppChat(BuildContext context) {
    // تأكد من وجود تفاصيل الطلب
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // جلب بيانات المورد (في التطبيق الحقيقي سنحصل على رقم الهاتف من قاعدة البيانات)
      String supplierPhone = '+966500000000'; // رقم هاتف افتراضي للتجربة

      // إعداد نص الرسالة
      String message = '''
السلام عليكم،
أنا مهتم بالمنتج: ${widget.product.name}
التفاصيل: $requestDetails
السعر المعروض: ${widget.product.price} ريال
هل يمكننا مناقشة التفاصيل؟
      ''';

      // تشفير الرسالة للاستخدام في URL
      String encodedMessage = Uri.encodeComponent(message);

      // إنشاء رابط واتساب
      final Uri whatsappUri =
          Uri.parse('https://wa.me/$supplierPhone?text=$encodedMessage');

      // فتح واتساب
      _launchWhatsapp(whatsappUri);
    } else {
      // إظهار رسالة للمستخدم لإدخال التفاصيل أولاً
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال تفاصيل الطلب أولاً'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // فتح تطبيق واتساب
  Future<void> _launchWhatsapp(Uri uri) async {
    try {
      final bool canLaunch = await url_launcher.canLaunchUrl(uri);
      if (canLaunch) {
        await url_launcher.launchUrl(uri,
            mode: url_launcher.LaunchMode.externalApplication);
      } else {
        throw Exception('لا يمكن فتح تطبيق واتساب');
      }
    } catch (e) {
      debugPrint('خطأ في فتح واتساب: $e');
    }
  }
}
