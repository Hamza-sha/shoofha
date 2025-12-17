import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoofha/features/auth/application/auth_notifier.dart';
import 'package:shoofha/features/auth/presentation/widgets/auth_header.dart';
import 'package:shoofha/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:shoofha/features/auth/presentation/widgets/auth_text_field.dart';

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

  String? _emailError;
  String? _passwordError;

  bool get _canSubmit =>
      _emailError == null &&
      _passwordError == null &&
      _emailController.text.trim().isNotEmpty &&
      _passwordController.text.trim().isNotEmpty;

  String? _validateEmail(String v) {
    final value = v.trim();
    if (value.isEmpty) return null; // ✅ ما نزعّج اليوزر وهو فاضي
    final ok = value.contains('@') && value.contains('.') && value.length >= 5;
    return ok ? null : 'Email is not valid';
  }

  String? _validatePassword(String v) {
    final value = v.trim();
    if (value.isEmpty) return null;
    return value.length >= 6 ? null : 'Password must be at least 6 characters';
  }

  void _runValidation() {
    setState(() {
      _emailError = _validateEmail(_emailController.text);
      _passwordError = _validatePassword(_passwordController.text);
    });
  }

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_runValidation);
    _passwordController.addListener(_runValidation);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (_loading) return;

    // ✅ تأكيد نهائي قبل الإرسال
    _runValidation();
    if (!_canSubmit) return;

    setState(() => _loading = true);

    try {
      await authNotifier.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        context.go('/app');
      }
    } catch (e) {
      debugPrint('Login error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
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
    final verticalSpacingLarge = height * 0.04;

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

                    Text(
                      'Sign in',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: height * 0.008),
                    Text(
                      'Welcome back! Enter your details to continue.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                    SizedBox(height: verticalSpacingMedium),

                    AuthTextField(
                      label: 'Email',
                      hint: 'you@example.com',
                      prefixIcon: Icons.email_outlined,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      errorText: _emailError,
                    ),

                    SizedBox(height: verticalSpacingSmall),

                    AuthTextField(
                      label: 'Password',
                      hint: '••••••••',
                      prefixIcon: Icons.lock_outline,
                      controller: _passwordController,
                      obscure: _obscure,
                      onToggleObscure: () =>
                          setState(() => _obscure = !_obscure),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _onLogin(),
                      errorText: _passwordError,
                    ),

                    SizedBox(height: height * 0.008),

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

                    if (_loading)
                      SizedBox(
                        width: double.infinity,
                        height: height * 0.065,
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    else
                      AuthPrimaryButton(
                        label: 'Sign in',
                        onPressed: _onLogin,
                        enabled: _canSubmit, // ✅
                      ),

                    SizedBox(height: verticalSpacingSmall),

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

                    Row(
                      children: [
                        Expanded(
                          child: _SocialButton(
                            label: 'Google',
                            icon: Icons.g_mobiledata,
                            onTap: () {},
                          ),
                        ),
                        SizedBox(width: width * 0.04),
                        Expanded(
                          child: _SocialButton(
                            label: 'Apple',
                            icon: Icons.apple,
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: verticalSpacingLarge),

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
    final cs = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final height = size.height;

    final radius = height * 0.02;

    return InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: onTap,
      child: Container(
        height: height * 0.06,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: cs.outline.withOpacity(0.25)),
          color: cs.surface,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: cs.onSurface.withOpacity(0.75)),
              SizedBox(width: size.width * 0.02),
              Text(label, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
