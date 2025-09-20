import 'package:flutter/foundation.dart';
import '../data/models/team.dart';
import '../data/models/exercise_template.dart';
import '../data/models/skill_template.dart';
import '../data/database/db_helper.dart';
import '../core/utils/enums.dart';

class TeamProvider extends ChangeNotifier {
  List<Team> _teams = [];
  bool _isLoading = false;
  Team? _selectedTeam;

  // محتوى الفريق (تعيينات)
  List<ExerciseTemplate> _teamExercises = [];
  List<SkillTemplate> _teamSkills = [];

  List<Team> get teams => _teams;
  bool get isLoading => _isLoading;
  Team? get selectedTeam => _selectedTeam;

  // getters للمحتوى
  List<ExerciseTemplate> get teamExercises => _teamExercises;
  List<SkillTemplate> get teamSkills => _teamSkills;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  TeamProvider() {
    loadTeams();
  }

  Future<void> loadTeams() async {
    _isLoading = true;
    notifyListeners();
    try {
      _teams = await _dbHelper.getAllTeams();
    } catch (e) {
      debugPrint('Error loading teams: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<String> addTeam(Team team) async {
    final id = await _dbHelper.createTeam(team);
    await loadTeams();
    return id;
  }

  Future<void> updateTeam(Team team) async {
    await _dbHelper.updateTeam(team);
    await loadTeams();
  }

  Future<void> deleteTeam(String id) async {
    await _dbHelper.deleteTeam(id);
    await loadTeams();
  }

  void selectTeam(Team team) {
    _selectedTeam = team;
    notifyListeners();
  }

  // فلترة حسب الفئة العمرية بالـ enum
  List<Team> getTeamsByAgeGroup(AgeCategory ageCategory) {
    return _teams.where((team) => team.ageCategory == ageCategory).toList();
  }

  // تحميل التعيينات الحالية لفريق (teamId هو UUID نصّي)
  Future<void> loadTeamContent(String teamId) async {
    try {
      _teamExercises = await _dbHelper.getTeamAssignedExercises(teamId);
      _teamSkills = await _dbHelper.getTeamAssignedSkills(teamId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading team content: $e');
    }
  }

  // تعيين/تحديث التمارين المعيَّنة للفريق
  Future<void> assignExercises(String teamId, List<String> exerciseTemplateIds) async {
    // ملاحظة: لو الteamId عندك String UUID، غيّر التوقيع إلى String في DBHelper واستخدمه هنا كذلك
    await _dbHelper.assignExercisesToTeam(teamId, exerciseTemplateIds);
    await loadTeamContent(teamId.toString());
  }

  // تعيين/تحديث المهارات المعيَّنة للفريق
  Future<void> assignSkills(String teamId, List<String> skillTemplateIds) async {
    await _dbHelper.assignSkillsToTeam(teamId, skillTemplateIds);
    await loadTeamContent(teamId.toString());
  }

  // أسماء مطابقة لما بتستخدمه الشاشة ManageAssignmentsScreen
  Future<void> assignExercisesToTeam(String teamId, List<String> exerciseTemplateIds) async {
    await _dbHelper.assignExercisesToTeam(teamId, exerciseTemplateIds);
    await loadTeamContent(teamId);
  }

  Future<void> assignSkillsToTeam(String teamId, List<String> skillTemplateIds) async {
    await _dbHelper.assignSkillsToTeam(teamId, skillTemplateIds);
    await loadTeamContent(teamId);
  }
}
