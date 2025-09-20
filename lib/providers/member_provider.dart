import 'package:flutter/foundation.dart';
import '../data/models/member.dart';
import '../data/database/db_helper.dart';

class MemberProvider extends ChangeNotifier {
  List<Member> _members = [];
  bool _isLoading = false;

  List<Member> get members => _members;
  bool get isLoading => _isLoading;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> loadTeamMembers(String teamId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _members = await _dbHelper.getTeamMembers(teamId);

      // Calculate progress for each member
      for (int i = 0; i < _members.length; i++) {
        final progress = await _dbHelper.getMemberOverallProgress(int.parse(_members[i].id));
        _members[i] = _members[i].copyWith(overallProgress: progress);
      }
    } catch (e) {
      debugPrint('Error loading members: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String> addMember(Member member) async {
    final id = await _dbHelper.createMember(member);
    await loadTeamMembers(member.teamId!);
    return id;
  }

  Future<void> updateMember(Member member) async {
    await _dbHelper.updateMember(member);
    await loadTeamMembers(member.teamId!);
  }

  Future<void> deleteMember(String id, String teamId) async {
    await _dbHelper.deleteMember(id);
    await loadTeamMembers(teamId);
  }
}

/// MemberLibraryProvider
class MemberLibraryProvider extends ChangeNotifier {
  List<Member> _globalMembers = [];
  List<Member> _filteredMembers = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Member> get globalMembers =>
      _filteredMembers.isEmpty ? _globalMembers : _filteredMembers;
  bool get isLoading => _isLoading;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  MemberLibraryProvider() {
    loadGlobalMembers();
  }

  Future<void> loadGlobalMembers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _globalMembers = await _dbHelper.getGlobalMembers();
      _applyFilters();
    } catch (e) {
      debugPrint('Error loading global members: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String> createGlobalMember(Member member) async {
    final globalMember = member.copyWith(isGlobal: true, teamId: null);
    final id = await _dbHelper.createMember(globalMember);
    await loadGlobalMembers();
    return id;
  }

  Future<void> updateGlobalMember(Member member) async {
    await _dbHelper.updateMember(member.copyWith(isGlobal: true));
    await loadGlobalMembers();
  }

  Future<void> deleteGlobalMember(String id) async {
    await _dbHelper.deleteMember(id);
    await loadGlobalMembers();
  }

  void searchMembers(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    if (_searchQuery.isEmpty) {
      _filteredMembers = _globalMembers;
    } else {
      _filteredMembers = _globalMembers
          .where((m) =>
      m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.level.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  List<Member> getMembersByAgeRange(int minAge, int maxAge) {
    return _globalMembers
        .where((m) => m.age >= minAge && m.age <= maxAge)
        .toList();
  }

  List<Member> getMembersByLevel(String level) {
    return _globalMembers.where((m) => m.level == level).toList();
  }
}