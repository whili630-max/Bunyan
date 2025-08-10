import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_manager.dart';
import 'bunyan_models.dart';
import 'pre_approved_companies.dart';
import 'bunyan_home_simple.dart';

class AuthPage extends StatefulWidget {
  final UserRole userRole;

  const AuthPage({super.key, required this.userRole});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = false;
  Map<String, String> texts = {
    // قيم افتراضية باللغة العربية
    'login': 'تسجيل الدخول',
    'register': 'إنشاء حساب جديد',
    'email': 'البريد الإلكتروني',
    'password': 'كلمة المرور',
    'name': 'الاسم الكامل',
    'phone': 'رقم الهاتف',
    'commercialRegister': 'السجل التجاري',
    'companyName': 'اسم الشركة',
    'loginButton': 'دخول',
    'registerButton': 'إنشاء حساب',
    'guest': 'دخول كزائر',
    'alreadyHaveAccount': 'لديك حساب؟ سجل الدخول',
    'dontHaveAccount': 'ليس لديك حساب؟ أنشئ حساباً جديداً',
    'forgotPassword': 'نسيت كلمة المرور؟',
  };

  // Login controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Register controllers
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPhoneController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();
  final _registerCompanyController = TextEditingController();
  final _registerCommercialRegisterController = TextEditingController();
  final _registerAddressController = TextEditingController();
  final _registerCityController = TextEditingController();

  String? selectedCity;
  BuildingCategory? selectedSpecialization;
  PreApprovedCompany? selectedCompany;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTexts();
    });
  }

  void _loadTexts() {
    final languageManager =
        Provider.of<LanguageManager>(context, listen: false);
    final isArabic = languageManager.currentLocale.languageCode == 'ar';

    setState(() {
      texts = {
        'login': isArabic ? 'تسجيل الدخول' : 'Login',
        'register': isArabic ? 'التسجيل' : 'Register',
        'guestMode': isArabic ? 'الدخول كزائر' : 'Guest Mode',
        'email': isArabic ? 'البريد الإلكتروني' : 'Email',
        'password': isArabic ? 'كلمة المرور' : 'Password',
        'confirmPassword': isArabic ? 'تأكيد كلمة المرور' : 'Confirm Password',
        'name': isArabic ? 'الاسم' : 'Name',
        'phone': isArabic ? 'رقم الهاتف' : 'Phone',
        'companyName': isArabic ? 'اسم الشركة' : 'Company Name',
        'commercialRegister':
            isArabic ? 'السجل التجاري' : 'Commercial Register',
        'address': isArabic ? 'العنوان' : 'Address',
        'city': isArabic ? 'المدينة' : 'City',
        'specialization': isArabic ? 'التخصص' : 'Specialization',
        'selectCity': isArabic ? 'اختر المدينة' : 'Select City',
        'selectSpecialization':
            isArabic ? 'اختر التخصص' : 'Select Specialization',
        'riyadh': isArabic ? 'الرياض' : 'Riyadh',
        'jeddah': isArabic ? 'جدة' : 'Jeddah',
        'dammam': isArabic ? 'الدمام' : 'Dammam',
        'medina': isArabic ? 'المدينة المنورة' : 'Medina',
        'mecca': isArabic ? 'مكة المكرمة' : 'Mecca',
        'loading': isArabic ? 'جاري التحميل...' : 'Loading...',
        'submit': isArabic ? 'إرسال' : 'Submit',
        'cancel': isArabic ? 'إلغاء' : 'Cancel',
        'error': isArabic ? 'خطأ' : 'Error',
        'success': isArabic ? 'نجح' : 'Success',
        'requiredField':
            isArabic ? 'هذا الحقل مطلوب' : 'This field is required',
        'invalidEmail': isArabic ? 'بريد إلكتروني غير صحيح' : 'Invalid email',
        'passwordMismatch':
            isArabic ? 'كلمات المرور غير متطابقة' : 'Passwords do not match',
        'companyNotApproved': isArabic
            ? 'الشركة غير معتمدة للتسجيل'
            : 'Company not approved for registration',
        'registrationSuccess':
            isArabic ? 'تم التسجيل بنجاح!' : 'Registration successful!',
        'loginSuccess':
            isArabic ? 'تم تسجيل الدخول بنجاح!' : 'Login successful!',
        'approvedCompaniesOnly': isArabic
            ? 'التسجيل متاح للشركات المعتمدة فقط'
            : 'Registration available for approved companies only',
        'searchCompany': isArabic ? 'البحث عن شركة...' : 'Search company...',
        'noCompaniesFound':
            isArabic ? 'لم يتم العثور على شركات' : 'No companies found',
        'selectFromList': isArabic ? 'اختر من القائمة' : 'Select from list',
      };
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
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: Text(_getUserRoleTitle()),
        bottom: widget.userRole == UserRole.client
            ? null
            : TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(text: texts['login']),
                  Tab(text: texts['register']),
                ],
              ),
      ),
      body: widget.userRole == UserRole.client
          ? _buildClientAuth()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLoginTab(),
                _buildRegisterTab(),
              ],
            ),
    );
  }

  Widget _buildClientAuth() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Guest Mode Button
          Card(
            child: ListTile(
              leading:
                  const Icon(Icons.person_outline, color: Color(0xFF2E7D32)),
              title: Text(texts['guestMode'] ?? 'Guest Mode'),
              subtitle: Text(
                'استعراض المنتجات والخدمات بدون تسجيل',
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _continueAsGuest,
            ),
          ),
          const SizedBox(height: 24),

          // Login Form
          _buildLoginForm(),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Register Form
          const Text(
            'إنشاء حساب جديد',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildClientRegisterForm(),
        ],
      ),
    );
  }

  Widget _buildLoginTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _buildLoginForm(),
    );
  }

  Widget _buildRegisterTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    texts['approvedCompaniesOnly'] ?? '',
                    style: const TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildCompanyRegisterForm(),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _loginEmailController,
          decoration: InputDecoration(
            labelText: texts['email'],
            prefixIcon: const Icon(Icons.email_outlined),
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _loginPasswordController,
          decoration: InputDecoration(
            labelText: texts['password'],
            prefixIcon: const Icon(Icons.lock_outlined),
            border: const OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: isLoading ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(texts['loading'] ?? 'Loading...'),
                  ],
                )
              : Text(texts['login'] ?? 'Login'),
        ),
      ],
    );
  }

  Widget _buildClientRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _registerNameController,
          decoration: InputDecoration(
            labelText: texts['name'],
            prefixIcon: const Icon(Icons.person_outlined),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _registerEmailController,
          decoration: InputDecoration(
            labelText: texts['email'],
            prefixIcon: const Icon(Icons.email_outlined),
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _registerPhoneController,
          decoration: InputDecoration(
            labelText: texts['phone'],
            prefixIcon: const Icon(Icons.phone_outlined),
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _registerPasswordController,
          decoration: InputDecoration(
            labelText: texts['password'],
            prefixIcon: const Icon(Icons.lock_outlined),
            border: const OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _registerConfirmPasswordController,
          decoration: InputDecoration(
            labelText: texts['confirmPassword'],
            prefixIcon: const Icon(Icons.lock_outlined),
            border: const OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: isLoading ? null : () => _handleRegister(UserRole.client),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(texts['loading'] ?? 'Loading...'),
                  ],
                )
              : Text(texts['register'] ?? 'Register'),
        ),
      ],
    );
  }

  Widget _buildCompanyRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Company Search
        TextFormField(
          decoration: InputDecoration(
            labelText: texts['searchCompany'],
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
          ),
          onChanged: _searchCompanies,
        ),
        const SizedBox(height: 16),

        // Selected Company Display
        if (selectedCompany != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              border: Border.all(color: Colors.green[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedCompany!.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('السجل التجاري: ${selectedCompany!.commercialRegister}'),
                Text('المدينة: ${selectedCompany!.city}'),
                Text(
                    'التخصص: ${buildingCategoryNames[selectedCompany!.category]}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Personal Information
        TextFormField(
          controller: _registerNameController,
          decoration: InputDecoration(
            labelText: texts['name'],
            prefixIcon: const Icon(Icons.person_outlined),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _registerEmailController,
          decoration: InputDecoration(
            labelText: texts['email'],
            prefixIcon: const Icon(Icons.email_outlined),
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _registerPhoneController,
          decoration: InputDecoration(
            labelText: texts['phone'],
            prefixIcon: const Icon(Icons.phone_outlined),
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _registerPasswordController,
          decoration: InputDecoration(
            labelText: texts['password'],
            prefixIcon: const Icon(Icons.lock_outlined),
            border: const OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _registerConfirmPasswordController,
          decoration: InputDecoration(
            labelText: texts['confirmPassword'],
            prefixIcon: const Icon(Icons.lock_outlined),
            border: const OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: (isLoading || selectedCompany == null)
              ? null
              : () => _handleRegister(widget.userRole),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(texts['loading'] ?? 'Loading...'),
                  ],
                )
              : Text(texts['register'] ?? 'Register'),
        ),
      ],
    );
  }

  String _getUserRoleTitle() {
    switch (widget.userRole) {
      case UserRole.client:
        return userRoleNames[widget.userRole] ?? 'عميل';
      case UserRole.supplier:
        return userRoleNames[widget.userRole] ?? 'مورد';
      case UserRole.transporter:
        return userRoleNames[widget.userRole] ?? 'ناقل';
      case UserRole.contractor:
        return userRoleNames[widget.userRole] ?? 'مقاول';
      case UserRole.admin:
        return userRoleNames[widget.userRole] ?? 'مدير';
    }
  }

  void _searchCompanies(String query) {
    if (query.length < 3) return;

    final companies =
        PreApprovedCompanies.searchCompanies(query, widget.userRole);

    if (companies.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(texts['selectFromList'] ?? 'Select from list'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: companies.length,
              itemBuilder: (context, index) {
                final company = companies[index];
                return ListTile(
                  title: Text(company.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('السجل التجاري: ${company.commercialRegister}'),
                      Text('المدينة: ${company.city}'),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      selectedCompany = company;
                      _registerCompanyController.text = company.name;
                      _registerCommercialRegisterController.text =
                          company.commercialRegister;
                      selectedCity = company.city;
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(texts['cancel'] ?? 'Cancel'),
            ),
          ],
        ),
      );
    }
  }

  void _continueAsGuest() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const BunyanDashboard(userRole: UserRole.client),
      ),
    );
  }

  void _handleLogin() async {
    if (_loginEmailController.text.isEmpty ||
        _loginPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(texts['requiredField'] ?? 'Required fields missing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // محاكاة تسجيل الدخول
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(texts['loginSuccess'] ?? 'Login successful!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => BunyanDashboard(userRole: widget.userRole),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${texts['error']}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _handleRegister(UserRole role) async {
    // التحقق من صحة البيانات
    if (_registerNameController.text.isEmpty ||
        _registerEmailController.text.isEmpty ||
        _registerPhoneController.text.isEmpty ||
        _registerPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(texts['requiredField'] ?? 'Required fields missing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_registerPasswordController.text !=
        _registerConfirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(texts['passwordMismatch'] ?? 'Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // للشركات: التحقق من الاعتماد
    if (role != UserRole.client && selectedCompany == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(texts['companyNotApproved'] ?? 'Company not approved'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // محاكاة التسجيل
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(texts['registrationSuccess'] ?? 'Registration successful!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => BunyanDashboard(userRole: role),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${texts['error']}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPhoneController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    _registerCompanyController.dispose();
    _registerCommercialRegisterController.dispose();
    _registerAddressController.dispose();
    _registerCityController.dispose();
    super.dispose();
  }
}
