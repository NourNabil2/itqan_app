// lib/screens/subscription/external_subscribe_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/services/payment_service.dart';
import 'package:provider/provider.dart';
import 'package:itqan_gym/providers/auth_provider.dart';

class ExternalSubscribePage extends StatefulWidget {
  final String selectedPlan;
  final double amount;

  const ExternalSubscribePage({
    super.key,
    required this.selectedPlan,
    required this.amount,
  });

  @override
  State<ExternalSubscribePage> createState() => _ExternalSubscribePageState();
}

class _ExternalSubscribePageState extends State<ExternalSubscribePage> {
  final PaymentService _paymentService = PaymentService();

  // Contact info - يمكن تعديلها
  static const String kPayEmail = 'nour.nabil0@instapay';
  static const String kSupportEmail = 'nour60g@gmail.com';

  bool _isSubmittingEmail = false;
  bool _isOpeningWhatsApp = false;

  Color get _accent => const Color(0xFFFF8A00);
  List<Color> get _gradientColors => const [Color(0xFFFFB800), Color(0xFFFF8A00)];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.subscriptionInstructions),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              _buildHeaderCard(theme, l10n),

              SizedBox(height: 20.h),

              // Features
              _buildFeaturesSection(theme, l10n),

              SizedBox(height: 20.h),

              // Instructions
              _buildInstructionsSection(theme, l10n),

              SizedBox(height: 20.h),

              // Contact Info
              _buildContactInfoSection(theme, l10n),

              SizedBox(height: 24.h),

              // Action Buttons
              _buildActionButtons(theme, l10n),

              SizedBox(height: 16.h),

              // Disclaimer
              _buildDisclaimer(theme, l10n),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(16.w),
            child: Icon(
              Icons.workspace_premium,
              color: Colors.white,
              size: 48.sp,
            ),
          ),

          SizedBox(height: 16.h),

          // Title
          Text(
            l10n.premiumSubscription,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 16.h),

          // Price Info
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                _buildPriceRow(
                  l10n.selectedPlan,
                  widget.selectedPlan == 'monthly'
                      ? l10n.monthlyPlan
                      : l10n.lifetimePlan,
                ),
                SizedBox(height: 8.h),
                Divider(color: Colors.white.withOpacity(0.3), height: 1),
                SizedBox(height: 8.h),
                _buildPriceRow(
                  l10n.totalAmount,
                  '${widget.amount.toStringAsFixed(2)} ${l10n.egp}',
                  isAmount: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isAmount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14.sp,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: isAmount ? 18.sp : 14.sp,
            fontWeight: isAmount ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.whatsIncluded,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _FeatureChip(text: l10n.removeAds),
            _FeatureChip(text: l10n.cloudBackup),
            _FeatureChip(text: l10n.syncDevices),
            _FeatureChip(text: l10n.premiumSupport),
          ],
        ),
      ],
    );
  }

  Widget _buildInstructionsSection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.howToSubscribe,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInstructionStep('1', l10n.contactUsForDetails),
              SizedBox(height: 12.h),
              _buildInstructionStep('2', l10n.makePaymentExternally),
              SizedBox(height: 12.h),
              _buildInstructionStep('3', l10n.sendPaymentConfirmation),
              SizedBox(height: 12.h),
              _buildInstructionStep('4', l10n.activationWithin24Hours),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            color: _accent.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: _accent,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfoSection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.contactInformation,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _ContactCard(
                icon: Icons.email_outlined,
                title: l10n.email,
                value: kPayEmail,
                onCopy: () => _copyToClipboard(context, kPayEmail),
                accent: _accent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isSubmittingEmail || _isOpeningWhatsApp
            ? null
            : () => _submitViaEmail(context),
        icon: _isSubmittingEmail
            ? SizedBox(
          width: 20.w,
          height: 20.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(_accent),
          ),
        )
            : Icon(Icons.email_outlined, size: 20.sp),
        label: Text(l10n.submitViaEmail),
        style: OutlinedButton.styleFrom(
          foregroundColor: _accent,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          side: BorderSide(color: _accent, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  Widget _buildDisclaimer(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 20.sp,
            color: theme.colorScheme.primary,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              l10n.paymentProcessedExternally,
              style: theme.textTheme.bodySmall?.copyWith(
                height: 1.5,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Actions

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).copiedToClipboard),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }

  Future<void> _submitViaEmail(BuildContext context) async {
    setState(() => _isSubmittingEmail = true);

    try {
      final l10n = AppLocalizations.of(context);
      final auth = context.read<AuthProvider>();

      if (!auth.isLoggedIn) {
        throw Exception(l10n.mustBeLoggedIn);
      }

      // Submit request to backend (without proof image)
      await _paymentService.submitPaymentRequest(
        subscriptionType: widget.selectedPlan,
        amount: widget.amount,
        paymentMethod: 'instapay',
      ).then((value) async {
        await _openEmailApp(context).then((value) {
          const Duration(seconds: 1);
          _showSuccessDialog(context);
        },);
      },);


      if (!context.mounted) return;


    } catch (e) {
      if (context.mounted) {
        print('error: $e');
        _showErrorSnackBar(
          context,
          AppLocalizations.of(context).errorSubmittingRequest,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmittingEmail = false);
      }
    }
  }

  Future<void> _openEmailApp(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    final planName = widget.selectedPlan == 'monthly'
        ? l10n.monthlyPlan
        : l10n.lifetimePlan;

    final subject = Uri.encodeComponent(l10n.subscriptionRequestSubject);
    final body = Uri.encodeComponent(
      '${l10n.emailBodyIntro}\n\n'
          '${l10n.plan}: $planName\n'
          '${l10n.totalAmount}: ${widget.amount.toStringAsFixed(2)} ${l10n.egp}\n\n'
          '${l10n.emailBodyInstructions}',
    );

    // mailto: (أفضل سيناريو)
    final mailtoUri = Uri(
      scheme: 'mailto',
      path: kSupportEmail, // تأكد انه مش فاضي
      query: 'subject=$subject&body=$body',
    );

    // Gmail Web Compose كبديل
    final gmailWeb = Uri.parse(
      'https://mail.google.com/mail/?view=cm&fs=1'
          '&to=${Uri.encodeComponent(kSupportEmail)}'
          '&su=$subject&body=$body',
    );

    // 1) جرّب mailto:
    if (await canLaunchUrl(mailtoUri)) {
      await launchUrl(mailtoUri, mode: LaunchMode.externalApplication);
      return;
    }

    // 2) جرّب Gmail Web
    if (await canLaunchUrl(gmailWeb)) {
      await launchUrl(gmailWeb, mode: LaunchMode.externalApplication);
      return;
    }

    // 3) آخر حل: انسخ البريد وبلّغ المستخدم
    await Clipboard.setData(ClipboardData(text: kSupportEmail));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.copiedToClipboard)),
      );
    }
  }

  void _showSuccessDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 64.sp,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              l10n.requestSubmitted,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              l10n.requestSubmittedMessage,
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            child: Text(
              l10n.understood,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }
}

// Supporting Widgets

class _FeatureChip extends StatelessWidget {
  final String text;
  const _FeatureChip({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 16.sp),
          SizedBox(width: 6.w),
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13.sp),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onCopy;
  final Color accent;
  final VoidCallback? onTap; // (اختياري) لو حابب تخليه يفتح لينك مثلاً

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.onCopy,
    required this.accent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Material(
      color: theme.cardColor,
      elevation: 0,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: theme.dividerColor.withOpacity(0.25)),
          ),
          child: Stack(
            children: [
              // شريط لهجي على الطرف
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 3.w,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.r),
                        bottomLeft: Radius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                child: Row(
                  children: [
                    // أيقونة داخل دائرة
                    Container(
                      decoration: BoxDecoration(
                        color: accent.withOpacity(.12),
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(10.w),
                      child: Icon(icon, color: accent, size: 22.sp),
                    ),

                    SizedBox(width: 12.w),

                    // نصوص
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // العنوان
                          Text(
                            title,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),

                          // القيمة
                          Text(
                            value,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 8.w),

                    // زر نسخ أنيق
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: accent.withOpacity(.10),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.all(8.w),
                        constraints: BoxConstraints.tightFor(
                          width: 36.w,
                          height: 36.w,
                        ),
                        icon: Icon(Icons.copy_rounded, color: accent, size: 18.sp),
                        tooltip: l10n.copiedToClipboard,
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          onCopy();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.copiedToClipboard),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
