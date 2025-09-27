// ============= محسن Member Provider للتحديثات الفورية =============
import 'dart:developer';
import 'dart:async';

import 'package:flutter/foundation.dart';
import '../data/models/member/member.dart';
import '../data/models/member/member_notes.dart';
import '../data/database/db_helper.dart';

/// Main Member Provider for team-specific members - محسن للتحديثات الفورية
class MemberProvider extends ChangeNotifier {
  List<Member> _members = [];
  bool _isLoading = false;
  String? _error;
  String? _currentTeamId;

  // ✅ Stream Controllers للتحديثات الفورية
  final StreamController<List<Member>> _membersStreamController = StreamController<List<Member>>.broadcast();
  final StreamController<Member> _memberUpdateStreamController = StreamController<Member>.broadcast();

  List<Member> get members => _members;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ✅ Streams للتحديثات الفورية
  Stream<List<Member>> get membersStream => _membersStreamController.stream;
  Stream<Member> get memberUpdateStream => _memberUpdateStreamController.stream;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Load all members assigned to a specific team
  Future<void> loadTeamMembers(String teamId) async {
    _currentTeamId = teamId;
    _setLoading(true);

    try {
      // Get members assigned to this team
      _members = await _dbHelper.getTeamMembers(teamId);

      // Calculate progress for each member in parallel
      await _calculateMembersProgress();

      // ✅ إشعار فوري للمستمعين
      _membersStreamController.add(_members);
      notifyListeners();
    } catch (e) {
      _setError('حدث خطأ في تحميل الأعضاء: ${e.toString()}');
      debugPrint('Error loading team members: $e');
    }

    _setLoading(false);
  }

  /// ✅ حساب التقدم بشكل متوازي
  Future<void> _calculateMembersProgress() async {
    if (_members.isEmpty) return;

    // تنفيذ العمليات بشكل متوازي لتحسين الأداء
    final futures = _members.map((member) async {
      final progress = await _dbHelper.getMemberOverallProgress(member.id);
      return member.copyWith(overallProgress: progress);
    });

    _members = await Future.wait(futures);
  }

  /// ✅ Assign members to current team with immediate UI update
  Future<void> assignMembersToTeam(List<String> memberIds) async {
    if (_currentTeamId == null) return;

    try {
      await _dbHelper.assignMembersToTeam(_currentTeamId!, memberIds);

      // ✅ تحديث فوري للواجهة
      await loadTeamMembers(_currentTeamId!);
    } catch (e) {
      _setError('حدث خطأ في تعيين الأعضاء: ${e.toString()}');
      debugPrint('Error assigning members: $e');
      rethrow;
    }
  }

  /// ✅ Remove member from current team with optimistic update
  Future<void> removeMemberFromTeam(String memberId) async {
    if (_currentTeamId == null) return;

    // ✅ Optimistic Update - إزالة فورية من الواجهة
    final originalMembers = List<Member>.from(_members);
    _members.removeWhere((member) => member.id == memberId);
    _membersStreamController.add(_members);
    notifyListeners();

    try {
      await _dbHelper.unassignMemberFromTeam(_currentTeamId!, memberId);
    } catch (e) {
      // ✅ في حالة الفشل، العودة للحالة السابقة
      _members = originalMembers;
      _membersStreamController.add(_members);
      _setError('حدث خطأ في إزالة العضو: ${e.toString()}');
      debugPrint('Error removing member from team: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// ✅ Update member with immediate notification
  Future<void> updateMemberInTeam(Member updatedMember) async {
    try {
      // ✅ تحديث فوري في القائمة المحلية
      final index = _members.indexWhere((m) => m.id == updatedMember.id);
      if (index != -1) {
        _members[index] = updatedMember;
        _memberUpdateStreamController.add(updatedMember);
        _membersStreamController.add(_members);
        notifyListeners();
      }

      // ✅ تحديث قاعدة البيانات
      await _dbHelper.updateMember(updatedMember);
    } catch (e) {
      _setError('حدث خطأ في تحديث العضو: ${e.toString()}');
      debugPrint('Error updating member: $e');
      rethrow;
    }
  }

  /// Get member by ID
  Member? getMemberById(String id) {
    try {
      return _members.firstWhere((member) => member.id == id);
    } catch (e) {
      return null;
    }
  }

  /// ✅ Helper methods للتحديثات
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get members by level
  List<Member> getMembersByLevel(String level) {
    return _members.where((member) => member.level == level).toList();
  }

  /// Get members by age range
  List<Member> getMembersByAgeRange(int minAge, int maxAge) {
    return _members.where((member) => member.age >= minAge && member.age <= maxAge).toList();
  }

  /// Get available members for assignment
  Future<List<Member>> getAvailableMembersForAssignment() async {
    if (_currentTeamId == null) return [];

    try {
      return await _dbHelper.getUnassignedMembers(_currentTeamId!);
    } catch (e) {
      debugPrint('Error getting available members: $e');
      return [];
    }
  }

  @override
  void dispose() {
    _membersStreamController.close();
    _memberUpdateStreamController.close();
    super.dispose();
  }
}

/// Global Members Library Provider - محسن للأداء والتحديثات الفورية
class MemberLibraryProvider extends ChangeNotifier {
  List<Member> _allMembers = [];
  List<Member> _filteredMembers = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _error;

  // ✅ Cache للبحث السريع
  final Map<String, Member> _membersCache = {};
  Timer? _searchDebouncer;

  // ✅ Stream Controllers للتحديثات الفورية
  final StreamController<List<Member>> _allMembersStreamController = StreamController<List<Member>>.broadcast();
  final StreamController<Member> _memberUpdateStreamController = StreamController<Member>.broadcast();

  List<Member> get members =>
      _filteredMembers.isEmpty && _searchQuery.isEmpty ? _allMembers : _filteredMembers;
  List<Member> get allMembers => _allMembers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ✅ Streams للتحديثات الفورية
  Stream<List<Member>> get allMembersStream => _allMembersStreamController.stream;
  Stream<Member> get memberUpdateStream => _memberUpdateStreamController.stream;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  MemberLibraryProvider() {
    loadAllMembers();
  }

  /// ✅ Load all members with improved performance
  Future<void> loadAllMembers() async {
    _setLoading(true);

    try {
      _allMembers = await _dbHelper.getAllMembers();

      // ✅ تحديث الـ cache
      _updateCache();

      // ✅ حساب التقدم بشكل متوازي
      await _calculateAllMembersProgress();

      _applyFilters();

      // ✅ إشعار فوري للمستمعين
      _allMembersStreamController.add(_allMembers);
      notifyListeners();
    } catch (e) {
      _setError('حدث خطأ في تحميل المكتبة: ${e.toString()}');
      debugPrint('Error loading all members: $e');
    }

    _setLoading(false);
  }

  /// ✅ تحديث الـ cache للبحث السريع
  void _updateCache() {
    _membersCache.clear();
    for (final member in _allMembers) {
      _membersCache[member.id] = member;
    }
  }

  /// ✅ حساب التقدم للجميع بشكل متوازي
  Future<void> _calculateAllMembersProgress() async {
    if (_allMembers.isEmpty) return;

    const batchSize = 10; // معالجة 10 أعضاء في كل مرة

    for (int i = 0; i < _allMembers.length; i += batchSize) {
      final batch = _allMembers.skip(i).take(batchSize);

      final futures = batch.map((member) async {
        final progress = await _dbHelper.getMemberOverallProgress(member.id);
        return member.copyWith(overallProgress: progress);
      });

      final updatedBatch = await Future.wait(futures);

      // تحديث الأعضاء في المكان الصحيح
      for (int j = 0; j < updatedBatch.length; j++) {
        _allMembers[i + j] = updatedBatch.elementAt(j);
      }

      // ✅ تحديث تدريجي للواجهة
      if (i + batchSize < _allMembers.length) {
        _allMembersStreamController.add(_allMembers);
        notifyListeners();
      }
    }
  }

  /// ✅ Create new member with immediate UI update
  Future<String> createMember(Member member) async {
    try {
      final id = await _dbHelper.createMember(member);
      final newMember = member.copyWith(id: id);

      // ✅ Optimistic Update - إضافة فورية للواجهة
      _allMembers.add(newMember);
      _updateCache();
      _applyFilters();
      _allMembersStreamController.add(_allMembers);
      notifyListeners();

      return id;
    } catch (e) {
      // ✅ في حالة الفشل، إزالة العضو المضاف
      _allMembers.removeWhere((m) => m.id == member.id);
      _setError('حدث خطأ في إضافة العضو: ${e.toString()}');
      debugPrint('Error creating member: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// ✅ Update existing member with immediate UI update
  Future<void> updateMember(Member member) async {
    // ✅ Optimistic Update
    final originalIndex = _allMembers.indexWhere((m) => m.id == member.id);
    Member? originalMember;

    if (originalIndex != -1) {
      originalMember = _allMembers[originalIndex];
      _allMembers[originalIndex] = member;
      _updateCache();
      _memberUpdateStreamController.add(member);
      _allMembersStreamController.add(_allMembers);
      notifyListeners();
    }

    try {
      await _dbHelper.updateMember(member);
    } catch (e) {
      // ✅ في حالة الفشل، العودة للحالة السابقة
      if (originalIndex != -1 && originalMember != null) {
        _allMembers[originalIndex] = originalMember;
        _updateCache();
        notifyListeners();
      }

      _setError('حدث خطأ في تحديث العضو: ${e.toString()}');
      debugPrint('Error updating member: $e');
      rethrow;
    }
  }

  /// ✅ Delete member with immediate UI update
  Future<void> deleteMember(String id) async {
    // ✅ Optimistic Update - حذف فوري من الواجهة
    final originalIndex = _allMembers.indexWhere((m) => m.id == id);
    Member? originalMember;

    if (originalIndex != -1) {
      originalMember = _allMembers.removeAt(originalIndex);
      _updateCache();
      _applyFilters();
      _allMembersStreamController.add(_allMembers);
      notifyListeners();
    }

    try {
      await _dbHelper.deleteMember(id);
    } catch (e) {
      // ✅ في حالة الفشل، إعادة العضو
      if (originalIndex != -1 && originalMember != null) {
        _allMembers.insert(originalIndex, originalMember);
        _updateCache();
        _applyFilters();
        notifyListeners();
      }

      _setError('حدث خطأ في حذف العضو: ${e.toString()}');
      debugPrint('Error deleting member: $e');
      rethrow;
    }
  }

  /// ✅ Search members with debouncing للأداء
  void searchMembers(String query) {
    _searchQuery = query.trim();

    // ✅ إلغاء التأخير السابق
    _searchDebouncer?.cancel();

    if (query.isEmpty) {
      _filteredMembers = [];
      notifyListeners();
      return;
    }

    // ✅ تأخير البحث لتحسين الأداء
    _searchDebouncer = Timer(const Duration(milliseconds: 300), () {
      _applyFilters();
      notifyListeners();
    });
  }

  /// ✅ Apply search filters with improved performance
  void _applyFilters() {
    if (_searchQuery.isEmpty) {
      _filteredMembers = [];
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredMembers = _allMembers
          .where((m) =>
      m.name.toLowerCase().contains(query) ||
          m.level.toLowerCase().contains(query))
          .toList();
    }
  }

  /// ✅ Get member by ID with cache
  Member? getMemberById(String id) {
    return _membersCache[id];
  }

  /// Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get members by age range
  List<Member> getMembersByAgeRange(int minAge, int maxAge) {
    return _allMembers
        .where((m) => m.age >= minAge && m.age <= maxAge)
        .toList();
  }

  /// Get members by level
  List<Member> getMembersByLevel(String level) {
    return _allMembers.where((m) => m.level == level).toList();
  }

  /// Get available members for team assignment
  Future<List<Member>> getAvailableMembersForTeam(String teamId) async {
    try {
      return await _dbHelper.getUnassignedMembers(teamId);
    } catch (e) {
      debugPrint('Error getting available members for team: $e');
      return [];
    }
  }

  @override
  void dispose() {
    _searchDebouncer?.cancel();
    _allMembersStreamController.close();
    _memberUpdateStreamController.close();
    super.dispose();
  }
}

/// Member Notes Provider - محسن للتحديثات الفورية
class MemberNotesProvider extends ChangeNotifier {
  List<MemberNote> _allNotes = [];
  Map<String, List<MemberNote>> _notesByType = {};
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;
  String _currentMemberId = '';

  // ✅ Stream Controllers للتحديثات الفورية
  final StreamController<List<MemberNote>> _notesStreamController = StreamController<List<MemberNote>>.broadcast();
  final StreamController<MemberNote> _noteUpdateStreamController = StreamController<MemberNote>.broadcast();

  List<MemberNote> get allNotes => _allNotes;
  Map<String, List<MemberNote>> get notesByType => _notesByType;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;

  // ✅ Streams للتحديثات الفورية
  Stream<List<MemberNote>> get notesStream => _notesStreamController.stream;
  Stream<MemberNote> get noteUpdateStream => _noteUpdateStreamController.stream;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// ✅ Load all notes for a specific member
  Future<void> loadMemberNotes(String memberId) async {
    // تجنب التحميل المتكرر
    if (_currentMemberId == memberId && _isInitialized && !_isLoading) {
      return;
    }

    _currentMemberId = memberId;
    _setLoading(true);

    try {
      _allNotes = await _dbHelper.getMemberNotes(memberId);
      _organizeNotesByType();
      _isInitialized = true;

      // ✅ إشعار فوري للمستمعين
      _notesStreamController.add(_allNotes);
      notifyListeners();
    } catch (e) {
      _setError('حدث خطأ في تحميل الملاحظات: ${e.toString()}');
      debugPrint('Error loading member notes: $e');
    }

    _setLoading(false);
  }

  /// Reset provider when changing members
  void resetProvider() {
    _isInitialized = false;
    _currentMemberId = '';
    _allNotes.clear();
    _notesByType.clear();
    _error = null;
    notifyListeners();
  }

  void _organizeNotesByType() {
    _notesByType = {
      'general': [],
      'performance': [],
      'behavior': [],
      'health': [],
    };

    for (var note in _allNotes) {
      if (_notesByType.containsKey(note.noteType)) {
        _notesByType[note.noteType]!.add(note);
      }
    }
  }

  /// ✅ Add note with immediate UI update
  Future<void> addNote(MemberNote note) async {
    // ✅ Optimistic Update - إضافة فورية للواجهة
    _allNotes.add(note);
    _organizeNotesByType();
    _noteUpdateStreamController.add(note);
    _notesStreamController.add(_allNotes);
    notifyListeners();

    try {
      await _dbHelper.createMemberNote(note);
    } catch (e) {
      // ✅ في حالة الفشل، إزالة الملاحظة
      _allNotes.removeWhere((n) => n.id == note.id);
      _organizeNotesByType();
      _setError('حدث خطأ في إضافة الملاحظة: ${e.toString()}');
      debugPrint('Error adding note: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// ✅ Update note with immediate UI update
  Future<void> updateNote(MemberNote note) async {
    // ✅ Optimistic Update
    final index = _allNotes.indexWhere((n) => n.id == note.id);
    MemberNote? originalNote;

    if (index != -1) {
      originalNote = _allNotes[index];
      _allNotes[index] = note;
      _organizeNotesByType();
      _noteUpdateStreamController.add(note);
      _notesStreamController.add(_allNotes);
      notifyListeners();
    }

    try {
      await _dbHelper.updateMemberNote(note);
    } catch (e) {
      // ✅ في حالة الفشل، العودة للحالة السابقة
      if (index != -1 && originalNote != null) {
        _allNotes[index] = originalNote;
        _organizeNotesByType();
        notifyListeners();
      }

      _setError('حدث خطأ في تحديث الملاحظة: ${e.toString()}');
      debugPrint('Error updating note: $e');
      rethrow;
    }
  }

  /// ✅ Delete note with immediate UI update
  Future<void> deleteNote(String noteId) async {
    // ✅ Optimistic Update - حذف فوري من الواجهة
    final originalIndex = _allNotes.indexWhere((n) => n.id == noteId);
    MemberNote? originalNote;

    if (originalIndex != -1) {
      originalNote = _allNotes.removeAt(originalIndex);
      _organizeNotesByType();
      _notesStreamController.add(_allNotes);
      notifyListeners();
    }

    try {
      await _dbHelper.deleteMemberNote(noteId);
    } catch (e) {
      // ✅ في حالة الفشل، إعادة الملاحظة
      if (originalIndex != -1 && originalNote != null) {
        _allNotes.insert(originalIndex, originalNote);
        _organizeNotesByType();
        notifyListeners();
      }

      _setError('حدث خطأ في حذف الملاحظة: ${e.toString()}');
      debugPrint('Error deleting note: $e');
      rethrow;
    }
  }

  /// Helper methods
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

  /// Utility methods
  List<MemberNote> getNotesByType(String type) {
    return _notesByType[type] ?? [];
  }

  List<MemberNote> getHighPriorityNotes() {
    return _allNotes.where((note) => note.priority == 'high').toList();
  }

  int getNotesCountByType(String type) {
    return _notesByType[type]?.length ?? 0;
  }

  List<MemberNote> getRecentNotes() {
    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _allNotes.where((note) => note.createdAt.isAfter(oneWeekAgo)).toList();
  }

  @override
  void dispose() {
    _notesStreamController.close();
    _noteUpdateStreamController.close();
    super.dispose();
  }
}