import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

/// نموذج لطلب العضوية
class MembershipRequest {
  final String id;
  final String name;
  final String email;
  final String userType; // 'supplier', 'contractor', 'transporter'
  final String? companyName;
  final String? crNumber;
  final String? phoneNumber;
  final String? address;
  final DateTime requestDate;
  final String status; // 'pending', 'approved', 'rejected'
  final String? rejectionReason;
  final DateTime? approvalDate;
  // بيانات مشفرة إضافية
  final Map<String, String>? encryptedData;

  MembershipRequest({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
    this.companyName,
    this.crNumber,
    this.phoneNumber,
    this.address,
    required this.requestDate,
    required this.status,
    this.rejectionReason,
    this.approvalDate,
    this.encryptedData,
  });

  factory MembershipRequest.fromMap(Map<String, dynamic> map) {
    return MembershipRequest(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      userType: map['user_type'],
      companyName: map['company_name'],
      crNumber: map['cr_number'],
      phoneNumber: map['phone_number'],
      address: map['address'],
      requestDate: DateTime.parse(map['request_date']),
      status: map['status'],
      rejectionReason: map['rejection_reason'],
      approvalDate: map['approval_date'] != null
          ? DateTime.parse(map['approval_date'])
          : null,
      encryptedData: map['encrypted_data'] != null
          ? Map<String, String>.from(map['encrypted_data'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'user_type': userType,
      'company_name': companyName,
      'cr_number': crNumber,
      'phone_number': phoneNumber,
      'address': address,
      'request_date': requestDate.toIso8601String(),
      'status': status,
      'rejection_reason': rejectionReason,
      'approval_date': approvalDate?.toIso8601String(),
      'encrypted_data': encryptedData,
    };
  }

  // نسخة من الطلب مع تغيير الحالة
  MembershipRequest copyWith({
    String? id,
    String? name,
    String? email,
    String? userType,
    String? companyName,
    String? crNumber,
    String? phoneNumber,
    String? address,
    DateTime? requestDate,
    String? status,
    String? rejectionReason,
    Map<String, String>? encryptedData,
    DateTime? approvalDate,
  }) {
    return MembershipRequest(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      companyName: companyName ?? this.companyName,
      crNumber: crNumber ?? this.crNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      requestDate: requestDate ?? this.requestDate,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      approvalDate: approvalDate ?? this.approvalDate,
      encryptedData: encryptedData ?? this.encryptedData,
    );
  }
}

/// مدير طلبات العضوية
class MembershipRequestsManager with ChangeNotifier {
  List<MembershipRequest> _requests = [];

  List<MembershipRequest> get allRequests => List.unmodifiable(_requests);

  List<MembershipRequest> get pendingRequests =>
      _requests.where((req) => req.status == 'pending').toList();

  List<MembershipRequest> get approvedRequests =>
      _requests.where((req) => req.status == 'approved').toList();

  List<MembershipRequest> get rejectedRequests =>
      _requests.where((req) => req.status == 'rejected').toList();

  MembershipRequestsManager() {
    _loadRequests();
  }

  // تحميل الطلبات من التخزين المحلي
  Future<void> _loadRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final requestsJson = prefs.getString('membership_requests');
      if (requestsJson != null) {
        final List<dynamic> decoded = jsonDecode(requestsJson);
        _requests =
            decoded.map((item) => MembershipRequest.fromMap(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('خطأ في تحميل طلبات العضوية: $e');
    }
  }

  // حفظ الطلبات في التخزين المحلي
  Future<void> _saveRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final requestsJson =
          jsonEncode(_requests.map((req) => req.toMap()).toList());
      await prefs.setString('membership_requests', requestsJson);
    } catch (e) {
      debugPrint('خطأ في حفظ طلبات العضوية: $e');
    }
  }

  // إضافة طلب عضوية جديد
  Future<void> addRequest(MembershipRequest request) async {
    _requests.add(request);
    await _saveRequests();
    notifyListeners();
  }

  // تحديث حالة طلب
  Future<void> updateRequestStatus(String requestId, String status,
      {String? rejectionReason}) async {
    final index = _requests.indexWhere((req) => req.id == requestId);
    if (index != -1) {
      _requests[index] = _requests[index].copyWith(
        status: status,
        rejectionReason: status == 'rejected' ? rejectionReason : null,
        approvalDate: status == 'approved' ? DateTime.now() : null,
      );
      await _saveRequests();
      notifyListeners();
    }
  }

  // الموافقة على طلب عضوية
  Future<void> approveRequest(String requestId) async {
    await updateRequestStatus(requestId, 'approved');
  }

  // رفض طلب عضوية
  Future<void> rejectRequest(String requestId, String reason) async {
    await updateRequestStatus(requestId, 'rejected', rejectionReason: reason);
  }

  // البحث عن طلب عضوية بالبريد الإلكتروني
  MembershipRequest? findRequestByEmail(String email) {
    try {
      return _requests.firstWhere((req) => req.email == email);
    } catch (e) {
      return null;
    }
  }

  // البحث عن طلب عضوية بالمعرف
  MembershipRequest? findRequestById(String id) {
    try {
      return _requests.firstWhere((req) => req.id == id);
    } catch (e) {
      return null;
    }
  }

  // الحصول على حالة طلب بالبريد الإلكتروني
  String getRequestStatusByEmail(String email) {
    final request = findRequestByEmail(email);
    return request?.status ?? 'not_found';
  }

  // إرسال الإشعارات عن طريق البريد الإلكتروني (محاكاة)
  Future<void> sendApprovalEmail(String email, String generatedPassword) async {
    // في بيئة الإنتاج، سنستخدم خدمة بريد حقيقية هنا
    debugPrint('إرسال بريد الموافقة إلى: $email');
    debugPrint('كلمة المرور المؤقتة: $generatedPassword');
    // أكواد إرسال البريد الإلكتروني
  }

  // محاكاة إرسال رسالة بريد إلكتروني للرفض
  Future<void> sendRejectionEmail(String email, String reason) async {
    debugPrint('إرسال بريد الرفض إلى: $email');
    debugPrint('سبب الرفض: $reason');
    // أكواد إرسال البريد الإلكتروني
  }

  // حذف طلب عضوية
  Future<void> deleteRequest(String requestId) async {
    _requests.removeWhere((req) => req.id == requestId);
    await _saveRequests();
    notifyListeners();
  }

  // الموافقة الجماعية على مجموعة طلبات
  Future<void> approveBatch(List<String> requestIds) async {
    for (final requestId in requestIds) {
      final request = findRequestById(requestId);
      if (request != null && request.status == 'pending') {
        await approveRequest(requestId);
      }
    }
  }

  // الرفض الجماعي لمجموعة طلبات
  Future<void> rejectBatch(List<String> requestIds, String reason) async {
    for (final requestId in requestIds) {
      final request = findRequestById(requestId);
      if (request != null && request.status == 'pending') {
        await rejectRequest(requestId, reason);
      }
    }
  }
}

/// واجهة لإدارة طلبات العضوية (للمدير)
class MembershipRequestsPage extends StatefulWidget {
  const MembershipRequestsPage({super.key});

  @override
  _MembershipRequestsPageState createState() => _MembershipRequestsPageState();
}

class _MembershipRequestsPageState extends State<MembershipRequestsPage> {
  final List<String> _selectedRequests = [];
  bool _isSelectMode = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة طلبات العضوية'),
          actions: [
            if (_isSelectMode && _selectedRequests.isNotEmpty)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle),
                    tooltip: 'الموافقة على المحدد',
                    onPressed: () => _showBatchApprovalDialog(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel),
                    tooltip: 'رفض المحدد',
                    onPressed: () => _showBatchRejectionDialog(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'إلغاء التحديد',
                    onPressed: () {
                      setState(() {
                        _selectedRequests.clear();
                        _isSelectMode = false;
                      });
                    },
                  ),
                ],
              )
            else
              IconButton(
                icon: const Icon(Icons.select_all),
                tooltip: 'تحديد متعدد',
                onPressed: () {
                  setState(() {
                    _isSelectMode = true;
                  });
                },
              ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'قيد الانتظار'),
              Tab(text: 'تمت الموافقة'),
              Tab(text: 'تم الرفض'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _RequestsList(
              status: 'pending',
              isSelectMode: _isSelectMode,
              selectedRequests: _selectedRequests,
              onToggleSelection: _toggleRequestSelection,
            ),
            const _RequestsList(
              status: 'approved',
              isSelectMode: false,
              selectedRequests: [],
              onToggleSelection: null,
            ),
            const _RequestsList(
              status: 'rejected',
              isSelectMode: false,
              selectedRequests: [],
              onToggleSelection: null,
            ),
          ],
        ),
      ),
    );
  }

  void _toggleRequestSelection(String requestId) {
    setState(() {
      if (_selectedRequests.contains(requestId)) {
        _selectedRequests.remove(requestId);
      } else {
        _selectedRequests.add(requestId);
      }

      // إذا لم يعد هناك عناصر محددة، إلغاء وضع التحديد
      if (_selectedRequests.isEmpty) {
        _isSelectMode = false;
      }
    });
  }

  void _showBatchApprovalDialog(BuildContext context) {
    final manager =
        Provider.of<MembershipRequestsManager>(context, listen: false);
    final count = _selectedRequests.length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الموافقة الجماعية'),
        content: Text('هل أنت متأكد من الموافقة على $count طلبات محددة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              Navigator.pop(context);

              // استخدام دالة الموافقة الجماعية
              await manager.approveBatch(_selectedRequests);

              // إرسال إيميلات الموافقة
              for (final requestId in _selectedRequests) {
                final request = manager.findRequestById(requestId);
                if (request != null) {
                  // توليد كلمة مرور لكل مستخدم
                  final generatedPassword = _generateRandomPassword();
                  await manager.sendApprovalEmail(
                      request.email, generatedPassword);

                  // يمكن إضافة كود هنا لإنشاء حساب المستخدم الجديد
                  // بناءً على بيانات الطلب وكلمة المرور المولّدة
                }
              }

              setState(() {
                _selectedRequests.clear();
                _isSelectMode = false;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تمت الموافقة على $count طلبات بنجاح')),
              );
            },
            child: const Text('تأكيد الموافقة'),
          ),
        ],
      ),
    );
  }

  void _showBatchRejectionDialog(BuildContext context) {
    final manager =
        Provider.of<MembershipRequestsManager>(context, listen: false);
    final count = _selectedRequests.length;
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الرفض الجماعي'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('هل أنت متأكد من رفض $count طلبات محددة؟'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'سبب الرفض',
                hintText: 'أدخل سبب الرفض الجماعي',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى إدخال سبب الرفض')),
                );
                return;
              }

              Navigator.pop(context);

              // استخدام دالة الرفض الجماعي
              await manager.rejectBatch(_selectedRequests, reason);

              // إرسال إيميلات الرفض
              for (final requestId in _selectedRequests) {
                final request = manager.findRequestById(requestId);
                if (request != null) {
                  await manager.sendRejectionEmail(request.email, reason);
                }
              }

              setState(() {
                _selectedRequests.clear();
                _isSelectMode = false;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم رفض $count طلبات بنجاح')),
              );
            },
            child: const Text('تأكيد الرفض'),
          ),
        ],
      ),
    );
  }

  String _generateRandomPassword() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch % chars.length;
    return 'Pass${random}X${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
  }
}

class _RequestsList extends StatelessWidget {
  final String status;
  final bool isSelectMode;
  final List<String> selectedRequests;
  final Function(String)? onToggleSelection;

  const _RequestsList({
    required this.status,
    required this.isSelectMode,
    required this.selectedRequests,
    this.onToggleSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MembershipRequestsManager>(
      builder: (context, manager, child) {
        List<MembershipRequest> requests;

        switch (status) {
          case 'pending':
            requests = manager.pendingRequests;
            break;
          case 'approved':
            requests = manager.approvedRequests;
            break;
          case 'rejected':
            requests = manager.rejectedRequests;
            break;
          default:
            requests = manager.allRequests;
        }

        if (requests.isEmpty) {
          return const Center(
            child: Text('لا توجد طلبات'),
          );
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return _buildRequestCard(context, request, manager);
          },
        );
      },
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    MembershipRequest request,
    MembershipRequestsManager manager,
  ) {
    String userTypeText;
    Color userTypeColor;

    switch (request.userType) {
      case 'supplier':
        userTypeText = 'مورد';
        userTypeColor = Colors.green;
        break;
      case 'contractor':
        userTypeText = 'مقاول';
        userTypeColor = Colors.orange;
        break;
      case 'transporter':
        userTypeText = 'ناقل';
        userTypeColor = Colors.pink;
        break;
      default:
        userTypeText = request.userType;
        userTypeColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: isSelectMode && status == 'pending' && onToggleSelection != null
            ? () => onToggleSelection!(request.id)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (isSelectMode && status == 'pending')
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Icon(
                              selectedRequests.contains(request.id)
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: selectedRequests.contains(request.id)
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            request.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: userTypeColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      userTypeText,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const Divider(),
              _buildInfoRow('البريد الإلكتروني', request.email),
              if (request.companyName != null)
                _buildInfoRow('اسم الشركة', request.companyName!),
              if (request.crNumber != null)
                _buildInfoRow('رقم السجل التجاري', request.crNumber!),
              if (request.phoneNumber != null)
                _buildInfoRow('رقم الهاتف', request.phoneNumber!),
              if (request.address != null)
                _buildInfoRow('العنوان', request.address!),
              _buildInfoRow('تاريخ الطلب', _formatDate(request.requestDate)),
              if (request.status == 'approved' && request.approvalDate != null)
                _buildInfoRow(
                    'تاريخ الموافقة', _formatDate(request.approvalDate!)),
              if (request.status == 'rejected' &&
                  request.rejectionReason != null)
                _buildInfoRow('سبب الرفض', request.rejectionReason!),
              const SizedBox(height: 16),
              if (request.status == 'pending')
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          _showApprovalDialog(context, request, manager),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('موافقة'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () =>
                          _showRejectionDialog(context, request, manager),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('رفض'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }

  // عرض حوار الموافقة على طلب عضوية
  void _showApprovalDialog(
    BuildContext context,
    MembershipRequest request,
    MembershipRequestsManager manager,
  ) {
    // توليد كلمة مرور عشوائية
    final generatedPassword = _generateRandomPassword();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الموافقة على الطلب'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'هل أنت متأكد من الموافقة على طلب العضوية هذا؟',
              ),
              const SizedBox(height: 16),
              const Text(
                  'سيتم إرسال بريد إلكتروني بالبيانات التالية للمستخدم:'),
              const SizedBox(height: 8),
              _buildInfoRow('البريد الإلكتروني', request.email),
              _buildInfoRow('كلمة المرور المؤقتة', generatedPassword),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              await manager.approveRequest(request.id);
              await manager.sendApprovalEmail(request.email, generatedPassword);

              // إضافة المستخدم إلى قاعدة البيانات بعد الموافقة
              // (هنا نحتاج إلى تكامل مع نظام المستخدمين)

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('تمت الموافقة على الطلب وإرسال الإيميل بنجاح'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('موافقة وإرسال البيانات'),
          ),
        ],
      ),
    );
  }

  // عرض حوار الرفض
  void _showRejectionDialog(
    BuildContext context,
    MembershipRequest request,
    MembershipRequestsManager manager,
  ) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رفض طلب العضوية'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('يرجى كتابة سبب الرفض:'),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'سبب الرفض',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = reasonController.text;
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('يرجى كتابة سبب الرفض'),
                  ),
                );
                return;
              }

              await manager.rejectRequest(request.id, reason);
              await manager.sendRejectionEmail(request.email, reason);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم رفض الطلب وإرسال الإيميل بنجاح'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('رفض وإرسال الإيميل'),
          ),
        ],
      ),
    );
  }

  // توليد كلمة مرور عشوائية
  String _generateRandomPassword() {
    // في الواقع يمكن استخدام مكتبة لتوليد كلمات مرور أكثر أماناً
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch % chars.length;
    return 'Pass${random}X${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
  }
}
