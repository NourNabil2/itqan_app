import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'language_selection_dialog.dart';
import 'setting_card/settings_card.dart';
import 'setting_card/settings_tile.dart';
import 'theme_selection_dialog.dart';

class AppearanceSection extends StatelessWidget {
  final ThemeMode currentTheme;
  final String currentLanguage;

  const AppearanceSection({
    super.key,
    required this.currentTheme,
    required this.currentLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      title: 'المظهر',
      icon: Icons.palette_outlined,
      children: [
        SettingsTile(
          icon: Icons.dark_mode_outlined,
          title: 'المظهر',
          subtitle: _getThemeName(currentTheme),
          onTap: () => _showThemeDialog(context),
        ),
        SettingsTile(
          icon: Icons.language,
          title: 'اللغة',
          subtitle: currentLanguage == 'ar' ? 'العربية' : 'English',
          onTap: () => _showLanguageDialog(context),
        ),
      ],
    );
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'فاتح';
      case ThemeMode.dark:
        return 'داكن';
      case ThemeMode.system:
        return 'حسب النظام';
    }
  }

  void _showThemeDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => ThemeSelectionDialog(
        currentTheme: currentTheme,
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => LanguageSelectionDialog(
        currentLanguage: currentLanguage,
      ),
    );
  }
}
