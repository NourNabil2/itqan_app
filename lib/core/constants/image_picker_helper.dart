import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource;

import '../theme/colors.dart';
import '../utils/app_size.dart';

/// Image Picker Helper
class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pickImage({
    ImageSource source = ImageSource.gallery,
    int imageQuality = 80,
    double maxWidth = 800,
    double maxHeight = 800,
  }) async {
    try {
      final image = await _picker.pickImage(
        source: source,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      return image?.path;
    } catch (e) {
      throw Exception('حدث خطأ في اختيار الصورة: $e');
    }
  }

  static void showImageSourceDialog({
    required BuildContext context,
    required Function(String?) onImageSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(SizeApp.radiusMed),
            topRight: Radius.circular(SizeApp.radiusMed),
          ),
        ),
        padding: EdgeInsets.all(SizeApp.s20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: ColorsManager.inputBorder.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            SizedBox(height: SizeApp.s20),

            Text(
              'اختر مصدر الصورة',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: ColorsManager.defaultText,
              ),
            ),

            SizedBox(height: SizeApp.s20),

            Row(
              children: [
                Expanded(
                  child: _buildSourceOption(
                    context: context,
                    icon: Icons.photo_library_rounded,
                    title: 'المعرض',
                    onTap: () async {
                      Navigator.pop(context);
                      final imagePath = await pickImage(source: ImageSource.gallery);
                      onImageSelected(imagePath);
                    },
                  ),
                ),

                SizedBox(width: SizeApp.s16),

                Expanded(
                  child: _buildSourceOption(
                    context: context,
                    icon: Icons.camera_alt_rounded,
                    title: 'الكاميرا',
                    onTap: () async {
                      Navigator.pop(context);
                      final imagePath = await pickImage(source: ImageSource.camera);
                      onImageSelected(imagePath);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildSourceOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SizeApp.radiusMed),
      child: Container(
        padding: EdgeInsets.all(SizeApp.s20),
        decoration: BoxDecoration(
          color: ColorsManager.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(SizeApp.radiusMed),
          border: Border.all(
            color: ColorsManager.primaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32.sp,
              color: ColorsManager.primaryColor,
            ),

            SizedBox(height: SizeApp.s8),

            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: ColorsManager.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
