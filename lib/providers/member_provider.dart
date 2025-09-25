import 'dart:developer';

import 'package:flutter/foundation.dart';
import '../data/models/member/member.dart';
import '../data/models/member/member_notes.dart';
import '../data/database/db_helper.dart';

/// Main Member Provider for team-specific members
class MemberProvider extends ChangeNotifier {
  List<Member> _members = [];
  bool _isLoading = false;
  String? _error;

  List<Member> get members => _members;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Load all members for a specific team
  Future<void> loadTeamMembers(String teamId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get both direct team members and assigned global members
      final directMembers = await _dbHelper.getTeamMembers(teamId);
      final assignedMembers = await _dbHelper.getTeamAssignedMembers(teamId);

      // Combine and remove duplicates
      final allMembers = <String, Member>{};

      for (final member in directMembers) {
        allMembers[member.id] = member;
      }

      for (final member in assignedMembers) {
        allMembers[member.id] = member;
      }

      _members = allMembers.values.toList();

      // Calculate progress for each member
      for (int i = 0; i < _members.length; i++) {
        final progress = await _dbHelper.getMemberOverallProgress(_members[i].id);
        _members[i] = _members[i].copyWith(overallProgress: progress);
      }
    } catch (e) {
      _error = 'حدث خطأ في تحميل الأعضاء: ${e.toString()}';
      debugPrint('Error loading team members: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Add new member to team
  Future<String> addMember(Member member) async {
    try {
      final id = await _dbHelper.createMember(member);
      await loadTeamMembers(member.teamId!);
      return id;
    } catch (e) {
      _error = 'حدث خطأ في إضافة العضو: ${e.toString()}';
      debugPrint('Error adding member: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Update existing member
  Future<void> updateMember(Member member) async {
    try {
      await _dbHelper.updateMember(member);
      await loadTeamMembers(member.teamId!);
    } catch (e) {
      _error = 'حدث خطأ في تحديث العضو: ${e.toString()}';
      debugPrint('Error updating member: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Delete member (من شاشة الفريق)
  Future<void> deleteMember(String id, String teamId) async {
    try {
      // هات العضو الحالي لتقرير هل هو global ولا لا
      final member = _members.firstWhere((m) => m.id == id, orElse: () => throw Exception('Member not in provider list'));

      if (member.isGlobal) {
        // في سياق شاشة فريق: الأفضل "إلغاء تعيين" فقط
        final unassigned = await _dbHelper.unassignMemberFromTeam(teamId, id);
        if (unassigned == 0) {
          // لو مش متعين أصلًا لهذا الفريق، نقدر نقرر نحذفه نهائيًا أو نتجاهل
          // هنا نتركه بدون حذف نهائي لحماية الفرق الأخرى
          debugPrint('Member was not assigned to this team.');
        }
      } else {
        // عضو فريق عادي (ليس global): احذفه نهائيًا
        await _dbHelper.hardDeleteMember(id);
      }

      await loadTeamMembers(teamId);
    } catch (e) {
      _error = 'حدث خطأ في حذف العضو: ${e.toString()}';
      debugPrint('Error deleting member: $e');
      notifyListeners();
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
}

/// Global Members Library Provider
class MemberLibraryProvider extends ChangeNotifier {
  List<Member> _globalMembers = [];
  List<Member> _filteredMembers = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _error;

  List<Member> get globalMembers =>
      _filteredMembers.isEmpty && _searchQuery.isEmpty ? _globalMembers : _filteredMembers;
  List<Member> get allGlobalMembers => _globalMembers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  MemberLibraryProvider() {
    loadGlobalMembers();
  }

  /// Load all global members
  Future<void> loadGlobalMembers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _globalMembers = await _dbHelper.getGlobalMembers();

      // Calculate progress for each member
      for (int i = 0; i < _globalMembers.length; i++) {
        final progress = await _dbHelper.getMemberOverallProgress(_globalMembers[i].id);
        _globalMembers[i] = _globalMembers[i].copyWith(overallProgress: progress);
      }

      _applyFilters();
    } catch (e) {
      _error = 'حدث خطأ في تحميل المكتبة: ${e.toString()}';
      debugPrint('Error loading global members: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Create new global member
  Future<String> createGlobalMember(Member member) async {
    try {
      final globalMember = member.copyWith(isGlobal: true, teamId: null);
      final id = await _dbHelper.createMember(globalMember);
      await loadGlobalMembers();
      return id;
    } catch (e) {
      _error = 'حدث خطأ في إضافة العضو: ${e.toString()}';
      debugPrint('Error creating global member: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Update global member
  Future<void> updateGlobalMember(Member member) async {
    try {
      await _dbHelper.updateMember(member.copyWith(isGlobal: true));
      await loadGlobalMembers();
    } catch (e) {
      _error = 'حدث خطأ في تحديث العضو: ${e.toString()}';
      debugPrint('Error updating global member: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Delete global member
  Future<void> deleteGlobalMember(String id) async {
    try {
      await _dbHelper.deleteMember(id);
      await loadGlobalMembers();
    } catch (e) {
      _error = 'حدث خطأ في حذف العضو: ${e.toString()}';
      debugPrint('Error deleting global member: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Search members by query
  void searchMembers(String query) {
    _searchQuery = query.trim();
    _applyFilters();
    notifyListeners();
  }

  /// Apply search filters
  void _applyFilters() {
    if (_searchQuery.isEmpty) {
      _filteredMembers = [];
    } else {
      _filteredMembers = _globalMembers
          .where((m) =>
      m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.level.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  /// Get members by age range
  List<Member> getMembersByAgeRange(int minAge, int maxAge) {
    return _globalMembers
        .where((m) => m.age >= minAge && m.age <= maxAge)
        .toList();
  }

  /// Get members by level
  List<Member> getMembersByLevel(String level) {
    return _globalMembers.where((m) => m.level == level).toList();
  }

  /// Get member by ID
  Member? getMemberById(String id) {
    try {
      return _globalMembers.firstWhere((member) => member.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get available members for team assignment (not already assigned)
  List<Member> getAvailableMembersForTeam(String teamId, List<Member> currentTeamMembers) {
    final currentMemberIds = currentTeamMembers.map((m) => m.id).toSet();
    return _globalMembers.where((member) => !currentMemberIds.contains(member.id)).toList();
  }
}

/// Member Notes Provider
class MemberNotesProvider extends ChangeNotifier {
  List<MemberNote> _allNotes = [];
  Map<String, List<MemberNote>> _notesByType = {};
  bool _isLoading = false;
  String? _error;
  String _currentMemberId = '';

  List<MemberNote> get allNotes => _allNotes;
  Map<String, List<MemberNote>> get notesByType => _notesByType;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Load all notes for a specific member
  Future<void> loadMemberNotes(String memberId) async {
    _currentMemberId = memberId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allNotes = await _dbHelper.getMemberNotes(memberId);
      _organizeNotesByType();
    } catch (e) {
      _error = 'حدث خطأ في تحميل الملاحظات: ${e.toString()}';
      debugPrint('Error loading member notes: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Organize notes by type
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

  /// Add new note
  Future<void> addNote(MemberNote note) async {
    try {
      await _dbHelper.createMemberNote(note);
      if (_currentMemberId.isNotEmpty) {
        await loadMemberNotes(_currentMemberId);
      }
    } catch (e) {
      _error = 'حدث خطأ في إضافة الملاحظة: ${e.toString()}';
      debugPrint('Error adding note: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Update existing note
  Future<void> updateNote(MemberNote note) async {
    try {
      await _dbHelper.updateMemberNote(note);
      if (_currentMemberId.isNotEmpty) {
        await loadMemberNotes(_currentMemberId);
      }
    } catch (e) {
      _error = 'حدث خطأ في تحديث الملاحظة: ${e.toString()}';
      debugPrint('Error updating note: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Delete note
  Future<void> deleteNote(String noteId) async {
    try {
      await _dbHelper.deleteMemberNote(noteId);
      if (_currentMemberId.isNotEmpty) {
        await loadMemberNotes(_currentMemberId);
      }
    } catch (e) {
      _error = 'حدث خطأ في حذف الملاحظة: ${e.toString()}';
      debugPrint('Error deleting note: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Get notes by type
  List<MemberNote> getNotesByType(String type) {
    return _notesByType[type] ?? [];
  }

  /// Get high priority notes
  List<MemberNote> getHighPriorityNotes() {
    return _allNotes.where((note) => note.priority == 'high').toList();
  }

  /// Get notes count by type
  int getNotesCountByType(String type) {
    return _notesByType[type]?.length ?? 0;
  }

  /// Get recent notes (within last week)
  List<MemberNote> getRecentNotes() {
    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _allNotes.where((note) => note.createdAt.isAfter(oneWeekAgo)).toList();
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}