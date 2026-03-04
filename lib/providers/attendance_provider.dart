// lib/providers/attendance_provider.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/models/session.dart';
import '../data/models/attendance.dart';
import '../data/models/member/member.dart';
import '../data/database/db_helper.dart';

// ─── حالة تحميل ───────────────────────────────────────────────
enum LoadState { idle, loading, loaded, error }

class AttendanceProvider extends ChangeNotifier {
  // ── الـ team المختار ────────────────────────────────────────
  String? _teamId;
  String? get teamId => _teamId;

  // ── الشهر المعروض ──────────────────────────────────────────
  DateTime _focusedMonth = DateTime.now();
  DateTime get focusedMonth => _focusedMonth;

  // ── الجلسات ─────────────────────────────────────────────────
  List<Session> _sessions = [];
  Set<DateTime> _sessionDates = {};
  Session? _selectedSession;

  List<Session> get sessions => _sessions;
  Set<DateTime> get sessionDates => _sessionDates;
  Session? get selectedSession => _selectedSession;

  // ── حضور الجلسة المختارة ───────────────────────────────────
  /// key: memberId → AttendanceStatus
  Map<String, AttendanceStatus> _attendanceMap = {};
  List<Member> _sessionMembers = [];

  Map<String, AttendanceStatus> get attendanceMap =>
      Map.unmodifiable(_attendanceMap);
  List<Member> get sessionMembers => _sessionMembers;

  // ── التقرير الشهري ──────────────────────────────────────────
  List<MemberMonthlyReport> _monthlyReport = [];
  List<MemberMonthlyReport> get monthlyReport => _monthlyReport;

  // ── States ──────────────────────────────────────────────────
  LoadState _calendarState = LoadState.idle;
  LoadState _attendanceState = LoadState.idle;
  LoadState _reportState = LoadState.idle;

  bool get isCalendarLoading => _calendarState == LoadState.loading;
  bool get isAttendanceLoading => _attendanceState == LoadState.loading;
  bool get isReportLoading => _reportState == LoadState.loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── أيام الأسبوع المختارة للتوليد ──────────────────────────
  /// weekdays: 1=Monday … 7=Sunday (Dart standard)
  Set<int> _selectedWeekdays = {};
  Set<int> get selectedWeekdays => _selectedWeekdays;

  final DatabaseHelper _db = DatabaseHelper.instance;

  // ════════════════════════════════════════════════════════════
  //  Init
  // ════════════════════════════════════════════════════════════

  /// استدعي هذه الدالة عند فتح الشاشة
  Future<void> init({
    required String teamId,
    DateTime? initialMonth,
  }) async {
    _teamId = teamId;
    _focusedMonth = initialMonth ?? DateTime.now();
    _selectedSession = null;
    _attendanceMap = {};
    _sessionMembers = [];
    _monthlyReport = [];
    _selectedWeekdays = {};
    _sessions = [];
    _sessionDates = {};
    notifyListeners();

    await _loadSessionsForMonth();
  }

  // ════════════════════════════════════════════════════════════
  //  Calendar Navigation
  // ════════════════════════════════════════════════════════════

  Future<void> changeFocusedMonth(DateTime month) async {
    _focusedMonth = DateTime(month.year, month.month, 1);
    _selectedSession = null;
    _attendanceMap = {};
    _sessionMembers = [];
    await _loadSessionsForMonth();
  }

  // ════════════════════════════════════════════════════════════
  //  Session — Loading
  // ════════════════════════════════════════════════════════════

  Future<void> _loadSessionsForMonth() async {
    if (_teamId == null) return;

    _calendarState = LoadState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _sessions = await _db.getSessionsForMonth(
        teamId: _teamId!,
        year: _focusedMonth.year,
        month: _focusedMonth.month,
      );

      _sessionDates = _sessions
          .where((s) => s.isScheduled)
          .map((s) => _normalizeDate(DateTime.parse(s.date)))
          .toSet();

      _calendarState = LoadState.loaded;
    } catch (e) {
      _calendarState = LoadState.error;
      _errorMessage = 'تعذّر تحميل الجلسات: $e';
      debugPrint('AttendanceProvider._loadSessionsForMonth: $e');
    }

    notifyListeners();
  }

  // ════════════════════════════════════════════════════════════
  //  Session — Generate
  // ════════════════════════════════════════════════════════════

  void toggleWeekday(int weekday) {
    if (_selectedWeekdays.contains(weekday)) {
      _selectedWeekdays.remove(weekday);
    } else {
      _selectedWeekdays.add(weekday);
    }
    notifyListeners();
  }

  void setWeekdays(Set<int> weekdays) {
    _selectedWeekdays = weekdays;
    notifyListeners();
  }

  /// توليد جلسات الشهر الحالي بناءً على _selectedWeekdays
  Future<bool> generateSessionsForCurrentMonth() async {
    if (_teamId == null || _selectedWeekdays.isEmpty) return false;

    _calendarState = LoadState.loading;
    notifyListeners();

    try {
      await _db.generateSessionsForMonth(
        teamId: _teamId!,
        weekdays: _selectedWeekdays.toList(),
        year: _focusedMonth.year,
        month: _focusedMonth.month,
      );
      await _loadSessionsForMonth();
      return true;
    } catch (e) {
      _calendarState = LoadState.error;
      _errorMessage = 'تعذّر توليد الجلسات: $e';
      notifyListeners();
      return false;
    }
  }

  /// توليد جلسات لنطاق تواريخ
  Future<bool> generateSessionsForRange({
    required DateTime start,
    required DateTime end,
  }) async {
    if (_teamId == null || _selectedWeekdays.isEmpty) return false;

    _calendarState = LoadState.loading;
    notifyListeners();

    try {
      await _db.generateSessionsForRange(
        teamId: _teamId!,
        weekdays: _selectedWeekdays.toList(),
        startDate: start,
        endDate: end,
      );
      await _loadSessionsForMonth();
      return true;
    } catch (e) {
      _calendarState = LoadState.error;
      _errorMessage = 'تعذّر توليد الجلسات: $e';
      notifyListeners();
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════
  //  Session — Select / Cancel
  // ════════════════════════════════════════════════════════════

  Future<void> selectDate(DateTime date) async {
    if (_teamId == null) return;

    final normalised = _normalizeDate(date);
    final session = _sessions.where((s) {
      return _normalizeDate(DateTime.parse(s.date)) == normalised;
    }).firstOrNull;

    _selectedSession = session;
    _attendanceMap = {};
    _sessionMembers = [];

    if (session != null) {
      await _loadSessionAttendance(session);
    }
  }

  Future<void> cancelSession({String? reason}) async {
    if (_selectedSession == null) return;

    try {
      await _db.updateSessionStatus(
        sessionId: _selectedSession!.id,
        status: SessionStatus.cancelled,
        notes: reason,
      );
      _selectedSession = _selectedSession!.copyWith(
        status: SessionStatus.cancelled,
        notes: reason,
      );
      final idx = _sessions.indexWhere((s) => s.id == _selectedSession!.id);
      if (idx != -1) _sessions[idx] = _selectedSession!;
      _sessionDates.remove(_normalizeDate(DateTime.parse(_selectedSession!.date)));
      notifyListeners();
    } catch (e) {
      _errorMessage = 'تعذّر إلغاء الجلسة: $e';
      notifyListeners();
    }
  }

  Future<void> deleteCurrentSession() async {
    if (_selectedSession == null) return;

    try {
      await _db.deleteSession(_selectedSession!.id);
      _sessions.removeWhere((s) => s.id == _selectedSession!.id);
      _sessionDates.remove(_normalizeDate(DateTime.parse(_selectedSession!.date)));
      _selectedSession = null;
      _attendanceMap = {};
      _sessionMembers = [];
      notifyListeners();
    } catch (e) {
      _errorMessage = 'تعذّر حذف الجلسة: $e';
      notifyListeners();
    }
  }

  // ════════════════════════════════════════════════════════════
  //  Attendance — Load
  // ════════════════════════════════════════════════════════════

  Future<void> _loadSessionAttendance(Session session) async {
    if (_teamId == null) return;

    _attendanceState = LoadState.loading;
    notifyListeners();

    try {
      // جلب أعضاء الفريق
      _sessionMembers = await _db.getTeamMembers(_teamId!);

      // جلب الحضور المسجَّل
      final records = await _db.getSessionAttendance(session.id);
      _attendanceMap = {
        for (final r in records) r.memberId: r.status,
      };

      // الأعضاء الذين لم يُسجَّل لهم بعد → غائب افتراضياً
      for (final member in _sessionMembers) {
        _attendanceMap.putIfAbsent(member.id, () => AttendanceStatus.absent);
      }

      _attendanceState = LoadState.loaded;
    } catch (e) {
      _attendanceState = LoadState.error;
      _errorMessage = 'تعذّر تحميل الحضور: $e';
      debugPrint('AttendanceProvider._loadSessionAttendance: $e');
    }

    notifyListeners();
  }

  // ════════════════════════════════════════════════════════════
  //  Attendance — Save
  // ════════════════════════════════════════════════════════════

  /// تحديث حالة عضو واحد مؤقتاً (بدون حفظ في DB)
  void setMemberStatus(String memberId, AttendanceStatus status) {
    _attendanceMap[memberId] = status;
    notifyListeners();
  }

  /// حفظ حضور كامل الجلسة دفعة واحدة
  Future<bool> saveAttendance() async {
    if (_selectedSession == null || _teamId == null) return false;

    _attendanceState = LoadState.loading;
    notifyListeners();

    try {
      await _db.saveSessionAttendanceBatch(
        sessionId: _selectedSession!.id,
        statusByMemberId: _attendanceMap,
      );
      _attendanceState = LoadState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _attendanceState = LoadState.error;
      _errorMessage = 'تعذّر حفظ الحضور: $e';
      notifyListeners();
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════
  //  Monthly Report
  // ════════════════════════════════════════════════════════════

  Future<void> loadMonthlyReport() async {
    if (_teamId == null) return;

    _reportState = LoadState.loading;
    notifyListeners();

    try {
      _monthlyReport = await _db.getTeamMonthlyReport(
        teamId: _teamId!,
        year: _focusedMonth.year,
        month: _focusedMonth.month,
      );
      _reportState = LoadState.loaded;
    } catch (e) {
      _reportState = LoadState.error;
      _errorMessage = 'تعذّر تحميل التقرير: $e';
    }

    notifyListeners();
  }

  // ════════════════════════════════════════════════════════════
  //  Helpers
  // ════════════════════════════════════════════════════════════

  bool hasSessionOn(DateTime date) =>
      _sessionDates.contains(_normalizeDate(date));

  Session? getSessionOn(DateTime date) {
    final normalised = _normalizeDate(date);
    return _sessions.where((s) {
      return _normalizeDate(DateTime.parse(s.date)) == normalised;
    }).firstOrNull;
  }

  AttendanceStatus statusOf(String memberId) =>
      _attendanceMap[memberId] ?? AttendanceStatus.absent;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSelectedSession() {
    _selectedSession = null;
    _attendanceMap = {};
    _sessionMembers = [];
    notifyListeners();
  }

  DateTime _normalizeDate(DateTime d) => DateTime(d.year, d.month, d.day);
}