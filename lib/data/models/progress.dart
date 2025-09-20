class Progress {
  final int? id;
  final int memberId;
  final int exerciseId;
  final String status; // Not Started, In Progress, Mastered
  final DateTime? completedAt;
  final String? notes;

  Progress({
    this.id,
    required this.memberId,
    required this.exerciseId,
    required this.status,
    this.completedAt,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'member_id': memberId,
      'exercise_id': exerciseId,
      'status': status,
      'completed_at': completedAt?.toIso8601String(),
      'notes': notes,
    };
  }

  factory Progress.fromMap(Map<String, dynamic> map) {
    return Progress(
      id: map['id'],
      memberId: map['member_id'],
      exerciseId: map['exercise_id'],
      status: map['status'],
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'])
          : null,
      notes: map['notes'],
    );
  }
}