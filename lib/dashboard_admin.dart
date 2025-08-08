import 'package:flutter/material.dart';
import 'user_management.dart';
import 'l10n/app_localizations.dart';
import 'language_switcher.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text(localizations.adminDashboard),
        centerTitle: true,
        actions: const [
          LanguageSwitcher(),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.admin_panel_settings,
                size: 80, color: Colors.purple),
            const SizedBox(height: 16),
            Text('${localizations.welcome} ${localizations.adminDashboard}!',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.people, color: Colors.white),
              label: Text(localizations.userManagement),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserManagementPage()),
                );
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.settings, color: Colors.white),
              label: Text(localizations.systemManagement),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
