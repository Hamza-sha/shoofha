import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoofha/features/auth/application/auth_notifier.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _useEmail = true;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  bool _agreeTerms = false;
  bool _emailUpdates = false;

  bool _loading = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _onSignup() async {
    if (_loading) return;

    if (!_agreeTerms) {
      // TODO: اعرض SnackBar محترمة مثلاً
      debugPrint('You must agree to terms & conditions');
      return;
    }

    if (_passwordController.text.trim() != _confirmController.text.trim()) {
      // TODO: اعرض رسالة "كلمات السر غير متطابقة"
      debugPrint('Passwords do not match');
      return;
    }

    setState(() => _loading = true);

    try {
      final email = _useEmail ? _emailController.text.trim() : '';
      final phone = _phoneController.text.trim();

      await authNotifier.signUp(
        name: _nameController.text.trim(),
        email: email,
        phone: phone,
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        context.go('/otp');
      }
    } catch (e) {
      debugPrint('Signup error: $e');
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
    final vSpaceXs = height * 0.008;
    final vSpaceSm = height * 0.015;
    final vSpaceMd = height * 0.022;
    final vSpaceLg = height * 0.03;

    final tabsContainerRadius = height * 0.035;
    final tabRadius = height * 0.03;

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

                    // عنوان الشاشة
                    Text(
                      'Sign up',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: vSpaceXs),
                    Text(
                      'Choose your sign-up method',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                    SizedBox(height: vSpaceMd),

                    // Tabs Email / Phone
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withOpacity(
                              theme.brightness == Brightness.light ? 0.6 : 0.18,
                            ),
                        borderRadius: BorderRadius.circular(
                          tabsContainerRadius,
                        ),
                      ),
                      padding: EdgeInsets.all(height * 0.004),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (!_useEmail) {
                                  setState(() => _useEmail = true);
                                }
                              },
                              child: _SignupTab(
                                label: 'Email',
                                isSelected: _useEmail,
                                radius: tabRadius,
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (_useEmail) {
                                  setState(() => _useEmail = false);
                                }
                              },
                              child: _SignupTab(
                                label: 'Phone Number',
                                isSelected: !_useEmail,
                                radius: tabRadius,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: vSpaceLg),

                    // الاسم
                    AuthTextField(
                      label: 'Name',
                      hint: 'Enter your name',
                      prefixIcon: Icons.person_outline,
                      controller: _nameController,
                    ),
                    SizedBox(height: vSpaceMd),

                    // Email / Phone حسب الاختيار
                    if (_useEmail) ...[
                      AuthTextField(
                        label: 'Email ID',
                        hint: 'Enter your email',
                        prefixIcon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                      ),
                      SizedBox(height: vSpaceMd),
                      AuthTextField(
                        label: 'Phone Number (optional)',
                        hint: 'Enter your phone number',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        controller: _phoneController,
                      ),
                    ] else ...[
                      AuthTextField(
                        label: 'Phone Number',
                        hint: 'Enter your phone number',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        controller: _phoneController,
                      ),
                    ],

                    SizedBox(height: vSpaceMd),

                    // كلمة المرور
                    AuthTextField(
                      label: 'Password',
                      hint: 'Create a password',
                      prefixIcon: Icons.lock_outline,
                      controller: _passwordController,
                      obscure: _obscurePassword,
                      onToggleObscure: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    SizedBox(height: vSpaceMd),

                    // تأكيد كلمة المرور
                    AuthTextField(
                      label: 'Confirm Password',
                      hint: 'Re-enter your password',
                      prefixIcon: Icons.lock_outline,
                      controller: _confirmController,
                      obscure: _obscureConfirm,
                      onToggleObscure: () {
                        setState(() {
                          _obscureConfirm = !_obscureConfirm;
                        });
                      },
                    ),

                    SizedBox(height: vSpaceSm),

                    // Checkboxes
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: width * 0.1,
                          child: Checkbox(
                            value: _agreeTerms,
                            onChanged: (v) =>
                                setState(() => _agreeTerms = v ?? false),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'By creating an account, you are agreeing with Shoofha terms and conditions',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.75),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: vSpaceXs),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: width * 0.1,
                          child: Checkbox(
                            value: _emailUpdates,
                            onChanged: (v) =>
                                setState(() => _emailUpdates = v ?? false),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Email me new updates',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.75),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: vSpaceMd),

                    // أزرار Confirm / Cancel
                    Row(
                      children: [
                        Expanded(
                          child: _loading
                              ? SizedBox(
                                  height: height * 0.065,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : AuthPrimaryButton(
                                  label: 'Confirm',
                                  onPressed: _onSignup,
                                ),
                        ),
                        SizedBox(width: width * 0.04),
                        Expanded(
                          child: SizedBox(
                            height: height * 0.065,
                            child: OutlinedButton(
                              onPressed: () => context.pop(),
                              child: const Text('Cancel'),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: vSpaceLg),

                    // عندك حساب؟
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            'Already have an account ? ',
                            style: theme.textTheme.bodyMedium,
                          ),
                          GestureDetector(
                            onTap: () => context.go('/login'),
                            child: Text(
                              'Login',
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

/// تبويبة Email / Phone في الأعلى
class _SignupTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final double radius;

  const _SignupTab({
    required this.label,
    required this.isSelected,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final height = size.height;

    final bgColor = isSelected ? colorScheme.primary : Colors.transparent;
    final textColor = isSelected
        ? colorScheme.onPrimary
        : theme.textTheme.bodyMedium?.color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: height * 0.012),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
