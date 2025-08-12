import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_manager.dart';
import 'bunyan_models.dart';
import 'bunyan_database.dart';

class ClientServicePage extends StatefulWidget {
  final bool isGuest;

  const ClientServicePage({super.key, this.isGuest = false});

  @override
  State<ClientServicePage> createState() => _ClientServicePageState();
}

class _ClientServicePageState extends State<ClientServicePage> {
  final BunyanDatabaseHelper _database = BunyanDatabaseHelper();
  List<BuildingProduct> products = [];
  List<BuildingProduct> filteredProducts = [];
  BuildingCategory? selectedCategory;
  String searchQuery = '';
  bool isLoading = true;
  late Map<String, String> texts;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTexts();
      _loadProducts();
    });
  }

  void _loadTexts() {
    final languageManager =
        Provider.of<LanguageManager>(context, listen: false);
    final isArabic = languageManager.currentLocale.languageCode == 'ar';

    setState(() {
      texts = {
        'clientService': isArabic ? 'خدمة العملاء' : 'Client Service',
        'guestMode': isArabic ? 'وضع الزائر' : 'Guest Mode',
        'browseProducts': isArabic ? 'تصفح المنتجات' : 'Browse Products',
        'buildingMaterials': isArabic ? 'مواد البناء' : 'Building Materials',
        'searchProducts':
            isArabic ? 'البحث في المنتجات...' : 'Search products...',
        'allCategories': isArabic ? 'جميع الفئات' : 'All Categories',
        'plumbing': isArabic ? 'سباكة' : 'Plumbing',
        'electrical': isArabic ? 'كهرباء' : 'Electrical',
        'concrete': isArabic ? 'خرسانة' : 'Concrete',
        'blocks': isArabic ? 'بلك' : 'Blocks',
        'steel': isArabic ? 'حديد' : 'Steel',
        'tiles': isArabic ? 'بلاط' : 'Tiles',
        'paint': isArabic ? 'دهانات' : 'Paint',
        'doors': isArabic ? 'أبواب ونوافذ' : 'Doors & Windows',
        'heavyEquipment': isArabic ? 'معدات ثقيلة' : 'Heavy Equipment',
        'tools': isArabic ? 'أدوات' : 'Tools',
        'noProducts': isArabic ? 'لا توجد منتجات' : 'No products found',
        'price': isArabic ? 'السعر' : 'Price',
        'sar': isArabic ? 'ريال' : 'SAR',
        'available': isArabic ? 'متوفر' : 'Available',
        'outOfStock': isArabic ? 'غير متوفر' : 'Out of Stock',
        'requestQuote': isArabic ? 'طلب عرض سعر' : 'Request Quote',
        'addToCart': isArabic ? 'إضافة للسلة' : 'Add to Cart',
        'loginRequired':
            isArabic ? 'يجب تسجيل الدخول أولاً' : 'Login required first',
        'contactSupplier': isArabic ? 'التواصل مع المورد' : 'Contact Supplier',
        'productDetails': isArabic ? 'تفاصيل المنتج' : 'Product Details',
      };
    });
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;
    try {
      final allProducts = await _database.getAllProducts();
      setState(() {
        products = allProducts;
        filteredProducts = allProducts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل المنتجات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterProducts() {
    setState(() {
      filteredProducts = products.where((product) {
        final matchesSearch = searchQuery.isEmpty ||
            product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            product.description
                .toLowerCase()
                .contains(searchQuery.toLowerCase());

        final matchesCategory =
            selectedCategory == null || product.category == selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
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
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(texts['clientService'] ?? 'Client Service'),
            if (widget.isGuest)
              Text(
                texts['guestMode'] ?? 'Guest Mode',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
          ],
        ),
        actions: [
          if (!widget.isGuest)
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                // فتح السلة
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('السلة قيد التطوير')),
                );
              },
            ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              if (widget.isGuest)
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.login),
                      SizedBox(width: 8),
                      Text('تسجيل الدخول'),
                    ],
                  ),
                  onTap: () {
                    // التوجه لصفحة تسجيل الدخول
                  },
                ),
              const PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.help),
                    SizedBox(width: 8),
                    Text('المساعدة'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: texts['searchProducts'] ?? 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    searchQuery = value;
                    _filterProducts();
                  },
                ),
                const SizedBox(height: 12),

                // Category Filter
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildCategoryChip(null, texts['allCategories'] ?? 'All'),
                      _buildCategoryChip(BuildingCategory.plumbing,
                          texts['plumbing'] ?? 'Plumbing'),
                      _buildCategoryChip(BuildingCategory.electrical,
                          texts['electrical'] ?? 'Electrical'),
                      _buildCategoryChip(BuildingCategory.concrete,
                          texts['concrete'] ?? 'Concrete'),
                      _buildCategoryChip(
                          BuildingCategory.blocks, texts['blocks'] ?? 'Blocks'),
                      _buildCategoryChip(
                          BuildingCategory.steel, texts['steel'] ?? 'Steel'),
                      _buildCategoryChip(
                          BuildingCategory.tools, texts['tools'] ?? 'Tools'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Products List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              texts['noProducts'] ?? 'No products found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return _buildProductCard(product);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: widget.isGuest
          ? null
          : FloatingActionButton(
              backgroundColor: const Color(0xFF1976D2),
              onPressed: () {
                // فتح صفحة طلب منتج مخصص
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('طلب منتج مخصص قيد التطوير')),
                );
              },
              child: const Icon(Icons.add_shopping_cart),
            ),
    );
  }

  Widget _buildCategoryChip(BuildingCategory? category, String label) {
    final isSelected = selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedCategory = selected ? category : null;
          });
          _filterProducts();
        },
        selectedColor: const Color(0x331976D2), // 0x33 is 20% opacity
        checkmarkColor: const Color(0xFF1976D2),
      ),
    );
  }

  Widget _buildProductCard(BuildingProduct product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showProductDetails(product),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image Placeholder
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(product.category),
                      size: 40,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '${product.price.toStringAsFixed(0)} ${texts['sar']}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                            Text(
                              ' / ${product.unit}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: product.isAvailable
                                    ? const Color(
                                        0x1A4CAF50) // Green with 10% opacity
                                    : const Color(
                                        0x1AF44336), // Red with 10% opacity
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                product.isAvailable
                                    ? texts['available'] ?? 'Available'
                                    : texts['outOfStock'] ?? 'Out of Stock',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: product.isAvailable
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              buildingCategoryNames[product.category] ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Action Buttons
              Row(
                children: [
                  if (!widget.isGuest) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: product.isAvailable
                            ? () => _requestQuote(product)
                            : null,
                        icon: const Icon(Icons.request_quote),
                        label: Text(texts['requestQuote'] ?? 'Request Quote'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: product.isAvailable
                            ? () => _addToCart(product)
                            : null,
                        icon: const Icon(Icons.add_shopping_cart),
                        label: Text(texts['addToCart'] ?? 'Add to Cart'),
                      ),
                    ),
                  ] else
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showLoginRequired(),
                        icon: const Icon(Icons.login),
                        label: Text(texts['loginRequired'] ?? 'Login Required'),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
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

  void _showProductDetails(BuildingProduct product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                product.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              if (product.specifications != null) ...[
                const Text(
                  'المواصفات:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(product.specifications!),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Text(
                    '${product.price.toStringAsFixed(0)} ${texts['sar']} / ${product.unit}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (!widget.isGuest)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _requestQuote(product),
                        child: Text(texts['requestQuote'] ?? 'Request Quote'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _addToCart(product),
                        child: Text(texts['addToCart'] ?? 'Add to Cart'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _requestQuote(BuildingProduct product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم طلب عرض سعر لـ ${product.name}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _addToCart(BuildingProduct product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إضافة ${product.name} للسلة'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showLoginRequired() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texts['loginRequired'] ?? 'Login required'),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: 'تسجيل الدخول',
          textColor: Colors.white,
          onPressed: () {
            // التوجه لصفحة تسجيل الدخول
          },
        ),
      ),
    );
  }
}
