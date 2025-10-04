import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:itqan_gym/core/assets/assets_manager.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/services/ad_service.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/core/widgets/Loading_widget.dart' show LoadingSpinner;
import 'package:itqan_gym/core/widgets/ads_widgets/banner_ad_widget.dart';
import 'package:itqan_gym/core/widgets/empty_state_widget.dart';
import 'package:itqan_gym/core/widgets/team_card.dart';
import 'package:itqan_gym/providers/team_provider.dart';
import 'package:itqan_gym/screens/dashboard/add_team_screen.dart';
import 'package:itqan_gym/screens/dashboard/widgets/age_group_section.dart';
import 'package:itqan_gym/screens/dashboard/widgets/logo_box_header.dart';
import 'package:provider/provider.dart' show Consumer;

import '../../providers/auth_provider.dart';

class TeamsTab extends StatefulWidget {
  const TeamsTab({Key? key}) : super(key: key);

  @override
  State<TeamsTab> createState() => _TeamsTabState();
}

class _TeamsTabState extends State<TeamsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // Load banner only after AdsService is fully initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AdsService.instance.loadBannerAd(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Consumer<TeamProvider>(
      builder: (context, teamProvider, _) {
        if (teamProvider.isLoading) return const LoadingSpinner();

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: LogoBoxHeader(
                title: 'ITQAN',
                subtitle: l10n.manageTeamsTrackSkills,
                assetLogo: AssetsManager.logo,
              ),
            ),

            if (teamProvider.teams.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyStateWidget(
                  title: l10n.noTeamsYet,
                  subtitle: l10n.noTeamsSubtitle,
                  buttonText: l10n.createTeam,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateTeamFlow()),
                    );
                  },
                  assetSvgPath: AssetsManager.iconsTeamIcons,
                  buttonIcon: Icons.group_add,
                ),
              )
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: SizeApp.padding),
                  child: Row(
                    children: [
                      Expanded(child: Divider(thickness: 1, color: theme.dividerColor)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Text(l10n.teams, style: theme.textTheme.titleLarge),
                      ),
                      Expanded(child: Divider(thickness: 1, color: theme.dividerColor)),
                    ],
                  ),
                ),
              ),

              // Banner Ad - using AdsService directly with ListenableBuilder
              SliverToBoxAdapter(
                child: ListenableBuilder(
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

              SliverPadding(
                padding: EdgeInsets.all(SizeApp.padding),
                sliver: SliverList.separated(
                  itemCount: AgeCategory.values.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (_, idx) => _buildAgeSection(
                    context,
                    AgeCategory.values[idx],
                    teamProvider,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildAgeSection(
      BuildContext context,
      AgeCategory category,
      TeamProvider provider,
      ) {
    final teams = provider.getTeamsByAgeGroup(category);
    if (teams.isEmpty) return const SizedBox.shrink();

    return AgeGroupSection(
      title: category.getLocalizedName(context),
      count: teams.length,
      initiallyExpanded: true,
      children: teams.map((t) => TeamCard(team: t)).toList(),
    );
  }
}
