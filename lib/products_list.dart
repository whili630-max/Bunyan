import 'package:flutter/material.dart';
import 'models.dart';
import 'mock_database.dart';
import 'product_form.dart';
import 'l10n/app_localizations.dart';
import 'language_switcher.dart';
import 'product_detail.dart';

class ProductsListPage extends StatefulWidget {
  const ProductsListPage({super.key});

  @override
  _ProductsListPageState createState() => _ProductsListPageState();
}

class _ProductsListPageState extends State<ProductsListPage> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.productsList),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ProductFormPage()),
              ).then((_) => setState(() {})); // تحديث القائمة عند العودة
            },
          ),
          const LanguageSwitcher(),
        ],
      ),
      body: MockDatabase.products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    localizations.noProducts,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.addNewProduct,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                int crossAxisCount;
                double childAspectRatio;

                if (width > 1200) {
                  crossAxisCount = 4;
                  childAspectRatio = 0.8;
                } else if (width > 800) {
                  crossAxisCount = 3;
                  childAspectRatio = 0.85;
                } else if (width > 500) {
                  crossAxisCount = 2;
                  childAspectRatio = 0.8;
                } else {
                  crossAxisCount = 1;
                  childAspectRatio = 2.5;
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: MockDatabase.products.length,
                  itemBuilder: (context, index) {
                    final product = MockDatabase.products[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailPage(product: product),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.image_outlined,
                                      size: 50, color: Colors.grey),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${product.price.toStringAsFixed(2)} ر.س',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                          fontSize: 16,
                                        ),
                                      ),
                                      PopupMenuButton(
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                const Icon(Icons.edit,
                                                    color: Colors.blue),
                                                const SizedBox(width: 8),
                                                Text(localizations.edit),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                const Icon(Icons.delete,
                                                    color: Colors.red),
                                                const SizedBox(width: 8),
                                                Text(localizations.delete),
                                              ],
                                            ),
                                          ),
                                        ],
                                        onSelected: (value) {
                                          if (value == 'delete') {
                                            _showDeleteConfirmation(context,
                                                product, localizations);
                                          }
                                          // TODO: تنفيذ التعديل
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductFormPage()),
          ).then((_) => setState(() {})); // تحديث القائمة عند العودة
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, Product product, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.confirmDelete),
          content: Text(localizations.confirmDeleteMsg(product.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.cancel),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  MockDatabase.products.remove(product);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('${localizations.deleted} "${product.name}"')),
                );
              },
              child: Text(localizations.delete,
                  style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
