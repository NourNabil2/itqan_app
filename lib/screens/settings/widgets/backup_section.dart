import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/providers/settings_provider.dart';
import 'package:provider/provider.dart';

import 'setting_card/settings_card.dart';
import 'setting_card/settings_tile.dart';
import 'setting_card/settings_toggle.dart';

class BackupSection extends StatelessWidget {
  final bool autoBackupEnabled;
  final bool isPremium;

  const BackupSection({
    super.key,
    required this.autoBackupEnabled,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SettingsCard(
      title: l10n.backup,
      icon: Icons.backup_outlined,
      isPremiumFeature: !isPremium,
      children: [
        SettingsTile(
          icon: Icons.cloud_upload_outlined,
          title: l10n.backupNow,
          subtitle: l10n.backupNowDescription,
          onTap: isPremium ? () => _handleBackup(context) : null,
          isDisabled: !isPremium,
        ),
        SettingsTile(
          icon: Icons.cloud_download_outlined,
          title: l10n.restoreData,
          subtitle: l10n.restoreDataDescription,
          onTap: isPremium ? () => _handleRestore(context) : null,
          isDisabled: !isPremium,
        ),
        SettingsToggle(
          icon: Icons.sync,
          title: l10n.autoBackupTitle,
          subtitle: l10n.autoBackupDescription,
          value: autoBackupEnabled && isPremium,
          onChanged: isPremium
              ? (value) {
            context.read<SettingsProvider>().toggleAutoBackup(value);
          }
              : null,
          isDisabled: !isPremium,
        ),
      ],
    );
  }

  void _handleBackup(BuildContext context) {
    HapticFeedback.mediumImpact();
    // Implement backup logic
  }

  void _handleRestore(BuildContext context) {
    HapticFeedback.mediumImpact();
    // Implement restore logic
  }
}