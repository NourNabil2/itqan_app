// lib/data/models/attendance.dart

import 'package:uuid/uuid.dart';

/// حالة الحضور لكل عضو في جلسة
enum AttendanceStatus {
  present,  // حاضر ✓
  absent,   // غائب ✗
  excused;  // بعذر ؟

  String get value => name;

  static AttendanceStatus fromString(String? v) {
    switch (v) {
      case 'present':
        return AttendanceStatus.present;
      case 'absent':
        return AttendanceStatus.absent;
      case 'excused':
        return AttendanceStatus.excused;
      default:
        return AttendanceStatus.absent;
    }
  }

  String get arabicLabel {
    switch (this) {
      case AttendanceStatus.present:
        return 'حاضر';
      case AttendanceStatus.absent:
        return 'غائب';
      case AttendanceStatus.excused:
        return 'بعذر';
    }
  }
}

class Attendance {
  final String id;
  final String sessionId;
  final String memberId;
  final AttendanceStatus status;
  final String? note;
  final DateTime recordedAt;

  const Attendance({
    required this.id,
    required this.sessionId,
    required this.memberId,
    required this.status,
    this.note,
    required this.recordedAt,
  });

  factory Attendance.create({
    required String sessionId,
    required String memberId,
    required AttendanceStatus status,
    String? note,
  }) {
    return Attendance(
      id: const Uuid().v4(),
      sessionId: sessionId,
      memberId: memberId,
      status: status,
      note: note,
      recordedAt: DateTime.now(),
    );
  }

  // ── serialization ────────────────────────────────
  Map<String, dynamic> toMap() => {
    'id': id,
    'session_id': sessionId,
    'member_id': memberId,
    'status': status.value,
    'note': note,
    'recorded_at': recordedAt.toIso8601String(),
  };

  factory Attendance.fromMap(Map<String, dynamic> map) => Attendance(
    id: map['id'] as String,
    sessionId: map['session_id'] as String,
    memberId: map['member_id'] as String,
    status: AttendanceStatus.fromString(map['status'] as String?),
    note: map['note'] as String?,
    recordedAt: DateTime.parse(map['recorded_at'] as String),
  );

  Attendance copyWith({
    String? id,
    String? sessionId,
    String? memberId,
    AttendanceStatus? status,
    String? note,
    DateTime? recordedAt,
  }) =>
      Attendance(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        memberId: memberId ?? this.memberId,
        status: status ?? this.status,
        note: note ?? this.note,
        recordedAt: recordedAt ?? this.recordedAt,
      );

  @override
  bool operator ==(Object other) => other is Attendance && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

// ── helper: تقرير الحضور لعضو في شهر ─────────────────────
class MemberMonthlyReport {
  final String memberId;
  final String memberName;
  final int totalSessions;
  final int presentCount;
  final int absentCount;
  final int excusedCount;

  const MemberMonthlyReport({
    required this.memberId,
    required this.memberName,
    required this.totalSessions,
    required this.presentCount,
    required this.absentCount,
    required this.excusedCount,
  });

  double get attendancePercentage =>
      totalSessions == 0 ? 0 : (presentCount / totalSessions) * 100;

  double get effectivePercentage =>
      totalSessions == 0
          ? 0
          : ((presentCount + excusedCount) / totalSessions) * 100;

  factory MemberMonthlyReport.fromMap(Map<String, dynamic> map) =>
      MemberMonthlyReport(
        memberId: map['member_id'] as String,
        memberName: map['member_name'] as String? ?? '',
        totalSessions: (map['total_sessions'] as num?)?.toInt() ?? 0,
        presentCount: (map['present_count'] as num?)?.toInt() ?? 0,
        absentCount: (map['absent_count'] as num?)?.toInt() ?? 0,
        excusedCount: (map['excused_count'] as num?)?.toInt() ?? 0,
      );
}