import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/core/widgets/full_screen_media_viewer.dart';
import 'package:itqan_gym/core/widgets/video_player_widget.dart';
import 'package:itqan_gym/data/models/member/member.dart';
import 'package:itqan_gym/data/models/skill_template.dart';
import 'package:itqan_gym/providers/exercise_assignment_provider.dart';
import 'package:itqan_gym/screens/team/widgets/assign_exercise_to_members_sheet.dart';
import 'package:provider/provider.dart';
import '../../../data/models/exercise_template.dart';

class ExerciseDetailSheet extends StatefulWidget {
  final ExerciseTemplate exercise;
  final String? teamId;

  const ExerciseDetailSheet({
    super.key,
    required this.exercise,
    this.teamId,
  });

  @override
  State<ExerciseDetailSheet> createState() => _ExerciseDetailSheetState();

  static void show(BuildContext context, ExerciseTemplate exercise, {required String teamId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExerciseDetailSheet(
        exercise: exercise,
        teamId: teamId,
      ),
    );
  }
}

class _ExerciseDetailSheetState extends State<ExerciseDetailSheet> {
  late Future<List<Member>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _membersFuture = Provider.of<ExerciseAssignmentProvider>(context, listen: false)
        .loadExerciseMembers(widget.exercise.id);
  }

  Future<void> _refreshMembers() async {
    setState(() {
      _membersFuture = Provider.of<ExerciseAssignmentProvider>(context, listen: false)
          .loadExerciseMembers(widget.exercise.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.dialogBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(SizeApp.radiusMed),
          topRight: Radius.circular(SizeApp.radiusMed),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: SizeApp.s12),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: theme.dividerColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          _buildHeaderWithActions(context),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(SizeApp.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.teamId != null) _buildAssignedMembersSection(context),
                  if (widget.exercise.hasMedia) _buildMediaSection(),
                  if (widget.exercise.description != null) _buildDescriptionSection(),
                  _buildTypeInfoSection(),
                  _buildStatsSection(),
                ],
              ),
            ),
          ),

          _buildBottomActions(context),
        ],
      ),
    );
  }

  Widget _buildHeaderWithActions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final exerciseColor = _getExerciseColor();

    return Container(
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: exerciseColor.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(SizeApp.radiusMed),
          topRight: Radius.circular(SizeApp.radiusMed),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(SizeApp.s12),
            decoration: BoxDecoration(
              color: exerciseColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(SizeApp.s10),
            ),
            child: Icon(
              _getExerciseIcon(),
              color: exerciseColor,
              size: 24.sp,
            ),
          ),
          SizedBox(width: SizeApp.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.exercise.title,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: exerciseColor,
                  ),
                ),
                SizedBox(height: SizeApp.s4),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeApp.s8,
                    vertical: SizeApp.s4,
                  ),
                  decoration: BoxDecoration(
                    color: exerciseColor,
                    borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                  ),
                  child: Text(
                    widget.exercise.type.getLocalizedName(context),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.teamId != null) ...[
            IconButton(
              onPressed: () => _showAssignmentSheet(context),
              icon: Container(
                padding: EdgeInsets.all(SizeApp.s8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                ),
                child: Icon(
                  Icons.person_add_rounded,
                  color: theme.primaryColor,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAssignedMembersSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return FutureBuilder<List<Member>>(
      future: _membersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingSection();
        }
        final members = snapshot.data ?? const <Member>[];
        if (members.isEmpty) {
          return _buildEmptyMembersSection(context);
        }
        return Container(
          margin: EdgeInsets.only(bottom: SizeApp.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.groups_rounded,
                    color: theme.primaryColor,
                    size: 20.sp,
                  ),
                  SizedBox(width: SizeApp.s8),
                  Text(
                    l10n.assignedMembers(members.length),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _showAssignmentSheet(context),
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline_rounded, size: 16.sp),
                        SizedBox(width: SizeApp.s4),
                        Text(
                          l10n.add,
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: SizeApp.s12),
              SizedBox(
                height: 90.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: members.length,
                  itemBuilder: (context, index) => _buildMemberCard(members[index]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMemberCard(Member member) {
    final theme = Theme.of(context);

    return Container(
      width: 140.w,
      margin: EdgeInsets.only(left: SizeApp.s8),
      padding: EdgeInsets.all(SizeApp.s12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                member.name.substring(0, 1),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ),
          ),
          SizedBox(height: SizeApp.s8),
          Text(
            member.name,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          if ((member.overallProgress ?? 0) > 0) ...[
            SizedBox(height: SizeApp.s4),
            LinearProgressIndicator(
              value: member.overallProgress ?? 0 / 100,
              backgroundColor: theme.dividerColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(theme.primaryColor),
              minHeight: 3,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyMembersSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s20),
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.group_add_rounded,
            size: 48.sp,
            color: theme.iconTheme.color?.withOpacity(0.5),
          ),
          SizedBox(height: SizeApp.s12),
          Text(
            l10n.noMembersAssigned,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          SizedBox(height: SizeApp.s12),
          ElevatedButton.icon(
            onPressed: () => _showAssignmentSheet(context),
            icon: Icon(Icons.person_add_rounded, size: 18.sp),
            label: Text(l10n.assignMembers),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: SizeApp.s16,
                vertical: SizeApp.s8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSection() {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s20),
      padding: EdgeInsets.all(SizeApp.s16),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(theme.primaryColor),
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withOpacity(0.3),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getExerciseColor(),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                  ),
                ),
                child: Text(
                  l10n.close,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (widget.teamId != null) ...[
              SizedBox(width: SizeApp.s12),
              Expanded(
                flex: 3,
                child: OutlinedButton.icon(
                  onPressed: () => _showAssignmentSheet(context),
                  icon: Icon(Icons.person_add_rounded),
                  label: Text(l10n.assignToMembers),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                    ),
                    side: BorderSide(color: theme.primaryColor),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showAssignmentSheet(BuildContext context) async {
    if (widget.teamId == null) return;

    final result = await AssignExerciseToMembersSheet.show(
      context,
      widget.exercise,
      widget.teamId!,
    );

    if (result == true && context.mounted) {
      final provider = Provider.of<ExerciseAssignmentProvider>(
        context,
        listen: false,
      );
      provider.loadExerciseMembers(widget.exercise.id);
    }
  }

  Widget _buildMediaSection() {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.educationalMedia,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: SizeApp.s12),

          if (widget.exercise.thumbnailPath != null) _buildThumbnailSection(),
          if (widget.exercise.mediaGallery.isNotEmpty) _buildMediaGallerySection(),
          if (widget.exercise.mediaPath != null &&
              widget.exercise.thumbnailPath == null &&
              widget.exercise.mediaGallery.isEmpty)
            _buildLegacyMediaSection(),
        ],
      ),
    );
  }

  Widget _buildThumbnailSection() {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.thumbnail,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: SizeApp.s8),
          Container(
            height: 180.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
              color: theme.cardColor,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
              child: Image.file(
                File(widget.exercise.thumbnailPath!),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                      color: theme.iconTheme.color?.withOpacity(0.1),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image_rounded,
                            size: 48.sp,
                            color: theme.iconTheme.color?.withOpacity(0.6),
                          ),
                          SizedBox(height: SizeApp.s8),
                          Text(
                            l10n.cannotDisplayImage,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGallerySection() {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.mediaGallery(widget.exercise.mediaGallery.length),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: SizeApp.s12),
          SizedBox(
            height: 120.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.exercise.mediaGallery.length,
              itemBuilder: (context, index) {
                final media = widget.exercise.mediaGallery[index];
                return _buildMediaPreview(media);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPreview(MediaItem media) {
    final theme = Theme.of(context);
    final isVideo = media.type == MediaType.video;

    return GestureDetector(
      onTap: () => FullScreenMediaViewer.show(
        context,
        filePath: media.path,
        isVideo: isVideo,
        accentColor: _getExerciseColor(),
      ),
      child: Container(
        width: 140.w,
        margin: EdgeInsets.only(right: SizeApp.s8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
          color: theme.cardColor,
        ),
        child: isVideo
            ? VideoPlayerWidget(
          videoPath: media.path,
          accentColor: _getExerciseColor(),
          height: 120.h,
          width: 140.w,
        )
            : ClipRRect(
          borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
          child: Image.file(
            File(media.path),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                  color: theme.iconTheme.color?.withOpacity(0.1),
                ),
                child: Center(
                  child: Icon(
                    Icons.broken_image_rounded,
                    size: 32.sp,
                    color: theme.iconTheme.color?.withOpacity(0.6),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLegacyMediaSection() {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isVideo = widget.exercise.mediaType == MediaType.video;

    return GestureDetector(
      onTap: () => FullScreenMediaViewer.show(
        context,
        filePath: widget.exercise.mediaPath!,
        isVideo: isVideo,
        accentColor: _getExerciseColor(),
      ),
      child: Container(
        height: 200.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
          color: theme.cardColor,
        ),
        child: isVideo
            ? VideoPlayerWidget(
          videoPath: widget.exercise.mediaPath!,
          accentColor: _getExerciseColor(),
          height: 200.h,
        )
            : ClipRRect(
          borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
          child: Image.file(
            File(widget.exercise.mediaPath!),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                  color: theme.iconTheme.color?.withOpacity(0.1),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image_rounded,
                        size: 48.sp,
                        color: theme.iconTheme.color?.withOpacity(0.6),
                      ),
                      SizedBox(height: SizeApp.s8),
                      Text(
                        l10n.cannotDisplayImage,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s20),
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: _getExerciseColor(),
                size: 20.sp,
              ),
              SizedBox(width: SizeApp.s8),
              Text(
                l10n.exerciseDescription,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: SizeApp.s12),
          Text(
            widget.exercise.description!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeInfoSection() {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s20),
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: _getExerciseColor().withOpacity(0.05),
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        border: Border.all(
          color: _getExerciseColor().withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: _getExerciseColor(),
                size: 20.sp,
              ),
              SizedBox(width: SizeApp.s8),
              Text(
                l10n.exerciseInfo,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: _getExerciseColor(),
                ),
              ),
            ],
          ),
          SizedBox(height: SizeApp.s12),
          _buildInfoRow(
            l10n.type,
            widget.exercise.type.getLocalizedName(context),
            _getExerciseIcon(),
          ),
          SizedBox(height: SizeApp.s8),
          _buildInfoRow(
            l10n.dateAdded,
            _formatDate(widget.exercise.createdAt),
            Icons.calendar_today_rounded,
          ),
          SizedBox(height: SizeApp.s8),
          _buildInfoRow(
            l10n.lastUpdate,
            _formatDate(widget.exercise.updatedAt),
            Icons.update_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: _getExerciseColor().withOpacity(0.7),
        ),
        SizedBox(width: SizeApp.s8),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: theme.primaryColor,
                size: 20.sp,
              ),
              SizedBox(width: SizeApp.s8),
              Text(
                l10n.usageStatistics,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: SizeApp.s12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  l10n.assignedTeams,
                  '${widget.exercise.assignedTeamsCount ?? 0}',
                  Icons.groups_rounded,
                  ColorsManager.primaryColor,
                ),
              ),
              SizedBox(width: SizeApp.s12),
              Expanded(
                child: _buildStatCard(
                  l10n.addition,
                  _formatShortDate(widget.exercise.createdAt),
                  Icons.add_circle_outline_rounded,
                  ColorsManager.secondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(SizeApp.s12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24.sp,
          ),
          SizedBox(height: SizeApp.s8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: SizeApp.s4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getExerciseColor() {
    switch (widget.exercise.type) {
      case ExerciseType.warmup:
        return const Color(0xFFFF5722);
      case ExerciseType.stretching:
        return const Color(0xFF4CAF50);
      case ExerciseType.conditioning:
        return const Color(0xFF2196F3);
    }
  }

  IconData _getExerciseIcon() {
    switch (widget.exercise.type) {
      case ExerciseType.warmup:
        return Icons.whatshot_rounded;
      case ExerciseType.stretching:
        return Icons.accessibility_new_rounded;
      case ExerciseType.conditioning:
        return Icons.fitness_center_rounded;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatShortDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}