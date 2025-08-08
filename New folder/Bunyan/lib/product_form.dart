import 'package:flutter/material.dart';
import 'models.dart';
import 'mock_database.dart';
import 'l10n/app_localizations.dart';
import 'language_switcher.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key});

  @override
  _ProductFormPageState createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  String productName = '';
  String productDesc = '';
  double? price;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.addProduct),
        backgroundColor: Colors.green,
        actions: const [
          LanguageSwitcher(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration:
                    InputDecoration(labelText: localizations.productName),
                validator: (value) => value == null || value.isEmpty
                    ? localizations.enterProductName
                    : null,
                onSaved: (value) => productName = value ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                    labelText: localizations.productDescription),
                validator: (value) => value == null || value.isEmpty
                    ? localizations.enterProductDesc
                    : null,
                onSaved: (value) => productDesc = value ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: localizations.price),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.enterPrice;
                  }
                  final num? parsed = num.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    return localizations.enterValidPrice;
                  }
                  return null;
                },
                onSaved: (value) => price = double.tryParse(value ?? ''),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: Text(localizations.uploadImage),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(localizations.imageUploadDev)),
                  );
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // إنشاء منتج جديد وحفظه في قاعدة البيانات
                    final product = Product(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: productName,
                      description: productDesc,
                      price: price!,
                      imagePath: '', // سيتم إضافة رفع الصور لاحقاً
                      supplierId: 'temp_supplier', // سيتم التعامل معه لاحقاً
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );

                    MockDatabase.addProduct(product);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              '${localizations.productAddedSuccess} "$productName"')),
                    );

                    // مسح النموذج بعد الحفظ
                    _formKey.currentState!.reset();
                    setState(() {
                      productName = '';
                      productDesc = '';
                      price = null;
                    });
                  }
                },
                child: Text(localizations.addProduct),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
