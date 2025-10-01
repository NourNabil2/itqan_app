import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/models/skill_template.dart';
import '../data/database/db_helper.dart';
import '../core/utils/enums.dart';

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
  Map<Apparatus, String>? _apparatusLocalizations; // ✅ إضافة هذا

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

  Future<String?> createSkill(SkillTemplate skill) async {
    try {
      _clearError();
      final id = await _dbHelper.createSkillTemplate(skill);

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

  Future<bool> updateSkill(SkillTemplate skill) async {
    try {
      _clearError();
      await _dbHelper.updateSkillTemplate(skill);

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

  Future<bool> deleteSkill(String id) async {
    try {
      _clearError();
      await _dbHelper.deleteSkillTemplate(id);

      _allSkills.removeWhere((s) => s.id == id);
      _applyFilters();

      return true;
    } catch (e) {
      _setError('فشل في حذف المهارة: ${e.toString()}');
      debugPrint('Error deleting skill: $e');
      return false;
    }
  }

  void filterByApparatus(Apparatus? apparatus) {
    if (_selectedApparatus == apparatus) return;

    _selectedApparatus = apparatus;
    _applyFilters();
  }

  // ✅ Search skills with localized apparatus names
  void searchSkills(String query, {Map<Apparatus, String>? apparatusLocalizations}) {
    if (_searchQuery == query) return;

    _searchQuery = query.trim();
    _searchTimer?.cancel();

    // Store localizations for use in _applyFilters
    _apparatusLocalizations = apparatusLocalizations;

    // Debounce search to avoid excessive filtering
    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      _applyFilters();
    });
  }

  void clearSearch() {
    if (_searchQuery.isEmpty) return;

    _searchQuery = '';
    _searchTimer?.cancel();
    _applyFilters();
  }

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

  Future<void> refresh() async {
    await loadSkills();
  }

  List<SkillTemplate> getSkillsByApparatus(Apparatus apparatus) {
    return _allSkills.where((s) => s.apparatus == apparatus).toList();
  }

  Map<Apparatus, int> getSkillsCountByApparatus() {
    final Map<Apparatus, int> counts = {};

    for (final apparatus in Apparatus.values) {
      counts[apparatus] = _allSkills
          .where((skill) => skill.apparatus == apparatus)
          .length;
    }

    return counts;
  }

  int get totalSkillsCount => _allSkills.length;

  bool isSkillNameExists(String name, {String? excludeId}) {
    return _allSkills.any((skill) =>
    skill.skillName.toLowerCase() == name.toLowerCase() &&
        skill.id != excludeId
    );
  }

  SkillTemplate? getSkillById(String id) {
    try {
      return _allSkills.firstWhere((skill) => skill.id == id);
    } catch (e) {
      return null;
    }
  }

  // ✅ Apply current filters and search with localization support
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
        // Search in skill name and technical analysis
        final matchesBasic = skill.skillName.toLowerCase().contains(query) ||
            (skill.technicalAnalysis?.toLowerCase().contains(query) ?? false);

        // Search in English apparatus value
        final matchesEnglish = skill.apparatus.value.toLowerCase().contains(query);

        // Search in localized apparatus name if available
        final matchesLocalized = _apparatusLocalizations != null
            ? (_apparatusLocalizations![skill.apparatus]?.toLowerCase().contains(query) ?? false)
            : false;

        return matchesBasic || matchesEnglish || matchesLocalized;
      }).toList();
    }

    // Sort by skill name
    filtered.sort((a, b) => a.skillName.compareTo(b.skillName));

    _displayedSkills = filtered;
    notifyListeners();
  }

  Future<void> _setLoadingState(bool loading) async {
    if (_isLoading == loading) return;

    _isLoading = loading;
    notifyListeners();

    if (loading) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}

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