import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_manager.dart';
import 'bunyan_models.dart';
import 'auth_manager.dart';

class ContractorServicePage extends StatefulWidget {
  final BunyanUser? contractorUser;

  const ContractorServicePage({super.key, this.contractorUser});

  @override
  State<ContractorServicePage> createState() => _ContractorServicePageState();
}

class _ContractorServicePageState extends State<ContractorServicePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> projects = [];
  List<Map<String, dynamic>> bids = [];
  List<Map<String, dynamic>> contracts = [];
  bool isLoading = true;
  late Map<String, String> texts;

  // التحقق من صلاحيات الوصول لخدمة المقاولين
  void _enforceContractorAccess() {
    final authManager = Provider.of<AuthManager>(context, listen: false);
    if (authManager.currentUser == null ||
        authManager.currentUser!.type != 'contractor') {
      // لا يوجد مستخدم مسجل الدخول أو المستخدم ليس مقاول
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // إظهار رسالة تحذير
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('غير مصرح لك بالوصول إلى خدمة المقاولين'),
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

    // التحقق من صلاحيات الوصول لخدمة المقاولين
    _enforceContractorAccess();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTexts();
      _loadContractorData();
    });
  }

  void _loadTexts() {
    final languageManager =
        Provider.of<LanguageManager>(context, listen: false);
    final isArabic = languageManager.currentLocale.languageCode == 'ar';

    setState(() {
      texts = {
        'contractorService': isArabic ? 'خدمة المقاولين' : 'Contractor Service',
        'projects': isArabic ? 'المشاريع' : 'Projects',
        'bids': isArabic ? 'المناقصات' : 'Bids',
        'contracts': isArabic ? 'العقود' : 'Contracts',
        'analytics': isArabic ? 'الإحصائيات' : 'Analytics',
        'submitBid': isArabic ? 'تقديم عرض' : 'Submit Bid',
        'viewProject': isArabic ? 'عرض المشروع' : 'View Project',
        'projectDetails': isArabic ? 'تفاصيل المشروع' : 'Project Details',
        'projectName': isArabic ? 'اسم المشروع' : 'Project Name',
        'location': isArabic ? 'الموقع' : 'Location',
        'budget': isArabic ? 'الميزانية' : 'Budget',
        'deadline': isArabic ? 'الموعد النهائي' : 'Deadline',
        'description': isArabic ? 'الوصف' : 'Description',
        'requirements': isArabic ? 'المتطلبات' : 'Requirements',
        'bidAmount': isArabic ? 'قيمة العرض' : 'Bid Amount',
        'timeline': isArabic ? 'الجدول الزمني' : 'Timeline',
        'experience': isArabic ? 'الخبرة' : 'Experience',
        'portfolio': isArabic ? 'معرض الأعمال' : 'Portfolio',
        'activeProjects': isArabic ? 'المشاريع النشطة' : 'Active Projects',
        'completedProjects':
            isArabic ? 'المشاريع المكتملة' : 'Completed Projects',
        'totalEarnings': isArabic ? 'إجمالي الأرباح' : 'Total Earnings',
        'pendingBids': isArabic ? 'العروض المعلقة' : 'Pending Bids',
        'noProjects':
            isArabic ? 'لا توجد مشاريع متاحة' : 'No projects available',
        'noBids': isArabic ? 'لا توجد مناقصات' : 'No bids',
        'noContracts': isArabic ? 'لا توجد عقود' : 'No contracts',
        'residential': isArabic ? 'سكني' : 'Residential',
        'commercial': isArabic ? 'تجاري' : 'Commercial',
        'industrial': isArabic ? 'صناعي' : 'Industrial',
        'infrastructure': isArabic ? 'بنية تحتية' : 'Infrastructure',
        'renovation': isArabic ? 'تجديد' : 'Renovation',
        'status': isArabic ? 'الحالة' : 'Status',
        'pending': isArabic ? 'معلق' : 'Pending',
        'inProgress': isArabic ? 'قيد التنفيذ' : 'In Progress',
        'completed': isArabic ? 'مكتمل' : 'Completed',
        'cancelled': isArabic ? 'ملغي' : 'Cancelled',
        'sar': isArabic ? 'ريال' : 'SAR',
        'days': isArabic ? 'يوم' : 'days',
        'months': isArabic ? 'شهر' : 'months',
        'welcome': isArabic ? 'مرحباً' : 'Welcome',
        'submit': isArabic ? 'إرسال' : 'Submit',
        'cancel': isArabic ? 'إلغاء' : 'Cancel',
        'save': isArabic ? 'حفظ' : 'Save',
        'client': isArabic ? 'العميل' : 'Client',
        'startDate': isArabic ? 'تاريخ البداية' : 'Start Date',
        'endDate': isArabic ? 'تاريخ الانتهاء' : 'End Date',
        'progress': isArabic ? 'التقدم' : 'Progress',
      };
    });
  }

  Future<void> _loadContractorData() async {
    // الحصول على بيانات المستخدم الحالي
    final authManager = Provider.of<AuthManager>(context, listen: false);
    final currentUser = authManager.currentUser;

    if (currentUser == null || currentUser.type != 'contractor') {
      // إذا لم يكن المستخدم مسجل دخول أو ليس مقاول، لا تحمل أي بيانات
      setState(() {
        projects = [];
        bids = [];
        contracts = [];
        isLoading = false;
      });
      return;
    }

    // بيانات وهمية للمشاريع المتاحة (في التطبيق الحقيقي ستأتي من قاعدة البيانات)
    final mockProjects = <Map<String, dynamic>>[
      {
        'id': '1',
        'name': 'بناء فيلا سكنية',
        'client': 'أحمد محمد العلي',
        'location': 'الرياض - حي الملقا',
        'budget': '500000',
        'deadline': '6 أشهر',
        'type': 'residential',
        'description': 'بناء فيلا سكنية من دورين مع حديقة',
        'requirements': 'خبرة في البناء السكني، رخصة مقاول معتمد',
        'bidsCount': 5,
        'status': 'pending'
      },
      {
        'id': '2',
        'name': 'تجديد مكتب تجاري',
        'client': 'شركة الأعمال المتقدمة',
        'location': 'جدة - حي الزهراء',
        'budget': '150000',
        'deadline': '3 أشهر',
        'type': 'commercial',
        'description': 'تجديد مكتب تجاري شامل التصميم الداخلي',
        'requirements': 'خبرة في التجديد التجاري، معرض أعمال سابقة',
        'bidsCount': 3,
        'status': 'pending'
      },
    ];

    // بيانات وهمية لعروض المقاول (في التطبيق الحقيقي ستأتي من قاعدة البيانات)
    final mockBids = <Map<String, dynamic>>[
      {
        'id': '1',
        'contractorId': currentUser.id, // ربط بهوية المقاول الحالي
        'projectName': 'بناء مسجد',
        'bidAmount': '800000',
        'timeline': '8 أشهر',
        'status': 'pending',
        'submittedDate': '2024-01-15',
        'client': 'مؤسسة الخير'
      },
      {
        'id': '2',
        'contractorId': currentUser.id, // ربط بهوية المقاول الحالي
        'projectName': 'ترميم مدرسة',
        'bidAmount': '200000',
        'timeline': '4 أشهر',
        'status': 'accepted',
        'submittedDate': '2024-01-10',
        'client': 'وزارة التعليم'
      },
      {
        'id': '3',
        'contractorId': 'other-contractor', // عرض لمقاول آخر - لا يجب أن يظهر
        'projectName': 'بناء مركز تجاري',
        'bidAmount': '1500000',
        'timeline': '12 أشهر',
        'status': 'pending',
        'submittedDate': '2024-01-20',
        'client': 'شركة التطوير العقاري'
      },
    ];

    // بيانات وهمية للعقود (في التطبيق الحقيقي ستأتي من قاعدة البيانات)
    final mockContracts = <Map<String, dynamic>>[
      {
        'id': '1',
        'contractorId': currentUser.id, // ربط بهوية المقاول الحالي
        'projectName': 'بناء مجمع سكني',
        'client': 'شركة العقارات الذهبية',
        'value': '2000000',
        'startDate': '2024-01-01',
        'endDate': '2024-12-31',
        'progress': 35,
        'status': 'inProgress'
      },
      {
        'id': '2',
        'contractorId': 'other-contractor', // عقد لمقاول آخر - لا يجب أن يظهر
        'projectName': 'بناء فندق',
        'client': 'مجموعة الفنادق العالمية',
        'value': '5000000',
        'startDate': '2023-10-01',
        'endDate': '2025-05-31',
        'progress': 20,
        'status': 'inProgress'
      },
    ];

    await Future.delayed(const Duration(milliseconds: 500)); // محاكاة التحميل

    // تصفية البيانات لعرض فقط البيانات المتعلقة بالمقاول الحالي
    final filteredBids =
        mockBids.where((bid) => bid['contractorId'] == currentUser.id).toList();
    final filteredContracts = mockContracts
        .where((contract) => contract['contractorId'] == currentUser.id)
        .toList();

    setState(() {
      projects = mockProjects; // المشاريع متاحة للجميع
      bids = filteredBids; // عرض العروض الخاصة بالمقاول الحالي فقط
      contracts = filteredContracts; // عرض العقود الخاصة بالمقاول الحالي فقط
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
        backgroundColor: const Color(0xFF8BC34A),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(texts['contractorService'] ?? 'Contractor Service'),
            if (widget.contractorUser != null)
              Text(
                '${texts['welcome'] ?? 'Welcome'} ${widget.contractorUser!.email}',
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
              icon: const Icon(Icons.work),
              text: texts['projects'],
            ),
            Tab(
              icon: const Icon(Icons.gavel),
              text: texts['bids'],
            ),
            Tab(
              icon: const Icon(Icons.description),
              text: texts['contracts'],
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
          _buildProjectsTab(),
          _buildBidsTab(),
          _buildContractsTab(),
          _buildAnalyticsTab(),
        ],
      ),
    );
  }

  Widget _buildProjectsTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              texts['noProjects'] ?? 'No projects available',
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
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return _buildProjectCard(project);
      },
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    project['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getProjectTypeColor(project['type']).withAlpha(26),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getProjectTypeText(project['type']),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getProjectTypeColor(project['type']),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${texts['client']}: ${project['client']}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey[500], size: 16),
                const SizedBox(width: 4),
                Text(project['location'] ?? ''),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              project['description'] ?? '',
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
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
                      const Icon(Icons.monetization_on,
                          color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      Text(
                          '${texts['budget']}: ${project['budget']} ${texts['sar']}'),
                      const Spacer(),
                      const Icon(Icons.schedule, color: Colors.blue, size: 16),
                      const SizedBox(width: 4),
                      Text(project['deadline'] ?? ''),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.groups, color: Colors.orange, size: 16),
                      const SizedBox(width: 8),
                      Text('عدد العروض المقدمة: ${project['bidsCount']}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showProjectDetails(project),
                    icon: const Icon(Icons.visibility),
                    label: Text(texts['viewProject'] ?? 'View Project'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showBidDialog(project),
                    icon: const Icon(Icons.send),
                    label: Text(texts['submitBid'] ?? 'Submit Bid'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8BC34A),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBidsTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bids.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.gavel_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              texts['noBids'] ?? 'No bids',
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
      itemCount: bids.length,
      itemBuilder: (context, index) {
        final bid = bids[index];
        return _buildBidCard(bid);
      },
    );
  }

  Widget _buildBidCard(Map<String, dynamic> bid) {
    final status = bid['status'] ?? 'pending';
    Color statusColor;
    String statusText;

    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = texts['pending'] ?? 'Pending';
        break;
      case 'accepted':
        statusColor = Colors.green;
        statusText = 'مقبول';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'مرفوض';
        break;
      default:
        statusColor = Colors.grey;
        statusText = status;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(bid['projectName'] ?? ''),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${texts['client']}: ${bid['client']}'),
            const SizedBox(height: 4),
            Text('قيمة العرض: ${bid['bidAmount']} ${texts['sar']}'),
            Text('المدة الزمنية: ${bid['timeline']}'),
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
                const Spacer(),
                Text(
                  'تاريخ التقديم: ${bid['submittedDate']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildContractsTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (contracts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              texts['noContracts'] ?? 'No contracts',
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
      itemCount: contracts.length,
      itemBuilder: (context, index) {
        final contract = contracts[index];
        return _buildContractCard(contract);
      },
    );
  }

  Widget _buildContractCard(Map<String, dynamic> contract) {
    final progress = (contract['progress'] ?? 0) as int;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    contract['projectName'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(26),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    texts['inProgress'] ?? 'In Progress',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${texts['client']}: ${contract['client']}'),
            Text('قيمة العقد: ${contract['value']} ${texts['sar']}'),
            Text('تاريخ البداية: ${contract['startDate']}'),
            Text('تاريخ الانتهاء: ${contract['endDate']}'),
            const SizedBox(height: 12),
            Text('${texts['progress']}: $progress%'),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: progress / 100.0,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress < 30
                    ? Colors.red
                    : progress < 70
                        ? Colors.orange
                        : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    final activeProjectsCount =
        contracts.where((c) => c['status'] == 'inProgress').length;
    final completedProjectsCount =
        contracts.where((c) => c['status'] == 'completed').length;
    final pendingBidsCount = bids.where((b) => b['status'] == 'pending').length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '$activeProjectsCount',
                  texts['activeProjects'] ?? 'Active Projects',
                  Icons.work,
                  const Color(0xFF8BC34A),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  '$completedProjectsCount',
                  texts['completedProjects'] ?? 'Completed Projects',
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
                  '$pendingBidsCount',
                  texts['pendingBids'] ?? 'Pending Bids',
                  Icons.gavel,
                  const Color(0xFFFF9800),
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

  Color _getProjectTypeColor(String? type) {
    switch (type) {
      case 'residential':
        return Colors.blue;
      case 'commercial':
        return Colors.green;
      case 'industrial':
        return Colors.orange;
      case 'infrastructure':
        return Colors.red;
      case 'renovation':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getProjectTypeText(String? type) {
    switch (type) {
      case 'residential':
        return texts['residential'] ?? 'Residential';
      case 'commercial':
        return texts['commercial'] ?? 'Commercial';
      case 'industrial':
        return texts['industrial'] ?? 'Industrial';
      case 'infrastructure':
        return texts['infrastructure'] ?? 'Infrastructure';
      case 'renovation':
        return texts['renovation'] ?? 'Renovation';
      default:
        return type ?? '';
    }
  }

  void _showProjectDetails(Map<String, dynamic> project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
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
                      project['name'] ?? '',
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
                '${texts['client']}: ${project['client']}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                '${texts['location']}: ${project['location']}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                '${texts['budget']}: ${project['budget']} ${texts['sar']}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${texts['deadline']}: ${project['deadline']}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                texts['description'] ?? 'Description',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(project['description'] ?? ''),
              const SizedBox(height: 16),
              Text(
                texts['requirements'] ?? 'Requirements',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(project['requirements'] ?? ''),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showBidDialog(project);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8BC34A),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(texts['submitBid'] ?? 'Submit Bid'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBidDialog(Map<String, dynamic> project) {
    final bidAmountController = TextEditingController();
    final timelineController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تقديم عرض - ${project['name']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bidAmountController,
                decoration: InputDecoration(
                  labelText: '${texts['bidAmount']} (${texts['sar']})',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: timelineController,
                decoration: InputDecoration(
                  labelText: texts['timeline'],
                  border: const OutlineInputBorder(),
                  hintText: 'مثال: 6 أشهر',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات إضافية',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
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
            onPressed: () => _submitBid(
              project: project,
              bidAmount: bidAmountController.text,
              timeline: timelineController.text,
              notes: notesController.text,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8BC34A),
              foregroundColor: Colors.white,
            ),
            child: Text(texts['submit'] ?? 'Submit'),
          ),
        ],
      ),
    );
  }

  void _submitBid({
    required Map<String, dynamic> project,
    required String bidAmount,
    required String timeline,
    required String notes,
  }) {
    if (bidAmount.isEmpty || timeline.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى ملء قيمة العرض والجدول الزمني'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Add the bid to the list
    setState(() {
      bids.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'projectName': project['name'],
        'bidAmount': bidAmount,
        'timeline': timeline,
        'status': 'pending',
        'submittedDate': DateTime.now().toString().split(' ')[0],
        'client': project['client'],
        'notes': notes,
      });
    });

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تقديم العرض بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
