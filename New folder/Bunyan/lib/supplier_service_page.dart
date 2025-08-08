import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_manager.dart';
import 'bunyan_models.dart';
import 'bunyan_database.dart';

class SupplierServicePage extends StatefulWidget {
  final BunyanUser? supplierUser;

  const SupplierServicePage({super.key, this.supplierUser});

  @override
  State<SupplierServicePage> createState() => _SupplierServicePageState();
}

class _SupplierServicePageState extends State<SupplierServicePage>
    with SingleTickerProviderStateMixin {
  final BunyanDatabaseHelper _database = BunyanDatabaseHelper();
  late TabController _tabController;

  List<BuildingProduct> myProducts = [];
  List<Map<String, dynamic>> pendingQuotes = [];
  bool isLoading = true;
  late Map<String, String> texts;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // التحقق من صلاحية الوصول للبيانات
    _enforceAccessControl();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTexts();
      _loadSupplierData();
    });
  }

  void _loadTexts() {
    final languageManager =
        Provider.of<LanguageManager>(context, listen: false);
    final isArabic = languageManager.currentLocale.languageCode == 'ar';

    setState(() {
      texts = {
        'supplierService': isArabic ? 'خدمة الموردين' : 'Supplier Service',
        'myProducts': isArabic ? 'منتجاتي' : 'My Products',
        'orders': isArabic ? 'الطلبات' : 'Orders',
        'quotes': isArabic ? 'عروض الأسعار' : 'Quotes',
        'analytics': isArabic ? 'الإحصائيات' : 'Analytics',
        'addProduct': isArabic ? 'إضافة منتج' : 'Add Product',
        'editProduct': isArabic ? 'تعديل منتج' : 'Edit Product',
        'deleteProduct': isArabic ? 'حذف منتج' : 'Delete Product',
        'productName': isArabic ? 'اسم المنتج' : 'Product Name',
        'description': isArabic ? 'الوصف' : 'Description',
        'price': isArabic ? 'السعر' : 'Price',
        'unit': isArabic ? 'الوحدة' : 'Unit',
        'category': isArabic ? 'الفئة' : 'Category',
        'specifications': isArabic ? 'المواصفات' : 'Specifications',
        'available': isArabic ? 'متوفر' : 'Available',
        'outOfStock': isArabic ? 'غير متوفر' : 'Out of Stock',
        'save': isArabic ? 'حفظ' : 'Save',
        'cancel': isArabic ? 'إلغاء' : 'Cancel',
        'delete': isArabic ? 'حذف' : 'Delete',
        'confirm': isArabic ? 'تأكيد' : 'Confirm',
        'confirmDelete': isArabic
            ? 'هل تريد حذف هذا المنتج؟'
            : 'Do you want to delete this product?',
        'noProducts': isArabic ? 'لا توجد منتجات' : 'No products',
        'addFirstProduct':
            isArabic ? 'أضف أول منتج لك' : 'Add your first product',
        'pendingQuotes': isArabic ? 'عروض أسعار معلقة' : 'Pending Quotes',
        'respondToQuote': isArabic ? 'الرد على العرض' : 'Respond to Quote',
        'acceptQuote': isArabic ? 'قبول العرض' : 'Accept Quote',
        'rejectQuote': isArabic ? 'رفض العرض' : 'Reject Quote',
        'viewDetails': isArabic ? 'عرض التفاصيل' : 'View Details',
        'totalProducts': isArabic ? 'إجمالي المنتجات' : 'Total Products',
        'totalOrders': isArabic ? 'إجمالي الطلبات' : 'Total Orders',
        'totalRevenue': isArabic ? 'إجمالي الإيرادات' : 'Total Revenue',
        'thisMonth': isArabic ? 'هذا الشهر' : 'This Month',
        'sar': isArabic ? 'ريال' : 'SAR',
        'welcome': isArabic ? 'مرحباً' : 'Welcome',
      };
    });
  }

  Future<void> _loadSupplierData() async {
    try {
      // التأكد من وجود معرف مستخدم صالح
      if (widget.supplierUser == null || widget.supplierUser!.id.isEmpty) {
        throw Exception('غير مصرح بالوصول - مستخدم غير موثق');
      }

      // تحميل منتجات المورد الحالي فقط (تصفية أمنية)
      final allProducts = await _database.getAllProducts();
      final filteredProducts = allProducts
          .where((product) => product.supplierId == widget.supplierUser!.id)
          .toList();

      // تحميل طلبات العروض الخاصة بهذا المورد فقط
      final allQuotes = await _database.getQuoteRequests();
      final filteredQuotes = allQuotes
          .where((quote) => quote['supplierId'] == widget.supplierUser!.id)
          .toList();

      // إذا لم تكن هناك بيانات حقيقية، استخدم بيانات وهمية للعرض
      final mockQuotes = filteredQuotes.isEmpty
          ? <Map<String, dynamic>>[
              {
                'id': '1',
                'productName': 'أسمنت أبيض',
                'clientName': 'أحمد محمد',
                'quantity': '10 أكياس',
                'message': 'نحتاج أسمنت أبيض عالي الجودة',
                'supplierId': widget.supplierUser!.id
              },
            ]
          : filteredQuotes;

      setState(() {
        // استخدام المنتجات المصفاة أمنيًا فقط
        myProducts = filteredProducts;
        pendingQuotes = mockQuotes;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل البيانات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (texts.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(texts['supplierService'] ?? 'Supplier Service'),
            if (widget.supplierUser != null)
              Text(
                '${texts['welcome'] ?? 'Welcome'} ${widget.supplierUser!.email}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              icon: const Icon(Icons.inventory),
              text: texts['myProducts'],
            ),
            Tab(
              icon: const Icon(Icons.shopping_cart),
              text: texts['orders'],
            ),
            Tab(
              icon: const Icon(Icons.request_quote),
              text: texts['quotes'],
            ),
            Tab(
              icon: const Icon(Icons.analytics),
              text: texts['analytics'],
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyProductsTab(),
          _buildOrdersTab(),
          _buildQuotesTab(),
          _buildAnalyticsTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF2E7D32),
              onPressed: _showAddProductDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildMyProductsTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (myProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              texts['noProducts'] ?? 'No products',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              texts['addFirstProduct'] ?? 'Add your first product',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddProductDialog,
              icon: const Icon(Icons.add),
              label: Text(texts['addProduct'] ?? 'Add Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myProducts.length,
      itemBuilder: (context, index) {
        final product = myProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(BuildingProduct product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF2E7D32),
          child: Icon(
            _getCategoryIcon(product.category),
            color: Colors.white,
          ),
        ),
        title: Text(product.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.description,
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${product.price.toStringAsFixed(0)} ${texts['sar']} / ${product.unit}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: product.isAvailable
                        ? Colors.green.withAlpha(26)
                        : Colors.red.withAlpha(26),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    product.isAvailable
                        ? texts['available'] ?? 'Available'
                        : texts['outOfStock'] ?? 'Out of Stock',
                    style: TextStyle(
                      fontSize: 12,
                      color: product.isAvailable ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Row(
                children: [
                  const Icon(Icons.edit),
                  const SizedBox(width: 8),
                  Text(texts['editProduct'] ?? 'Edit'),
                ],
              ),
              onTap: () => _showEditProductDialog(product),
            ),
            PopupMenuItem(
              child: Row(
                children: [
                  const Icon(Icons.delete, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(texts['deleteProduct'] ?? 'Delete',
                      style: const TextStyle(color: Colors.red)),
                ],
              ),
              onTap: () => _showDeleteProductDialog(product),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildOrdersTab() {
    return const Center(
      child: Text('قائمة الطلبات قيد التطوير'),
    );
  }

  Widget _buildQuotesTab() {
    if (pendingQuotes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.request_quote_outlined,
                size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'لا توجد عروض أسعار معلقة',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pendingQuotes.length,
      itemBuilder: (context, index) {
        final quote = pendingQuotes[index];
        return Card(
          child: ListTile(
            title: Text('طلب عرض سعر #${quote['id']}'),
            subtitle: Text(quote['productName'] ?? ''),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => _respondToQuote(quote, false),
                  child: const Text('رفض', style: TextStyle(color: Colors.red)),
                ),
                ElevatedButton(
                  onPressed: () => _respondToQuote(quote, true),
                  child: const Text('قبول'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '${myProducts.length}',
                  texts['totalProducts'] ?? 'Total Products',
                  Icons.inventory,
                  const Color(0xFF1976D2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  '0', // placeholder
                  texts['totalOrders'] ?? 'Total Orders',
                  Icons.shopping_cart,
                  const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '0 ${texts['sar']}', // placeholder
                  texts['totalRevenue'] ?? 'Total Revenue',
                  Icons.monetization_on,
                  const Color(0xFFFF9800),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  '${pendingQuotes.length}',
                  texts['pendingQuotes'] ?? 'Pending Quotes',
                  Icons.request_quote,
                  const Color(0xFF9C27B0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String value, String label, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductDialog() {
    _showProductDialog();
  }

  void _showEditProductDialog(BuildingProduct product) {
    _showProductDialog(product: product);
  }

  void _showProductDialog({BuildingProduct? product}) {
    final isEditing = product != null;
    final nameController = TextEditingController(text: product?.name ?? '');
    final descController =
        TextEditingController(text: product?.description ?? '');
    final priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );
    final unitController = TextEditingController(text: product?.unit ?? '');
    final specsController =
        TextEditingController(text: product?.specifications ?? '');

    BuildingCategory selectedCategory =
        product?.category ?? BuildingCategory.concrete;
    bool isAvailable = product?.isAvailable ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing
              ? (texts['editProduct'] ?? 'Edit Product')
              : (texts['addProduct'] ?? 'Add Product')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: texts['productName'] ?? 'Product Name',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: texts['description'] ?? 'Description',
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: priceController,
                        decoration: InputDecoration(
                          labelText: texts['price'] ?? 'Price',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: unitController,
                        decoration: InputDecoration(
                          labelText: texts['unit'] ?? 'Unit',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<BuildingCategory>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: texts['category'] ?? 'Category',
                    border: const OutlineInputBorder(),
                  ),
                  items: BuildingCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(buildingCategoryNames[category] ?? ''),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: specsController,
                  decoration: InputDecoration(
                    labelText: texts['specifications'] ?? 'Specifications',
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: isAvailable,
                      onChanged: (value) {
                        setState(() {
                          isAvailable = value ?? true;
                        });
                      },
                    ),
                    Text(texts['available'] ?? 'Available'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(texts['cancel'] ?? 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _saveProduct(
                isEditing: isEditing,
                productId: product?.id,
                name: nameController.text,
                description: descController.text,
                price: double.tryParse(priceController.text) ?? 0.0,
                unit: unitController.text,
                category: selectedCategory,
                specifications:
                    specsController.text.isEmpty ? null : specsController.text,
                isAvailable: isAvailable,
              ),
              child: Text(texts['save'] ?? 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteProductDialog(BuildingProduct product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(texts['confirm'] ?? 'Confirm'),
        content: Text(
            texts['confirmDelete'] ?? 'Do you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(texts['cancel'] ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteProduct(product);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(texts['delete'] ?? 'Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProduct({
    required bool isEditing,
    String? productId,
    required String name,
    required String description,
    required double price,
    required String unit,
    required BuildingCategory category,
    String? specifications,
    required bool isAvailable,
  }) async {
    if (name.isEmpty || description.isEmpty || price <= 0 || unit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى ملء جميع الحقول المطلوبة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final product = BuildingProduct(
        id: isEditing
            ? productId!
            : DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        price: price,
        unit: unit,
        category: category,
        specifications: specifications,
        isAvailable: isAvailable,
        quantity: 0, // Default quantity
        supplierId: widget.supplierUser?.id ?? 'default_supplier',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isEditing) {
        await _database.updateProduct(product);
      } else {
        await _database.insertProduct(product);
      }

      if (context.mounted) {
        Navigator.of(context).pop();
        await _loadSupplierData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'تم تحديث المنتج' : 'تم إضافة المنتج'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حفظ المنتج: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteProduct(BuildingProduct product) async {
    try {
      await _database.deleteProduct(product.id);
      await _loadSupplierData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف المنتج'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حذف المنتج: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _respondToQuote(Map<String, dynamic> quote, bool accept) {
    // في الواقع، سنحتاج لتحديث حالة العرض في قاعدة البيانات
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(accept ? 'تم قبول العرض' : 'تم رفض العرض'),
        backgroundColor: accept ? Colors.green : Colors.red,
      ),
    );
  }

  IconData _getCategoryIcon(BuildingCategory category) {
    switch (category) {
      case BuildingCategory.plumbing:
        return Icons.plumbing;
      case BuildingCategory.electrical:
        return Icons.electrical_services;
      case BuildingCategory.concrete:
        return Icons.foundation;
      case BuildingCategory.blocks:
        return Icons.view_module;
      case BuildingCategory.steel:
        return Icons.construction;
      case BuildingCategory.tiles:
        return Icons.grid_on;
      case BuildingCategory.paint:
        return Icons.format_paint;
      case BuildingCategory.doors:
        return Icons.door_front_door;
      case BuildingCategory.heavyEquipment:
        return Icons.precision_manufacturing;
      case BuildingCategory.tools:
        return Icons.build;
      case BuildingCategory.transport:
        return Icons.local_shipping;
    }
  }

  // التحقق من صلاحية الوصول
  void _enforceAccessControl() {
    // التأكد من أن المستخدم الحالي هو مورد وأنه يستطيع رؤية البيانات الخاصة به فقط
    if (widget.supplierUser == null) {
      // لا يوجد مستخدم مصرح به، إعادة توجيه المستخدم إلى صفحة تسجيل الدخول
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يجب تسجيل الدخول للوصول إلى هذه الصفحة'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
