// lib/screens/settings/widgets/backup_section.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/services/backup_service.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'setting_card/settings_card.dart';
import 'setting_card/settings_tile.dart';
import 'setting_card/settings_toggle.dart';

class BackupSection extends StatefulWidget {
  final bool autoBackupEnabled;
  final bool isPremium;

  const BackupSection({
    super.key,
    required this.autoBackupEnabled,
    required this.isPremium,
  });

  @override
  State<BackupSection> createState() => _BackupSectionState();
}

class _BackupSectionState extends State<BackupSection> {
  final BackupService _backupService = BackupService();
  BackupStats? _stats;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isPremium) {
      _loadStats();
    }
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _backupService.getBackupStats();
      if (mounted) {
        setState(() {
          _stats = stats;
        });
      }
    } catch (e) {
      // Silent fail
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SettingsCard(
      title: l10n.backup,
      icon: Icons.backup_outlined,
      isPremiumFeature: !widget.isPremium,
      children: [
        // Backup Stats (if available)
        if (widget.isPremium && _stats != null)
          _buildStatsInfo(context),

        SettingsTile(
          icon: Icons.cloud_upload_outlined,
          title: l10n.backupNow,
          subtitle: l10n.backupNowDescription,
          onTap: widget.isPremium ? () => _handleBackup(context) : null,
          isDisabled: !widget.isPremium || _isLoading,
          trailing: _isLoading
              ? SizedBox(
            width: 20.w,
            height: 20.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(
                ColorsManager.primaryColor,
              ),
            ),
          )
              : null,
        ),

        SettingsTile(
          icon: Icons.cloud_download_outlined,
          title: l10n.restoreData,
          subtitle: l10n.restoreDataDescription,
          onTap: widget.isPremium ? () => _handleRestore(context) : null,
          isDisabled: !widget.isPremium || _isLoading,
        ),

        if (widget.isPremium)
          SettingsTile(
            icon: Icons.history,
            title: l10n.backupHistory,
            subtitle: l10n.viewBackupHistory,
            onTap: () => _showBackupHistory(context),
            isDisabled: _isLoading,
          ),

        SettingsToggle(
          icon: Icons.sync,
          title: l10n.autoBackupTitle,
          subtitle: l10n.autoBackupDescription,
          value: widget.autoBackupEnabled && widget.isPremium,
          onChanged: widget.isPremium
              ? (value) {
            context.read<SettingsProvider>().toggleAutoBackup(value);
          }
              : null,
          isDisabled: !widget.isPremium,
        ),
      ],
    );
  }

  Widget _buildStatsInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: ColorsManager.infoSurface,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20.sp,
            color: ColorsManager.infoText,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_stats!.count} ${l10n.backupsAvailable}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ColorsManager.infoText,
                  ),
                ),
                if (_stats!.lastBackup != null)
                  Text(
                    '${l10n.lastBackup}: ${_formatDate(_stats!.lastBackup!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11.sp,
                      color: ColorsManager.infoText.withOpacity(0.8),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBackup(BuildContext context) async {
    HapticFeedback.mediumImpact();
    final l10n = AppLocalizations.of(context);

    // Show confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.createBackup),
        content: Text(l10n.createBackupConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.backup),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final result = await _backupService.createBackup();

      if (mounted) {
        setState(() => _isLoading = false);

        if (result.success) {
          // Clean old backups
          await _backupService.cleanOldBackups(keepCount: 5);

          // Reload stats
          await _loadStats();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.backupSuccess),
              backgroundColor: ColorsManager.successFill,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: ColorsManager.errorFill,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.backupFailed}: $e'),
            backgroundColor: ColorsManager.errorFill,
          ),
        );
      }
    }
  }

  Future<void> _handleRestore(BuildContext context) async {
    HapticFeedback.mediumImpact();
    final l10n = AppLocalizations.of(context);

    // Get backups list
    try {
      final backups = await _backupService.getBackupsList();

      if (backups.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.noBackupsFound),
            backgroundColor: ColorsManager.warningFill,
          ),
        );
        return;
      }

      // Show confirmation with warning
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: ColorsManager.warningFill),
              SizedBox(width: 8.w),
              Text(l10n.restoreData),
            ],
          ),
          content: Text(l10n.restoreWarning),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.warningFill,
              ),
              child: Text(l10n.restore),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      setState(() => _isLoading = true);

      final result = await _backupService.restoreLatestBackup();

      if (mounted) {
        setState(() => _isLoading = false);

        if (result.success) {
          // Show success and prompt to restart app
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text(l10n.restoreSuccess),
              content: Text(l10n.restartAppMessage),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    // Force close app - user will restart manually
                    SystemNavigator.pop();
                  },
                  child: Text(l10n.closeApp),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: ColorsManager.errorFill,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.restoreFailed}: $e'),
            backgroundColor: ColorsManager.errorFill,
          ),
        );
      }
    }
  }

  Future<void> _showBackupHistory(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    try {
      final backups = await _backupService.getBackupsList();

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.backupHistory),
          content: SizedBox(
            width: double.maxFinite,
            child: backups.isEmpty
                ? Text(l10n.noBackupsFound)
                : ListView.builder(
              shrinkWrap: true,
              itemCount: backups.length,
              itemBuilder: (context, index) {
                final backup = backups[index];
                return ListTile(
                  leading: Icon(Icons.backup),
                  title: Text(_formatDate(backup.createdAt)),
                  subtitle: Text(backup.sizeFormatted),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: ColorsManager.errorFill),
                    onPressed: () async {
                      final l10n = AppLocalizations.of(context);

                      // Confirm deletion
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(l10n.deleteBackup),
                          content: Text(l10n.deleteBackupConfirmation),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(l10n.cancel),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorsManager.errorFill,
                              ),
                              child: Text(l10n.delete),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        final success = await _backupService.deleteBackup(backup.fullPath);
                        if (success) {
                          Navigator.pop(context);
                          _loadStats();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.backupDeleted),
                              backgroundColor: ColorsManager.successFill,
                            ),
                          );
                        }
                      }
                    },
                  ),
                  onTap: () {
                    // Restore from this backup
                    Navigator.pop(context);
                    _restoreSpecificBackup(backup);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.close),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.error}: $e'),
          backgroundColor: ColorsManager.errorFill,
        ),
      );
    }
  }

  Future<void> _restoreSpecificBackup(BackupInfo backup) async {
    final l10n = AppLocalizations.of(context);

    // Show confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: ColorsManager.warningFill),
            SizedBox(width: 8.w),
            Text(l10n.restoreData),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.restoreWarning),
            SizedBox(height: 12.h),
            Text(
              '${l10n.backupDate}: ${_formatDate(backup.createdAt)}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
            Text(
              '${l10n.size}: ${backup.sizeFormatted}',
              style: TextStyle(
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.warningFill,
            ),
            child: Text(l10n.restore),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final result = await _backupService.restoreFromBackup(backup.fullPath);

      if (mounted) {
        setState(() => _isLoading = false);

        if (result.success) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text(l10n.restoreSuccess),
              content: Text(l10n.restartAppMessage),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  child: Text(l10n.closeApp),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: ColorsManager.errorFill,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.restoreFailed}: $e'),
            backgroundColor: ColorsManager.errorFill,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}