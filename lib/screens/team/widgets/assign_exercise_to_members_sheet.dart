import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/core/widgets/loading_widget.dart';
import 'package:itqan_gym/core/widgets/full_screen_media_viewer.dart';
import 'package:itqan_gym/core/widgets/video_player_widget.dart';
import 'package:itqan_gym/data/models/member/member.dart';
import 'package:itqan_gym/providers/exercise_assignment_provider.dart';
import 'package:itqan_gym/providers/member_provider.dart';
import 'package:provider/provider.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import '../../../data/models/exercise_template.dart';
import '../team_detailes/team_detail_screen.dart';

class AssignExerciseToMembersSheet extends StatefulWidget {
  final ExerciseTemplate exercise;
  final String teamId;

  const AssignExerciseToMembersSheet({
    super.key,
    required this.exercise,
    required this.teamId,
  });

  static Future<bool?> show(BuildContext context, ExerciseTemplate exercise, String teamId) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AssignExerciseToMembersSheet(
        exercise: exercise,
        teamId: teamId,
      ),
    );
  }

  @override
  State<AssignExerciseToMembersSheet> createState() => _AssignExerciseToMembersSheetState();
}

class _AssignExerciseToMembersSheetState extends State<AssignExerciseToMembersSheet> with SingleTickerProviderStateMixin {
  final Set<String> _selectedMemberIds = {};
  List<Member> _availableMembers = [];
  List<Member> _assignedMembers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _loadMembers();
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    try {
      final memberProvider = Provider.of<MemberProvider>(context, listen: false);
      final exerciseProvider = Provider.of<ExerciseAssignmentProvider>(context, listen: false);
      await memberProvider.loadTeamMembers(widget.teamId);
      final teamMembers = memberProvider.members;
      final assignedMemberIds = await exerciseProvider.getExerciseAssignedMemberIds(widget.exercise.id);
      setState(() {
        _assignedMembers = teamMembers.where((m) => assignedMemberIds.contains(m.id)).toList();
        _availableMembers = teamMembers.where((m) => !assignedMemberIds.contains(m.id)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).errorLoadingData,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            margin: EdgeInsets.all(16.w),
          ),
        );
      }
    }
  }

  List<Member> get _filteredMembers {
    if (_searchQuery.isEmpty) return _availableMembers;
    final q = _searchQuery.toLowerCase();
    return _availableMembers.where((m) {
      final name = m.name.toLowerCase();
      final level = (m.level ?? '').toLowerCase();
      return name.contains(q) || level.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            // Header
            _buildHeader(theme, colorScheme, l10n),
            // Search Bar
            _buildSearchBar(theme, colorScheme, l10n),
            // Content
            Expanded(
              child: _isLoading
                  ? const LoadingSpinner()
                  : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_assignedMembers.isNotEmpty) ...[
                      _buildSectionTitle(
                        l10n.assignedMembers(_assignedMembers.length),
                        Icons.check_circle_rounded,
                        theme,
                        colorScheme,
                      ),
                      SizedBox(height: 8.h),
                      ..._assignedMembers.map((m) => _buildAssignedMemberCard(m, theme, colorScheme, l10n)),
                      SizedBox(height: 20.h),
                    ],
                    if (_filteredMembers.isNotEmpty) ...[
                      _buildSectionTitle(
                        l10n.members,
                        Icons.people_rounded,
                        theme,
                        colorScheme,
                        action: _selectedMemberIds.isNotEmpty
                            ? Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            l10n.memberCount(_selectedMemberIds.length),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                            : null,
                      ),
                      SizedBox(height: 8.h),
                      ..._filteredMembers.map((m) => _buildMemberSelectionCard(m, theme, colorScheme, l10n)),
                    ] else
                      _buildEmptyState(theme, colorScheme, l10n),
                  ],
                ),
              ),
            ),
            // Bottom Actions
            _buildBottomActions(theme, colorScheme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.assignment_ind_rounded,
              color: colorScheme.primary,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.assignMembers,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.exercise.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: l10n.searchForMember,
          prefixIcon: Icon(Icons.search_rounded, color: colorScheme.onSurfaceVariant),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear_rounded, color: colorScheme.onSurfaceVariant),
            onPressed: () => setState(() {
              _searchController.clear();
              _searchQuery = '';
            }),
          )
              : null,
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
        style: TextStyle(fontSize: 14.sp, color: colorScheme.onSurface),
        textInputAction: TextInputAction.search,
        keyboardType: TextInputType.text,
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, ThemeData theme, ColorScheme colorScheme, {Widget? action}) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
            size: 18.sp,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (action != null) ...[
          SizedBox(width: 8.w),
          action,
        ],
      ],
    );
  }

  Widget _buildAssignedMemberCard(Member member, ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.secondary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.secondary.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: colorScheme.secondary.withOpacity(0.2),
            child: Text(
              member.name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: colorScheme.secondary,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: colorScheme.secondary,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_rounded, size: 14.sp, color: colorScheme.onSecondary),
                SizedBox(width: 4.w),
                Text(
                  l10n.assigned,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: colorScheme.onSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: colorScheme.error,
              size: 20.sp,
            ),
            onPressed: () => _showUnassignConfirmation(member, l10n),
            padding: EdgeInsets.all(4.w),
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildMemberSelectionCard(Member member, ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    final isSelected = _selectedMemberIds.contains(member.id);
    return GestureDetector(
      onTap: () => setState(() {
        isSelected ? _selectedMemberIds.remove(member.id) : _selectedMemberIds.add(member.id);
      }),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer.withOpacity(0.1) : colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(isSelected ? 0.1 : 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: isSelected ? colorScheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(
                  color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check_rounded, size: 16.sp, color: colorScheme.onPrimary)
                  : null,
            ),
            SizedBox(width: 12.w),
            CircleAvatar(
              radius: 20.r,
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              child: Text(
                member.name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Text(
                        l10n.yearsOld(member.age),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12.sp,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if ((member.level ?? '').isNotEmpty) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: _getLevelColor(member.level!).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            member.level!,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: _getLevelColor(member.level!),
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if ((member.overallProgress ?? 0) > 0)
              SizedBox(
                width: 50.w,
                height: 50.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: (member.overallProgress ?? 0) / 100,
                      backgroundColor: colorScheme.outline.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                      strokeWidth: 3,
                    ),
                    Text(
                      '${(member.overallProgress ?? 0).toInt()}%',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(32.w),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 64.sp,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            SizedBox(height: 16.h),
            Text(
              _searchQuery.isNotEmpty ? l10n.noMembersInLibrary : l10n.noMembersAssigned,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 16.sp,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.onSurfaceVariant,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  side: BorderSide(color: colorScheme.outline),
                ),
                child: Text(
                  l10n.cancel,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: FilledButton(
                onPressed: _selectedMemberIds.isEmpty ? null : _assignExercise,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text(
                  _selectedMemberIds.isEmpty ? l10n.members : l10n.assignedMembers(_selectedMemberIds.length),
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showUnassignConfirmation(Member member, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          l10n.delete,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        content: Text(
          l10n.deleteExerciseConfirmation(member.name),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(l10n.confirmDelete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _unassignExercise(member,l10n);
    }
  }

  Future<void> _unassignExercise(Member member,l10n) async {
    try {
      final provider = Provider.of<ExerciseAssignmentProvider>(context, listen: false);
      await provider.unassignExerciseFromMember(member.id, widget.exercise.id);
      await _loadMembers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.exerciseUnassigned(member.name),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            margin: EdgeInsets.all(16.w),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.errorUnassigning(e.toString()),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            margin: EdgeInsets.all(16.w),
          ),
        );
      }
    }
  }

  Future<void> _assignExercise() async {
    try {
      final provider = Provider.of<ExerciseAssignmentProvider>(context, listen: false);
      await provider.assignExerciseToMembers(widget.exercise.id, _selectedMemberIds.toList());
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'exercise Assigned successfully',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            margin: EdgeInsets.all(16.w),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error Assigning Error: $e',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            margin: EdgeInsets.all(16.w),
          ),
        );
      }
    }
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'مبتدئ':
        return ColorsManager.secondaryColor;
      case 'متوسط':
        return ColorsManager.primaryColor;
      case 'متقدم':
        return ColorsManager.errorFill;
      default:
        return ColorsManager.defaultTextSecondary;
    }
  }
}