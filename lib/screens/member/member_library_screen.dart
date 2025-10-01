import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/widgets/app_text_feild.dart';
import 'package:itqan_gym/core/widgets/member_card.dart';
import 'package:itqan_gym/providers/member_provider.dart';
import 'package:provider/provider.dart';
import 'add_member_screen/add_member_screen.dart';

class MemberLibraryScreen extends StatefulWidget {
  const MemberLibraryScreen({super.key});

  @override
  State<MemberLibraryScreen> createState() => _MemberLibraryScreenState();
}

class _MemberLibraryScreenState extends State<MemberLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              SizeApp.s16,
              SizeApp.s20,
              SizeApp.s16,
              SizeApp.s16,
            ),
            child: AppTextFieldFactory.search(
              controller: _searchController,
              hintText: l10n.searchForMember,
              fillColor: theme.cardColor,
              onChanged: (query) {
                Provider.of<MemberLibraryProvider>(context, listen: false)
                    .searchMembers(query);
              },
            ),
          ),

          // Stats Section
          Container(
            margin: EdgeInsets.symmetric(horizontal: SizeApp.s16),
            padding: EdgeInsets.all(SizeApp.s16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor.withOpacity(0.08),
                  theme.primaryColor.withOpacity(0.04),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(SizeApp.radiusMed),
              border: Border.all(
                color: theme.primaryColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Consumer<MemberLibraryProvider>(
              builder: (context, provider, child) {
                return Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(SizeApp.s10),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(SizeApp.s10),
                      ),
                      child: Icon(
                        Icons.groups_rounded,
                        color: theme.primaryColor,
                        size: SizeApp.iconSize,
                      ),
                    ),
                    SizedBox(width: SizeApp.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.totalMembers,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            l10n.activeMembers(provider.members.length),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeApp.s16,
                        vertical: SizeApp.s8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.primaryColor,
                            ColorsManager.secondLightColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(SizeApp.s12),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${provider.members.length}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          SizedBox(height: SizeApp.s16),

          // Members List
          Expanded(
            child: Consumer<MemberLibraryProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 60.w,
                          height: 60.h,
                          padding: EdgeInsets.all(SizeApp.s16),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(SizeApp.radius),
                          ),
                          child: CircularProgressIndicator(
                            color: theme.primaryColor,
                            strokeWidth: 3,
                          ),
                        ),
                        SizedBox(height: SizeApp.s16),
                        Text(
                          l10n.loadingMembers,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.members.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    SizeApp.s16,
                    0,
                    SizeApp.s16,
                    SizeApp.s20,
                  ),
                  itemCount: provider.members.length,
                  itemBuilder: (context, index) {
                    return MemberCard(
                      member: provider.members[index],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Center(
      child: Container(
        padding: EdgeInsets.all(SizeApp.s32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(SizeApp.radius),
                border: Border.all(
                  color: theme.dividerColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: 60.sp,
                color: theme.iconTheme.color?.withOpacity(0.6),
              ),
            ),
            SizedBox(height: SizeApp.s24),
            Text(
              l10n.noMembersInLibrary,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: SizeApp.s8),
            Text(
              l10n.startAddingFirstMember,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: SizeApp.s32),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primaryColor,
                    ColorsManager.secondLightColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(SizeApp.radiusMed),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(SizeApp.radiusMed),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddGlobalMemberScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeApp.s24,
                      vertical: SizeApp.s16,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_add_rounded,
                          color: Colors.white,
                          size: SizeApp.iconSize,
                        ),
                        SizedBox(width: SizeApp.s8),
                        Text(
                          l10n.addFirstMember,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}