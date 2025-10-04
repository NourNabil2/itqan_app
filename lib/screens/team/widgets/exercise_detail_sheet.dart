import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/core/utils/extension.dart';
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

  static void show(BuildContext context, ExerciseTemplate exercise,
      {required String teamId}) {
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

class _ExerciseDetailSheetState extends State<ExerciseDetailSheet>
    with SingleTickerProviderStateMixin {
  late Future<List<Member>> _membersFuture;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _membersFuture = Provider.of<ExerciseAssignmentProvider>(
      context,
      listen: false,
    ).loadExerciseMembers(widget.exercise.id);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshMembers() async {
    setState(() {
      _membersFuture = Provider.of<ExerciseAssignmentProvider>(
        context,
        listen: false,
      ).loadExerciseMembers(widget.exercise.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final exerciseColor = widget.exercise.type.color;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.92,
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
            _buildHeader(theme, colorScheme, l10n, exerciseColor),
// Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.teamId != null)
                      _buildAssignedMembersSection(
                          theme, colorScheme, l10n, exerciseColor),
                    if (widget.exercise.hasMedia)
                      _buildMediaSection(
                          theme, colorScheme, l10n, exerciseColor),
                    if (widget.exercise.description != null)
                      _buildDescriptionSection(
                          theme, colorScheme, l10n, exerciseColor),
                    _buildTypeInfoSection(
                        theme, colorScheme, l10n, exerciseColor),
                    _buildStatsSection(theme, colorScheme, l10n, exerciseColor),
                    SizedBox(height: 80.h),
                  ],
                ),
              ),
            ),
// Bottom Actions
            _buildBottomActions(theme, colorScheme, l10n, exerciseColor),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme,
      AppLocalizations l10n, Color exerciseColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            exerciseColor.withOpacity(0.2),
            exerciseColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: exerciseColor.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              widget.exercise.type.icon,
              color: exerciseColor,
              size: 26.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.exercise.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    fontSize: 20.sp,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: exerciseColor,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.exercise.type.icon,
                        color: Colors.white,
                        size: 14.sp,
                      ),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          widget.exercise.type.getLocalizedName(context),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (widget.teamId != null)
            IconButton(
              tooltip: l10n.assignToMembers,
              onPressed: () => _showAssignmentSheet(context),
              icon: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: exerciseColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.person_add_rounded,
                  color: exerciseColor,
                  size: 22.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAssignedMembersSection(ThemeData theme, ColorScheme colorScheme,
      AppLocalizations l10n, Color exerciseColor) {
    return FutureBuilder<List<Member>>(
      future: _membersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingSection(colorScheme, exerciseColor);
        }
        final members = snapshot.data ?? const <Member>[];
        if (members.isEmpty) {
          return _buildEmptyMembersSection(
              theme, colorScheme, l10n, exerciseColor);
        }
        return Container(
          margin: EdgeInsets.only(bottom: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSectionHeader(
                l10n.assignedMembers(members.length),
                Icons.groups_rounded,
                exerciseColor,
                theme,
                colorScheme,
                action: TextButton.icon(
                  onPressed: () => _showAssignmentSheet(context),
                  icon: Icon(Icons.add_circle_outline_rounded,
                      size: 16.sp, color: exerciseColor),
                  label: Text(
                    l10n.add,
                    style: TextStyle(fontSize: 14.sp, color: exerciseColor),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                height: 120.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: members.length,
                  itemBuilder: (context, index) => _buildMemberCard(
                      members[index], theme, colorScheme, l10n, exerciseColor),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMemberCard(Member member, ThemeData theme,
      ColorScheme colorScheme, AppLocalizations l10n, Color exerciseColor) {
    return Container(
      width: 140.w,
      margin: EdgeInsets.only(right: 12.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: exerciseColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: exerciseColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: exerciseColor.withOpacity(0.15),
            child: Text(
              member.name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: exerciseColor,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            member.name,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          if ((member.overallProgress ?? 0) > 0) ...[
            SizedBox(height: 4.h),
            LinearProgressIndicator(
              value: (member.overallProgress ?? 0) / 100,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(exerciseColor),
              minHeight: 3,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyMembersSection(ThemeData theme, ColorScheme colorScheme,
      AppLocalizations l10n, Color exerciseColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.group_add_rounded,
            size: 48.sp,
            color: colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: 12.h),
          Text(
            l10n.noMembersAssigned,
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12.h),
          FilledButton.icon(
            onPressed: () => _showAssignmentSheet(context),
            icon: Icon(Icons.person_add_rounded, size: 18.sp),
            label: Text(l10n.assignMembers, style: TextStyle(fontSize: 14.sp)),
            style: FilledButton.styleFrom(
              backgroundColor: exerciseColor,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSection(ColorScheme colorScheme, Color exerciseColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      child: Center(
        child: CircularProgressIndicator(
          color: exerciseColor,
          strokeWidth: 2.5,
        ),
      ),
    );
  }

  Widget _buildMediaSection(ThemeData theme, ColorScheme colorScheme,
      AppLocalizations l10n, Color exerciseColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.exercise.thumbnailPath != null)
            _buildThumbnailSection(theme, colorScheme, l10n, exerciseColor),
          if (widget.exercise.mediaGallery.isNotEmpty)
            _buildMediaGallerySection(theme, colorScheme, l10n, exerciseColor),
          if (widget.exercise.mediaPath != null &&
              widget.exercise.thumbnailPath == null &&
              widget.exercise.mediaGallery.isEmpty)
            _buildLegacyMediaSection(theme, colorScheme, l10n, exerciseColor),
        ],
      ),
    );
  }

  Widget _buildThumbnailSection(ThemeData theme, ColorScheme colorScheme,
      AppLocalizations l10n, Color exerciseColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSectionHeader(
            l10n.thumbnail,
            Icons.image_rounded,
            exerciseColor,
            theme,
            colorScheme,
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: () => FullScreenMediaViewer.show(
              context,
              filePath: widget.exercise.thumbnailPath!,
              isVideo: false,
              accentColor: exerciseColor,
            ),
            child: Container(
              height: 200.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      File(widget.exercise.thumbnailPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.broken_image_rounded,
                                  size: 48.sp,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  l10n.cannotDisplayImage,
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(fontSize: 14.sp),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 50.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.5),
                            ],
                          ),
                        ),
                        padding: EdgeInsets.all(10.w),
                        child: Row(
                          children: [
                            Icon(
                              Icons.zoom_in_rounded,
                              color: Colors.white,
                              size: 18.sp,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              l10n.tapToZoom,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGallerySection(ThemeData theme, ColorScheme colorScheme,
      AppLocalizations l10n, Color exerciseColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSectionHeader(
            l10n.mediaGallery(widget.exercise.mediaGallery.length),
            Icons.perm_media_rounded,
            exerciseColor,
            theme,
            colorScheme,
            action: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: exerciseColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '${widget.exercise.mediaGallery.length}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: exerciseColor,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 160.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: widget.exercise.mediaGallery.length,
              itemBuilder: (context, index) {
                final media = widget.exercise.mediaGallery[index];
                return _buildMediaPreview(
                    media, theme, colorScheme, l10n, exerciseColor);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPreview(MediaItem media, ThemeData theme,
      ColorScheme colorScheme, AppLocalizations l10n, Color exerciseColor) {
    final isVideo = media.type == MediaType.video;

    return GestureDetector(
      onTap: () => FullScreenMediaViewer.show(
        context,
        filePath: media.path,
        isVideo: isVideo,
        accentColor: exerciseColor,
      ),
      child: Container(
        width: 150.w,
        height: 160.h,
        margin: EdgeInsets.only(right: 12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              isVideo
                  ? VideoThumbnailWidget(
                videoPath: media.path,
                accentColor: exerciseColor,
                height: 160.h,
                width: 150.w,
              )
                  : Image.file(
                File(media.path),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: Icon(
                        Icons.broken_image_rounded,
                        size: 32.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
              if (isVideo)
                Center(
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 32.sp,
                    ),
                  ),
                ),
              Positioned(
                top: 6.h,
                right: 6.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isVideo ? Icons.play_circle_rounded : Icons.image_rounded,
                        color: Colors.white,
                        size: 12.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        isVideo ? l10n.video : l10n.image,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 40.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                  padding: EdgeInsets.all(8.w),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.zoom_in_rounded,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        l10n.tapToZoom,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegacyMediaSection(ThemeData theme, ColorScheme colorScheme,
      AppLocalizations l10n, Color exerciseColor) {
    final isVideo = widget.exercise.mediaType == MediaType.video;

    return GestureDetector(
      onTap: () => FullScreenMediaViewer.show(
        context,
        filePath: widget.exercise.mediaPath!,
        isVideo: isVideo,
        accentColor: exerciseColor,
      ),
      child: Container(
        height: 200.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              isVideo
                  ? VideoPlayerWidget(
                      videoPath: widget.exercise.mediaPath!,
                      accentColor: exerciseColor,
                      height: 200.h,
                    )
                  : Image.file(
                      File(widget.exercise.mediaPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.broken_image_rounded,
                                  size: 48.sp,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  l10n.cannotDisplayImage,
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(fontSize: 14.sp),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 50.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                  padding: EdgeInsets.all(10.w),
                  child: Row(
                    children: [
                      Icon(
                        Icons.zoom_in_rounded,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        l10n.tapToZoom,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(ThemeData theme, ColorScheme colorScheme,
      AppLocalizations l10n, Color exerciseColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: exerciseColor.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSectionHeader(
            l10n.exerciseDescription,
            Icons.description_outlined,
            exerciseColor,
            theme,
            colorScheme,
          ),
          SizedBox(height: 12.h),
          Text(
            widget.exercise.description!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14.sp,
              height: 1.6,
            ),
            maxLines: 10,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeInfoSection(ThemeData theme, ColorScheme colorScheme,
      AppLocalizations l10n, Color exerciseColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: exerciseColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: exerciseColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSectionHeader(
            l10n.exerciseInfo,
            Icons.info_outline_rounded,
            exerciseColor,
            theme,
            colorScheme,
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            theme,
            l10n.type,
            widget.exercise.type.getLocalizedName(context),
            widget.exercise.type.icon,
            exerciseColor,
          ),
          SizedBox(height: 8.h),
          _buildInfoRow(
            theme,
            l10n.dateAdded,
            _formatDate(widget.exercise.createdAt),
            Icons.calendar_today_rounded,
            exerciseColor,
          ),
          SizedBox(height: 8.h),
          _buildInfoRow(
            theme,
            l10n.lastUpdate,
            _formatDate(widget.exercise.updatedAt),
            Icons.update_rounded,
            exerciseColor,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value,
      IconData icon, Color exerciseColor) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: exerciseColor.withOpacity(0.7),
        ),
        SizedBox(width: 8.w),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(ThemeData theme, ColorScheme colorScheme,
      AppLocalizations l10n, Color exerciseColor) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSectionHeader(
            l10n.usageStatistics,
            Icons.analytics_outlined,
            exerciseColor,
            theme,
            colorScheme,
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  theme,
                  colorScheme,
                  l10n.assignedTeams,
                  '${widget.exercise.assignedTeamsCount ?? 0}',
                  Icons.groups_rounded,
                  exerciseColor,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  theme,
                  colorScheme,
                  l10n.addition,
                  _formatShortDate(widget.exercise.createdAt),
                  Icons.add_circle_outline_rounded,
                  exerciseColor.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, ColorScheme colorScheme, String title,
      String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color accentColor,
      ThemeData theme, ColorScheme colorScheme,
      {Widget? action}) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: accentColor,
            size: 18.sp,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
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

  Widget _buildBottomActions(ThemeData theme, ColorScheme colorScheme,
      AppLocalizations l10n, Color exerciseColor) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
            top:
                BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: exerciseColor,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      l10n.close,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.teamId != null) ...[
              SizedBox(width: 12.w),
              Expanded(
                flex: 3,
                child: OutlinedButton.icon(
                  onPressed: () => _showAssignmentSheet(context),
                  icon: Icon(Icons.person_add_rounded, size: 20.sp),
                  label: Text(
                    l10n.assignToMembers,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: exerciseColor,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    side: BorderSide(color: exerciseColor, width: 1.5),
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
      await _refreshMembers();
      final l10n = AppLocalizations.of(context);
      final colorScheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.assignmentsSavedSuccessfully,
            style: TextStyle(fontSize: 14.sp),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: widget.exercise.type.color,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          margin: EdgeInsets.all(16.w),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatShortDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}
