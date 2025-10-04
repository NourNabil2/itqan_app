// lib/core/constants/image_picker_helper.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';

class MediaPickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Show dialog for selecting image source
  static void showImageSourceDialog({
    required BuildContext context,
    required Function(String?) onImageSelected,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            SizedBox(height: 20.h),

            // Title
            Text(
              l10n.selectImageSource,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 20.h),

            // Options
            Row(
              children: [
                Expanded(
                  child: _buildSourceOption(
                    context: context,
                    icon: Icons.photo_library_rounded,
                    title: l10n.gallery,
                    color: theme.primaryColor,
                    onTap: () async {
                      Navigator.pop(context);
                      final imagePath = await _pickImageFromGallery();
                      onImageSelected(imagePath);
                    },
                  ),
                ),

                SizedBox(width: 12.w),

                Expanded(
                  child: _buildSourceOption(
                    context: context,
                    icon: Icons.camera_alt_rounded,
                    title: l10n.camera,
                    color: theme.primaryColor,
                    onTap: () async {
                      Navigator.pop(context);
                      final imagePath = await _pickImageFromCamera();
                      onImageSelected(imagePath);
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            SizedBox(height: 20.h),

            // Title
            Text(
              l10n.selectVideoSource,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 20.h),

            // Options
            Row(
              children: [
                Expanded(
                  child: _buildSourceOption(
                    context: context,
                    icon: Icons.video_library_rounded,
                    title: l10n.selectVideo,
                    color: theme.primaryColor,
                    onTap: () async {
                      Navigator.pop(context);
                      final videoPath = await _pickVideoFromGallery();
                      onVideoSelected(videoPath);
                    },
                  ),
                ),

                SizedBox(width: 12.w),

                Expanded(
                  child: _buildSourceOption(
                    context: context,
                    icon: Icons.videocam_rounded,
                    title: l10n.recordVideo,
                    color: theme.primaryColor,
                    onTap: () async {
                      Navigator.pop(context);
                      final videoPath = await _recordVideo();
                      onVideoSelected(videoPath);
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),
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
    required Color color,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28.sp,
                color: color,
              ),
            ),

            SizedBox(height: 12.h),

            Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      return image?.path;
    } catch (e) {
      debugPrint('❌ Error picking image from camera: $e');
      return null;
    }
  }

  static Future<String?> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      return image?.path;
    } catch (e) {
      debugPrint('❌ Error picking image from gallery: $e');
      return null;
    }
  }

  // Private methods for picking videos
  static Future<String?> _recordVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5),
      );
      return video?.path;
    } catch (e) {
      debugPrint('❌ Error recording video: $e');
      return null;
    }
  }

  static Future<String?> _pickVideoFromGallery() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 10),
      );
      return video?.path;
    } catch (e) {
      debugPrint('❌ Error picking video from gallery: $e');
      return null;
    }
  }

  // Legacy method for backward compatibility
  static Future<String?> pickImage({
    ImageSource source = ImageSource.gallery,
    int imageQuality = 85,
    double maxWidth = 1920,
    double maxHeight = 1080,
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
      debugPrint('❌ Error picking image: $e');
      return null;
    }
  }

  // Utility methods
  static bool isImageFile(String path) {
    final ext = path.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'heic'].contains(ext);
  }

  static bool isVideoFile(String path) {
    final ext = path.toLowerCase().split('.').last;
    return ['mp4', 'avi', 'mov', 'mkv', 'wmv', 'flv', '3gp', 'webm', 'm4v']
        .contains(ext);
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
      debugPrint('❌ Error getting file size: $e');
      return '--';
    }
  }

  static String getFileName(String path) {
    return path.split('/').last;
  }

  static String getFileExtension(String path) {
    return path.split('.').last.toLowerCase();
  }

  static bool fileExists(String path) {
    try {
      return File(path).existsSync();
    } catch (e) {
      return false;
    }
  }
}