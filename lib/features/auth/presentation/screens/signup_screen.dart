import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoofha/features/auth/application/auth_notifier.dart';
import 'package:shoofha/features/auth/presentation/widgets/auth_header.dart';
import 'package:shoofha/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:shoofha/features/auth/presentation/widgets/auth_text_field.dart';

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

  // ✅ errors
  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmError;
  String? _termsError;

  // ✅ Live: نخلي الزر ما يشتغل إلا إذا كل شي valid
  bool get _canSubmit {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final pass = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    final nameOk = name.length >= 2;
    final passOk = pass.length >= 6;
    final confirmOk = confirm.isNotEmpty && confirm == pass;

    final emailOk = !_useEmail ? true : _isValidEmail(email);
    final phoneOk = _useEmail
        ? (phone.isEmpty ? true : _isValidPhone(phone)) // optional
        : _isValidPhone(phone);

    return !_loading &&
        _agreeTerms &&
        nameOk &&
        emailOk &&
        phoneOk &&
        passOk &&
        confirmOk;
  }

  @override
  void initState() {
    super.initState();

    // ✅ Live validation listeners
    _nameController.addListener(_liveValidateName);
    _emailController.addListener(_liveValidateEmail);
    _phoneController.addListener(_liveValidatePhone);
    _passwordController.addListener(_liveValidatePasswordAndConfirm);
    _confirmController.addListener(_liveValidateConfirmOnly);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String v) {
    final value = v.trim();
    if (value.isEmpty) return false;
    final at = value.indexOf('@');
    if (at <= 0) return false;
    final dot = value.lastIndexOf('.');
    if (dot <= at + 1) return false;
    if (dot == value.length - 1) return false;
    return true;
  }

  bool _isValidPhone(String v) {
    final value = v.trim();
    if (value.isEmpty) return false;
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length >= 8;
  }

  // --------------------
  // ✅ Live Validation helpers
  // --------------------

  void _liveValidateName() {
    final name = _nameController.text.trim();
    final err = (name.isEmpty)
        ? null
        : (name.length < 2 ? 'الاسم لازم يكون حرفين على الأقل' : null);

    if (err != _nameError && mounted) {
      setState(() => _nameError = err);
    }
  }

  void _liveValidateEmail() {
    if (!_useEmail) return;

    final email = _emailController.text.trim();
    final err = (email.isEmpty)
        ? null
        : (_isValidEmail(email) ? null : 'Email غير صحيح');

    if (err != _emailError && mounted) {
      setState(() => _emailError = err);
    }
  }

  void _liveValidatePhone() {
    final phone = _phoneController.text.trim();

    if (_useEmail) {
      // optional
      final err = (phone.isEmpty)
          ? null
          : (_isValidPhone(phone) ? null : 'رقم الهاتف غير صحيح');
      if (err != _phoneError && mounted) {
        setState(() => _phoneError = err);
      }
    } else {
      // required
      final err = (phone.isEmpty)
          ? null
          : (_isValidPhone(phone) ? null : 'رقم الهاتف غير صحيح');
      if (err != _phoneError && mounted) {
        setState(() => _phoneError = err);
      }
    }
  }

  void _liveValidatePasswordAndConfirm() {
    final pass = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    final passErr = (pass.isEmpty)
        ? null
        : (pass.length < 6 ? 'Password لازم يكون 6 خانات أو أكثر' : null);

    // ✅ لما تتغير كلمة السر لازم نعيد فحص confirm فوراً
    final confirmErr = (confirm.isEmpty)
        ? null
        : (confirm == pass ? null : 'كلمات السر غير متطابقة');

    if (mounted) {
      if (passErr != _passwordError || confirmErr != _confirmError) {
        setState(() {
          _passwordError = passErr;
          _confirmError = confirmErr;
        });
      } else {
        // حتى الزر يتحدّث بشكل فوري بدون تغيير errors
        setState(() {});
      }
    }
  }

  void _liveValidateConfirmOnly() {
    final pass = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    final confirmErr = (confirm.isEmpty)
        ? null
        : (confirm == pass ? null : 'كلمات السر غير متطابقة');

    if (confirmErr != _confirmError && mounted) {
      setState(() => _confirmError = confirmErr);
    } else {
      // لتحديث _canSubmit
      if (mounted) setState(() {});
    }
  }

  void _liveValidateTerms() {
    final err = _agreeTerms ? null : 'لازم توافق على الشروط والأحكام';
    if (err != _termsError && mounted) {
      setState(() => _termsError = err);
    } else {
      if (mounted) setState(() {});
    }
  }

  // ✅ Final validation قبل الإرسال (بس يكون Live already)
  bool _validateAll() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final pass = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    String? nameErr;
    String? emailErr;
    String? phoneErr;
    String? passErr;
    String? confirmErr;
    String? termsErr;

    if (name.isEmpty || name.length < 2) {
      nameErr = 'الاسم لازم يكون حرفين على الأقل';
    }

    if (_useEmail) {
      if (!_isValidEmail(email)) {
        emailErr = 'Email غير صحيح';
      }
      if (phone.isNotEmpty && !_isValidPhone(phone)) {
        phoneErr = 'رقم الهاتف غير صحيح';
      }
    } else {
      if (!_isValidPhone(phone)) {
        phoneErr = 'رقم الهاتف غير صحيح';
      }
    }

    if (pass.isEmpty) {
      passErr = 'Password مطلوب';
    } else if (pass.length < 6) {
      passErr = 'Password لازم يكون 6 خانات أو أكثر';
    }

    if (confirm.isEmpty) {
      confirmErr = 'Confirm Password مطلوب';
    } else if (confirm != pass) {
      confirmErr = 'كلمات السر غير متطابقة';
    }

    if (!_agreeTerms) {
      termsErr = 'لازم توافق على الشروط والأحكام';
    }

    setState(() {
      _nameError = nameErr;
      _emailError = emailErr;
      _phoneError = phoneErr;
      _passwordError = passErr;
      _confirmError = confirmErr;
      _termsError = termsErr;
    });

    return nameErr == null &&
        emailErr == null &&
        phoneErr == null &&
        passErr == null &&
        confirmErr == null &&
        termsErr == null;
  }

  Future<void> _onSignup() async {
    if (_loading) return;

    // ✅ منع الإرسال إذا مش valid
    if (!_validateAll()) {
      if (!mounted) return;
      if (_termsError != null) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_termsError!),
            duration: const Duration(milliseconds: 1200),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
      if (!mounted) return;

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر إنشاء الحساب. حاول مرة ثانية.'),
          duration: Duration(milliseconds: 1200),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
            const AuthHeader(showBack: true),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height * 0.01),
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
                                  setState(() {
                                    _useEmail = true;
                                    _emailError = null;
                                    _phoneError = null;
                                  });
                                  _liveValidateEmail();
                                  _liveValidatePhone();
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
                                  setState(() {
                                    _useEmail = false;
                                    _emailError = null;
                                    _phoneError = null;
                                  });
                                  _liveValidateEmail();
                                  _liveValidatePhone();
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

                    // Name
                    AuthTextField(
                      label: 'Name',
                      hint: 'Enter your name',
                      prefixIcon: Icons.person_outline,
                      controller: _nameController,
                      errorText: _nameError,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: vSpaceMd),

                    if (_useEmail) ...[
                      AuthTextField(
                        label: 'Email ID',
                        hint: 'Enter your email',
                        prefixIcon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        errorText: _emailError,
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: vSpaceMd),
                      AuthTextField(
                        label: 'Phone Number (optional)',
                        hint: 'Enter your phone number',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        controller: _phoneController,
                        errorText: _phoneError,
                        textInputAction: TextInputAction.next,
                      ),
                    ] else ...[
                      AuthTextField(
                        label: 'Phone Number',
                        hint: 'Enter your phone number',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        controller: _phoneController,
                        errorText: _phoneError,
                        textInputAction: TextInputAction.next,
                      ),
                    ],

                    SizedBox(height: vSpaceMd),

                    // Password
                    AuthTextField(
                      label: 'Password',
                      hint: 'Create a password',
                      prefixIcon: Icons.lock_outline,
                      controller: _passwordController,
                      obscure: _obscurePassword,
                      errorText: _passwordError,
                      onToggleObscure: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: vSpaceMd),

                    // Confirm
                    AuthTextField(
                      label: 'Confirm Password',
                      hint: 'Re-enter your password',
                      prefixIcon: Icons.lock_outline,
                      controller: _confirmController,
                      obscure: _obscureConfirm,
                      errorText: _confirmError,
                      onToggleObscure: () {
                        setState(() => _obscureConfirm = !_obscureConfirm);
                      },
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _onSignup(),
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
                            onChanged: (v) {
                              setState(() {
                                _agreeTerms = v ?? false;
                              });
                              _liveValidateTerms();
                            },
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

                    if (_termsError != null) ...[
                      SizedBox(height: vSpaceXs),
                      Text(
                        _termsError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],

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

                    // ✅ CTA Disabled if invalid + loading safe
                    _loading
                        ? SizedBox(
                            height: height * 0.065,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : AuthPrimaryButton(
                            label: 'Create account',
                            onPressed: _onSignup,
                            enabled: _canSubmit, // ✅
                          ),

                    SizedBox(height: height * 0.03),

                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: theme.textTheme.bodyMedium,
                          ),
                          GestureDetector(
                            onTap: () => context.go('/login'),
                            child: Text(
                              'Log in',
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
    final cs = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);
    final height = size.height;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.symmetric(vertical: height * 0.012),
      decoration: BoxDecoration(
        color: isSelected ? cs.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Center(
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? cs.onPrimary
                : theme.textTheme.bodyMedium?.color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
