import 'package:flutter/foundation.dart';
import '../data/models/team.dart';
import '../data/models/exercise_template.dart';
import '../data/models/skill_template.dart';
import '../data/models/member/member.dart';
import '../data/database/db_helper.dart';
import '../core/utils/enums.dart';

class TeamProvider extends ChangeNotifier {
  List<Team> _teams = [];
  bool _isLoading = false;
  Team? _selectedTeam;
  String? _errorMessage;

  // محتوى الفريق (تعيينات)
  List<ExerciseTemplate> _teamExercises = [];
  List<SkillTemplate> _teamSkills = [];
  List<Member> _teamMembers = [];

  // Getters
  List<Team> get teams => _teams;
  bool get isLoading => _isLoading;
  Team? get selectedTeam => _selectedTeam;
  String? get errorMessage => _errorMessage;
  List<ExerciseTemplate> get teamExercises => _teamExercises;
  List<SkillTemplate> get teamSkills => _teamSkills;
  List<Member> get teamMembers => _teamMembers;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  TeamProvider() {
    loadTeams();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> loadTeams() async {
    _setLoading(true);
    _setError(null);

    try {
      _teams = await _dbHelper.getAllTeams();
    } catch (e) {
      _setError('خطأ في تحميل الفرق: $e');
      debugPrint('Error loading teams: $e');
    }

    _setLoading(false);
  }

  Future<String?> addTeam(Team team) async {
    _setError(null);

    try {
      final id = await _dbHelper.createTeam(team);
      await loadTeams();
      return id;
    } catch (e) {
      _setError('خطأ في إضافة الفريق: $e');
      debugPrint('Error adding team: $e');
      return null;
    }
  }

  Future<bool> updateTeam(Team team) async {
    _setError(null);

    try {
      await _dbHelper.updateTeam(team);
      await loadTeams();
      return true;
    } catch (e) {
      _setError('خطأ في تحديث الفريق: $e');
      debugPrint('Error updating team: $e');
      return false;
    }
  }

  Future<bool> deleteTeam(String id) async {
    _setError(null);

    try {
      await _dbHelper.deleteTeam(id);
      await loadTeams();
      return true;
    } catch (e) {
      _setError('خطأ في حذف الفريق: $e');
      debugPrint('Error deleting team: $e');
      return false;
    }
  }

  void selectTeam(Team team) {
    _selectedTeam = team;
    notifyListeners();
  }

  // فلترة حسب الفئة العمرية
  List<Team> getTeamsByAgeGroup(AgeCategory ageCategory) {
    return _teams.where((team) => team.ageCategory == ageCategory).toList();
  }

  // تحميل محتوى الفريق الكامل
  Future<void> loadTeamContent(String teamId) async {
    _setError(null);

    try {
      _teamExercises = await _dbHelper.getTeamAssignedExercises(teamId);
      _teamSkills = await _dbHelper.getTeamAssignedSkills(teamId);
      _teamMembers = await _dbHelper.getTeamMembers(teamId);
      notifyListeners();
    } catch (e) {
      _setError('خطأ في تحميل محتوى الفريق: $e');
      debugPrint('Error loading team content: $e');
    }
  }

  // تحميل أعضاء الفريق فقط
  Future<void> loadTeamMembers(String teamId) async {
    _setError(null);

    try {
      _teamMembers = await _dbHelper.getTeamMembers(teamId);
      notifyListeners();
    } catch (e) {
      _setError('خطأ في تحميل أعضاء الفريق: $e');
      debugPrint('Error loading team members: $e');
    }
  }

  // إدارة الأعضاء
  Future<bool> addMembersToTeam(String teamId, List<String> memberIds) async {
    _setError(null);

    try {
      await _dbHelper.addMembersToTeam(teamId, memberIds);
      await loadTeamMembers(teamId);
      return true;
    } catch (e) {
      _setError('خطأ في إضافة الأعضاء للفريق: $e');
      debugPrint('Error adding members to team: $e');
      return false;
    }
  }

  Future<bool> removeMemberFromTeam(String teamId, String memberId) async {
    _setError(null);

    try {
      await _dbHelper.removeMemberFromTeam(teamId, memberId);
      await loadTeamMembers(teamId);
      return true;
    } catch (e) {
      _setError('خطأ في إزالة العضو من الفريق: $e');
      debugPrint('Error removing member from team: $e');
      return false;
    }
  }

  // تعيين التمارين والمهارات
  Future<bool> assignExercisesToTeam(String teamId, List<String> exerciseTemplateIds) async {
    _setError(null);

    try {
      await _dbHelper.assignExercisesToTeam(teamId, exerciseTemplateIds);
      await loadTeamContent(teamId);
      return true;
    } catch (e) {
      _setError('خطأ في تعيين التمارين: $e');
      debugPrint('Error assigning exercises: $e');
      return false;
    }
  }

  Future<bool> assignSkillsToTeam(String teamId, List<String> skillTemplateIds) async {
    _setError(null);

    try {
      await _dbHelper.assignSkillsToTeam(teamId, skillTemplateIds);
      await loadTeamContent(teamId);
      return true;
    } catch (e) {
      _setError('خطأ في تعيين المهارات: $e');
      debugPrint('Error assigning skills: $e');
      return false;
    }
  }

  // إحصائيات الفريق
  int get totalMembers => _teamMembers.length;
  int get totalExercises => _teamExercises.length;
  int get totalSkills => _teamSkills.length;

  // تنظيف البيانات
  void clearTeamData() {
    _selectedTeam = null;
    _teamExercises.clear();
    _teamSkills.clear();
    _teamMembers.clear();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}