// ============= Shared Form Widgets - مكونات مشتركة =============
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/constants/image_picker_helper.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/data/models/skill_template.dart';

/// Thumbnail Picker Widget
class ThumbnailPicker extends StatelessWidget {
  final String? thumbnailPath;
  final VoidCallback onPick;
  final VoidCallback onRemove;
  final Color? accentColor;

  const ThumbnailPicker({
    super.key,
    this.thumbnailPath,
    required this.onPick,
    required this.onRemove,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? ColorsManager.primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الصورة المصغرة',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: ColorsManager.defaultText,
          ),
        ),
        SizedBox(height: SizeApp.s8),
        if (thumbnailPath != null) ...[
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                child: Image.file(
                  File(thumbnailPath!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 120.h,
                ),
              ),
              Positioned(
                top: SizeApp.s4,
                right: SizeApp.s4,
                child: IconButton(
                  onPressed: onRemove,
                  icon: Icon(Icons.close_rounded, size: 16.sp),
                  style: IconButton.styleFrom(
                    backgroundColor: ColorsManager.errorFill,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.all(SizeApp.s4),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: SizeApp.s8),
        ],
        OutlinedButton.icon(
          onPressed: onPick,
          icon: Icon(Icons.image_rounded, size: SizeApp.iconSize),
          label: Text(thumbnailPath == null ? 'إضافة صورة' : 'تغيير الصورة'),
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color),
            padding: EdgeInsets.symmetric(vertical: 12.h),
            minimumSize: Size(double.infinity, 48.h),
          ),
        ),
      ],
    );
  }
}

/// Media Gallery Picker
class MediaGalleryPicker extends StatelessWidget {
  final List<MediaItem> mediaGallery;
  final Function(MediaType) onAddMedia;
  final Function(MediaItem) onRemoveMedia;

  const MediaGalleryPicker({
    super.key,
    required this.mediaGallery,
    required this.onAddMedia,
    required this.onRemoveMedia,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'معرض الوسائط',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: ColorsManager.defaultText,
          ),
        ),
        SizedBox(height: SizeApp.s8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => onAddMedia(MediaType.image),
                icon: Icon(Icons.add_photo_alternate_rounded, size: SizeApp.iconSize),
                label: const Text('صورة'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorsManager.primaryColor,
                  side: BorderSide(color: ColorsManager.primaryColor),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
            SizedBox(width: SizeApp.s8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => onAddMedia(MediaType.video),
                icon: Icon(Icons.videocam_rounded, size: SizeApp.iconSize),
                label: const Text('فيديو'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorsManager.secondaryColor,
                  side: BorderSide(color: ColorsManager.secondaryColor),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
          ],
        ),
        if (mediaGallery.isNotEmpty) ...[
          SizedBox(height: SizeApp.s12),
          Wrap(
            spacing: SizeApp.s8,
            runSpacing: SizeApp.s8,
            children: mediaGallery
                .map((media) => MediaChip(
              media: media,
              onDelete: () => onRemoveMedia(media),
            ))
                .toList(),
          ),
        ],
      ],
    );
  }
}

/// Media Chip
class MediaChip extends StatelessWidget {
  final MediaItem media;
  final VoidCallback onDelete;

  const MediaChip({
    super.key,
    required this.media,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isVideo = media.type == MediaType.video;
    final fileName = media.path.split('/').last;
    final fileSize = MediaPickerHelper.getFileSize(media.path);

    return Chip(
      avatar: Icon(
        isVideo ? Icons.videocam : Icons.image,
        size: 16.sp,
        color: isVideo ? ColorsManager.secondaryColor : ColorsManager.primaryColor,
      ),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${isVideo ? 'فيديو' : 'صورة'}: $fileName',
            style: TextStyle(fontSize: 12.sp),
          ),
          Text(
            fileSize,
            style: TextStyle(
              fontSize: 10.sp,
              color: ColorsManager.defaultTextSecondary,
            ),
          ),
        ],
      ),
      onDeleted: onDelete,
      deleteIconColor: ColorsManager.errorFill,
    );
  }
}

/// Form Section Header
class FormSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;

  const FormSectionHeader({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor ?? ColorsManager.primaryColor,
          size: 16.sp,
        ),
        SizedBox(width: SizeApp.s8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: ColorsManager.defaultText,
          ),
        ),
      ],
    );
  }
}

/// Error Container
class FormErrorContainer extends StatelessWidget {
  final String error;

  const FormErrorContainer({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s16),
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: ColorsManager.errorFill.withOpacity(0.1),
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
            size: SizeApp.iconSize,
          ),
          SizedBox(width: SizeApp.s12),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                fontSize: 14.sp,
                color: ColorsManager.errorFill,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Type Badge (for Exercise/Skill type)
class TypeBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const TypeBadge({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeApp.s16,
        vertical: SizeApp.s8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(SizeApp.radiusMed),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16.sp),
          SizedBox(width: SizeApp.s8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Delete Confirmation Dialog
class DeleteConfirmationDialog extends StatelessWidget {
  final String title;
  final String itemName;
  final VoidCallback onConfirm;

  const DeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.itemName,
    required this.onConfirm,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String itemName,
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        title: title,
        itemName: itemName,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SizeApp.radiusMed),
      ),
      title: Row(
        children: [
          Icon(
            Icons.warning_rounded,
            color: ColorsManager.errorFill,
            size: 24.sp,
          ),
          SizedBox(width: SizeApp.s8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: ColorsManager.errorFill,
            ),
          ),
        ],
      ),
      content: Text(
        'هل أنت متأكد من حذف "$itemName" نهائياً؟\n\nلا يمكن التراجع عن هذا الإجراء.',
        style: TextStyle(fontSize: 14.sp, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'إلغاء',
            style: TextStyle(
              color: ColorsManager.defaultTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorsManager.errorFill,
          ),
          child: const Text('حذف نهائياً'),
        ),
      ],
    );
  }
}