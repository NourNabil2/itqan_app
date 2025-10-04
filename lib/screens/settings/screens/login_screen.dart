// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/widgets/app_buton.dart';
import 'package:itqan_gym/core/widgets/app_text_feild.dart';
import 'package:itqan_gym/core/widgets/custom_app_bar.dart';
import 'package:itqan_gym/providers/auth_provider.dart';
import 'package:itqan_gym/providers/settings_provider.dart';
import 'package:itqan_gym/screens/settings/screens/signup_screen.dart';
import 'package:itqan_gym/screens/settings/widgets/premium_dialog.dart';
import 'package:provider/provider.dart';

import '../../../core/assets/assets_manager.dart';
import '../../dashboard/widgets/logo_box_header.dart';

class LoginScreen extends StatefulWidget {
  final bool returnToPremium;
  const LoginScreen({super.key, required this.returnToPremium});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

// في login_screen.dart - _handleLogin
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pop(context);
      if (widget.returnToPremium) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            PremiumDialog.show(context);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                    SizedBox(height: SizeApp.s32),

                    // Logo
                    Image.asset(
                      AssetsManager.logo,
                      width: SizeApp.logoSize,
                      height: SizeApp.logoSize,
                      fit: BoxFit.contain,
                    ),

                    // Title
                    Text(
                      l10n.loginTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: SizeApp.s8),

                    Text(
                      l10n.loginDescription,
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
                      hintText: l10n.passwordRequired,
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

                    // Error Message
                    if (authProvider.error != null) ...[
                      SizedBox(height: SizeApp.s16),
                      Container(
                        padding: EdgeInsets.all(SizeApp.s12),
                        decoration: BoxDecoration(
                          color: ColorsManager.errorFill.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                          border: Border.all(
                            color: ColorsManager.errorFill,
                          ),
                        ),
                        child: Text(
                          authProvider.error!,
                          style: TextStyle(
                            color: ColorsManager.errorFill,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],

                    SizedBox(height: SizeApp.s24),

                    // Login Button
                    AppButton(
                      text: l10n.loginTitle,
                      onPressed: authProvider.isLoading ? null : _handleLogin,
                      isLoading: authProvider.isLoading,
                    ),

                    // // Forgot Password
                    // TextButton(
                    //   onPressed: () {
                    //     // Navigate to forgot password
                    //   },
                    //   child: Text(l10n.forgotPassword),
                    // ),
                    //
                    // SizedBox(height: SizeApp.s24),

                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.dontHaveAccount,
                          style: theme.textTheme.labelSmall,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SignUpScreen(
                                  returnToPremium: widget.returnToPremium,
                                ),
                              ),
                            );
                          },
                          child: Text(l10n.signUpTitle, style: theme.textTheme.labelSmall?.copyWith(
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