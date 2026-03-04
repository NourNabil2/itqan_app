// lib/screens/calendar/training_calendar_screen.dart
//
// Dependencies to add in pubspec.yaml:
//   table_calendar: ^3.1.2
//
// Register AttendanceProvider in your MultiProvider (main.dart or wherever):
//   ChangeNotifierProvider(create: (_) => AttendanceProvider()),

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/app_size.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../data/models/attendance.dart';
import '../../../data/models/member/member.dart';
import '../../../data/models/team.dart';
import '../../../providers/attendance_provider.dart';


// ═══════════════════════════════════════════════════════════════
//  Entry Point
// ═══════════════════════════════════════════════════════════════
class TrainingCalendarScreen extends StatefulWidget {
  final Team team;

  const TrainingCalendarScreen({super.key, required this.team});

  @override
  State<TrainingCalendarScreen> createState() => _TrainingCalendarScreenState();
}

class _TrainingCalendarScreenState extends State<TrainingCalendarScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // تهيئة الـ provider بعد البناء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().init(teamId: widget.team.id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'تقويم ${widget.team.name}',
        showBackIcon: false,
        action: _AppBarActions(team: widget.team),
      ),
      floatingActionButton: Consumer<AttendanceProvider>(
        builder: (context, provider, _) {
          final shouldShow = _tabController.index == 0 &&
              provider.selectedSession != null &&
              !provider.selectedSession!.isCancelled &&
              !provider.isAttendanceLoading &&
              provider.sessionMembers.isNotEmpty;

          return AnimatedSlide(
            offset: shouldShow ? Offset.zero : const Offset(0, 2),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: AnimatedOpacity(
              opacity: shouldShow ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: shouldShow
                  ? _FloatingSaveButton(provider: provider)
                  : const SizedBox.shrink(),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      body: Column(
        children: [
          // ── TabBar ─────────────────────────────────────────
          Container(
            color: Theme.of(context).cardColor,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF007C77),
              unselectedLabelColor:
              Theme.of(context).textTheme.bodySmall?.color,
              indicatorColor: const Color(0xFF007C77),
              indicatorWeight: 3,
              labelStyle: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
              tabs: const [
                Tab(text: 'التقويم'),
                Tab(text: 'التقرير الشهري'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _CalendarTab(team: widget.team),
                _MonthlyReportTab(team: widget.team),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  AppBar Actions
// ═══════════════════════════════════════════════════════════════
class _AppBarActions extends StatelessWidget {
  final Team team;

  const _AppBarActions({required this.team});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'ضبط جدول التدريب',
      icon: const Icon(Icons.tune_rounded),
      onPressed: () => _ScheduleSetupSheet.show(context, team),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  TAB 1 — Calendar
// ═══════════════════════════════════════════════════════════════
class _CalendarTab extends StatelessWidget {
  final Team team;

  const _CalendarTab({required this.team});

  static const _primary = Color(0xFF007C77);

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, _) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── التقويم كـ SliverToBoxAdapter ──────────────
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // ── header: إحصائية سريعة للشهر ───────────
                  _MonthSummaryBanner(provider: provider),

                  // ── التقويم ─────────────────────────────
                  _ItqanCalendar(provider: provider),

                  // ── legend ──────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeApp.s16,
                      vertical: SizeApp.s8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LegendDot(
                          color: _primary,
                          label: 'جلسة مجدولة',
                        ),
                        SizedBox(width: SizeApp.s20),
                        _LegendDot(
                          color: Colors.orange,
                          label: 'ملغاة',
                        ),
                      ],
                    ),
                  ),

                  Divider(
                    height: 1,
                    thickness: 1,
                    color:
                    Theme.of(context).dividerColor.withOpacity(0.15),
                  ),

                  // ── prompt / session header ──────────────
                  provider.selectedSession == null
                      ? _NoSessionSelected(provider: provider)
                      : _SelectedSessionHeader(provider: provider),
                ],
              ),
            ),

            // ── قائمة الأعضاء كـ SliverList ────────────────
            if (provider.selectedSession != null &&
                !provider.isAttendanceLoading &&
                provider.sessionMembers.isNotEmpty)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  SizeApp.s16,
                  SizeApp.s8,
                  SizeApp.s16,
                  // مسافة إضافية للزر الثابت أسفله
                  80.h + MediaQuery.of(context).padding.bottom,
                ),
                sliver: SliverList.separated(
                  itemCount: provider.sessionMembers.length,
                  separatorBuilder: (_, __) =>
                      SizedBox(height: SizeApp.s8),
                  itemBuilder: (context, index) {
                    final member = provider.sessionMembers[index];
                    return _MemberAttendanceTile(
                      member: member,
                      provider: provider,
                    );
                  },
                ),
              ),

            // ── loading state ────────────────────────────────
            if (provider.selectedSession != null &&
                provider.isAttendanceLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF007C77),
                  ),
                ),
              ),

            // ── empty members ────────────────────────────────
            if (provider.selectedSession != null &&
                !provider.isAttendanceLoading &&
                provider.sessionMembers.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.group_off_rounded,
                        size: 48.sp,
                        color: _primary.withOpacity(0.2),
                      ),
                      SizedBox(height: SizeApp.s12),
                      Text(
                        'لا يوجد أعضاء في هذا الفريق',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}


// ───────────────────────────────────────────────────────────────
//  table_calendar widget
// ───────────────────────────────────────────────────────────────
class _ItqanCalendar extends StatelessWidget {
  final AttendanceProvider provider;

  const _ItqanCalendar({required this.provider});

  static const _primary = Color(0xFF007C77);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TableCalendar(
      // ── locale & range ─────────────────────────────────
      locale: 'ar',
      firstDay: DateTime(2020),
      lastDay: DateTime(2030),
      focusedDay: provider.focusedMonth,

      // ── header style ───────────────────────────────────
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w700,
          color: theme.textTheme.titleMedium?.color,
        ),
        leftChevronIcon: Icon(
          Icons.chevron_left_rounded,
          color: _primary,
          size: 24.sp,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right_rounded,
          color: _primary,
          size: 24.sp,
        ),
      ),

      // ── days of week style ─────────────────────────────
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          fontSize: 11.sp,
          color: theme.textTheme.bodySmall?.color,
          fontWeight: FontWeight.w600,
        ),
        weekendStyle: TextStyle(
          fontSize: 11.sp,
          color: _primary.withOpacity(0.7),
          fontWeight: FontWeight.w600,
        ),
      ),

      // ── calendar style ─────────────────────────────────
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        todayDecoration: BoxDecoration(
          color: _primary.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        todayTextStyle: TextStyle(
          color: _primary,
          fontWeight: FontWeight.w700,
          fontSize: 14.sp,
        ),
        selectedDecoration: const BoxDecoration(
          color: _primary,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 14.sp,
        ),
        defaultTextStyle: TextStyle(fontSize: 13.sp),
        weekendTextStyle: TextStyle(
          fontSize: 13.sp,
          color: _primary.withOpacity(0.8),
        ),
        markerDecoration: const BoxDecoration(
          color: _primary,
          shape: BoxShape.circle,
        ),
        markerSize: 6,
        markersMaxCount: 1,
      ),

      // ── selected day ───────────────────────────────────
      selectedDayPredicate: (day) {
        final sel = provider.selectedSession;
        if (sel == null) return false;
        final sessionDay = DateTime.parse(sel.date);
        return isSameDay(day, sessionDay);
      },

      // ── markers (session days) ─────────────────────────
      eventLoader: (day) {
        return provider.hasSessionOn(day) ? [true] : [];
      },

      // ── callbacks ──────────────────────────────────────
      onDaySelected: (selectedDay, focusedDay) {
        HapticFeedback.selectionClick();
        provider.selectDate(selectedDay);
      },

      onPageChanged: (focusedDay) {
        provider.changeFocusedMonth(focusedDay);
      },

      calendarBuilders: CalendarBuilders(
        // ── يوم عنده جلسة مع marker ─────────────────────
        markerBuilder: (context, date, events) {
          if (events.isEmpty) return const SizedBox.shrink();
          final session = provider.getSessionOn(date);
          final isCancelled = session?.isCancelled ?? false;

          return Positioned(
            bottom: 4,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isCancelled
                    ? Colors.orange
                    : _primary,
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────
//  No session selected placeholder
// ───────────────────────────────────────────────────────────────
class _NoSessionSelected extends StatelessWidget {
  final AttendanceProvider provider;

  const _NoSessionSelected({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.isCalendarLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF007C77)),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.touch_app_rounded,
            size: 56.sp,
            color: const Color(0xFF007C77).withOpacity(0.3),
          ),
          SizedBox(height: SizeApp.s12),
          Text(
            'اضغط على يوم التدريب\nلتسجيل الحضور',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color
                  ?.withOpacity(0.6),
              height: 1.6,
            ),
          ),
          SizedBox(height: SizeApp.s8),
          // legend
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LegendDot(color: const Color(0xFF007C77), label: 'جلسة مجدولة'),
              SizedBox(width: SizeApp.s16),
              _LegendDot(color: Colors.orange, label: 'ملغاة'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Session Attendance View (shown below calendar when day tapped)
// ═══════════════════════════════════════════════════════════════
class _SessionAttendanceView extends StatelessWidget {
  final AttendanceProvider provider;

  const _SessionAttendanceView({required this.provider});

  static const _primary = Color(0xFF007C77);

  @override
  Widget build(BuildContext context) {
    final session = provider.selectedSession!;
    final theme = Theme.of(context);
    final dateFormatted = DateFormat(
      'EEEE، d MMMM yyyy',
      'ar',
    ).format(DateTime.parse(session.date));

    return Column(
      children: [
        // ── رأس الجلسة ─────────────────────────────────────
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: SizeApp.s16,
            vertical: SizeApp.s10,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: SizeApp.s16,
            vertical: SizeApp.s12,
          ),
          decoration: BoxDecoration(
            color: session.isCancelled
                ? Colors.orange.withOpacity(0.1)
                : _primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: session.isCancelled
                  ? Colors.orange.withOpacity(0.3)
                  : _primary.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                session.isCancelled
                    ? Icons.cancel_rounded
                    : Icons.calendar_today_rounded,
                color: session.isCancelled ? Colors.orange : _primary,
                size: 20.sp,
              ),
              SizedBox(width: SizeApp.s10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateFormatted,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    if (session.isCancelled)
                      Text(
                        'الجلسة ملغاة${session.notes != null ? ' — ${session.notes}' : ''}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.orange,
                        ),
                      ),
                  ],
                ),
              ),
              // ── زر إلغاء الجلسة ──────────────────────
              if (!session.isCancelled)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    size: 20.sp,
                    color: theme.iconTheme.color,
                  ),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'cancel',
                      child: Row(
                        children: [
                          Icon(Icons.cancel_outlined, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('إلغاء الجلسة'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red),
                          SizedBox(width: 8),
                          Text('حذف الجلسة'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'cancel') {
                      _showCancelDialog(context, provider);
                    } else if (value == 'delete') {
                      await provider.deleteCurrentSession();
                    }
                  },
                ),
            ],
          ),
        ),

        // ── قائمة الأعضاء ───────────────────────────────────
        if (provider.isAttendanceLoading)
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF007C77)),
            ),
          )
        else if (provider.sessionMembers.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                'لا يوجد أعضاء مسجّلون في هذا الفريق',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ),
          )
        else ...[
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeApp.s16,
                  vertical: SizeApp.s4,
                ),
                itemCount: provider.sessionMembers.length,
                separatorBuilder: (_, __) => SizedBox(height: SizeApp.s8),
                itemBuilder: (context, index) {
                  final member = provider.sessionMembers[index];
                  return _MemberAttendanceTile(
                    member: member,
                    provider: provider,
                  );
                },
              ),
            ),

            // ── زر حفظ ────────────────────────────────────────
            if (!session.isCancelled)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  SizeApp.s16,
                  SizeApp.s8,
                  SizeApp.s16,
                  SizeApp.s16 + MediaQuery.of(context).padding.bottom,
                ),
                child: _SaveAttendanceButton(provider: provider),
              ),
          ],
      ],
    );
  }

  void _showCancelDialog(BuildContext context, AttendanceProvider provider) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إلغاء الجلسة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('هل تريد إلغاء هذه الجلسة لهذا اليوم فقط؟'),
            SizedBox(height: 12.h),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'السبب (اختياري)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await provider.cancelSession(
                reason: reasonController.text.trim().isEmpty
                    ? null
                    : reasonController.text.trim(),
              );
            },
            child: const Text('تأكيد الإلغاء',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────
//  Member Attendance Tile
// ───────────────────────────────────────────────────────────────
class _MemberAttendanceTile extends StatelessWidget {
  final Member member;
  final AttendanceProvider provider;

  const _MemberAttendanceTile({
    required this.member,
    required this.provider,
  });

  static const _primary = Color(0xFF007C77);

  @override
  Widget build(BuildContext context) {
    final status = provider.statusOf(member.id);
    final theme = Theme.of(context);
    final isSessionCancelled = provider.selectedSession?.isCancelled ?? false;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _borderColor(status).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeApp.s12,
          vertical: SizeApp.s10,
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 20.r,
              backgroundColor: _primary.withOpacity(0.1),
              child: Text(
                member.name.isNotEmpty ? member.name[0] : '؟',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: _primary,
                ),
              ),
            ),
            SizedBox(width: SizeApp.s10),

            // الاسم والمستوى
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    member.level,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            // ── أزرار الحضور الثلاثة ─────────────────────
            if (!isSessionCancelled)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StatusButton(
                    icon: Icons.check_circle_rounded,
                    label: 'حاضر',
                    color: _primary,
                    isSelected: status == AttendanceStatus.present,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      provider.setMemberStatus(
                          member.id, AttendanceStatus.present);
                    },
                  ),
                  SizedBox(width: 6.w),
                  _StatusButton(
                    icon: Icons.cancel_rounded,
                    label: 'غائب',
                    color: Colors.red,
                    isSelected: status == AttendanceStatus.absent,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      provider.setMemberStatus(
                          member.id, AttendanceStatus.absent);
                    },
                  ),
                  SizedBox(width: 6.w),
                  _StatusButton(
                    icon: Icons.help_rounded,
                    label: 'بعذر',
                    color: Colors.orange,
                    isSelected: status == AttendanceStatus.excused,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      provider.setMemberStatus(
                          member.id, AttendanceStatus.excused);
                    },
                  ),
                ],
              )
            else
            // عرض فقط إذا كانت الجلسة ملغاة
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'ملغاة',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _borderColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return const Color(0xFF007C77);
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.excused:
        return Colors.orange;
    }
  }
}

// ───────────────────────────────────────────────────────────────
//  Status Button (✓ / ✗ / ؟)
// ───────────────────────────────────────────────────────────────
class _StatusButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 36.w,
          height: 36.h,
          decoration: BoxDecoration(
            color: isSelected ? color : color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withOpacity(isSelected ? 1 : 0.4),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            size: 18.sp,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────
//  Save Attendance Button
// ───────────────────────────────────────────────────────────────
class _SaveAttendanceButton extends StatelessWidget {
  final AttendanceProvider provider;

  const _SaveAttendanceButton({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: provider.isAttendanceLoading
            ? null
            : () async {
          final success = await provider.saveAttendance();
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? 'تم حفظ الحضور بنجاح ✓'
                    : 'تعذّر الحفظ — ${provider.errorMessage}',
              ),
              backgroundColor:
              success ? const Color(0xFF007C77) : Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007C77),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        icon: provider.isAttendanceLoading
            ? SizedBox(
          width: 18.w,
          height: 18.h,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        )
            : Icon(Icons.save_rounded, size: 20.sp),
        label: Text(
          provider.isAttendanceLoading ? 'جاري الحفظ...' : 'حفظ الحضور',
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  TAB 2 — Monthly Report
// ═══════════════════════════════════════════════════════════════
class _MonthlyReportTab extends StatefulWidget {
  final Team team;

  const _MonthlyReportTab({required this.team});

  @override
  State<_MonthlyReportTab> createState() => _MonthlyReportTabState();
}

class _MonthlyReportTabState extends State<_MonthlyReportTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().loadMonthlyReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, _) {
        if (provider.isReportLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF007C77)),
          );
        }

        if (provider.monthlyReport.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bar_chart_rounded,
                  size: 60.sp,
                  color: const Color(0xFF007C77).withOpacity(0.2),
                ),
                SizedBox(height: SizeApp.s12),
                Text(
                  'لا توجد بيانات حضور لهذا الشهر',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          );
        }

        final monthLabel = DateFormat('MMMM yyyy', 'ar')
            .format(provider.focusedMonth);

        return Column(
          children: [
            // ── عنوان الشهر ──────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(SizeApp.s16),
              color: const Color(0xFF007C77).withOpacity(0.07),
              child: Row(
                children: [
                  Icon(
                    Icons.bar_chart_rounded,
                    color: const Color(0xFF007C77),
                    size: 20.sp,
                  ),
                  SizedBox(width: SizeApp.s8),
                  Text(
                    'تقرير الحضور — $monthLabel',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF007C77),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.refresh_rounded,
                      size: 20.sp,
                      color: const Color(0xFF007C77),
                    ),
                    onPressed: () => provider.loadMonthlyReport(),
                  ),
                ],
              ),
            ),

            // ── قائمة التقارير ───────────────────────────
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.all(SizeApp.s16),
                itemCount: provider.monthlyReport.length,
                separatorBuilder: (_, __) => SizedBox(height: SizeApp.s10),
                itemBuilder: (context, index) {
                  final report = provider.monthlyReport[index];
                  return _MemberReportCard(report: report);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ───────────────────────────────────────────────────────────────
//  Member Report Card
// ───────────────────────────────────────────────────────────────
class _MemberReportCard extends StatelessWidget {
  final MemberMonthlyReport report;

  const _MemberReportCard({required this.report});

  static const _primary = Color(0xFF007C77);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = report.attendancePercentage;
    final color = pct >= 80
        ? _primary
        : pct >= 60
        ? Colors.orange
        : Colors.red;

    return Container(
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
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
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 20.r,
                backgroundColor: _primary.withOpacity(0.1),
                child: Text(
                  report.memberName.isNotEmpty ? report.memberName[0] : '؟',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: _primary,
                  ),
                ),
              ),
              SizedBox(width: SizeApp.s10),

              Expanded(
                child: Text(
                  report.memberName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // نسبة الحضور
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(
                  '${pct.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: SizeApp.s10),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: pct / 100,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6.h,
            ),
          ),

          SizedBox(height: SizeApp.s10),

          // إحصائيات تفصيلية
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatChip(
                count: report.totalSessions,
                label: 'إجمالي',
                color: Colors.blueGrey,
              ),
              _StatChip(
                count: report.presentCount,
                label: 'حاضر',
                color: _primary,
              ),
              _StatChip(
                count: report.absentCount,
                label: 'غائب',
                color: Colors.red,
              ),
              _StatChip(
                count: report.excusedCount,
                label: 'بعذر',
                color: Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _StatChip({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: Theme.of(context)
                .textTheme
                .bodySmall
                ?.color
                ?.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Bottom Sheet — Schedule Setup (اختيار أيام الأسبوع + توليد)
// ═══════════════════════════════════════════════════════════════
class _ScheduleSetupSheet extends StatefulWidget {
  final Team team;

  const _ScheduleSetupSheet({required this.team});

  static void show(BuildContext context, Team team) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AttendanceProvider>(),
        child: _ScheduleSetupSheet(team: team),
      ),
    );
  }

  @override
  State<_ScheduleSetupSheet> createState() => _ScheduleSetupSheetState();
}

class _ScheduleSetupSheetState extends State<_ScheduleSetupSheet> {
  static const _primary = Color(0xFF007C77);

  /// أسماء أيام الأسبوع (Dart weekday: 1=Mon … 7=Sun)
  static const _weekdayNames = {
    1: 'الإثنين',
    2: 'الثلاثاء',
    3: 'الأربعاء',
    4: 'الخميس',
    5: 'الجمعة',
    6: 'السبت',
    7: 'الأحد',
  };

  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    final theme = Theme.of(context);
    final monthLabel = DateFormat('MMMM yyyy', 'ar')
        .format(provider.focusedMonth);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all(SizeApp.s20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: SizeApp.s16),

              // عنوان
              Text(
                'جدول التدريب الأسبوعي',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              SizedBox(height: SizeApp.s4),
              Text(
                'اختر أيام التدريب لتوليد جلسات شهر $monthLabel',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              SizedBox(height: SizeApp.s20),

              // ── أيام الأسبوع ─────────────────────────────
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: _weekdayNames.entries.map((e) {
                  final isSelected =
                  provider.selectedWeekdays.contains(e.key);
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      provider.toggleWeekday(e.key);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _primary
                            : _primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: _primary.withOpacity(isSelected ? 1 : 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        e.value,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : _primary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: SizeApp.s24),

              // ── زر التوليد ──────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: provider.selectedWeekdays.isEmpty || _isSaving
                      ? null
                      : () async {
                    setState(() => _isSaving = true);
                    final ok =
                    await provider.generateSessionsForCurrentMonth();
                    setState(() => _isSaving = false);

                    if (!context.mounted) return;
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok
                              ? 'تم توليد جلسات شهر $monthLabel بنجاح ✓'
                              : 'تعذّر توليد الجلسات',
                        ),
                        backgroundColor: ok ? _primary : Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  icon: _isSaving
                      ? SizedBox(
                    width: 18.w,
                    height: 18.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                      AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                      : Icon(Icons.auto_awesome_rounded, size: 20.sp),
                  label: Text(
                    _isSaving
                        ? 'جاري التوليد...'
                        : 'توليد جلسات الشهر الحالي',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              SizedBox(height: SizeApp.s8),

              // ── زر مسح جلسات الشهر ──────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isSaving
                      ? null
                      : () async {
                    final confirmed =
                    await _confirmDelete(context);
                    if (!confirmed) return;

                    await provider.generateSessionsForCurrentMonth();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  icon: Icon(Icons.delete_sweep_rounded, size: 18.sp),
                  label: Text(
                    'مسح جلسات الشهر غير المنجزة',
                    style: TextStyle(fontSize: 13.sp),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('مسح الجلسات'),
        content: const Text(
          'سيتم حذف جلسات هذا الشهر المجدولة فقط (لن تُحذف جلسات تم تسجيل حضور فيها).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}



// ─── إحصائية سريعة للشهر ────────────────────────────────────
class _MonthSummaryBanner extends StatelessWidget {
  final AttendanceProvider provider;

  const _MonthSummaryBanner({required this.provider});

  static const _primary = Color(0xFF007C77);

  @override
  Widget build(BuildContext context) {
    final scheduledCount =
        provider.sessions.where((s) => s.isScheduled).length;
    final cancelledCount =
        provider.sessions.where((s) => s.isCancelled).length;
    final monthLabel =
    DateFormat('MMMM yyyy', 'ar').format(provider.focusedMonth);

    return Container(
      margin: EdgeInsets.fromLTRB(
        SizeApp.s16,
        SizeApp.s12,
        SizeApp.s16,
        SizeApp.s4,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: SizeApp.s16,
        vertical: SizeApp.s12,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _primary.withOpacity(0.12),
            _primary.withOpacity(0.05),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _primary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_month_rounded,
            color: _primary,
            size: 22.sp,
          ),
          SizedBox(width: SizeApp.s10),
          Expanded(
            child: Text(
              monthLabel,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: _primary,
              ),
            ),
          ),
          // عدد الجلسات
          _MiniStat(
            count: scheduledCount,
            label: 'جلسة',
            color: _primary,
          ),
          if (cancelledCount > 0) ...[
            SizedBox(width: SizeApp.s8),
            _MiniStat(
              count: cancelledCount,
              label: 'ملغاة',
              color: Colors.orange,
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _MiniStat({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        '$count $label',
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ─── Session Header (بعد اختيار يوم) ─────────────────────────
class _SelectedSessionHeader extends StatelessWidget {
  final AttendanceProvider provider;

  const _SelectedSessionHeader({required this.provider});

  static const _primary = Color(0xFF007C77);

  @override
  Widget build(BuildContext context) {
    final session = provider.selectedSession!;
    final theme = Theme.of(context);
    final dateFormatted =
    DateFormat('EEEE، d MMMM yyyy', 'ar')
        .format(DateTime.parse(session.date));
    final totalMembers = provider.sessionMembers.length;
    final presentCount = provider.attendanceMap.values
        .where((s) => s == AttendanceStatus.present)
        .length;

    return Container(
      margin: EdgeInsets.fromLTRB(
        SizeApp.s16,
        SizeApp.s12,
        SizeApp.s16,
        SizeApp.s4,
      ),
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: session.isCancelled
            ? Colors.orange.withOpacity(0.08)
            : _primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: session.isCancelled
              ? Colors.orange.withOpacity(0.25)
              : _primary.withOpacity(0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // أيقونة
          Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: session.isCancelled
                  ? Colors.orange.withOpacity(0.15)
                  : _primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              session.isCancelled
                  ? Icons.event_busy_rounded
                  : Icons.how_to_reg_rounded,
              color: session.isCancelled ? Colors.orange : _primary,
              size: 22.sp,
            ),
          ),
          SizedBox(width: SizeApp.s12),

          // التاريخ والحضور
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateFormatted,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                ),
                SizedBox(height: 4.h),
                if (session.isCancelled)
                  Text(
                    'الجلسة ملغاة${session.notes != null ? ' — ${session.notes}' : ''}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.orange,
                    ),
                  )
                else if (!provider.isAttendanceLoading && totalMembers > 0)
                  Text(
                    'حضر $presentCount من $totalMembers عضو',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: _primary.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),

          // قائمة الخيارات
          if (!session.isCancelled)
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                size: 20.sp,
                color: theme.iconTheme.color?.withOpacity(0.6),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'cancel',
                  child: Row(
                    children: [
                      Icon(Icons.event_busy_rounded, color: Colors.orange),
                      SizedBox(width: 10),
                      Text('إلغاء الجلسة'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, color: Colors.red),
                      SizedBox(width: 10),
                      Text('حذف الجلسة'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                if (value == 'cancel') {
                  _showCancelDialog(context, provider);
                } else if (value == 'delete') {
                  await provider.deleteCurrentSession();
                }
              },
            ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, AttendanceProvider provider) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: const Row(
          children: [
            Icon(Icons.event_busy_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('إلغاء الجلسة'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('هل تريد إلغاء هذه الجلسة لهذا اليوم فقط؟'),
            SizedBox(height: 12.h),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'السبب (اختياري)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await provider.cancelSession(
                reason: reasonController.text.trim().isEmpty
                    ? null
                    : reasonController.text.trim(),
              );
            },
            child: const Text(
              'تأكيد الإلغاء',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  زر حفظ ثابت في الأسفل — أضفه في TrainingCalendarScreen
//  داخل الـ Scaffold كـ floatingActionButton أو bottomNavigationBar
// ═══════════════════════════════════════════════════════════════
//
//  في _TrainingCalendarScreenState.build():
//
//  floatingActionButton: Consumer<AttendanceProvider>(
//    builder: (context, provider, _) {
//      final show = provider.selectedSession != null &&
//          !provider.selectedSession!.isCancelled &&
//          _tabController.index == 0;
//      if (!show) return const SizedBox.shrink();
//      return _FloatingSaveButton(provider: provider);
//    },
//  ),

class _FloatingSaveButton extends StatelessWidget {
  final AttendanceProvider provider;

  const _FloatingSaveButton({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: SizeApp.s16),
      child: FloatingActionButton.extended(
        onPressed: provider.isAttendanceLoading
            ? null
            : () async {
          HapticFeedback.mediumImpact();
          final success = await provider.saveAttendance();
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    success
                        ? Icons.check_circle_rounded
                        : Icons.error_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    success
                        ? 'تم حفظ الحضور بنجاح ✓'
                        : 'تعذّر الحفظ',
                  ),
                ],
              ),
              backgroundColor:
              success ? const Color(0xFF007C77) : Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              margin: EdgeInsets.all(SizeApp.s16),
            ),
          );
        },
        backgroundColor: const Color(0xFF007C77),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        icon: provider.isAttendanceLoading
            ? SizedBox(
          width: 20.w,
          height: 20.h,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Icon(Icons.save_rounded),
        label: Text(
          provider.isAttendanceLoading ? 'جاري الحفظ...' : 'حفظ الحضور',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

