import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' show AdWidget, AdSize;
import 'package:itqan_gym/core/services/ad_service.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/widgets/ads_widgets/banner_ad_widget.dart';
import 'package:itqan_gym/core/widgets/app_text_feild.dart';
import 'package:itqan_gym/core/widgets/loading_widget.dart';
import 'package:itqan_gym/data/database/db_helper.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../data/models/member/member.dart';
import '../../../data/models/team.dart';
import '../../../providers/team_provider.dart';
import '../../member/widgets/editInfo_notice.dart';

class TeamMembersManager extends StatefulWidget {
  final Team team;

  const TeamMembersManager({super.key, required this.team});

  @override
  State<TeamMembersManager> createState() => _TeamMembersManagerState();
}

class _TeamMembersManagerState extends State<TeamMembersManager> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Load banner only after AdsService is fully initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AdsService.instance.loadBannerAd(context);
      }
    });
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _loadTeamMembers();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadTeamMembers() {
    context.read<TeamProvider>().loadTeamMembers(widget.team.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Consumer<TeamProvider>(
        builder: (context, teamProvider, child) {
          if (teamProvider.isLoading) {
            return _buildLoadingState(theme, colorScheme, l10n);
          }
          if (teamProvider.teamMembers.isEmpty) {
            return _buildEmptyState(theme, colorScheme, l10n);
          }
          return _buildMembersList(teamProvider.teamMembers, theme, colorScheme, l10n);
        },
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            strokeWidth: 3,
          ),
          SizedBox(height: 16.h),
          Text(
            l10n.loadingMembers,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 16.sp,
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.group_add_rounded,
                size: 64.sp,
                color: colorScheme.primary,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              l10n.noMembersInLibrary,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.addMember,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _showAddMembersDialog,
                icon: Icon(Icons.library_add_rounded, size: 24.sp),
                label: Text(
                  l10n.addMemberToLibrary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersList(List<Member> members, ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    return Column(
      children: [
        ListenableBuilder(
          listenable: AdsService.instance,
          builder: (context, _) {
            // Wait for initialization
            if (!AdsService.instance.isInitialized) {
              return SizedBox(height: AdSize.banner.height.toDouble());
            }

            // Premium user - no ads
            if (AdsService.instance.isPremium) {
              return const SizedBox.shrink();
            }

            // Non-premium - show banner
            return const BannerAdWidget();
          },
        ),
        // Add Members Button
        Padding(
          padding: EdgeInsets.all(SizeApp.padding),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showAddMembersDialog,
                  icon: Icon(Icons.add, size: 24.sp),
                  label: Text(
                    l10n.addMemberToLibrary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(color: colorScheme.primary),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Members Count
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary.withOpacity(0.1),
                colorScheme.primary.withOpacity(0.05),
              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.teamMembers,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${members.length}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Members List
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.onSurface.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(12.w),
                  leading: CircleAvatar(
                    radius: 24.r,
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    backgroundImage: member.photoPath != null
                        ? FileImage(File(member.photoPath!))
                        : null,
                    child: member.photoPath == null
                        ? Text(
                      member.name.isNotEmpty ? member.name[0].toUpperCase() : '',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    )
                        : null,
                  ),
                  title: Text(
                    member.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    onPressed: () => _showRemoveMemberDialog(member, l10n),
                    icon: Icon(
                      Icons.remove_circle_outline_rounded,
                      color: colorScheme.error,
                      size: 24.sp,
                    ),
                    tooltip: l10n.removeFromTeam,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddMembersDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddMembersSheet(team: widget.team),
    ).then((result) {
      if (result == true) {
        _loadTeamMembers();
      }
    });
  }

  void _showRemoveMemberDialog(Member member, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_rounded,
              color: Theme.of(context).colorScheme.error,
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              l10n.delete,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.error,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        content: Text(
          l10n.deleteMemberConfirmation(member.name),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 14.sp,
            height: 1.4,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => _removeMember(member,l10n),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              l10n.remove,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onError,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _removeMember(Member member,l10n) async {
    Navigator.pop(context); // Close dialog
    final teamProvider = context.read<TeamProvider>();
    final success = await teamProvider.removeMemberFromTeam(widget.team.id, member.id);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.deleteMemberConfirmation(member.name),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            margin: EdgeInsets.all(16.w),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              teamProvider.errorMessage ?? l10n.errorRemovingMember,
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
}

class _AddMembersSheet extends StatefulWidget {
  final Team team;

  const _AddMembersSheet({required this.team});

  @override
  State<_AddMembersSheet> createState() => _AddMembersSheetState();
}

class _AddMembersSheetState extends State<_AddMembersSheet> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = {};
  List<Member> _allMembers = [];
  List<Member> _filteredMembers = [];
  List<Member> _currentTeamMembers = [];
  bool _isLoading = true;
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
    final db = DatabaseHelper.instance;
    final allMembers = await db.getAllMembers();
    final teamMembers = await db.getTeamMembers(widget.team.id);
    final teamMemberIds = teamMembers.map((m) => m.id).toSet();
    final availableMembers = allMembers.where((m) => !teamMemberIds.contains(m.id)).toList();
    setState(() {
      _allMembers = availableMembers;
      _filteredMembers = availableMembers;
      _currentTeamMembers = teamMembers;
      _isLoading = false;
    });
  }

  void _applyFilter(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      _filteredMembers = q.isEmpty
          ? _allMembers
          : _allMembers.where((m) => m.name.toLowerCase().contains(q) || (m.level ?? '').toLowerCase().contains(q)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
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
            SizedBox(height: 12.h),
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.library_add_rounded,
                      color: colorScheme.primary,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      l10n.addMemberToLibrary,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            // Search Field
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: AppTextFieldFactory.search(
                controller: _searchController,
                hintText: l10n.searchForMember,
                onChanged: _applyFilter,
                prefixIcon: Icon(Icons.search_rounded, color: colorScheme.onSurfaceVariant),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: colorScheme.onSurfaceVariant),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _applyFilter('');
                    });
                  },
                )
                    : null,
                fillColor: colorScheme.surfaceContainerHighest,
                borderRadius: 12.r,
              ),
            ),
            SizedBox(height: 12.h),
            // Content
            Expanded(
              child: _isLoading ? _buildLoadingState(theme, colorScheme, l10n) : _buildContent(theme, colorScheme, l10n),
            ),
            // Bottom Action Buttons
            _buildBottomButtons(theme, colorScheme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
        strokeWidth: 3,
      ),
    );
  }

  Widget _buildContent(ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    if (_filteredMembers.isEmpty) {
      return _buildEmptyState(theme, colorScheme, l10n);
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: _filteredMembers.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: colorScheme.outlineVariant.withOpacity(0.3),
      ),
      itemBuilder: (context, index) {
        final member = _filteredMembers[index];
        final isSelected = _selectedIds.contains(member.id);

        return CheckboxListTile(
          value: isSelected,
          onChanged: (_) {
            setState(() {
              if (isSelected) {
                _selectedIds.remove(member.id);
              } else {
                _selectedIds.add(member.id);
              }
            });
          },
          title: Text(
            member.name,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          secondary: CircleAvatar(
            backgroundColor: colorScheme.primary.withOpacity(0.1),
            backgroundImage: member.photoPath != null ? FileImage(File(member.photoPath!)) : null,
            child: member.photoPath == null
                ? Text(
              member.name.isNotEmpty ? member.name[0].toUpperCase() : '',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            )
                : null,
          ),
          activeColor: colorScheme.primary,
          checkColor: colorScheme.onPrimary,
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _allMembers.isEmpty ? Icons.group_add_rounded : Icons.search_off_rounded,
            size: 64.sp,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            _allMembers.isEmpty ? l10n.noMembersInLibrary : l10n.notFound,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (_allMembers.isEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              l10n.noMembersInLibrary,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomButtons(ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.3),
          ),
        ),
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
                  side: BorderSide(
                    color: colorScheme.outline.withOpacity(0.5),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  l10n.cancel,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: FilledButton.icon(
                onPressed: _selectedIds.isEmpty ? null : _addSelectedMembers,
                icon: Icon(Icons.check_rounded, size: 24.sp),
                label: Text(
                  l10n.memberCount(_selectedIds.length),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addSelectedMembers() async {
    if (_selectedIds.isEmpty) return;
    final teamProvider = context.read<TeamProvider>();
    final success = await teamProvider.addMembersToTeam(widget.team.id, _selectedIds.toList());
    if (mounted) {
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'added ${_selectedIds.length} members',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            margin: EdgeInsets.all(16.w),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              teamProvider.errorMessage ?? 'error',
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
}