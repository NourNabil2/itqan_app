import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';

class AgeGroupSection extends StatefulWidget {
  final String title;
  final int count;
  final List<Widget> children;
  final Color color;
  final bool initiallyExpanded;

  const AgeGroupSection({
    super.key,
    required this.title,
    required this.count,
    required this.children,
    this.color = ColorsManager.primaryColor,
    this.initiallyExpanded = true,
  });

  @override
  State<AgeGroupSection> createState() => _AgeGroupSectionState();
}

class _AgeGroupSectionState extends State<AgeGroupSection>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late AnimationController _controller;
  late Animation<double> _arrowTurn;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: _expanded ? 1 : 0,
    );
    _arrowTurn = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.25)),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.12), color.withOpacity(0.06)],
        ),
      ),
      child: Column(
        children: [
          // Header (tappable)
          InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: _toggle,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Row(
                children: [
                  Container(
                    width: 6.w,
                    height: 22.h,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                  // Count pill
                  Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '${widget.count}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Arrow
                  RotationTransition(
                    turns: _arrowTurn,
                    child: Icon(Icons.keyboard_arrow_down,
                        color: color, size: 24.sp),
                  ),
                ],
              ),
            ),
          ),

          // Body (animated)
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeInOut,
                opacity: _expanded ? 1 : 0,
                child: _expanded
                    ? Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 12.h),
                  child: Column(
                    children: widget.children
                        .expand((w) => [
                      w,
                      SizedBox(height: 8.h),
                    ])
                        .toList()
                      ..removeLast(), // يشيل آخر Spacer
                  ),
                )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
