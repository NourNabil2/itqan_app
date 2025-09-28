import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/colors.dart';
import '../utils/app_size.dart';

class MediaPickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Show dialog for selecting image source
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
                      final imagePath = await _pickImageFromGallery();
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
                      final imagePath = await _pickImageFromCamera();
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

  /// Show dialog for selecting video source
  static void showVideoSourceDialog({
    required BuildContext context,
    required Function(String?) onVideoSelected,
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
              'اختر مصدر الفيديو',
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
                    icon: Icons.video_library_rounded,
                    title: 'اختر فيديو',
                    color: ColorsManager.secondaryColor,
                    onTap: () async {
                      Navigator.pop(context);
                      final videoPath = await _pickVideoFromGallery();
                      onVideoSelected(videoPath);
                    },
                  ),
                ),

                SizedBox(width: SizeApp.s16),

                Expanded(
                  child: _buildSourceOption(
                    context: context,
                    icon: Icons.videocam_rounded,
                    title: 'تسجيل فيديو',
                    color: ColorsManager.secondaryColor,
                    onTap: () async {
                      Navigator.pop(context);
                      final videoPath = await _recordVideo();
                      onVideoSelected(videoPath);
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

  /// Show dialog for selecting media type (image or video)
  static void showMediaTypeDialog({
    required BuildContext context,
    required Function(String?) onMediaSelected,
    required bool isVideo,
  }) {
    if (isVideo) {
      showVideoSourceDialog(
        context: context,
        onVideoSelected: onMediaSelected,
      );
    } else {
      showImageSourceDialog(
        context: context,
        onImageSelected: onMediaSelected,
      );
    }
  }

  static Widget _buildSourceOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final optionColor = color ?? ColorsManager.primaryColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SizeApp.radiusMed),
      child: Container(
        padding: EdgeInsets.all(SizeApp.s20),
        decoration: BoxDecoration(
          color: optionColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(SizeApp.radiusMed),
          border: Border.all(
            color: optionColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32.sp,
              color: optionColor,
            ),

            SizedBox(height: SizeApp.s8),

            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: optionColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Private methods for picking images
  static Future<String?> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      return image?.path;
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      return null;
    }
  }

  static Future<String?> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      return image?.path;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  // Private methods for picking videos
  static Future<String?> _recordVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: Duration(minutes: 5), // حد أقصى 5 دقائق
      );
      return video?.path;
    } catch (e) {
      debugPrint('Error recording video: $e');
      return null;
    }
  }

  static Future<String?> _pickVideoFromGallery() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: Duration(minutes: 10), // حد أقصى 10 دقائق من المعرض
      );
      return video?.path;
    } catch (e) {
      debugPrint('Error picking video from gallery: $e');
      return null;
    }
  }

  // Legacy method for backward compatibility
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

  // Utility methods
  static bool isImageFile(String path) {
    final ext = path.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
  }

  static bool isVideoFile(String path) {
    final ext = path.toLowerCase().split('.').last;
    return ['mp4', 'avi', 'mov', 'mkv', 'wmv', 'flv', '3gp', 'webm'].contains(ext);
  }

  static String getFileSize(String path) {
    try {
      final file = File(path);
      final bytes = file.lengthSync();
      if (bytes < 1024) {
        return '$bytes B';
      } else if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(1)} KB';
      } else if (bytes < 1024 * 1024 * 1024) {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      } else {
        return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
      }
    } catch (e) {
      return 'غير معروف';
    }
  }

  static String getFileName(String path) {
    return path.split('/').last;
  }
}