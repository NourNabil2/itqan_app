// lib/providers/skill_library_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/skill_template.dart';
import '../data/database/db_helper.dart';
import '../core/utils/enums.dart';

class SkillLibraryProvider extends ChangeNotifier {
  // Core data
  List<SkillTemplate> _allSkills = [];
  List<SkillTemplate> _displayedSkills = [];
  List<SkillTemplate> _systemSkills = []; // ✅ المهارات الجاهزة من Supabase
  List<SkillTemplate> _localSkills = []; // ✅ المهارات المحلية

  // Loading and error states
  bool _isLoading = false;
  bool _isLoadingSystem = false; // ✅ تحميل المنفصل للمهارات الجاهزة
  String? _errorMessage;

  // Filter and search states
  Apparatus? _selectedApparatus;
  String _searchQuery = '';
  Timer? _searchTimer;
  Map<Apparatus, String>? _apparatusLocalizations;

  // ✅ Supabase client
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _tableName = 'system_skills';
  static const String _bucketName = 'gym-skills-media';

  // Getters
  List<SkillTemplate> get skills => _displayedSkills;
  List<SkillTemplate> get allSkills => List.unmodifiable(_allSkills);
  List<SkillTemplate> get systemSkills => List.unmodifiable(_systemSkills); // ✅
  List<SkillTemplate> get localSkills => List.unmodifiable(_localSkills); // ✅
  bool get isLoading => _isLoading;
  bool get isLoadingSystem => _isLoadingSystem; // ✅
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

  // ✅ تحميل البيانات المحلية + السحابية
  Future<void> loadSkills() async {
    await _setLoadingState(true);
    _errorMessage = null;

    try {
      // تحميل الموازي (Parallel) للبيانات المحلية والسحابية
      await Future.wait([
        _loadLocalSkills(),
        _loadSystemSkills(),
      ]);

      _mergeSkills();
      _applyFilters();
    } catch (e) {
      _setError('فشل في تحميل المهارات: ${e.toString()}');
      debugPrint('Error loading skills: $e');
    }

    await _setLoadingState(false);
  }

  // ✅ تحميل المهارات المحلية من SQLite
  Future<void> _loadLocalSkills() async {
    try {
      final localData = await _dbHelper.getSkillTemplates();
      _localSkills = localData.map((skill) =>
          skill.copyWith(isSystem: false)
      ).toList();
      debugPrint('Loaded ${_localSkills.length} local skills');
    } catch (e) {
      debugPrint('Error loading local skills: $e');
      _localSkills = [];
    }
  }

  // ✅ تحميل المهارات الجاهزة من Supabase
  Future<void> _loadSystemSkills() async {
    _isLoadingSystem = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true)
          .order('skill_name_ar', ascending: true);

      _systemSkills = (response as List)
          .map((data) => SkillTemplate.fromSupabase(data))
          .toList();

      debugPrint('Loaded ${_systemSkills.length} system skills from Supabase');
    } on PostgrestException catch (e) {
      debugPrint('Supabase error: ${e.message}');
      _systemSkills = [];
    } catch (e) {
      debugPrint('Error loading system skills: $e');
      _systemSkills = [];
    }

    _isLoadingSystem = false;
    notifyListeners();
  }

  // ✅ دمج المهارات المحلية مع الجاهزة
  void _mergeSkills() {
    // نبدأ بالمهارات الجاهزة ثم نضيف المحلية (أو العكس حسب الأولوية)
    // المهارات المحلية تظهر أولاً أو يمكن ترتيبها حسب التاريخ
    _allSkills = [..._systemSkills, ..._localSkills];

    // إزالة التكرار إذا وجد (بناءً على ID)
    final seen = <String>{};
    _allSkills = _allSkills.where((skill) {
      if (seen.contains(skill.id)) return false;
      seen.add(skill.id);
      return true;
    }).toList();

    debugPrint('Total merged skills: ${_allSkills.length}');
  }

  // ✅ تحديث/إعادة تحميل المهارات الجاهزة فقط (للـ Pull to Refresh)
  Future<void> refreshSystemSkills() async {
    await _loadSystemSkills();
    _mergeSkills();
    _applyFilters();
  }

  // CRUD Operations للمهارات المحلية فقط
  Future<String?> createSkill(SkillTemplate skill) async {
    try {
      _clearError();
      // نتأكد أنها ليست system skill
      final localSkill = skill.copyWith(isSystem: false);
      final id = await _dbHelper.createSkillTemplate(localSkill);

      final newSkill = localSkill.copyWith(id: id);
      _localSkills.add(newSkill);
      _mergeSkills();
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

      // لا يمكن تعديل المهارات الجاهزة
      if (skill.isSystem) {
        _setError('لا يمكن تعديل المهارات الجاهزة من النظام');
        return false;
      }

      await _dbHelper.updateSkillTemplate(skill);

      final index = _localSkills.indexWhere((s) => s.id == skill.id);
      if (index != -1) {
        _localSkills[index] = skill;
        _mergeSkills();
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

      // التحقق من أنها ليست مهارة جاهزة
      final skill = _allSkills.firstWhere((s) => s.id == id);
      if (skill.isSystem) {
        _setError('لا يمكن حذف المهارات الجاهزة من النظام');
        return false;
      }

      await _dbHelper.deleteSkillTemplate(id);

      _localSkills.removeWhere((s) => s.id == id);
      _mergeSkills();
      _applyFilters();

      return true;
    } catch (e) {
      _setError('فشل في حذف المهارة: ${e.toString()}');
      debugPrint('Error deleting skill: $e');
      return false;
    }
  }

  // Filter Methods
  void filterByApparatus(Apparatus? apparatus) {
    if (_selectedApparatus == apparatus) return;

    _selectedApparatus = apparatus;
    _applyFilters();
  }

  void searchSkills(String query, {Map<Apparatus, String>? apparatusLocalizations}) {
    if (_searchQuery == query) return;

    _searchQuery = query.trim();
    _searchTimer?.cancel();

    _apparatusLocalizations = apparatusLocalizations;

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

  // ✅ الحصول على المهارات مجمعة حسب الجهاز (للـ UI)
  Map<Apparatus, List<SkillTemplate>> getSkillsGroupedByApparatus() {
    final grouped = <Apparatus, List<SkillTemplate>>{};

    for (final apparatus in Apparatus.values) {
      final skills = _displayedSkills.where((s) => s.apparatus == apparatus).toList();
      if (skills.isNotEmpty) {
        grouped[apparatus] = skills;
      }
    }

    return grouped;
  }

  // ✅ الحصول على المهارات الجاهزة فقط حسب الجهاز
  List<SkillTemplate> getSystemSkillsByApparatus(Apparatus apparatus) {
    return _systemSkills.where((s) => s.apparatus == apparatus).toList();
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

  // ✅ إحصائيات منفصلة للمهارات الجاهزة والمحلية
  Map<String, int> getSkillsStats() {
    return {
      'total': _allSkills.length,
      'system': _systemSkills.length,
      'local': _localSkills.length,
    };
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

  // ✅ تطبيق الفلاتر على كل المهارات (المحلية + الجاهزة)
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
        // Search in skill name
        final matchesName = skill.skillName.toLowerCase().contains(query);

        // Search in description (للمهارات الجاهزة)
        final matchesDesc = skill.description?.toLowerCase().contains(query) ?? false;

        // Search in technical analysis
        final matchesTech = skill.technicalAnalysis?.toLowerCase().contains(query) ?? false;

        // Search in apparatus
        final matchesEnglish = skill.apparatus.value.toLowerCase().contains(query);
        final matchesLocalized = _apparatusLocalizations != null
            ? (_apparatusLocalizations![skill.apparatus]?.toLowerCase().contains(query) ?? false)
            : false;

        // Search in difficulty level
        final matchesDifficulty = skill.difficultyLevel?.toLowerCase().contains(query) ?? false;

        return matchesName || matchesDesc || matchesTech ||
            matchesEnglish || matchesLocalized || matchesDifficulty;
      }).toList();
    }

    // Sort: المهارات الجاهزة أولاً ثم المحلية، ثم حسب الاسم
    filtered.sort((a, b) {
      if (a.isSystem != b.isSystem) {
        return a.isSystem ? -1 : 1; // الجاهزة أولاً
      }
      return a.skillName.compareTo(b.skillName);
    });

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

  // ✅ Helper methods للـ Storage (للرفع من التطبيق لو احتجت)
  String getVideoUrl(String path) {
    return _supabase.storage.from(_bucketName).getPublicUrl('videos/$path');
  }

  String getThumbnailUrl(String path) {
    return _supabase.storage.from(_bucketName).getPublicUrl('thumbnails/$path');
  }
}

// Extension للـ copyWith (يبقى زي ما هو)
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
    bool? isSystem,
    String? videoUrl,
    String? description,
    String? difficultyLevel,
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
      isSystem: isSystem ?? this.isSystem,
      videoUrl: videoUrl ?? this.videoUrl,
      description: description ?? this.description,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
    );
  }
}