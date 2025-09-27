import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';


class ErrorNotesWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const ErrorNotesWidget({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: ColorsManager.errorSurface,
        borderRadius: BorderRadius.circular(SizeApp.radiusMed),
        border: Border.all(
          color: ColorsManager.errorFill.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: ColorsManager.errorFill,
            size: 20.sp,
          ),
          SizedBox(width: SizeApp.s8),
          Expanded(
            child: Text(
              'خطأ في تحميل الملاحظات',
              style: TextStyle(
                fontSize: 14.sp,
                color: ColorsManager.errorText,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'إعادة المحاولة',
              style: TextStyle(
                fontSize: 12.sp,
                color: ColorsManager.errorFill,
              ),
            ),
          ),
        ],
      ),
    );
  }
}