import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoofha/features/auth/application/auth_notifier.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      await authNotifier.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // GoRouter redirect رح يتكفّل ينقله لـ /app
    } catch (e) {
      debugPrint('Login error: $e');
      // TODO: ممكن تحط SnackBar لرسالة خطأ أنيقة
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final horizontalPadding = width * 0.08;
    final verticalSpacingSmall = height * 0.015;
    final verticalSpacingMedium = height * 0.025;
    final verticalSpacingLarge = height * 0.035;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const AuthHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height * 0.01),
                    // العنوان الرئيسي
                    Text(
                      // TODO: استبدلها لاحقاً بـ AppLocalizations
                      'Log in',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: verticalSpacingSmall),
                    Text(
                      'Welcome back to Shoofha!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                    SizedBox(height: verticalSpacingLarge),

                    // حقل الإيميل
                    AuthTextField(
                      label: 'Email',
                      hint: 'Enter your email',
                      prefixIcon: Icons.mail_outline,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: verticalSpacingMedium),

                    // حقل الباسورد
                    AuthTextField(
                      label: 'Password',
                      hint: 'Enter your password',
                      prefixIcon: Icons.lock_outline,
                      controller: _passwordController,
                      obscure: _obscure,
                      onToggleObscure: () {
                        setState(() {
                          _obscure = !_obscure;
                        });
                      },
                    ),

                    SizedBox(height: height * 0.008),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          minimumSize: Size(width * 0.1, height * 0.03),
                        ),
                        onPressed: () {
                          // TODO: شاشة نسيان كلمة المرور
                        },
                        child: Text(
                          'Forgot Password ?',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: verticalSpacingMedium),

                    // زر تسجيل الدخول (Gradient)
                    if (_loading)
                      SizedBox(
                        width: double.infinity,
                        height: height * 0.065,
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    else
                      AuthPrimaryButton(label: 'Sign in', onPressed: _onLogin),

                    SizedBox(height: verticalSpacingSmall),

                    // Divider نصي بسيط
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: height * 0.015),
                        child: Text(
                          'or continue with',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),

                    // أزرار سوشال (شكل فقط الآن)
                  Row(
                    children: [
                      Expanded(
                        child: _SocialButton(
                          label: 'Google',
                            icon: Icons.g_mobiledata,
                            onTap: () {
                              // TODO: Google sign-in
                            },
                          ),
                        ),
                        SizedBox(width: width * 0.04),
                      Expanded(
                        child: _SocialButton(
                          label: 'Apple',
                          icon: Icons.apple,
                            onTap: () {
                              // TODO: Apple sign-in
                            },
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: verticalSpacingLarge),

                    // "ما عندك حساب؟"
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: theme.textTheme.bodyMedium,
                          ),
                          GestureDetector(
                            onTap: () => context.go('/signup'),
                            child: Text(
                              'Sign Up.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.secondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: height * 0.03),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// زر سوشال بسيط، برضه بدون سايزات ثابتة
class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final height = size.height;

    final borderRadius = BorderRadius.circular(height * 0.02);

    return SizedBox(
      height: height * 0.06,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: borderRadius,
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
            width: height * 0.0012,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: height * 0.028, color: theme.iconTheme.color),
                SizedBox(width: size.width * 0.02),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
