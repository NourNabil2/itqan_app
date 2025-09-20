import 'package:flutter/foundation.dart';
import '../data/models/skill_template.dart';
import '../data/database/db_helper.dart';
import '../core/utils/enums.dart';

class SkillLibraryProvider extends ChangeNotifier {
  List<SkillTemplate> _skills = [];
  List<SkillTemplate> _filteredSkills = [];
  bool _isLoading = false;
  Apparatus? _selectedApparatus;

  List<SkillTemplate> get skills => _filteredSkills.isEmpty ? _skills : _filteredSkills;
  bool get isLoading => _isLoading;
  Apparatus? get selectedApparatus => _selectedApparatus;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  SkillLibraryProvider() {
    loadSkills();
  }

  Future<void> loadSkills() async {
    _isLoading = true;
    notifyListeners();

    try {
      _skills = await _dbHelper.getSkillTemplates();
      _filteredSkills = _skills;
      filterByApparatus(_selectedApparatus);
    } catch (e) {
      debugPrint('Error loading skills: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String> createSkill(SkillTemplate skill) async {
    final id = await _dbHelper.createSkillTemplate(skill);
    await loadSkills();
    return id;
  }

  Future<void> updateSkill(SkillTemplate skill) async {
    await _dbHelper.updateSkillTemplate(skill);
    await loadSkills();
  }

  Future<void> deleteSkill(String id) async {
    await _dbHelper.deleteSkillTemplate(id);
    await loadSkills();
  }

  void filterByApparatus(Apparatus? apparatus) {
    _selectedApparatus = apparatus;
    if (apparatus == null) {
      _filteredSkills = _skills;
    } else {
      _filteredSkills = _skills.where((s) => s.apparatus == apparatus).toList();
    }
    notifyListeners();
  }

  void searchSkills(String query) {
    if (query.isEmpty) {
      _filteredSkills = _skills;
    } else {
      _filteredSkills = _skills
          .where((s) => s.skillName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  List<SkillTemplate> getSkillsByApparatus(Apparatus apparatus) {
    return _skills.where((s) => s.apparatus == apparatus).toList();
  }
}