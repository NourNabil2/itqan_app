import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:itqan_gym/core/assets/assets_manager.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/widgets/ads_widgets/banner_ad_widget.dart';
import 'package:itqan_gym/core/widgets/app_text_feild.dart';
import 'package:itqan_gym/core/widgets/custom_app_bar.dart';
import 'package:itqan_gym/core/widgets/empty_state_widget.dart';
import 'package:itqan_gym/core/widgets/error_container_widget.dart';
import 'package:itqan_gym/core/widgets/section_header.dart';
import 'package:provider/provider.dart';
import '../../core/services/ad_service.dart' show AdsService;
import '../../core/utils/enums.dart';
import '../../data/models/team.dart';
import '../../data/models/exercise_template.dart';
import '../../data/models/skill_template.dart';
import '../../providers/exercise_library_provider.dart';
import '../../providers/skill_library_provider.dart';
import '../../providers/team_provider.dart';

class ManageAssignmentsScreen extends StatefulWidget {
  final Team team;

  const ManageAssignmentsScreen({super.key, required this.team});

  @override
  State<ManageAssignmentsScreen> createState() => _ManageAssignmentsScreenState();
}

class _ManageAssignmentsScreenState extends State<ManageAssignmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _selectedExercises = {};
  final Set<String> _selectedSkills = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<AssignmentTab> get _tabs => [
    AssignmentTab(
      title: ExerciseType.warmup.getLocalizedName(context),
      icon: Icons.whatshot_rounded,
      exerciseType: ExerciseType.warmup,
      color: const Color(0xFFFF5722),
    ),
    AssignmentTab(
      title: ExerciseType.stretching.getLocalizedName(context),
      icon: Icons.accessibility_new_rounded,
      exerciseType: ExerciseType.stretching,
      color: const Color(0xFF4CAF50),
    ),
    AssignmentTab(
      title: ExerciseType.conditioning.getLocalizedName(context),
      icon: Icons.fitness_center_rounded,
      exerciseType: ExerciseType.conditioning,
      color: const Color(0xFF2196F3),
    ),
    AssignmentTab(
      title: AppLocalizations.of(context).skills,
      icon: Icons.star_rounded,
      color: const Color(0xFF9C27B0),
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Load banner only after AdsService is fully initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AdsService.instance.loadBannerAd(context);
      }
    });
    _tabController = TabController(length: 4, vsync: this);
    _loadCurrentAssignments();
  }

  void _loadCurrentAssignments() async {
    final teamProvider = Provider.of<TeamProvider>(context, listen: false);
    await teamProvider.loadTeamContent(widget.team.id);

    setState(() {
      _selectedExercises.addAll(
        teamProvider.teamExercises.map((e) => e.id),
      );
      _selectedSkills.addAll(
        teamProvider.teamSkills.map((s) => s.id),
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: widget.team.name,
        action: _buildSaveButton(),
      ),

      // ✅ خلي البانر هنا بدل الـ Column
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.only(
          bottom: SizeApp.s8,
          left: SizeApp.s8,
          right: SizeApp.s8,
        ),
        child:ListenableBuilder(
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
      ),

      body: Column(
        children: [
          // Header Section
          SectionHeader(
            title: l10n.assignContentToTeam,
            subtitle: l10n.assignContentDescription(widget.team.name),
            leading: Container(
              padding: EdgeInsets.all(SizeApp.s8),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(SizeApp.s8),
              ),
              child: Icon(
                Icons.assignment_rounded,
                color: theme.primaryColor,
                size: SizeApp.iconSize,
              ),
            ),
            padding: EdgeInsets.all(SizeApp.s16),
            showDivider: true,
          ),

          // Error Display
          if (_errorMessage != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SizeApp.s16),
              child: ErrorContainer(
                generalError: _errorMessage,
                errorIcon: Icons.error_outline_rounded,
                margin: EdgeInsets.only(bottom: SizeApp.s12),
                padding: EdgeInsets.all(SizeApp.s12),
                borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                showIcon: true,
                errorColor: ColorsManager.errorFill,
                backgroundColor: ColorsManager.errorFill.withOpacity(0.1),
                borderColor: ColorsManager.errorFill.withOpacity(0.3),
              ),
            ),

          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeApp.s16,
              vertical: SizeApp.s8,
            ),
            child: AppTextFieldFactory.search(
              hintText: l10n.searchInContent,
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              fillColor: theme.cardColor,
              focusedFillColor: theme.cardColor,
              borderRadius: SizeApp.radiusSmall,
              contentPadding: EdgeInsets.symmetric(
                horizontal: SizeApp.s16,
                vertical: SizeApp.s12,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                icon: Icon(
                  Icons.clear_rounded,
                  color: theme.iconTheme.color?.withOpacity(0.6),
                  size: 20.sp,
                ),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
              )
                  : null,
            ),
          ),

          // Tab Bar
          _buildTabBar(),

          // Selected Count Banner (لو عندك بار صغير بيعرض عدد العناصر)
          _buildSelectedCountBanner(),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildExerciseList(ExerciseType.warmup),
                _buildExerciseList(ExerciseType.stretching),
                _buildExerciseList(ExerciseType.conditioning),
                _buildSkillsList(),
              ],
            ),
          ),
        ],
      ),
    );

  }

  Widget _buildSaveButton() {
    final l10n = AppLocalizations.of(context);

    return TextButton.icon(
      onPressed: _isLoading ? null : _saveAssignments,
      icon: _isLoading
          ? SizedBox(
        width: 16.w,
        height: 16.h,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      )
          : Icon(Icons.check_rounded, size: SizeApp.iconSize),
      label: Text(
        _isLoading ? l10n.saving : l10n.save,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14.sp,
        ),
      ),
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: ColorsManager.primaryColor,
        padding: EdgeInsets.symmetric(
          horizontal: SizeApp.s16,
          vertical: SizeApp.s8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final theme = Theme.of(context);

    return TabBar(
      controller: _tabController,
      isScrollable: true, // ✅ مهم لمنع الزحمة والـ overflow
      labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelColor: theme.primaryColor,
      unselectedLabelColor: theme.textTheme.bodySmall?.color,
      indicatorColor: theme.primaryColor,
      indicatorWeight: 3,
      labelStyle: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
      ),
      tabs: _tabs.map((tab) {
        return Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(tab.icon, size: 16.sp),
              SizedBox(width: SizeApp.s4),
              Flexible(
                child: Text(
                  tab.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis, // ✅ يمنع الـ overflow
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }


  Widget _buildSelectedCountBanner() {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final totalSelected = _selectedExercises.length + _selectedSkills.length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: totalSelected > 0
          ? theme.primaryColor.withOpacity(0.1)
          : theme.cardColor,
      padding: EdgeInsets.symmetric(
        horizontal: SizeApp.s16,
        vertical: SizeApp.s12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.checklist_rounded,
                color: theme.primaryColor,
                size: 16.sp,
              ),
              SizedBox(width: SizeApp.s8),
              Text(
                l10n.selectedItems,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeApp.s12,
              vertical: SizeApp.s4,
            ),
            decoration: BoxDecoration(
              color: totalSelected > 0
                  ? theme.primaryColor
                  : theme.iconTheme.color?.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '$totalSelected',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList(ExerciseType type) {
    final l10n = AppLocalizations.of(context);

    return Consumer<ExerciseLibraryProvider>(
      builder: (context, provider, child) {
        final exercises = provider.getExercisesByType(type);
        final tabColor = _tabs.firstWhere((tab) => tab.exerciseType == type).color;

        final filteredExercises = _searchQuery.isEmpty
            ? exercises
            : exercises.where((e) =>
        e.title.toLowerCase().contains(_searchQuery) ||
            (e.description?.toLowerCase().contains(_searchQuery) ?? false)
        ).toList();

        if (filteredExercises.isEmpty) {
          return EmptyStateWidget(
            title: _searchQuery.isNotEmpty
                ? l10n.noResultsFound
                : l10n.noExercisesInCategory(type.getLocalizedName(context)),
            subtitle: _searchQuery.isNotEmpty
                ? l10n.tryDifferentKeywords
                : l10n.addNewFromLibrary,
            buttonText: l10n.addExercise,
            onPressed: () => Navigator.pop(context),
            assetSvgPath: _getAssetForExerciseType(type),
            buttonIcon: Icons.add_rounded,
            circleSize: 100,
            iconSize: 50,
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(SizeApp.s16),
          itemCount: filteredExercises.length,
          itemBuilder: (context, index) {
            final exercise = filteredExercises[index];
            final isSelected = _selectedExercises.contains(exercise.id);
            return _buildExerciseCard(exercise, isSelected, tabColor);
          },
        );
      },
    );
  }

  Widget _buildSkillsList() {
    final l10n = AppLocalizations.of(context);

    return Consumer<SkillLibraryProvider>(
      builder: (context, provider, child) {
        final skills = provider.skills;

        final filteredSkills = _searchQuery.isEmpty
            ? skills
            : skills.where((s) =>
        s.skillName.toLowerCase().contains(_searchQuery) ||
            s.apparatus.getLocalizedName(context).toLowerCase().contains(_searchQuery)
        ).toList();

        if (filteredSkills.isEmpty) {
          return EmptyStateWidget(
            title: _searchQuery.isNotEmpty
                ? l10n.noResultsFound
                : l10n.noSkillsAvailable,
            subtitle: _searchQuery.isNotEmpty
                ? l10n.tryDifferentKeywords
                : l10n.addNewFromLibrary,
            buttonText: l10n.addSkill,
            onPressed: () => Navigator.pop(context),
            assetSvgPath: AssetsManager.iconsGymnastEx2,
            buttonIcon: Icons.add_rounded,
            circleSize: 100,
            iconSize: 50,
          );
        }

        final skillsByApparatus = <Apparatus, List<SkillTemplate>>{};
        for (final skill in filteredSkills) {
          skillsByApparatus.putIfAbsent(skill.apparatus, () => []).add(skill);
        }

        return ListView.builder(
          padding: EdgeInsets.all(SizeApp.s16),
          itemCount: skillsByApparatus.length,
          itemBuilder: (context, index) {
            final apparatus = skillsByApparatus.keys.elementAt(index);
            final apparatusSkills = skillsByApparatus[apparatus]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(
                    bottom: SizeApp.s12,
                    top: index == 0 ? 0 : SizeApp.s20,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeApp.s12,
                    vertical: SizeApp.s8,
                  ),
                  decoration: BoxDecoration(
                    color: getApparatusColor(apparatus).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        getApparatusIcon(apparatus),
                        color: getApparatusColor(apparatus),
                        size: 16.sp,
                      ),
                      SizedBox(width: SizeApp.s8),
                      Text(
                        apparatus.getLocalizedName(context),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: getApparatusColor(apparatus),
                        ),
                      ),
                    ],
                  ),
                ),
                ...apparatusSkills.map((skill) {
                  final isSelected = _selectedSkills.contains(skill.id);
                  return _buildSkillCard(skill, isSelected);
                }),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildExerciseCard(ExerciseTemplate exercise, bool isSelected, Color accentColor) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s12),
      decoration: BoxDecoration(
        color: isSelected ? accentColor.withOpacity(0.05) : theme.cardColor,
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        border: Border.all(
          color: isSelected
              ? accentColor.withOpacity(0.3)
              : theme.dividerColor.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (value) {
          setState(() {
            if (value == true) {
              _selectedExercises.add(exercise.id);
            } else {
              _selectedExercises.remove(exercise.id);
            }
          });
        },
        contentPadding: EdgeInsets.all(SizeApp.s12),
        title: Text(
          exercise.title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: exercise.description != null
            ? Padding(
          padding: EdgeInsets.only(top: SizeApp.s4),
          child: Text(
            exercise.description!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              height: 1.3,
            ),
          ),
        )
            : null,
        secondary: Container(
          width: 48.w,
          height: 48.h,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
          ),
          child: Icon(
            _getExerciseIcon(exercise.type),
            color: accentColor,
            size: 24.sp,
          ),
        ),
        activeColor: accentColor,
        checkColor: Colors.white,
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  Widget _buildSkillCard(SkillTemplate skill, bool isSelected) {
    final theme = Theme.of(context);
    final apparatusColor = getApparatusColor(skill.apparatus);

    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s8),
      decoration: BoxDecoration(
        color: isSelected ? apparatusColor.withOpacity(0.05) : theme.cardColor,
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        border: Border.all(
          color: isSelected
              ? apparatusColor.withOpacity(0.3)
              : theme.dividerColor.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (value) {
          setState(() {
            if (value == true) {
              _selectedSkills.add(skill.id);
            } else {
              _selectedSkills.remove(skill.id);
            }
          });
        },
        contentPadding: EdgeInsets.all(SizeApp.s12),
        title: Text(
          skill.skillName,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        secondary: Container(
          width: 48.w,
          height: 48.h,
          decoration: BoxDecoration(
            color: apparatusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
          ),
          child: Icon(
            getApparatusIcon(skill.apparatus),
            color: apparatusColor,
            size: 24.sp,
          ),
        ),
        activeColor: apparatusColor,
        checkColor: Colors.white,
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  IconData _getExerciseIcon(ExerciseType type) {
    switch (type) {
      case ExerciseType.warmup:
        return Icons.whatshot_rounded;
      case ExerciseType.stretching:
        return Icons.accessibility_new_rounded;
      case ExerciseType.conditioning:
        return Icons.fitness_center_rounded;
    }
  }

  String _getAssetForExerciseType(ExerciseType type) {
    switch (type) {
      case ExerciseType.warmup:
        return AssetsManager.iconsGymnastEx1;
      case ExerciseType.stretching:
        return AssetsManager.iconsGymnastEx2;
      case ExerciseType.conditioning:
        return AssetsManager.iconsGymnastEx2;
    }
  }

  Future<void> _saveAssignments() async {
    final l10n = AppLocalizations.of(context);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final teamProvider = Provider.of<TeamProvider>(context, listen: false);

      final exerciseSuccess = await teamProvider.assignExercisesToTeam(
        widget.team.id,
        _selectedExercises.toList(),
      );

      final skillSuccess = await teamProvider.assignSkillsToTeam(
        widget.team.id,
        _selectedSkills.toList(),
      );

      if (exerciseSuccess && skillSuccess) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.assignmentsSavedSuccessfully),
              backgroundColor: ColorsManager.successFill,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
              ),
            ),
          );
        }
      } else {
        throw Exception(teamProvider.errorMessage ?? l10n.errorSavingAssignments);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

class AssignmentTab {
  final String title;
  final IconData icon;
  final ExerciseType? exerciseType;
  final Color color;

  const AssignmentTab({
    required this.title,
    required this.icon,
    required this.color,
    this.exerciseType,
  });
}