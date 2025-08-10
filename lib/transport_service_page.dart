import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_manager.dart';
import 'bunyan_models.dart';
import 'auth_manager.dart';

class TransportServicePage extends StatefulWidget {
  final BunyanUser? transportUser;

  const TransportServicePage({super.key, this.transportUser});

  @override
  State<TransportServicePage> createState() => _TransportServicePageState();
}

class _TransportServicePageState extends State<TransportServicePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> transportRequests = [];
  List<Map<String, dynamic>> myVehicles = [];
  bool isLoading = true;
  late Map<String, String> texts;

  // التحقق من صلاحيات الوصول لخدمة النقل
  void _enforceTransportAccess() {
    final authManager = Provider.of<AuthManager>(context, listen: false);
    if (authManager.currentUser == null ||
        authManager.currentUser!.type != 'transporter') {
      // لا يوجد مستخدم مسجل الدخول أو المستخدم ليس ناقل
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // إظهار رسالة تحذير
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('غير مصرح لك بالوصول إلى خدمة النقل'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );

        // إعادة التوجيه إلى الصفحة الرئيسية
        Navigator.of(context).pushReplacementNamed('/home');
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // التحقق من صلاحيات الوصول لخدمة النقل
    _enforceTransportAccess();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTexts();
      _loadTransportData();
    });
  }

  void _loadTexts() {
    final languageManager =
        Provider.of<LanguageManager>(context, listen: false);
    final isArabic = languageManager.currentLocale.languageCode == 'ar';

    setState(() {
      texts = {
        'transportService': isArabic ? 'خدمة النقل' : 'Transport Service',
        'requests': isArabic ? 'طلبات النقل' : 'Transport Requests',
        'myVehicles': isArabic ? 'مركباتي' : 'My Vehicles',
        'routes': isArabic ? 'الطرق' : 'Routes',
        'analytics': isArabic ? 'الإحصائيات' : 'Analytics',
        'addVehicle': isArabic ? 'إضافة مركبة' : 'Add Vehicle',
        'vehicleType': isArabic ? 'نوع المركبة' : 'Vehicle Type',
        'plateNumber': isArabic ? 'رقم اللوحة' : 'Plate Number',
        'capacity': isArabic ? 'السعة' : 'Capacity',
        'available': isArabic ? 'متاح' : 'Available',
        'busy': isArabic ? 'مشغول' : 'Busy',
        'maintenance': isArabic ? 'صيانة' : 'Maintenance',
        'acceptRequest': isArabic ? 'قبول الطلب' : 'Accept Request',
        'rejectRequest': isArabic ? 'رفض الطلب' : 'Reject Request',
        'viewDetails': isArabic ? 'عرض التفاصيل' : 'View Details',
        'noRequests': isArabic ? 'لا توجد طلبات نقل' : 'No transport requests',
        'noVehicles': isArabic ? 'لا توجد مركبات' : 'No vehicles',
        'addFirstVehicle':
            isArabic ? 'أضف أول مركبة' : 'Add your first vehicle',
        'from': isArabic ? 'من' : 'From',
        'to': isArabic ? 'إلى' : 'To',
        'distance': isArabic ? 'المسافة' : 'Distance',
        'estimatedTime': isArabic ? 'الوقت المتوقع' : 'Estimated Time',
        'cargo': isArabic ? 'البضاعة' : 'Cargo',
        'weight': isArabic ? 'الوزن' : 'Weight',
        'price': isArabic ? 'السعر' : 'Price',
        'sar': isArabic ? 'ريال' : 'SAR',
        'km': isArabic ? 'كم' : 'km',
        'ton': isArabic ? 'طن' : 'ton',
        'hour': isArabic ? 'ساعة' : 'hour',
        'totalRequests': isArabic ? 'إجمالي الطلبات' : 'Total Requests',
        'completedTrips': isArabic ? 'الرحلات المكتملة' : 'Completed Trips',
        'totalEarnings': isArabic ? 'إجمالي الأرباح' : 'Total Earnings',
        'activeVehicles': isArabic ? 'المركبات النشطة' : 'Active Vehicles',
        'welcome': isArabic ? 'مرحباً' : 'Welcome',
        'truck': isArabic ? 'شاحنة' : 'Truck',
        'pickup': isArabic ? 'بيك آب' : 'Pickup',
        'van': isArabic ? 'فان' : 'Van',
        'trailer': isArabic ? 'مقطورة' : 'Trailer',
        'crane': isArabic ? 'كرين' : 'Crane',
        'mixer': isArabic ? 'خلاطة' : 'Mixer',
        'save': isArabic ? 'حفظ' : 'Save',
        'cancel': isArabic ? 'إلغاء' : 'Cancel',
        'edit': isArabic ? 'تعديل' : 'Edit',
        'delete': isArabic ? 'حذف' : 'Delete',
        'status': isArabic ? 'الحالة' : 'Status',
      };
    });
  }

  Future<void> _loadTransportData() async {
    // الحصول على بيانات المستخدم الحالي
    final authManager = Provider.of<AuthManager>(context, listen: false);
    final currentUser = authManager.currentUser;

    if (currentUser == null || currentUser.type != 'transporter') {
      // إذا لم يكن المستخدم مسجل دخول أو ليس ناقل، لا تحمل أي بيانات
      setState(() {
        transportRequests = [];
        myVehicles = [];
        isLoading = false;
      });
      return;
    }

    // بيانات وهمية لطلبات النقل (في التطبيق الحقيقي ستأتي من قاعدة البيانات)
    final mockRequests = <Map<String, dynamic>>[
      {
        'id': '1',
        'transporterId': currentUser.id, // ربط بهوية الناقل الحالي
        'from': 'الرياض - الملقا',
        'to': 'الرياض - العليا',
        'cargo': 'أسمنت ورمل',
        'weight': '5 طن',
        'distance': '25 كم',
        'estimatedTime': '45 دقيقة',
        'price': '250 ريال',
        'clientName': 'شركة البناء السريع',
        'status': 'pending'
      },
      {
        'id': '2',
        'transporterId': currentUser.id, // ربط بهوية الناقل الحالي
        'from': 'الدمام - الخبر',
        'to': 'الدمام - القطيف',
        'cargo': 'حديد تسليح',
        'weight': '8 طن',
        'distance': '40 كم',
        'estimatedTime': '1 ساعة',
        'price': '400 ريال',
        'clientName': 'مؤسسة العمار',
        'status': 'pending'
      },
      {
        'id': '3',
        'transporterId': 'other-transporter', // طلب لناقل آخر - لا يجب أن يظهر
        'from': 'جدة - الشاطئ',
        'to': 'جدة - الصفا',
        'cargo': 'بلاط وسيراميك',
        'weight': '3 طن',
        'distance': '15 كم',
        'estimatedTime': '30 دقيقة',
        'price': '180 ريال',
        'clientName': 'شركة الإعمار الدولية',
        'status': 'pending'
      },
    ];

    // بيانات وهمية للمركبات (في التطبيق الحقيقي ستأتي من قاعدة البيانات)
    final mockVehicles = <Map<String, dynamic>>[
      {
        'id': '1',
        'ownerId': currentUser.id, // ربط بهوية الناقل الحالي
        'type': 'شاحنة',
        'plateNumber': 'أ ب ج 1234',
        'capacity': '10 طن',
        'status': 'available'
      },
      {
        'id': '2',
        'ownerId': currentUser.id, // ربط بهوية الناقل الحالي
        'type': 'بيك آب',
        'plateNumber': 'د ه و 5678',
        'capacity': '2 طن',
        'status': 'busy'
      },
      {
        'id': '3',
        'ownerId': 'other-transporter', // مركبة لناقل آخر - لا يجب أن تظهر
        'type': 'شاحنة كبيرة',
        'plateNumber': 'س ش ص 9012',
        'capacity': '15 طن',
        'status': 'available'
      },
    ];

    await Future.delayed(const Duration(milliseconds: 500)); // محاكاة التحميل

    // تصفية البيانات لعرض فقط البيانات المتعلقة بالناقل الحالي
    final filteredRequests = mockRequests
        .where((req) => req['transporterId'] == currentUser.id)
        .toList();
    final filteredVehicles = mockVehicles
        .where((vehicle) => vehicle['ownerId'] == currentUser.id)
        .toList();

    setState(() {
      transportRequests = filteredRequests;
      myVehicles = filteredVehicles;
      isLoading = false;
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
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(texts['transportService'] ?? 'Transport Service'),
            if (widget.transportUser != null)
              Text(
                '${texts['welcome'] ?? 'Welcome'} ${widget.transportUser!.email}',
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
              icon: const Icon(Icons.local_shipping),
              text: texts['requests'],
            ),
            Tab(
              icon: const Icon(Icons.directions_car),
              text: texts['myVehicles'],
            ),
            Tab(
              icon: const Icon(Icons.route),
              text: texts['routes'],
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
          _buildRequestsTab(),
          _buildVehiclesTab(),
          _buildRoutesTab(),
          _buildAnalyticsTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
              backgroundColor: const Color(0xFFFF9800),
              onPressed: _showAddVehicleDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildRequestsTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (transportRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping_outlined,
                size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              texts['noRequests'] ?? 'No transport requests',
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
      itemCount: transportRequests.length,
      itemBuilder: (context, index) {
        final request = transportRequests[index];
        return _buildRequestCard(request);
      },
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withAlpha(26),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'طلب #${request['id']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFFF9800),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  request['price'] ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Route info
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${texts['from']}: ${request['from']}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.flag, color: Colors.red, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${texts['to']}: ${request['to']}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Cargo and details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.inventory_2,
                          color: Colors.grey[600], size: 16),
                      const SizedBox(width: 8),
                      Text('${texts['cargo']}: ${request['cargo']}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.scale, color: Colors.grey[600], size: 16),
                      const SizedBox(width: 8),
                      Text('${texts['weight']}: ${request['weight']}'),
                      const Spacer(),
                      Icon(Icons.straighten, color: Colors.grey[600], size: 16),
                      const SizedBox(width: 4),
                      Text('${request['distance']}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          color: Colors.grey[600], size: 16),
                      const SizedBox(width: 8),
                      Text(
                          '${texts['estimatedTime']}: ${request['estimatedTime']}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Text(
              'العميل: ${request['clientName']}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleRequestAction(request, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: Text(texts['rejectRequest'] ?? 'Reject'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleRequestAction(request, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(texts['acceptRequest'] ?? 'Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehiclesTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (myVehicles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car_outlined,
                size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              texts['noVehicles'] ?? 'No vehicles',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              texts['addFirstVehicle'] ?? 'Add your first vehicle',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddVehicleDialog,
              icon: const Icon(Icons.add),
              label: Text(texts['addVehicle'] ?? 'Add Vehicle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myVehicles.length,
      itemBuilder: (context, index) {
        final vehicle = myVehicles[index];
        return _buildVehicleCard(vehicle);
      },
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> vehicle) {
    final status = vehicle['status'] ?? 'available';
    Color statusColor;
    String statusText;

    switch (status) {
      case 'available':
        statusColor = Colors.green;
        statusText = texts['available'] ?? 'Available';
        break;
      case 'busy':
        statusColor = Colors.orange;
        statusText = texts['busy'] ?? 'Busy';
        break;
      case 'maintenance':
        statusColor = Colors.red;
        statusText = texts['maintenance'] ?? 'Maintenance';
        break;
      default:
        statusColor = Colors.grey;
        statusText = status;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFFF9800),
          child: Icon(Icons.local_shipping, color: Colors.white),
        ),
        title: Text('${vehicle['type']} - ${vehicle['plateNumber']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${texts['capacity']}: ${vehicle['capacity']}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
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
                  Text(texts['edit'] ?? 'Edit'),
                ],
              ),
              onTap: () => _editVehicle(vehicle),
            ),
            PopupMenuItem(
              child: Row(
                children: [
                  const Icon(Icons.delete, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(texts['delete'] ?? 'Delete',
                      style: const TextStyle(color: Colors.red)),
                ],
              ),
              onTap: () => _deleteVehicle(vehicle),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildRoutesTab() {
    return const Center(
      child: Text('خريطة الطرق قيد التطوير'),
    );
  }

  Widget _buildAnalyticsTab() {
    final availableVehicles =
        myVehicles.where((v) => v['status'] == 'available').length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '${transportRequests.length}',
                  texts['totalRequests'] ?? 'Total Requests',
                  Icons.local_shipping,
                  const Color(0xFFFF9800),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  '0', // placeholder
                  texts['completedTrips'] ?? 'Completed Trips',
                  Icons.check_circle,
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
                  texts['totalEarnings'] ?? 'Total Earnings',
                  Icons.monetization_on,
                  const Color(0xFF1976D2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  '$availableVehicles',
                  texts['activeVehicles'] ?? 'Active Vehicles',
                  Icons.directions_car,
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

  void _showAddVehicleDialog() {
    final plateController = TextEditingController();
    final capacityController = TextEditingController();
    String selectedType = 'شاحنة';
    String selectedStatus = 'available';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(texts['addVehicle'] ?? 'Add Vehicle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: texts['vehicleType'] ?? 'Vehicle Type',
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    'شاحنة',
                    'بيك آب',
                    'فان',
                    'مقطورة',
                    'كرين',
                    'خلاطة',
                  ].map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: plateController,
                  decoration: InputDecoration(
                    labelText: texts['plateNumber'] ?? 'Plate Number',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: capacityController,
                  decoration: InputDecoration(
                    labelText: '${texts['capacity']} (${texts['ton']})',
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: InputDecoration(
                    labelText: texts['status'] ?? 'Status',
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    {
                      'value': 'available',
                      'text': texts['available'] ?? 'Available'
                    },
                    {'value': 'busy', 'text': texts['busy'] ?? 'Busy'},
                    {
                      'value': 'maintenance',
                      'text': texts['maintenance'] ?? 'Maintenance'
                    },
                  ].map((item) {
                    return DropdownMenuItem(
                      value: item['value'],
                      child: Text(item['text']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedStatus = value;
                      });
                    }
                  },
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
              onPressed: () => _saveVehicle(
                type: selectedType,
                plateNumber: plateController.text,
                capacity: capacityController.text,
                status: selectedStatus,
              ),
              child: Text(texts['save'] ?? 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveVehicle({
    required String type,
    required String plateNumber,
    required String capacity,
    required String status,
  }) {
    if (plateNumber.isEmpty || capacity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى ملء جميع الحقول'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      myVehicles.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': type,
        'plateNumber': plateNumber,
        'capacity': '$capacity طن',
        'status': status,
      });
    });

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إضافة المركبة بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _editVehicle(Map<String, dynamic> vehicle) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تعديل المركبة قيد التطوير')),
    );
  }

  void _deleteVehicle(Map<String, dynamic> vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل تريد حذف هذه المركبة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(texts['cancel'] ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                myVehicles.removeWhere((v) => v['id'] == vehicle['id']);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حذف المركبة'),
                  backgroundColor: Colors.green,
                ),
              );
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

  void _handleRequestAction(Map<String, dynamic> request, bool accept) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(accept ? 'تم قبول طلب النقل' : 'تم رفض طلب النقل'),
        backgroundColor: accept ? Colors.green : Colors.red,
      ),
    );

    if (accept) {
      // في الواقع، سنحتاج لتحديث حالة الطلب وربطه بإحدى المركبات
      setState(() {
        transportRequests.removeWhere((r) => r['id'] == request['id']);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
