// lib/screens/library/system_skills_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/core/utils/extension.dart';
import 'package:itqan_gym/core/widgets/custom_app_bar.dart';
import 'package:itqan_gym/core/widgets/skill_card.dart';
import 'package:itqan_gym/data/models/skill_template.dart';
import 'package:itqan_gym/providers/skill_library_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart'; // أضف المكتبة في pubspec.yaml

class SystemSkillsScreen extends StatefulWidget {
  const SystemSkillsScreen({super.key});

  @override
  State<SystemSkillsScreen> createState() => _SystemSkillsScreenState();
}

class _SystemSkillsScreenState extends State<SystemSkillsScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل المهارات الجاهزة عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SkillLibraryProvider>().refreshSystemSkills();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Consumer<SkillLibraryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingSystem) {
            return _buildLoadingState();
          }

          if (provider.systemSkills.isEmpty) {
            return _buildEmptyState(l10n);
          }

          // تجميع المهارات حسب الجهاز
          final groupedSkills = _groupSkillsByApparatus(provider.systemSkills);

          return RefreshIndicator(
            onRefresh: () => provider.refreshSystemSkills(),
            color: ColorsManager.primaryColor,
            child: ListView.builder(
              padding: EdgeInsets.all(SizeApp.padding),
              itemCount: groupedSkills.length,
              itemBuilder: (context, index) {
                final entry = groupedSkills.entries.elementAt(index);
                return _ApparatusExpansionTile(
                  apparatus: entry.key,
                  skills: entry.value,
                  onSkillTap: (skill) => _showSkillDetails(context, skill),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Map<Apparatus, List<SkillTemplate>> _groupSkillsByApparatus(
      List<SkillTemplate> skills,
      ) {
    final grouped = <Apparatus, List<SkillTemplate>>{};

    for (final skill in skills) {
      if (!grouped.containsKey(skill.apparatus)) {
        grouped[skill.apparatus] = [];
      }
      grouped[skill.apparatus]!.add(skill);
    }

    // ترتيب الأجهزة حسب الترتيب المعرف في Enum
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) => a.key.index.compareTo(b.key.index));

    return Map.fromEntries(sortedEntries);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: ColorsManager.primaryColor,
          ),
          SizedBox(height: SizeApp.s16),
          Text(
            'جاري تحميل المهارات المرجعية...',
            style: TextStyle(
              fontSize: 16.sp,
              color: ColorsManager.defaultTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 64.sp,
            color: Colors.grey,
          ),
          SizedBox(height: SizeApp.s16),
          Text(
            'لا توجد مهارات مرجعية متاحة',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: SizeApp.s8),
          Text(
            'تحقق من اتصال الإنترنت',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showSkillDetails(BuildContext context, SkillTemplate skill) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SkillDetailBottomSheet(skill: skill),
    );
  }
}

// ✅ ExpansionTile مخصص لكل جهاز
class _ApparatusExpansionTile extends StatefulWidget {
  final Apparatus apparatus;
  final List<SkillTemplate> skills;
  final Function(SkillTemplate) onSkillTap;

  const _ApparatusExpansionTile({
    required this.apparatus,
    required this.skills,
    required this.onSkillTap,
  });

  @override
  State<_ApparatusExpansionTile> createState() => _ApparatusExpansionTileState();
}

class _ApparatusExpansionTileState extends State<_ApparatusExpansionTile>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final color = getApparatusColor(widget.apparatus);
    final icon = getApparatusIcon(widget.apparatus);
    final name = widget.apparatus.getLocalizedName(context);

    return Card(
      margin: EdgeInsets.only(bottom: SizeApp.s12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ExpansionTile(
        initiallyExpanded: _isExpanded,
        onExpansionChanged: (expanded) => setState(() => _isExpanded = expanded),
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        subtitle: Text(
          '${widget.skills.length} مهارة',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey,
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Text(
            '${widget.skills.length}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        children: [
          Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(SizeApp.s12),
            itemCount: widget.skills.length,
            separatorBuilder: (_, __) => SizedBox(height: SizeApp.s8),
            itemBuilder: (context, index) {
              final skill = widget.skills[index];
              return SkillCard(
                skill: skill,
                onTap: () => widget.onSkillTap(skill),
                showSystemBadge: false, // مخفي داخل الـ Expansion
              );
            },
          ),
        ],
      ),
    );
  }
}

// ✅ Bottom Sheet لعرض تفاصيل المهارة مع الفيديو
class SkillDetailBottomSheet extends StatefulWidget {
  final SkillTemplate skill;

  const SkillDetailBottomSheet({super.key, required this.skill});

  @override
  State<SkillDetailBottomSheet> createState() => _SkillDetailBottomSheetState();
}

class _SkillDetailBottomSheetState extends State<SkillDetailBottomSheet> {
  VideoPlayerController? _videoController;
  bool _isVideoLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.skill.videoUrl != null) {
      _initializeVideo();
    }
  }

  void _initializeVideo() async {
    setState(() => _isVideoLoading = true);
    try {
      _videoController = VideoPlayerController.network(widget.skill.videoUrl!);
      await _videoController!.initialize();
      if (mounted) {
        setState(() => _isVideoLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading video: $e');
      if (mounted) setState(() => _isVideoLoading = false);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.symmetric(vertical: 8.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(SizeApp.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: getApparatusColor(widget.skill.apparatus)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          getApparatusIcon(widget.skill.apparatus),
                          color: getApparatusColor(widget.skill.apparatus),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.skill.skillName,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.skill.apparatus.getLocalizedName(context),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: SizeApp.s20),

                  // ✅ Video Player
                  if (widget.skill.videoUrl != null) ...[
                    Text(
                      'الفيديو التوضيحي',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: SizeApp.s12),
                    _buildVideoPlayer(),
                    SizedBox(height: SizeApp.s20),
                  ],

                  // Details
                  if (widget.skill.description != null) ...[
                    _buildSection('الوصف', widget.skill.description!),
                  ],

                  if (widget.skill.technicalAnalysis != null) ...[
                    _buildSection('التحليل الفني', widget.skill.technicalAnalysis!),
                  ],

                  if (widget.skill.preRequisites != null) ...[
                    _buildSection('المتطلبات السابقة', widget.skill.preRequisites!),
                  ],

                  if (widget.skill.skillProgression != null) ...[
                    _buildSection('التدرج في التعلم', widget.skill.skillProgression!),
                  ],

                  if (widget.skill.drills != null) ...[
                    _buildSection('التدريبات المساعدة', widget.skill.drills!),
                  ],

                  if (widget.skill.physicalPreparation != null) ...[
                    _buildSection('الإعداد البدني', widget.skill.physicalPreparation!),
                  ],

                  SizedBox(height: SizeApp.s20),

                  // Add to local library button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _addToLocalLibrary(context),
                      icon: Icon(Icons.add_circle_outline),
                      label: Text('إضافة إلى مكتبتي'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_isVideoLoading) {
      return Container(
        height: 200.h,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_videoController == null || !_videoController!.value.isInitialized) {
      return Container(
        height: 200.h,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 40),
              SizedBox(height: 8),
              Text(
                'فشل تحميل الفيديو',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_videoController!),
            if (!_videoController!.value.isPlaying)
              Container(
                color: Colors.black45,
                child: IconButton(
                  icon: Icon(Icons.play_arrow, color: Colors.white, size: 50),
                  onPressed: () => _videoController!.play(),
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _videoController!,
                allowScrubbing: true,
                colors: VideoProgressColors(
                  playedColor: Colors.red,
                  bufferedColor: Colors.grey,
                  backgroundColor: Colors.black45,
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: IconButton(
                icon: Icon(
                  _videoController!.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _videoController!.value.isPlaying
                        ? _videoController!.pause()
                        : _videoController!.play();
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: ColorsManager.primaryColor,
          ),
        ),
        SizedBox(height: SizeApp.s8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14.sp,
            height: 1.5,
          ),
        ),
        SizedBox(height: SizeApp.s16),
      ],
    );
  }

  void _addToLocalLibrary(BuildContext context) async {
    // نسخ المهارة إلى المكتبة المحلية
    final localSkill = widget.skill.copyWith(
      id: null, // generate new ID
      isSystem: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final provider = context.read<SkillLibraryProvider>();
    final id = await provider.createSkill(localSkill);

    if (id != null && context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تمت الإضافة إلى مكتبتك بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}