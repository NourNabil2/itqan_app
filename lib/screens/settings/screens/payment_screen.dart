// lib/screens/payment/payment_screen.dart
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/services/payment_service.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/widgets/app_buton.dart';
import 'package:itqan_gym/core/widgets/app_text_feild.dart';


class PaymentScreen extends StatefulWidget {
  final String subscriptionType;
  final double amount;

  const PaymentScreen({
    super.key,
    required this.subscriptionType,
    required this.amount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  final TextEditingController _referenceController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String _selectedMethod = 'vodafone_cash';
  File? _proofImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _proofImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل اختيار الصورة: $e'),
          backgroundColor: ColorsManager.errorFill,
        ),
      );
    }
  }

  Future<void> _submitPayment() async {
    if (_proofImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى إرفاق صورة إثبات الدفع'),
          backgroundColor: ColorsManager.warningFill,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _paymentService.submitPaymentRequest(
        subscriptionType: widget.subscriptionType,
        amount: widget.amount,
        paymentMethod: _selectedMethod,
        proofImage: _proofImage!,
        transactionReference: _referenceController.text.trim().isEmpty
            ? null
            : _referenceController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        log(('فشل إرسال الطلب: $e'),);
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل إرسال الطلب: $e'),
            backgroundColor: ColorsManager.errorFill,
          ),
        );
      }
    }
  }

  void _showSuccessDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 80.sp,
              color: ColorsManager.successFill,
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.paymentRequestSubmitted,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              l10n.paymentUnderReview,
              style: TextStyle(
                fontSize: 14.sp,
                color: ColorsManager.defaultTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back
            },
            child: Text(l10n.gotIt),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.payment),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(SizeApp.s24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Amount Card
            Container(
              padding: EdgeInsets.all(SizeApp.s20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFB800), Color(0xFFFF8A00)],
                ),
                borderRadius: BorderRadius.circular(SizeApp.radiusMed),
              ),
              child: Column(
                children: [
                  Text(
                    l10n.totalAmount,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${widget.amount.toStringAsFixed(2)} ${l10n.egp}',
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    widget.subscriptionType == 'monthly'
                        ? l10n.monthlyPlan
                        : l10n.lifetimePlan,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: SizeApp.s24),

            // Instructions Card
            Container(
              padding: EdgeInsets.all(SizeApp.s16),
              decoration: BoxDecoration(
                color: ColorsManager.infoSurface,
                borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                border: Border.all(color: ColorsManager.infoText),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: ColorsManager.infoText,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        l10n.paymentInstructions,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: ColorsManager.infoText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    l10n.paymentInstructionsDetails,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: ColorsManager.infoText.withOpacity(0.9),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: SizeApp.s24),

            // Phone Number Card
            Container(
              padding: EdgeInsets.all(SizeApp.s16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                border: Border.all(
                  color: theme.dividerColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.phone_android,
                    color: ColorsManager.successFill,
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.phoneNumber,
                          style: theme.textTheme.bodySmall,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '01029718817',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(
                        const ClipboardData(text: '01029718817'),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.copiedToClipboard),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: Icon(Icons.copy, size: 20.sp),
                  ),
                ],
              ),
            ),

            SizedBox(height: SizeApp.s24),

            // Payment Method Selection
            Text(
              l10n.paymentMethod,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),

            _buildPaymentMethodOption(
              'vodafone_cash',
              l10n.vodafoneCash,
              Icons.phone_android,
            ),
            SizedBox(height: 12.h),
            _buildPaymentMethodOption(
              'instapay',
              l10n.instaPay,
              Icons.account_balance_wallet,
            ),

            SizedBox(height: SizeApp.s24),

            // Transaction Reference (Optional)
            AppTextField(
              controller: _referenceController,
              hintText: l10n.transactionReferenceOptional,
              title: l10n.transactionReference,
            ),

            SizedBox(height: SizeApp.s24),

            // Upload Payment Proof
            Text(
              l10n.uploadPaymentProof,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),

            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200.h,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                  border: Border.all(
                    color: _proofImage != null
                        ? ColorsManager.successFill
                        : theme.dividerColor,
                    width: 2,
                  ),
                ),
                child: _proofImage != null
                    ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        SizeApp.radiusSmall - 2,
                      ),
                      child: Image.file(
                        _proofImage!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                          onPressed: () {
                            setState(() {
                              _proofImage = null;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 48.sp,
                      color: theme.iconTheme.color?.withOpacity(0.5),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      l10n.tapToUploadProof,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: SizeApp.s32),

            // Submit Button
            AppButton(
              text: l10n.submitPaymentRequest,
              onPressed: _isLoading ? null : _submitPayment,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodOption(String value, String title, IconData icon) {
    final theme = Theme.of(context);
    final isSelected = _selectedMethod == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = value;
        });
      },
      child: Container(
        padding: EdgeInsets.all(SizeApp.s16),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorsManager.primaryColor.withOpacity(0.1)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
          border: Border.all(
            color: isSelected
                ? ColorsManager.primaryColor
                : theme.dividerColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? ColorsManager.primaryColor
                      : theme.dividerColor,
                  width: 2,
                ),
                color: isSelected
                    ? ColorsManager.primaryColor
                    : Colors.transparent,
              ),
              child: isSelected
                  ? Center(
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              )
                  : null,
            ),
            SizedBox(width: 12.w),
            Icon(icon, size: 24.sp),
            SizedBox(width: 12.w),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}