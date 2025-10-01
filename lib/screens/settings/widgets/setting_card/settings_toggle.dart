import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:itqan_gym/core/theme/colors.dart';

class SettingsToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isDisabled;

  const SettingsToggle({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: SwitchListTile(
        value: value,
        onChanged: isDisabled ? null : onChanged,
        activeColor: ColorsManager.primaryColor,
        secondary: Icon(
          icon,
          color: theme.iconTheme.color,
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge,
        ),
        subtitle: subtitle != null
            ? Text(
          subtitle!,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        )
            : null,
      ),
    );
  }
}