// lib/data/models/session.dart

import 'package:uuid/uuid.dart';

/// حالة الجلسة — عادية / ملغاة / مؤجلة
enum SessionStatus {
  scheduled,   // مجدولة
  cancelled,   // ملغاة (لهذا اليوم فقط)
  postponed;   // مؤجلة

  String get value => name;

  static SessionStatus fromString(String? v) {
    switch (v) {
      case 'cancelled':
        return SessionStatus.cancelled;
      case 'postponed':
        return SessionStatus.postponed;
      default:
        return SessionStatus.scheduled;
    }
  }

  String get arabicLabel {
    switch (this) {
      case SessionStatus.scheduled:
        return 'مجدولة';
      case SessionStatus.cancelled:
        return 'ملغاة';
      case SessionStatus.postponed:
        return 'مؤجلة';
    }
  }
}

class Session {
  final String id;
  final String teamId;

  /// التاريخ بصيغة 'yyyy-MM-dd'
  final String date;

  final SessionStatus status;
  final String? notes;
  final DateTime createdAt;

  const Session({
    required this.id,
    required this.teamId,
    required this.date,
    this.status = SessionStatus.scheduled,
    this.notes,
    required this.createdAt,
  });

  factory Session.create({
    required String teamId,
    required DateTime date,
    SessionStatus status = SessionStatus.scheduled,
    String? notes,
  }) {
    return Session(
      id: const Uuid().v4(),
      teamId: teamId,
      date: _formatDate(date),
      status: status,
      notes: notes,
      createdAt: DateTime.now(),
    );
  }

  // ── helpers ──────────────────────────────────────
  static String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  DateTime get dateTime => DateTime.parse(date);

  bool get isScheduled => status == SessionStatus.scheduled;
  bool get isCancelled => status == SessionStatus.cancelled;

  // ── serialization ────────────────────────────────
  Map<String, dynamic> toMap() => {
    'id': id,
    'team_id': teamId,
    'date': date,
    'status': status.value,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
  };

  factory Session.fromMap(Map<String, dynamic> map) => Session(
    id: map['id'] as String,
    teamId: map['team_id'] as String,
    date: map['date'] as String,
    status: SessionStatus.fromString(map['status'] as String?),
    notes: map['notes'] as String?,
    createdAt: DateTime.parse(map['created_at'] as String),
  );

  Session copyWith({
    String? id,
    String? teamId,
    String? date,
    SessionStatus? status,
    String? notes,
    DateTime? createdAt,
  }) =>
      Session(
        id: id ?? this.id,
        teamId: teamId ?? this.teamId,
        date: date ?? this.date,
        status: status ?? this.status,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) => other is Session && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Session(id:$id, team:$teamId, date:$date, status:$status)';
}