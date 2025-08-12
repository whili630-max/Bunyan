import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bunyan/main_admin.dart' as admin_portal;
import 'package:bunyan/main_client.dart' as client_site;

class MainSelectorPage extends StatelessWidget {
  const MainSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.business_center_outlined,
                size: 80,
                color: Colors.teal.shade700,
              ),
              const SizedBox(height: 20),
              Text(
                'منصة بنيان',
                style: GoogleFonts.cairo(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'بوابتك المتكاملة لقطاع الإنشاءات',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 60),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildPortalCard(
                        context: context,
                        title: 'بوابة الأعمال',
                        subtitle: 'للموردين، المقاولين، والمدراء',
                        icon: Icons.work_outline,
                        color: Colors.teal,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const admin_portal.BunyanAdminPortal()),
                          );
                        },
                      ),
                      const SizedBox(width: 30),
                      _buildPortalCard(
                        context: context,
                        title: 'بوابة العملاء',
                        subtitle: 'تصفح المنتجات واطلب عروض الأسعار',
                        icon: Icons.person_outline,
                        color: Colors.orange,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const client_site.BunyanClientSite()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortalCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Card(
          elevation: 6,
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: color, width: 6)),
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 60, color: color),
                const SizedBox(height: 24),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
