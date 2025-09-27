// ============= Exercise Assignment Provider =============
import 'package:flutter/foundation.dart';
import 'package:itqan_gym/data/database/db_helper.dart';
import 'package:itqan_gym/data/models/exercise_template.dart';
import 'package:itqan_gym/data/models/skill_template.dart';
import 'package:itqan_gym/data/models/member/member.dart';

/// نموذج للتمرين المعين للعضو
class AssignedExercise {
  final String exerciseId;
  final String memberId;
  final String status;
  final double progress;
  final DateTime assignedAt;
  final DateTime? completedAt;
  final String? notes;
  final ExerciseTemplate? exercise;

  AssignedExercise({
    required this.exerciseId,
    required this.memberId,
    required this.status,
    required this.progress,
    required this.assignedAt,
    this.completedAt,
    this.notes,
    this.exercise,
  });

  bool get isCompleted => status == 'completed' || progress >= 100;
  bool get isInProgress => status == 'in_progress' || (progress > 0 && progress < 100);
  bool get isNotStarted => status == 'not_started' || progress == 0;

  AssignedExercise copyWith({
    String? status,
    double? progress,
    DateTime? completedAt,
    String? notes,
  }) {
    return AssignedExercise(
      exerciseId: exerciseId,
      memberId: memberId,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      assignedAt: assignedAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      exercise: exercise,
    );
  }
}

/// نموذج للمهارة المعينة للعضو
class AssignedSkill {
  final String skillId;
  final String memberId;
  final String status;
  final double progress;
  final DateTime assignedAt;
  final DateTime? completedAt;
  final String? notes;
  final SkillTemplate? skill;

  AssignedSkill({
    required this.skillId,
    required this.memberId,
    required this.status,
    required this.progress,
    required this.assignedAt,
    this.completedAt,
    this.notes,
    this.skill,
  });

  bool get isCompleted => status == 'completed' || progress >= 100;
  bool get isInProgress => status == 'in_progress' || (progress > 0 && progress < 100);
  bool get isNotStarted => status == 'not_started' || progress == 0;
}

/// Provider لإدارة تعيين التمارين والمهارات للأعضاء
class ExerciseAssignmentProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // تعيينات التمارين
  Map<String, List<AssignedExercise>> _memberExercises = {};
  Map<String, List<Member>> _exerciseMembers = {};

  // تعيينات المهارات
  Map<String, List<AssignedSkill>> _memberSkills = {};
  Map<String, List<Member>> _skillMembers = {};

  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ============= Exercise Assignment Methods =============

  /// تعيين تمرين لعدة أعضاء
  Future<void> assignExerciseToMembers(
      String exerciseId,
      List<String> memberIds, {
        String? assignedBy,
      }) async {
    try {
      _setLoading(true);

      final db = await _dbHelper.database;
      await DatabaseHelper.assignExerciseToMembers(
        db,
        exerciseId,
        memberIds,
        assignedBy: assignedBy,
      );

      // تحديث البيانات المحلية
      for (final memberId in memberIds) {
        await loadMemberExercises(memberId);
      }

      notifyListeners();
    } catch (e) {
      _setError('حدث خطأ في تعيين التمرين: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// جلب التمارين المعينة لعضو
  Future<List<AssignedExercise>> loadMemberExercises(String memberId) async {
    try {
      final db = await _dbHelper.database;
      final results = await DatabaseHelper.getMemberAssignedExercises(
        db,
        memberId,
      );

      final exercises = <AssignedExercise>[];
      for (final row in results) {
        exercises.add(AssignedExercise(
          exerciseId: row['id'] as String,
          memberId: memberId,
          status: row['status'] as String,
          progress: (row['progress'] as num).toDouble(),
          assignedAt: DateTime.parse(row['assigned_at'] as String),
          completedAt: row['completed_at'] != null
              ? DateTime.parse(row['completed_at'] as String)
              : null,
          notes: row['member_notes'] as String?,
          exercise: ExerciseTemplate.fromMap(row),
        ));
      }

      _memberExercises[memberId] = exercises;
      notifyListeners();
      return exercises;
    } catch (e) {
      _setError('حدث خطأ في جلب التمارين: ${e.toString()}');
      return [];
    }
  }

  /// جلب الأعضاء المعينين لتمرين
  Future<List<Member>> loadExerciseMembers(String exerciseId) async {
    try {
      final db = await _dbHelper.database;
      final results = await DatabaseHelper.getExerciseAssignedMembers(
        db,
        exerciseId,
      );

      final members = results.map((row) => Member.fromMap(row)).toList();
      _exerciseMembers[exerciseId] = members;
      notifyListeners();
      return members;
    } catch (e) {
      _setError('حدث خطأ في جلب الأعضاء: ${e.toString()}');
      return [];
    }
  }

  /// جلب معرفات الأعضاء المعينين لتمرين
  Future<List<String>> getExerciseAssignedMemberIds(String exerciseId) async {
    try {
      final members = await loadExerciseMembers(exerciseId);
      return members.map((m) => m.id).toList();
    } catch (e) {
      return [];
    }
  }

  /// تحديث تقدم العضو في التمرين
  Future<void> updateMemberExerciseProgress(
      String memberId,
      String exerciseId,
      double progress, {
        String? status,
        String? notes,
      }) async {
    try {
      _setLoading(true);

      final db = await _dbHelper.database;
      await DatabaseHelper.updateMemberExerciseProgress(
        db,
        memberId,
        exerciseId,
        progress,
        status: status,
        notes: notes,
      );

      // تحديث البيانات المحلية
      await loadMemberExercises(memberId);

      notifyListeners();
    } catch (e) {
      _setError('حدث خطأ في تحديث التقدم: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// إلغاء تعيين تمرين من عضو
  Future<void> unassignExerciseFromMember(String memberId, String exerciseId) async {
    try {
      _setLoading(true);

      final db = await _dbHelper.database;
      await DatabaseHelper.unassignExerciseFromMember(
        db,
        memberId,
        exerciseId,
      );

      // تحديث البيانات المحلية
      _memberExercises[memberId]?.removeWhere((e) => e.exerciseId == exerciseId);
      _exerciseMembers[exerciseId]?.removeWhere((m) => m.id == memberId);

      notifyListeners();
    } catch (e) {
      _setError('حدث خطأ في إلغاء التعيين: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ============= Skill Assignment Methods =============

  /// تعيين مهارة لعدة أعضاء
  Future<void> assignSkillToMembers(
      String skillId,
      List<String> memberIds, {
        String? assignedBy,
      }) async {
    try {
      _setLoading(true);

      final db = await _dbHelper.database;
      await DatabaseHelper.assignSkillToMembers(
        db,
        skillId,
        memberIds,
        assignedBy: assignedBy,
      );

      // تحديث البيانات المحلية
      for (final memberId in memberIds) {
        await loadMemberSkills(memberId);
      }

      notifyListeners();
    } catch (e) {
      _setError('حدث خطأ في تعيين المهارة: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// جلب المهارات المعينة لعضو
  Future<List<AssignedSkill>> loadMemberSkills(String memberId) async {
    try {
      final db = await _dbHelper.database;
      final results = await DatabaseHelper.getMemberAssignedSkills(
        db,
        memberId,
      );

      final skills = <AssignedSkill>[];
      for (final row in results) {
        skills.add(AssignedSkill(
          skillId: row['id'] as String,
          memberId: memberId,
          status: row['status'] as String,
          progress: (row['progress'] as num).toDouble(),
          assignedAt: DateTime.parse(row['assigned_at'] as String),
          completedAt: row['completed_at'] != null
              ? DateTime.parse(row['completed_at'] as String)
              : null,
          notes: row['member_notes'] as String?,
          skill: SkillTemplate.fromMap(row),
        ));
      }

      _memberSkills[memberId] = skills;
      notifyListeners();
      return skills;
    } catch (e) {
      _setError('حدث خطأ في جلب المهارات: ${e.toString()}');
      return [];
    }
  }

  // ============= Statistics Methods =============

  /// حساب التقدم الكلي للعضو
  Future<double> calculateMemberOverallProgress(String memberId) async {
    try {
      final db = await _dbHelper.database;
      return await DatabaseHelper.calculateMemberOverallProgress(
        db,
        memberId,
      );
    } catch (e) {
      return 0.0;
    }
  }

  /// جلب إحصائيات العضو
  Future<Map<String, dynamic>> getMemberStatistics(String memberId) async {
    try {
      final db = await _dbHelper.database;
      return await DatabaseHelper.getMemberStatistics(
        db,
        memberId,
      );
    } catch (e) {
      return {
        'exercises': {
          'total': 0,
          'completed': 0,
          'in_progress': 0,
          'not_started': 0,
        },
        'skills': {
          'total': 0,
          'completed': 0,
          'in_progress': 0,
          'not_started': 0,
        },
      };
    }
  }

  // ============= Utility Methods =============

  /// الحصول على التمارين المعينة لعضو (من الذاكرة)
  List<AssignedExercise> getMemberExercises(String memberId) {
    return _memberExercises[memberId] ?? [];
  }

  /// الحصول على المهارات المعينة لعضو (من الذاكرة)
  List<AssignedSkill> getMemberSkills(String memberId) {
    return _memberSkills[memberId] ?? [];
  }

  /// الحصول على الأعضاء المعينين لتمرين (من الذاكرة)
  List<Member> getExerciseMembers(String exerciseId) {
    return _exerciseMembers[exerciseId] ?? [];
  }

  /// الحصول على الأعضاء المعينين لمهارة (من الذاكرة)
  List<Member> getSkillMembers(String skillId) {
    return _skillMembers[skillId] ?? [];
  }

  /// التحقق من تعيين تمرين لعضو
  bool isExerciseAssignedToMember(String memberId, String exerciseId) {
    final exercises = _memberExercises[memberId] ?? [];
    return exercises.any((e) => e.exerciseId == exerciseId);
  }

  /// التحقق من تعيين مهارة لعضو
  bool isSkillAssignedToMember(String memberId, String skillId) {
    final skills = _memberSkills[memberId] ?? [];
    return skills.any((s) => s.skillId == skillId);
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// مسح كل البيانات المحفوظة
  void clearCache() {
    _memberExercises.clear();
    _exerciseMembers.clear();
    _memberSkills.clear();
    _skillMembers.clear();
    notifyListeners();
  }
}