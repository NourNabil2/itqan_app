// ============= Edit Member Widgets - كمبوننتات تحرير العضو =============
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/widgets/app_text_feild.dart';

/// Member Photo Upload Widget
class MemberPhotoUpload extends StatelessWidget {
  final String? photoPath;
  final String memberName;
  final VoidCallback onPickImage;
  final bool isLoading;

  const MemberPhotoUpload({
    super.key,
    this.photoPath,
    required this.memberName,
    required this.onPickImage,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              _buildPhotoContainer(),
              _buildCameraButton(),
            ],
          ),

          SizedBox(height: SizeApp.s12),

          Text(
            'اضغط على الكاميرا لتغيير الصورة',
            style: TextStyle(
              fontSize: 13.sp,
              color: ColorsManager.defaultTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoContainer() {
    return Container(
      width: 120.w,
      height: 120.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SizeApp.radius),
        gradient: photoPath == null
            ? LinearGradient(
          colors: [
            ColorsManager.secondaryColor,
            ColorsManager.secondaryColor.withOpacity(0.8),
          ],
        )
            : null,
        image: photoPath != null
            ? DecorationImage(
          image: FileImage(File(photoPath!)),
          fit: BoxFit.cover,
        )
            : null,
        boxShadow: [
          BoxShadow(
            color: ColorsManager.secondaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: photoPath == null
          ? Center(
        child: Text(
          memberName.isNotEmpty ? memberName[0].toUpperCase() : '؟',
          style: TextStyle(
            fontSize: 40.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      )
          : null,
    );
  }

  Widget _buildCameraButton() {
    return Container(
      width: 36.w,
      height: 36.h,
      decoration: BoxDecoration(
        color: ColorsManager.primaryColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: ColorsManager.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: isLoading ? null : onPickImage,
        padding: EdgeInsets.zero,
        icon: isLoading
            ? SizedBox(
          width: 16.w,
          height: 16.h,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Icon(
          Icons.camera_alt_rounded,
          color: Colors.white,
          size: 18.sp,
        ),
      ),
    );
  }
}

