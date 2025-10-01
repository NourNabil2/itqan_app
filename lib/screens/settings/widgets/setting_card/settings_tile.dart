import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;
  final bool isDisabled;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.iconColor,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: ListTile(
        onTap: isDisabled ? null : onTap,
        leading: Icon(
          icon,
          color: iconColor ?? theme.iconTheme.color,
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
        trailing: trailing ??
            (onTap != null
                ? Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: theme.iconTheme.color?.withOpacity(0.5),
            )
                : null),
      ),
    );
  }
}