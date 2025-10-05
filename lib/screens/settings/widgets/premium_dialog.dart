// lib/screens/subscription/premium_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/screens/settings/widgets/payment/external_subscribe_page.dart';
import 'package:provider/provider.dart';
import 'package:itqan_gym/providers/auth_provider.dart';
import 'package:itqan_gym/screens/settings/screens/login_screen.dart';

class PremiumDialog extends StatefulWidget {
  const PremiumDialog({super.key});

  @override
  State<PremiumDialog> createState() => _PremiumDialogState();

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const PremiumDialog(),
    );
  }
}

class _PremiumDialogState extends State<PremiumDialog> {
  String _selectedPlan = 'monthly';
  bool _isNavigating = false;

  Color get _accent => const Color(0xFFFF8A00);
  List<Color> get _headerGradient => const [Color(0xFFFFB800), Color(0xFFFF8A00)];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 520.w,
            maxHeight: size.height * 0.9,
          ),
          child: Material(
            color: theme.dialogBackgroundColor,
            borderRadius: BorderRadius.circular(24.r),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: Column(
                children: [
                  // Header
                  _buildHeader(theme, l10n),

                  // Content
                  Expanded(
                    child: _buildContent(theme, l10n),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: _headerGradient),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.workspace_premium, size: 48.sp, color: Colors.white),
                SizedBox(height: 8.h),
                Text(
                  l10n.upgradeToAccess,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(Icons.close_rounded, color: Colors.white, size: 22.sp),
              onPressed: () => Navigator.pop(context),
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme, AppLocalizations l10n) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 420;
        return SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Plans
              if (isWide)
                Row(
                  children: [
                    Expanded(
                      child: _PlanCard(
                        title: l10n.monthlyPlan,
                        price:  59.99,
                        oldPrice:99.97,
                        period: l10n.perMonth,
                        value: 'monthly',
                        isSelected: _selectedPlan == 'monthly',
                        accent: _accent,
                        onTap: () => setState(() => _selectedPlan = 'monthly'),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _PlanCard(
                        title: l10n.lifetimePlan,
                        price: 249.99 ,
                        oldPrice: 599.97,
                        period: l10n.oneTime,
                        value: 'lifetime',
                        isSelected: _selectedPlan == 'lifetime',
                        accent: _accent,
                        badgeText: l10n.bestValue,
                        onTap: () => setState(() => _selectedPlan = 'lifetime'),
                      ),
                    ),
                  ],
                )
              else ...[
                _PlanCard(
                  title: l10n.monthlyPlan,
                  price: 59.99,
                  oldPrice: 99.97,
                  period: l10n.perMonth,
                  value: 'monthly',
                  isSelected: _selectedPlan == 'monthly',
                  accent: _accent,
                  onTap: () => setState(() => _selectedPlan = 'monthly'),
                ),
                SizedBox(height: 12.h),
                _PlanCard(
                  title: l10n.lifetimePlan,
                  price: 249.99,
                  oldPrice:  599.97,
                  period: l10n.oneTime,
                  value: 'lifetime',
                  isSelected: _selectedPlan == 'lifetime',
                  accent: _accent,
                  badgeText: l10n.bestValue,
                  onTap: () => setState(() => _selectedPlan = 'lifetime'),
                ),
              ],

              SizedBox(height: 20.h),

              // Features
              _buildFeatures(theme, l10n),

              SizedBox(height: 16.h),

              // CTA: View Subscription Instructions
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isNavigating ? null : _onViewInstructions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _isNavigating
                        ? SizedBox(
                      key: const ValueKey('loading'),
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                        : Text(
                      key: const ValueKey('text'),
                      l10n.paymentInstructions,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 8.h),

              Center(
                child: TextButton(
                  onPressed: _isNavigating ? null : () => Navigator.pop(context),
                  child: Text(
                    l10n.maybeLater,
                    style: TextStyle(fontSize: 13.sp),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatures(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.whatsIncluded,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 10.h),
          _FeatureRow(text: l10n.removeAds),
          _FeatureRow(text: l10n.cloudBackup),
          _FeatureRow(text: l10n.syncDevices),
          _FeatureRow(text: l10n.premiumSupport),
        ],
      ),
    );
  }

  Future<void> _onViewInstructions() async {
    HapticFeedback.lightImpact();
    setState(() => _isNavigating = true);

    try {
      // Check if user is logged in
      final auth = context.read<AuthProvider>();
      if (!auth.isLoggedIn) {
        // Close dialog and navigate to login
        if (mounted) Navigator.pop(context);

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(returnToPremium: true),
          ),
        );

        // Check again after login
        if (!mounted) return;
        final authAfter = context.read<AuthProvider>();
        if (!authAfter.isLoggedIn) return; // User didn't complete login
      }

      // Navigate to external subscribe page
      if (!mounted) return;
      Navigator.pop(context); // Close dialog

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ExternalSubscribePage(
            selectedPlan: _selectedPlan,
            amount: _selectedPlan == 'monthly' ? 59.99 : 249.99,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isNavigating = false);
    }
  }
}

// Feature Row Widget
class _FeatureRow extends StatelessWidget {
  final String text;
  const _FeatureRow({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 18.sp, color: Colors.green),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13.sp),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}

// Plan Card Widget
class _PlanCard extends StatelessWidget {
  final String title;
  final double price;
  final double? oldPrice;
  final String period;
  final String value;
  final bool isSelected;
  final Color accent;
  final String? badgeText;
  final VoidCallback onTap;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.period,
    required this.value,
    required this.isSelected,
    required this.accent,
    required this.onTap,
    this.badgeText,
    this.oldPrice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        splashColor: accent.withOpacity(0.08),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: isSelected
                ? accent.withOpacity(0.08)
                : theme.cardColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected
                  ? accent
                  : theme.dividerColor.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: accent.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Radio indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20.w,
                height: 20.w,
                margin: EdgeInsets.only(right: 10.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? accent : theme.dividerColor,
                    width: 2,
                  ),
                  color: isSelected ? accent : Colors.transparent,
                ),
                child: isSelected
                    ? Center(
                  child: Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                )
                    : null,
              ),

              // Info + price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 4.h,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                          ),
                        ),
                        if (badgeText != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              badgeText!,
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      period,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11.sp,
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 10.w),

              // Price area with discount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (oldPrice != null && oldPrice! > price)
                    Text(
                      '${l10n.egp} ${oldPrice!.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: theme.disabledColor,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  Text(
                    '${l10n.egp} ${price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
