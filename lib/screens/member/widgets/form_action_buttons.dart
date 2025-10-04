import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';

/// Form Action Buttons
class FormActionButtons extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final bool isLoading;
  final String saveText;
  final String cancelText;

  const FormActionButtons({
    super.key,
    required this.onSave,
    required this.onCancel,
    this.isLoading = false,
    this.saveText = 'حفظ التغييرات',
    this.cancelText = 'إلغاء',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // علشان مايتغطّاش تحت البوتوم نوتش/ناف بار
    return Material(
      color: theme.cardColor,
      elevation: 6, // نعومة لطيفة
      shadowColor: theme.shadowColor.withOpacity(0.12),
      child: Padding(
        padding: EdgeInsets.only(
          left: SizeApp.s16,
          right: SizeApp.s16,
          top: SizeApp.s12,
          // نخلي فيه مسافة إضافية لما الكيبورد مفتوح
          bottom: SizeApp.s16 + MediaQuery.viewInsetsOf(context).bottom * 0.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: FilledButton.icon(
                onPressed: isLoading ? null : onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: ColorsManager.primaryColor, // لو عايز تلتزم بألوانك
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                  ),
                ),
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isLoading
                      ? SizedBox(
                    key: const ValueKey('loading'),
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Icon(Icons.save_rounded, key: const ValueKey('icon'), size: 20.sp),
                ),
                label: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    isLoading ? '...جارٍ الحفظ' : saveText,
                    key: ValueKey(isLoading),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: SizeApp.s12),

            // زر الإلغاء (Outlined/Secondary)
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: OutlinedButton(
                onPressed: isLoading ? null : onCancel,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: theme.dividerColor.withOpacity(0.6),
                    width: 1,
                  ),
                  foregroundColor: theme.textTheme.bodyMedium?.color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                  ),
                ),
                child: Text(
                  cancelText,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
