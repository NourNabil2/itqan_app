import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/member.dart';
import '../../screens/member/member_detail_screen.dart';

class MemberCard extends StatelessWidget {
  final Member member;

  const MemberCard({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MemberDetailScreen(member: member),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // Member Avatar
              Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFF3E0),
                  image: member.photoPath != null
                      ? DecorationImage(
                    image: AssetImage(member.photoPath!),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: member.photoPath == null
                    ? Center(
                  child: Text(
                    member.name[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFF9800),
                    ),
                  ),
                )
                    : null,
              ),
              SizedBox(width: 12.w),
              // Member Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Text(
                          'Age: ${member.age}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            member.level,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: const Color(0xFF4CAF50),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    // Progress Bar
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: LinearProgressIndicator(
                              value: member.overallProgress / 100,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getProgressColor(member.overallProgress),
                              ),
                              minHeight: 4.h,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '${member.overallProgress.toInt()}%',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: _getProgressColor(member.overallProgress),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 30) return Colors.red;
    if (progress < 60) return Colors.orange;
    if (progress < 80) return Colors.blue;
    return const Color(0xFF4CAF50);
  }
}