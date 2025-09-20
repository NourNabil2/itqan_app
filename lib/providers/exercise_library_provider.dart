import 'package:flutter/foundation.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import '../data/models/exercise_template.dart';
import '../data/database/db_helper.dart';


class ExerciseLibraryProvider extends ChangeNotifier {
  List<ExerciseTemplate> _exercises = [];
  List<ExerciseTemplate> _filteredExercises = [];
  bool _isLoading = false;
  ExerciseType? _selectedType;

  List<ExerciseTemplate> get exercises => _filteredExercises.isEmpty ? _exercises : _filteredExercises;
  bool get isLoading => _isLoading;
  ExerciseType? get selectedType => _selectedType;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  ExerciseLibraryProvider() {
    loadExercises();
  }

  Future<void> loadExercises() async {
    _isLoading = true;
    notifyListeners();

    try {
      _exercises = await _dbHelper.getExerciseTemplates();
      _filteredExercises = _exercises;
      filterByType(_selectedType);
    } catch (e) {
      debugPrint('Error loading exercises: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String> createExercise(ExerciseTemplate exercise) async {
    final id = await _dbHelper.createExerciseTemplate(exercise);
    await loadExercises();
    return id;
  }

  Future<void> updateExercise(ExerciseTemplate exercise) async {
    await _dbHelper.updateExerciseTemplate(exercise);
    await loadExercises();
  }

  Future<void> deleteExercise(String id) async {
    await _dbHelper.deleteExerciseTemplate(id);
    await loadExercises();
  }

  void filterByType(ExerciseType? type) {
    _selectedType = type;
    if (type == null) {
      _filteredExercises = _exercises;
    } else {
      _filteredExercises = _exercises.where((e) => e.type == type).toList();
    }
    notifyListeners();
  }

  void searchExercises(String query) {
    if (query.isEmpty) {
      _filteredExercises = _exercises;
    } else {
      _filteredExercises = _exercises
          .where((e) =>
      e.title.toLowerCase().contains(query.toLowerCase()) ||
          (e.description?.toLowerCase().contains(query.toLowerCase()) ?? false))
          .toList();
    }
    notifyListeners();
  }

  List<ExerciseTemplate> getExercisesByType(ExerciseType type) {
    return _exercises.where((e) => e.type == type).toList();
  }
}