import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:itqan_gym/core/utils/app_size.dart';


class LoadingNotesWidget extends StatelessWidget {
  const LoadingNotesWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeApp.radiusMed),
      ),
      child: const Center(
        child: RepaintBoundary(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

