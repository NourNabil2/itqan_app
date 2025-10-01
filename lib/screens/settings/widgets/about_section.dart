import 'package:flutter/material.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';

import 'setting_card/settings_card.dart';
import 'setting_card/settings_tile.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SettingsCard(
      title: l10n.about,
      icon: Icons.info_outline,
      children: [
        SettingsTile(
          icon: Icons.privacy_tip_outlined,
          title: l10n.privacyPolicy,
          onTap: () {},
        ),
        SettingsTile(
          icon: Icons.description_outlined,
          title: l10n.termsOfService,
          onTap: () {},
        ),
        SettingsTile(
          icon: Icons.share_outlined,
          title: l10n.shareApp,
          onTap: () {},
        ),
        SettingsTile(
          icon: Icons.star_outline,
          title: l10n.rateApp,
          onTap: () {},
        ),
        SettingsTile(
          icon: Icons.code,
          title: l10n.version,
          subtitle: '1.0.0',
          onTap: null,
        ),
      ],
    );
  }
}