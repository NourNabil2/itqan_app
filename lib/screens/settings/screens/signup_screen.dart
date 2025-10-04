// lib/screens/auth/signup_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/widgets/app_buton.dart';
import 'package:itqan_gym/core/widgets/app_text_feild.dart';
import 'package:itqan_gym/core/widgets/error_container_widget.dart';
import 'package:itqan_gym/providers/auth_provider.dart';
import 'package:provider/provider.dart';
class _TipRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _TipRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall,
            softWrap: true,
          ),
        ),
      ],
    );
  }
}


class SignUpScreen extends StatefulWidget {
  final bool returnToPremium;
  const SignUpScreen({super.key, this.returnToPremium = false});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).mustAgreeToTerms),
          backgroundColor: ColorsManager.errorFill,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      _showVerificationDialog(context);
    }
  }

  void _showVerificationDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: theme.colorScheme.scrim.withOpacity(0.35),
      builder: (dialogCtx) {
        bool isSending = false;
        int cooldown = 0; // seconds
        Timer? timer;

        Future<void> startCooldown([int seconds = 30]) async {
          cooldown = seconds;
          timer?.cancel();
          timer = Timer.periodic(const Duration(seconds: 1), (t) {
            if (cooldown <= 1) {
              t.cancel();
            }
            cooldown = (cooldown - 1).clamp(0, seconds);
            (dialogCtx as Element).markNeedsBuild();
          });
        }

        Future<void> resend() async {
          if (isSending || cooldown > 0) return;
          isSending = true;
          (dialogCtx as Element).markNeedsBuild();
          try {
            final auth = context.read<AuthProvider>();
            await auth.resendVerificationEmail();
            // نجاح
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.verificationEmailSent),
                behavior: SnackBarBehavior.floating,
              ),
            );
            await startCooldown(30); // عدّاد 30 ثانية
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } finally {
            isSending = false;
            (dialogCtx as Element).markNeedsBuild();
          }
        }

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeApp.radiusMed),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          contentPadding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
          titlePadding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
          title: Row(
            children: [
              Icon(Icons.mark_email_read, color: ColorsManager.successFill, size: 24.sp),
              SizedBox(width: 10.w),
              Flexible(
                child: Text(
                  l10n.verifyEmail,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.visible,
                  softWrap: true,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              Text(
                l10n.verificationEmailSent,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.start,
                softWrap: true,
              ),
              SizedBox(height: 14.h),

              // تلميحات صغيرة
              _TipRow(icon: Icons.inbox_outlined, text: 'Check Inbox / Spam / Promotions'),
              SizedBox(height: 6.h),
              _TipRow(icon: Icons.link_outlined, text: 'Open the latest email only'),
              SizedBox(height: 12.h),

              // زر إعادة الإرسال مع حالة تحميل وعدّاد
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: (isSending || cooldown > 0) ? null : resend,
                  icon: isSending
                      ? SizedBox(
                    width: 16.sp, height: 16.sp,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Icon(Icons.refresh),
                  label: Text(
                    cooldown > 0 ? '${l10n.resendEmail} (${cooldown}s)' : l10n.resendEmail,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actionsPadding: EdgeInsets.only(right: 12.w, left: 12.w, bottom: 8.h),
          actions: [
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  timer?.cancel();
                  Navigator.pop(dialogCtx); // close dialog
                  Navigator.pop(context);   // back to login
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(l10n.gotIt),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(SizeApp.s24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: SizeApp.s16),

                    // Logo
                    Icon(
                      Icons.fitness_center,
                      size: 80.sp,
                      color: theme.primaryColor,
                    ),

                    SizedBox(height: SizeApp.s24),

                    // Title
                    Text(
                      l10n.signUpTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: SizeApp.s8),

                    Text(
                      l10n.signUpDescription,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: SizeApp.s40),

                    // Email Field
                    AppTextField(
                      controller: _emailController,
                      hintText: l10n.email,
                      title: l10n.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.emailRequired;
                        }
                        if (!value.contains('@')) {
                          return l10n.emailInvalid;
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: SizeApp.s16),

                    // Password Field
                    AppTextField(
                      controller: _passwordController,
                      hintText: l10n.password,
                      title: l10n.password,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.passwordRequired;
                        }
                        if (value.length < 6) {
                          return l10n.passwordTooShort;
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: SizeApp.s16),

                    // Confirm Password Field
                    AppTextField(
                      controller: _confirmPasswordController,
                      hintText: l10n.confirmPassword,
                      title: l10n.confirmPassword,
                      obscureText: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.confirmPasswordRequired;
                        }
                        if (value != _passwordController.text) {
                          return l10n.passwordsDoNotMatch;
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: SizeApp.s16),

                    // Terms & Conditions
                    Row(
                      children: [
                        Checkbox(
                          value: _agreedToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreedToTerms = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _agreedToTerms = !_agreedToTerms;
                              });
                            },
                            child: Text.rich(
                              TextSpan(
                                text: l10n.iAgreeToThe,
                                style: theme.textTheme.bodySmall,
                                children: [
                                  TextSpan(
                                    text: l10n.termsAndConditions,
                                    style: TextStyle(
                                      color: theme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Error Message
                    if (authProvider.error != null) ...[
                      SizedBox(height: SizeApp.s16),
                      ErrorContainer(
                        generalError: authProvider.error!,
                      ),
                    ],

                    SizedBox(height: SizeApp.s24),

                    // Sign Up Button
                    AppButton(
                      text: l10n.signUpTitle,
                      onPressed: authProvider.isLoading ? null : _handleSignUp,
                      isLoading: authProvider.isLoading,
                    ),
                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.alreadyHaveAccount,
                          style: theme.textTheme.labelSmall,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(l10n.loginTitle,style: theme.textTheme.labelSmall?.copyWith(
            color: ColorsManager.primaryColor
            ),),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}