import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/models/skill_template.dart';
import '../data/database/db_helper.dart';
import '../core/utils/enums.dart';

/// ✅ Enhanced Skill Library Provider with improved state management
class SkillLibraryProvider extends ChangeNotifier {
  // Core data
  List<SkillTemplate> _allSkills = [];
  List<SkillTemplate> _displayedSkills = [];

  // Loading and error states
  bool _isLoading = false;
  String? _errorMessage;

  // Filter and search states
  Apparatus? _selectedApparatus;
  String _searchQuery = '';
  Timer? _searchTimer;

  // Getters
  List<SkillTemplate> get skills => _displayedSkills;
  List<SkillTemplate> get allSkills => List.unmodifiable(_allSkills);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Apparatus? get selectedApparatus => _selectedApparatus;
  String get searchQuery => _searchQuery;
  bool get hasSkills => _allSkills.isNotEmpty;
  bool get hasResults => _displayedSkills.isNotEmpty;
  bool get isFiltered => _selectedApparatus != null || _searchQuery.isNotEmpty;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  SkillLibraryProvider() {
    loadSkills();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }

  // ✅ Load skills from database
  Future<void> loadSkills() async {
    await _setLoadingState(true);

    try {
      _allSkills = await _dbHelper.getSkillTemplates();
      _applyFilters();
      _clearError();
    } catch (e) {
      _setError('فشل في تحميل المهارات: ${e.toString()}');
      debugPrint('Error loading skills: $e');
    }

    await _setLoadingState(false);
  }

  // ✅ Create new skill
  Future<String?> createSkill(SkillTemplate skill) async {
    try {
      _clearError();
      final id = await _dbHelper.createSkillTemplate(skill);

      // Add to local list instead of reloading everything
      final newSkill = skill.copyWith(id: id);
      _allSkills.add(newSkill);
      _applyFilters();

      return id;
    } catch (e) {
      _setError('فشل في إنشاء المهارة: ${e.toString()}');
      debugPrint('Error creating skill: $e');
      return null;
    }
  }

  // ✅ Update existing skill
  Future<bool> updateSkill(SkillTemplate skill) async {
    try {
      _clearError();
      await _dbHelper.updateSkillTemplate(skill);

      // Update local list
      final index = _allSkills.indexWhere((s) => s.id == skill.id);
      if (index != -1) {
        _allSkills[index] = skill;
        _applyFilters();
      }

      return true;
    } catch (e) {
      _setError('فشل في تحديث المهارة: ${e.toString()}');
      debugPrint('Error updating skill: $e');
      return false;
    }
  }

  // ✅ Delete skill
  Future<bool> deleteSkill(String id) async {
    try {
      _clearError();
      await _dbHelper.deleteSkillTemplate(id);

      // Remove from local list
      _allSkills.removeWhere((s) => s.id == id);
      _applyFilters();

      return true;
    } catch (e) {
      _setError('فشل في حذف المهارة: ${e.toString()}');
      debugPrint('Error deleting skill: $e');
      return false;
    }
  }

  // ✅ Filter by apparatus
  void filterByApparatus(Apparatus? apparatus) {
    if (_selectedApparatus == apparatus) return;

    _selectedApparatus = apparatus;
    _applyFilters();
  }

  // ✅ Search skills with debouncing
  void searchSkills(String query) {
    if (_searchQuery == query) return;

    _searchQuery = query.trim();

    // Cancel previous timer
    _searchTimer?.cancel();

    // Debounce search to avoid excessive filtering
    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      _applyFilters();
    });
  }

  // ✅ Clear search
  void clearSearch() {
    if (_searchQuery.isEmpty) return;

    _searchQuery = '';
    _searchTimer?.cancel();
    _applyFilters();
  }

  // ✅ Clear all filters
  void clearAllFilters() {
    bool hasChanges = false;

    if (_selectedApparatus != null) {
      _selectedApparatus = null;
      hasChanges = true;
    }

    if (_searchQuery.isNotEmpty) {
      _searchQuery = '';
      _searchTimer?.cancel();
      hasChanges = true;
    }

    if (hasChanges) {
      _applyFilters();
    }
  }

  // ✅ Refresh data
  Future<void> refresh() async {
    await loadSkills();
  }

  // ✅ Get skills by apparatus (without changing current filter)
  List<SkillTemplate> getSkillsByApparatus(Apparatus apparatus) {
    return _allSkills.where((s) => s.apparatus == apparatus).toList();
  }

  // ✅ Get skills count by apparatus
  Map<Apparatus, int> getSkillsCountByApparatus() {
    final Map<Apparatus, int> counts = {};

    for (final apparatus in Apparatus.values) {
      counts[apparatus] = _allSkills
          .where((skill) => skill.apparatus == apparatus)
          .length;
    }

    return counts;
  }

  // ✅ Get total skills count
  int get totalSkillsCount => _allSkills.length;

  // ✅ Check if skill name exists (for validation)
  bool isSkillNameExists(String name, {String? excludeId}) {
    return _allSkills.any((skill) =>
    skill.skillName.toLowerCase() == name.toLowerCase() &&
        skill.id != excludeId
    );
  }

  // ✅ Get skill by id
  SkillTemplate? getSkillById(String id) {
    try {
      return _allSkills.firstWhere((skill) => skill.id == id);
    } catch (e) {
      return null;
    }
  }

  // Private helper methods

  // Apply current filters and search to the skills list
  void _applyFilters() {
    List<SkillTemplate> filtered = List.from(_allSkills);

    // Apply apparatus filter
    if (_selectedApparatus != null) {
      filtered = filtered
          .where((skill) => skill.apparatus == _selectedApparatus)
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((skill) {
        return skill.skillName.toLowerCase().contains(query) ||
            (skill.technicalAnalysis?.toLowerCase().contains(query) ?? false) ||
            skill.apparatus.arabicName.toLowerCase().contains(query);
      }).toList();
    }

    // Sort by skill name
    filtered.sort((a, b) => a.skillName.compareTo(b.skillName));

    _displayedSkills = filtered;
    notifyListeners();
  }

  // Set loading state
  Future<void> _setLoadingState(bool loading) async {
    if (_isLoading == loading) return;

    _isLoading = loading;
    notifyListeners();

    // Small delay to ensure UI updates
    if (loading) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  // Set error message
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Clear error message
  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}

/// ✅ Extension for better skill template handling
extension SkillTemplateExtension on SkillTemplate {
  SkillTemplate copyWith({
    String? id,
    String? skillName,
    Apparatus? apparatus,
    String? thumbnailPath,
    List<MediaItem>? mediaGallery,
    String? technicalAnalysis,
    String? preRequisites,
    String? skillProgression,
    String? drills,
    String? physicalPreparation,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? assignedTeamsCount,
  }) {
    return SkillTemplate(
      id: id ?? this.id,
      skillName: skillName ?? this.skillName,
      apparatus: apparatus ?? this.apparatus,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      mediaGallery: mediaGallery ?? this.mediaGallery,
      technicalAnalysis: technicalAnalysis ?? this.technicalAnalysis,
      preRequisites: preRequisites ?? this.preRequisites,
      skillProgression: skillProgression ?? this.skillProgression,
      drills: drills ?? this.drills,
      physicalPreparation: physicalPreparation ?? this.physicalPreparation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assignedTeamsCount: assignedTeamsCount ?? this.assignedTeamsCount,
    );
  }
}