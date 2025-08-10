import 'package:flutter/material.dart';
import 'models.dart';
import 'mock_database.dart';
import 'language_switcher.dart';

class QuoteRequestsPage extends StatefulWidget {
  const QuoteRequestsPage({super.key});

  @override
  _QuoteRequestsPageState createState() => _QuoteRequestsPageState();
}

class _QuoteRequestsPageState extends State<QuoteRequestsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات الأسعار'),
        backgroundColor: Colors.green,
        actions: const [
          LanguageSwitcher(),
        ],
      ),
      body: MockDatabase.quoteRequests.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.request_quote_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد طلبات أسعار حالياً',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
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
                  crossAxisCount = 3;
                  childAspectRatio = 2.5;
                } else if (width > 800) {
                  crossAxisCount = 2;
                  childAspectRatio = 2.2;
                } else {
                  crossAxisCount = 1;
                  childAspectRatio = 3.5;
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: MockDatabase.quoteRequests.length,
                  itemBuilder: (context, index) {
                    final request = MockDatabase.quoteRequests[index];

                    String clientName = 'عميل';
                    try {
                      final client = MockDatabase.users
                          .firstWhere((user) => user.id == request.clientId);
                      clientName = client.name;
                    } catch (e) {
                      clientName = 'عميل غير معروف';
                    }

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.all(8),
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'طلب سعر #${_formatRequestId(request.id)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'من: $clientName',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'التاريخ: ${_formatDate(request.date)}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(request.status),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getStatusText(request.status),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'التفاصيل:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(request.details),
                            if (request.attachmentPath != null) ...[
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: () {
                                  // يمكن فتح الملف المرفق هنا
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('جاري فتح الملف المرفق...'),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    const Icon(Icons.attach_file,
                                        size: 16, color: Colors.blue),
                                    const SizedBox(width: 4),
                                    Text(
                                      request.attachmentPath!.split('/').last,
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (request.status == 'pending')
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.red.shade100.withAlpha(255),
                                      foregroundColor: Colors.red,
                                    ),
                                    onPressed: () {
                                      _showRejectDialog(context, request);
                                    },
                                    child: const Text('رفض'),
                                  ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.reply),
                                  label: const Text('الرد'),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white),
                                  onPressed: () {
                                    _showRespondDialog(context, request);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'approved':
        return 'تمت الموافقة';
      case 'rejected':
        return 'مرفوض';
      default:
        return 'قيد الانتظار';
    }
  }

  String _formatDate(DateTime date) {
    try {
      final localDate = date.toLocal();
      final year = localDate.year.toString();
      final month = localDate.month.toString().padLeft(2, '0');
      final day = localDate.day.toString().padLeft(2, '0');
      final hour = localDate.hour.toString().padLeft(2, '0');
      final minute = localDate.minute.toString().padLeft(2, '0');
      return '$year-$month-$day $hour:$minute';
    } catch (e) {
      return 'تاريخ غير صالح';
    }
  }

  String _formatRequestId(String id) {
    try {
      return id.length > 6 ? id.substring(0, 6) : id;
    } catch (e) {
      return 'غير معروف';
    }
  }

  void _showRespondDialog(BuildContext context, QuoteRequest request) {
    final TextEditingController priceController = TextEditingController();
    final TextEditingController responseController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('الرد على طلب السعر'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'السعر المقترح (ر.س)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: responseController,
                  decoration: const InputDecoration(
                    labelText: 'تفاصيل الرد',
                    border: OutlineInputBorder(),
                    hintText:
                        'اكتب تفاصيل الرد، الشروط، مدة التنفيذ، وغيرها...',
                  ),
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  // تحديث طلب السعر بالرد والسعر
                  final index = MockDatabase.quoteRequests.indexOf(request);
                  if (index != -1) {
                    final double? price = double.tryParse(priceController.text);
                    final QuoteRequest updatedRequest = QuoteRequest(
                      id: request.id,
                      clientId: request.clientId,
                      supplierId: request.supplierId,
                      productId: request.productId,
                      details: request.details,
                      quantity: request.quantity,
                      date: request.date,
                      status: 'approved',
                      quotedPrice: price,
                      response: responseController.text,
                      attachmentPath: request.attachmentPath,
                    );
                    MockDatabase.quoteRequests[index] = updatedRequest;
                  }
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم الرد على الطلب بنجاح')),
                );
              },
              child: const Text('إرسال الرد',
                  style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  void _showRejectDialog(BuildContext context, QuoteRequest request) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('رفض طلب السعر'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('يرجى تحديد سبب الرفض:'),
              const SizedBox(height: 16),
              TextFormField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'سبب الرفض',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  // تحديث طلب السعر بالرفض
                  final index = MockDatabase.quoteRequests.indexOf(request);
                  if (index != -1) {
                    final QuoteRequest updatedRequest = QuoteRequest(
                      id: request.id,
                      clientId: request.clientId,
                      supplierId: request.supplierId,
                      productId: request.productId,
                      details: request.details,
                      quantity: request.quantity,
                      date: request.date,
                      status: 'rejected',
                      quotedPrice: null,
                      response: 'تم الرفض: ${reasonController.text}',
                      attachmentPath: request.attachmentPath,
                    );
                    MockDatabase.quoteRequests[index] = updatedRequest;
                  }
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم رفض الطلب')),
                );
              },
              child: const Text('رفض', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
