import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import '../data/models/exercise_template.dart';
import '../data/database/db_helper.dart';

/// ✅ Enhanced Exercise Library Provider with improved state management
class ExerciseLibraryProvider extends ChangeNotifier {
  // Core data
  List<ExerciseTemplate> _allExercises = [];
  List<ExerciseTemplate> _displayedExercises = [];

  // Loading and error states
  bool _isLoading = false;
  String? _errorMessage;

  // Filter and search states
  ExerciseType? _selectedType;
  String _searchQuery = '';
  Timer? _searchTimer;

  // Getters
  List<ExerciseTemplate> get exercises => _displayedExercises;
  List<ExerciseTemplate> get allExercises => List.unmodifiable(_allExercises);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ExerciseType? get selectedType => _selectedType;
  String get searchQuery => _searchQuery;
  bool get hasExercises => _allExercises.isNotEmpty;
  bool get hasResults => _displayedExercises.isNotEmpty;
  bool get isFiltered => _selectedType != null || _searchQuery.isNotEmpty;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  ExerciseLibraryProvider() {
    loadExercises();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }

  // ✅ Load exercises from database
  Future<void> loadExercises() async {
    await _setLoadingState(true);

    try {
      _allExercises = await _dbHelper.getExerciseTemplates();
      _applyFilters();
      _clearError();
    } catch (e) {
      _setError('فشل في تحميل التمارين: ${e.toString()}');
      debugPrint('Error loading exercises: $e');
    }

    await _setLoadingState(false);
  }

  // ✅ Create new exercise
  Future<String?> createExercise(ExerciseTemplate exercise) async {
    try {
      _clearError();
      final id = await _dbHelper.createExerciseTemplate(exercise);

      // Add to local list instead of reloading everything
      final newExercise = exercise.copyWith(id: id);
      _allExercises.add(newExercise);
      _applyFilters();

      return id;
    } catch (e) {
      _setError('فشل في إنشاء التمرين: ${e.toString()}');
      debugPrint('Error creating exercise: $e');
      return null;
    }
  }

  // ✅ Update existing exercise
  Future<bool> updateExercise(ExerciseTemplate exercise) async {
    try {
      _clearError();
      await _dbHelper.updateExerciseTemplate(exercise);

      // Update local list
      final index = _allExercises.indexWhere((e) => e.id == exercise.id);
      if (index != -1) {
        _allExercises[index] = exercise;
        _applyFilters();
      }

      return true;
    } catch (e) {
      _setError('فشل في تحديث التمرين: ${e.toString()}');
      debugPrint('Error updating exercise: $e');
      return false;
    }
  }

  // ✅ Delete exercise
  Future<bool> deleteExercise(String id) async {
    try {
      _clearError();
      await _dbHelper.deleteExerciseTemplate(id);

      // Remove from local list
      _allExercises.removeWhere((e) => e.id == id);
      _applyFilters();

      return true;
    } catch (e) {
      _setError('فشل في حذف التمرين: ${e.toString()}');
      debugPrint('Error deleting exercise: $e');
      return false;
    }
  }

  // ✅ Filter by exercise type
  void filterByType(ExerciseType? type) {
    if (_selectedType == type) return;

    _selectedType = type;
    _applyFilters();
  }

  // ✅ Search exercises with debouncing
  void searchExercises(String query) {
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

    if (_selectedType != null) {
      _selectedType = null;
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
    await loadExercises();
  }

  // ✅ Get exercises by type (without changing current filter)
  List<ExerciseTemplate> getExercisesByType(ExerciseType type) {
    return _allExercises.where((e) => e.type == type).toList();
  }

  // ✅ Get exercises count by type
  Map<ExerciseType, int> getExercisesCountByType() {
    final Map<ExerciseType, int> counts = {};

    for (final type in ExerciseType.values) {
      counts[type] = _allExercises
          .where((exercise) => exercise.type == type)
          .length;
    }

    return counts;
  }

  // ✅ Get total exercises count
  int get totalExercisesCount => _allExercises.length;

  // ✅ Check if exercise title exists (for validation)
  bool isExerciseTitleExists(String title, {String? excludeId}) {
    return _allExercises.any((exercise) =>
    exercise.title.toLowerCase() == title.toLowerCase() &&
        exercise.id != excludeId
    );
  }

  // ✅ Get exercise by id
  ExerciseTemplate? getExerciseById(String id) {
    try {
      return _allExercises.firstWhere((exercise) => exercise.id == id);
    } catch (e) {
      return null;
    }
  }

  // Private helper methods

  // Apply current filters and search to the exercises list
  void _applyFilters() {
    List<ExerciseTemplate> filtered = List.from(_allExercises);

    // Apply type filter
    if (_selectedType != null) {
      filtered = filtered
          .where((exercise) => exercise.type == _selectedType)
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((exercise) {
        return exercise.title.toLowerCase().contains(query) ||
            (exercise.description?.toLowerCase().contains(query) ?? false) ||
            exercise.type.arabicName.toLowerCase().contains(query);
      }).toList();
    }

    // Sort by title
    filtered.sort((a, b) => a.title.compareTo(b.title));

    _displayedExercises = filtered;
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

/// ✅ Extension for better exercise template handling
extension ExerciseTemplateExtension on ExerciseTemplate {
  ExerciseTemplate copyWith({
    String? id,
    ExerciseType? type,
    String? title,
    String? description,
    String? mediaPath,
    MediaType? mediaType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExerciseTemplate(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      mediaPath: mediaPath ?? this.mediaPath,
      mediaType: mediaType ?? this.mediaType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// ✅ Exercise Library State for better state management
enum ExerciseLibraryState {
  initial,
  loading,
  loaded,
  error,
  empty,
}

/// ✅ Enhanced Provider with state enum
class EnhancedExerciseLibraryProvider extends ExerciseLibraryProvider {
  ExerciseLibraryState _state = ExerciseLibraryState.initial;

  ExerciseLibraryState get state => _state;

  @override
  Future<void> loadExercises() async {
    _state = ExerciseLibraryState.loading;
    notifyListeners();

    await super.loadExercises();

    if (errorMessage != null) {
      _state = ExerciseLibraryState.error;
    } else if (allExercises.isEmpty) {
      _state = ExerciseLibraryState.empty;
    } else {
      _state = ExerciseLibraryState.loaded;
    }

    notifyListeners();
  }
}