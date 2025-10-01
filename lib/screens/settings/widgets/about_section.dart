// ============= 11. About Section =============
import 'package:flutter/material.dart';

import 'setting_card/settings_card.dart';
import 'setting_card/settings_tile.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      title: 'حول التطبيق',
      icon: Icons.info_outline,
      children: [
        SettingsTile(
          icon: Icons.privacy_tip_outlined,
          title: 'سياسة الخصوصية',
          onTap: () {},
        ),
        SettingsTile(
          icon: Icons.description_outlined,
          title: 'شروط الاستخدام',
          onTap: () {},
        ),
        SettingsTile(
          icon: Icons.share_outlined,
          title: 'مشاركة التطبيق',
          onTap: () {},
        ),
        SettingsTile(
          icon: Icons.star_outline,
          title: 'تقييم التطبيق',
          onTap: () {},
        ),
        SettingsTile(
          icon: Icons.code,
          title: 'الإصدار',
          subtitle: '1.0.0',
          onTap: null,
        ),
      ],
    );
  }
}