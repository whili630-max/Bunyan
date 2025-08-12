import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_manager.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageManager>(
      builder: (context, languageManager, child) {
        return PopupMenuButton<String>(
          icon: Icon(languageManager
              .getLanguageIcon(languageManager.currentLocale.languageCode)),
          onSelected: (String languageCode) {
            languageManager.changeLanguage(languageCode);
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'ar',
              child: Row(
                children: [
                  Icon(languageManager.getLanguageIcon('ar')),
                  const SizedBox(width: 8),
                  Text(languageManager.getLanguageName('ar')),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'en',
              child: Row(
                children: [
                  Icon(languageManager.getLanguageIcon('en')),
                  const SizedBox(width: 8),
                  Text(languageManager.getLanguageName('en')),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'ur',
              child: Row(
                children: [
                  Icon(languageManager.getLanguageIcon('ur')),
                  const SizedBox(width: 8),
                  Text(languageManager.getLanguageName('ur')),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
