import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:itqan_gym/core/widgets/app_buton.dart';
import 'package:itqan_gym/core/widgets/error_container_widget.dart';
import 'package:itqan_gym/data/models/member/member.dart';
import 'package:itqan_gym/screens/member/edit_member_screen.dart';
import 'package:itqan_gym/screens/member/member_notes_screen.dart';
import 'package:provider/provider.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/widgets/custom_app_bar.dart';
import 'package:itqan_gym/core/widgets/empty_state_widget.dart';
import 'package:itqan_gym/core/assets/assets_manager.dart';
import '../../providers/member_provider.dart';
import 'dart:io';

class MemberDetailScreen extends StatefulWidget {
  final Member member;

  const MemberDetailScreen({super.key, required this.member});

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _error;
  late Member _currentMember;

  // Mock data - replace with real data from providers
  final List<Map<String, dynamic>> _exerciseProgress = [
    {
      'name': 'التوازن على العارضة',
      'progress': 85.0,
      'status': 'مكتمل',
      'lastUpdated': DateTime.now().subtract(const Duration(days: 2)),
      'color': ColorsManager.successFill,
      'icon': Icons.check_circle_rounded,
    },
    {
      'name': 'تمارين الأرضي',
      'progress': 65.0,
      'status': 'قيد التقدم',
      'lastUpdated': DateTime.now().subtract(const Duration(days: 1)),
      'color': ColorsManager.primaryColor,
      'icon': Icons.schedule_rounded,
    },
    {
      'name': 'القفز على المهر',
      'progress': 25.0,
      'status': 'بداية',
      'lastUpdated': DateTime.now().subtract(const Duration(days: 5)),
      'color': ColorsManager.warningFill,
      'icon': Icons.play_circle_outline_rounded,
    },
    {
      'name': 'التمارين الحرة',
      'progress': 0.0,
      'status': 'لم يبدأ',
      'lastUpdated': null,
      'color': ColorsManager.errorFill,
      'icon': Icons.radio_button_unchecked_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentMember = widget.member;
    _loadMemberData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMemberData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load updated member data and exercises from providers
      // This would typically involve calling provider methods
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading

      // Update member progress and other data here
      setState(() {
        _currentMember = _currentMember.copyWith(
          overallProgress: _calculateOverallProgress(),
        );
      });
    } catch (e) {
      setState(() {
        _error = 'حدث خطأ في تحميل بيانات العضو: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  double _calculateOverallProgress() {
    if (_exerciseProgress.isEmpty) return 0.0;
    double total = _exerciseProgress
        .map((e) => e['progress'] as double)
        .reduce((a, b) => a + b);
    return total / _exerciseProgress.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.backgroundSurface,
      appBar: CustomAppBar(
        title: 'ملف العضو',
        action: Row(
          children: [
            IconButton(
              onPressed: () => _editMember(),
              icon: Icon(
                Icons.edit_rounded,
                color: ColorsManager.primaryColor,
                size: SizeApp.iconSize,
              ),
            ),
            IconButton(
              onPressed: () => _showMemberOptions(),
              icon: Icon(
                Icons.more_vert_rounded,
                color: ColorsManager.defaultTextSecondary,
                size: SizeApp.iconSize,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _error != null
          ? _buildErrorState()
          : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.h,
            padding: EdgeInsets.all(SizeApp.s20),
            decoration: BoxDecoration(
              color: ColorsManager.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(SizeApp.radius),
            ),
            child: CircularProgressIndicator(
              color: ColorsManager.primaryColor,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: SizeApp.s20),
          Text(
            'جاري تحميل بيانات العضو...',
            style: TextStyle(
              fontSize: 16.sp,
              color: ColorsManager.defaultTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        SizedBox(height: SizeApp.s20),
        ErrorContainer(
          errors: [_error!],
          margin: EdgeInsets.symmetric(horizontal: SizeApp.s16),
        ),
        const Spacer(),
        EmptyStateWidget(
          title: 'حدث خطأ',
          subtitle: 'لم نتمكن من تحميل بيانات العضو، يرجى المحاولة مرة أخرى',
          buttonText: 'إعادة المحاولة',
          assetSvgPath: AssetsManager.notFoundIcon,
          onPressed: _loadMemberData,
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Member Header
        _buildMemberHeader(),

        // Tabs
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: ColorsManager.primaryColor,
            unselectedLabelColor: ColorsManager.defaultTextSecondary,
            indicatorColor: ColorsManager.primaryColor,
            labelStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'التقدم'),
              Tab(text: 'التمارين'),
              Tab(text: 'الملاحظات'),
            ],
          ),
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildProgressTab(),
              _buildExercisesTab(),
              _buildNotesTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMemberHeader() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(SizeApp.s20),
      child: Column(
        children: [
          Row(
            children: [
              // Member Avatar
              Hero(
                tag: 'member_avatar_${_currentMember.id}',
                child: Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(SizeApp.radiusMed),
                    gradient: _currentMember.photoPath == null
                        ? LinearGradient(
                      colors: [
                        ColorsManager.secondaryColor,
                        ColorsManager.secondaryColor.withOpacity(0.8),
                      ],
                    )
                        : null,
                    image: _currentMember.photoPath != null
                        ? DecorationImage(
                      image: FileImage(File(_currentMember.photoPath!)),
                      fit: BoxFit.cover,
                    )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: ColorsManager.secondaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _currentMember.photoPath == null
                      ? Center(
                    child: Text(
                      _currentMember.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  )
                      : null,
                ),
              ),

              SizedBox(width: SizeApp.s16),

              // Member Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentMember.name,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: ColorsManager.defaultText,
                        height: 1.2,
                      ),
                    ),

                    SizedBox(height: 6.h),

                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeApp.s8,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: ColorsManager.infoSurface,
                            borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.cake_outlined,
                                size: 14.sp,
                                color: ColorsManager.infoText,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '${_currentMember.age} سنة',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: ColorsManager.infoText,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: SizeApp.s8),

                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeApp.s8,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getLevelColor(_currentMember.level).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                          ),
                          child: Text(
                            _currentMember.level,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: _getLevelColor(_currentMember.level),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: SizeApp.s16),

          // Progress Summary
          Container(
            padding: EdgeInsets.all(SizeApp.s16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorsManager.primaryColor.withOpacity(0.08),
                  ColorsManager.primaryColor.withOpacity(0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(SizeApp.radiusMed),
              border: Border.all(
                color: ColorsManager.primaryColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50.w,
                  height: 50.h,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 50.w,
                        height: 50.h,
                        child: CircularProgressIndicator(
                          value: _currentMember.overallProgress / 100,
                          strokeWidth: 4,
                          backgroundColor: ColorsManager.primaryColor.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            ColorsManager.primaryColor,
                          ),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Text(
                        '${_currentMember.overallProgress.toInt()}%',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: ColorsManager.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: SizeApp.s16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'التقدم الإجمالي',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: ColorsManager.defaultText,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'تحسن بنسبة 12% خلال الشهر الماضي',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: ColorsManager.successText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(SizeApp.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Performance Chart
          Container(
            padding: EdgeInsets.all(SizeApp.s20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(SizeApp.radiusMed),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الأداء خلال الـ 6 أسابيع الماضية',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: ColorsManager.defaultText,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeApp.s8,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: ColorsManager.successSurface,
                        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                      ),
                      child: Text(
                        '+12%',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: ColorsManager.successText,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: SizeApp.s20),

                SizedBox(
                  height: 200.h,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 20,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: ColorsManager.inputBorder.withOpacity(0.1),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}%',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: ColorsManager.defaultTextSecondary,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              const weeks = ['الأسبوع 1', 'الأسبوع 2', 'الأسبوع 3', 'الأسبوع 4', 'الأسبوع 5', 'الأسبوع 6'];
                              if (value.toInt() < weeks.length) {
                                return Text(
                                  weeks[value.toInt()],
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    color: ColorsManager.defaultTextSecondary,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 45),
                            FlSpot(1, 52),
                            FlSpot(2, 48),
                            FlSpot(3, 65),
                            FlSpot(4, 72),
                            FlSpot(5, 78),
                          ],
                          isCurved: true,
                          curveSmoothness: 0.3,
                          color: ColorsManager.primaryColor,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: Colors.white,
                                strokeWidth: 2,
                                strokeColor: ColorsManager.primaryColor,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                ColorsManager.primaryColor.withOpacity(0.2),
                                ColorsManager.primaryColor.withOpacity(0.05),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                      minY: 0,
                      maxY: 100,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: SizeApp.s20),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'التمارين المكتملة',
                  '${_exerciseProgress.where((e) => e['progress'] >= 80).length}/${_exerciseProgress.length}',
                  Icons.check_circle_outline_rounded,
                  ColorsManager.successFill,
                ),
              ),
              SizedBox(width: SizeApp.s12),
              Expanded(
                child: _buildStatCard(
                  'معدل الحضور',
                  '85%',
                  Icons.calendar_today_outlined,
                  ColorsManager.primaryColor,
                ),
              ),
            ],
          ),

          SizedBox(height: SizeApp.s12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'متوسط الدرجات',
                  '${_currentMember.overallProgress.toInt()}%',
                  Icons.trending_up_rounded,
                  ColorsManager.warningFill,
                ),
              ),
              SizedBox(width: SizeApp.s12),
              Expanded(
                child: _buildStatCard(
                  'أيام التدريب',
                  '24 يوم',
                  Icons.fitness_center_outlined,
                  ColorsManager.infoFill,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesTab() {
    if (_exerciseProgress.isEmpty) {
      return EmptyStateWidget(
        title: 'لا توجد تمارين',
        subtitle: 'لم يتم إضافة أي تمارين لهذا العضو بعد',
        buttonText: 'إضافة تمرين',
        assetSvgPath: AssetsManager.iconsGymnastEx2,
        onPressed: () {
          // Navigate to add exercise
        },
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(SizeApp.s16),
      itemCount: _exerciseProgress.length,
      itemBuilder: (context, index) {
        final exercise = _exerciseProgress[index];
        return _buildExerciseCard(exercise);
      },
    );
  }

  Widget _buildNotesTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(SizeApp.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(SizeApp.s16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(SizeApp.radiusMed),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ملاحظات المدرب',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: ColorsManager.defaultText,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _editNotes(),
                      icon: Icon(
                        Icons.edit_rounded,
                        size: 20.sp,
                        color: ColorsManager.primaryColor,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: SizeApp.s12),

                Text(
                  _currentMember.notes?.isNotEmpty == true
                      ? _currentMember.notes!
                      : 'لا توجد ملاحظات حاليًا.\nيمكنك إضافة ملاحظات حول أداء العضو وتطوره.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: _currentMember.notes?.isNotEmpty == true
                        ? ColorsManager.defaultText
                        : ColorsManager.defaultTextSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: SizeApp.s20),

          AppButton(
            text: 'إضافة ملاحظة جديدة',
            onPressed: () => _editNotes(),
            leadingIcon: Icons.note_add_rounded,
            horizontalPadding: 0,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeApp.radiusMed),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(SizeApp.s10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(SizeApp.s10),
            ),
            child: Icon(
              icon,
              size: 24.sp,
              color: color,
            ),
          ),
          SizedBox(height: SizeApp.s10),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: ColorsManager.defaultTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise) {
    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s12),
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeApp.radiusMed),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(SizeApp.s8),
                decoration: BoxDecoration(
                  color: (exercise['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(SizeApp.s8),
                ),
                child: Icon(
                  exercise['icon'],
                  color: exercise['color'],
                  size: 20.sp,
                ),
              ),

              SizedBox(width: SizeApp.s12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise['name'],
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: ColorsManager.defaultText,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      exercise['status'],
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: exercise['color'],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '${exercise['progress'].toInt()}%',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: exercise['color'],
                ),
              ),
            ],
          ),

          SizedBox(height: SizeApp.s12),

          // Progress Bar
          Container(
            height: 6.h,
            decoration: BoxDecoration(
              color: ColorsManager.defaultSurface,
              borderRadius: BorderRadius.circular(3.r),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: exercise['progress'] / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: exercise['color'],
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),
          ),

          if (exercise['lastUpdated'] != null) ...[
            SizedBox(height: SizeApp.s8),
            Text(
              'آخر تحديث: ${_formatDate(exercise['lastUpdated'])}',
              style: TextStyle(
                fontSize: 11.sp,
                color: ColorsManager.defaultTextSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
      case 'مبتدئ':
        return ColorsManager.infoFill;
      case 'intermediate':
      case 'متوسط':
        return ColorsManager.warningFill;
      case 'advanced':
      case 'متقدم':
        return ColorsManager.successFill;
      case 'expert':
      case 'خبير':
        return ColorsManager.primaryColor;
      default:
        return ColorsManager.defaultTextSecondary;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _editMember() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMemberScreen(
          member: _currentMember,
          isGlobalMember: _currentMember.isGlobal,
        ),
      ),
    ).then((result) {
      if (result == true) {
        // Reload member data if edited successfully
        _loadMemberData();
      }
    });
  }

  void _editNotes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberNotesScreen(member: _currentMember),
      ),
    );
  }

  void _showMemberOptions() {
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

            ListTile(
              leading: Container(
                padding: EdgeInsets.all(SizeApp.s8),
                decoration: BoxDecoration(
                  color: ColorsManager.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(SizeApp.s8),
                ),
                child: Icon(
                  Icons.share_rounded,
                  color: ColorsManager.primaryColor,
                  size: 20.sp,
                ),
              ),
              title: Text(
                'مشاركة الملف',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('سيتم مشاركة ملف العضو'),
                    backgroundColor: ColorsManager.primaryColor,
                  ),
                );
              },
            ),

            ListTile(
              leading: Container(
                padding: EdgeInsets.all(SizeApp.s8),
                decoration: BoxDecoration(
                  color: ColorsManager.warningFill.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(SizeApp.s8),
                ),
                child: Icon(
                  Icons.archive_rounded,
                  color: ColorsManager.warningFill,
                  size: 20.sp,
                ),
              ),
              title: Text(
                'أرشفة العضو',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showArchiveDialog();
              },
            ),

            ListTile(
              leading: Container(
                padding: EdgeInsets.all(SizeApp.s8),
                decoration: BoxDecoration(
                  color: ColorsManager.errorFill.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(SizeApp.s8),
                ),
                child: Icon(
                  Icons.delete_rounded,
                  color: ColorsManager.errorFill,
                  size: 20.sp,
                ),
              ),
              title: Text(
                'حذف العضو',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: ColorsManager.errorFill,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog();
              },
            ),

            SizedBox(height: SizeApp.s10),
          ],
        ),
      ),
    );
  }

  void _showArchiveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'أرشفة العضو',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: ColorsManager.defaultText,
          ),
        ),
        content: Text(
          'هل أنت متأكد من أرشفة هذا العضو؟ سيتم نقله إلى الأرشيف ولن يظهر في القائمة الرئيسية.',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: TextStyle(color: ColorsManager.defaultTextSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم أرشفة العضو بنجاح'),
                  backgroundColor: ColorsManager.warningFill,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.warningFill,
            ),
            child: Text(
              'أرشفة',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'حذف العضو',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: ColorsManager.errorFill,
          ),
        ),
        content: Text(
          'هل أنت متأكد من حذف هذا العضو نهائياً؟ لا يمكن التراجع عن هذا الإجراء.',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: TextStyle(color: ColorsManager.defaultTextSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to previous screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم حذف العضو نهائياً'),
                  backgroundColor: ColorsManager.errorFill,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.errorFill,
            ),
            child: Text(
              'حذف نهائياً',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}