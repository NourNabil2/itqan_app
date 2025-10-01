import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);

    return SettingsCard(
      title: l10n.appearance,
      icon: Icons.palette_outlined,
      children: [
        SettingsTile(
          icon: Icons.dark_mode_outlined,
          title: l10n.theme,
          subtitle: l10n.getThemeName(currentTheme),
          onTap: () => _showThemeDialog(context),
        ),
        SettingsTile(
          icon: Icons.language,
          title: l10n.language,
          subtitle: currentLanguage == 'ar' ? l10n.arabic : l10n.english,
          onTap: () => _showLanguageDialog(context),
        ),
      ],
    );
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