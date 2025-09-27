import 'package:flutter/material.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';

/// Edit Info Notice - ملاحظة معلومات التحرير
class EditInfoNotice extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;

  const EditInfoNotice({
    super.key,
    this.message =
    'تعديل هذه البيانات سيؤثر على جميع التمارين والتقييمات المرتبطة بهذا العضو. تأكد من صحة البيانات قبل الحفظ.',
    this.icon = Icons.info_outline_rounded,
    this.backgroundColor = Colors.transparent,
    this.textColor = Colors.transparent,
    this.iconColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // 👇 شيلنا العرض الثابت
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: backgroundColor != Colors.transparent
            ? backgroundColor
            : ColorsManager.infoSurface,
        borderRadius: BorderRadius.circular(SizeApp.radiusMed),
        border: Border.all(
          color: (iconColor != Colors.transparent
              ? iconColor
              : ColorsManager.infoText)
              .withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // 👈 الكونتينر يلف على قد المحتوى
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: iconColor != Colors.transparent
                ? iconColor
                : ColorsManager.infoText,
            size: SizeApp.iconSize,
          ),
          SizedBox(width: SizeApp.s12),
          // 👇 Expanded علشان النص يلف وما يعملش overflow
          Flexible(
            child: Text(
              message,
              softWrap: true,             // يلف الأسطر
              overflow: TextOverflow.visible,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: textColor != Colors.transparent
                    ? textColor
                    : ColorsManager.infoText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

