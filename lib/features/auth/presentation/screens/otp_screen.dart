import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoofha/features/auth/application/auth_notifier.dart';
import 'package:shoofha/features/auth/presentation/widgets/auth_header.dart';
import 'package:shoofha/features/auth/presentation/widgets/auth_primary_button.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _otpLength = 4;
  static const int _resendCooldownSeconds = 30;

  final List<TextEditingController> _controllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );

  Timer? _timer;
  int _secondsLeft = _resendCooldownSeconds;

  bool _loading = false;
  String? _otpError;

  bool get _isOtpComplete {
    for (final c in _controllers) {
      if (c.text.trim().length != 1) return false;
    }
    return true;
  }

  // ignore: unused_element
  String get _otpValue => _controllers.map((c) => c.text.trim()).join();

  bool get _canResend => _secondsLeft == 0 && !_loading;

  bool get _canVerify => _isOtpComplete && !_loading;

  @override
  void initState() {
    super.initState();
    _startResendTimer();

    for (final c in _controllers) {
      c.addListener(_onOtpChanged);
    }
  }

  void _onOtpChanged() {
    // إذا اليوزر صار يكتب من جديد، نشيل الخطأ فوراً
    if (_otpError != null && mounted) {
      setState(() => _otpError = null);
    } else {
      // لتحديث زر Verify
      if (mounted) setState(() {});
    }
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendCooldownSeconds);

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.removeListener(_onOtpChanged);
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(milliseconds: 1100), // ✅ أسرع و أنظف
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearOtp() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
  }

  Future<void> _onResend() async {
    if (!_canResend) return;

    _showSnack('تم إرسال رمز جديد');
    _clearOtp();
    _startResendTimer();

    // TODO: هنا لاحقاً تربطه بالـ API الفعلي لإعادة الإرسال
  }

  bool _validateOtp() {
    if (!_isOtpComplete) {
      setState(() => _otpError = 'ادخل رمز التحقق كامل');
      return false;
    }
    // إذا بدك قواعد أقوى (مثل: أرقام فقط) موجودة أصلاً من input formatter بالحقول
    return true;
  }

  Future<void> _onVerify() async {
    if (_loading) return;

    if (!_validateOtp()) return;

    setState(() => _loading = true);

    try {
      // TODO: ربط تحقق OTP الحقيقي لاحقاً
      // حالياً نجاح مباشر
      authNotifier.verifyOtpSuccess();

      if (!mounted) return;

      // أهم نقطة: بعد OTP نروح للـ Interests
      // (إذا عندك route مختلف غيّرها مرة واحدة)
      context.go('/choose-interests');
    } catch (_) {
      if (!mounted) return;
      setState(() => _otpError = 'رمز غير صحيح، حاول مرة ثانية');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onDigitChanged(int index, String v) {
    final value = v.trim();

    if (value.isEmpty) return;

    // نسمح برقم واحد فقط
    _controllers[index].text = value.characters.last;
    _controllers[index].selection = TextSelection.fromPosition(
      TextPosition(offset: _controllers[index].text.length),
    );

    // انتقال تلقائي
    if (index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isNotEmpty) {
      _controllers[index].clear();
      return;
    }
    if (index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    final horizontalPadding = w * 0.08;
    final boxSize = w * 0.14; // responsive
    final boxRadius = h * 0.02;

    return Scaffold(
      backgroundColor: cs.surface,
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
                    SizedBox(height: h * 0.01),
                    Text(
                      'OTP Verification',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: h * 0.008),
                    Text(
                      'Enter the 4-digit code we sent to you.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                    SizedBox(height: h * 0.03),

                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_otpLength, (i) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: w * 0.015,
                            ),
                            child: _OtpBox(
                              size: boxSize,
                              radius: boxRadius,
                              controller: _controllers[i],
                              focusNode: _focusNodes[i],
                              error: _otpError != null,
                              onChanged: (v) => _onDigitChanged(i, v),
                              onBackspace: () => _onBackspace(i),
                            ),
                          );
                        }),
                      ),
                    ),

                    if (_otpError != null) ...[
                      SizedBox(height: h * 0.015),
                      Center(
                        child: Text(
                          _otpError!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],

                    SizedBox(height: h * 0.03),

                    _loading
                        ? SizedBox(
                            height: h * 0.065,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : AuthPrimaryButton(
                            label: 'Verify',
                            onPressed: _onVerify,
                            enabled: _canVerify,
                          ),

                    SizedBox(height: h * 0.02),

                    Center(
                      child: TextButton(
                        onPressed: _canResend ? _onResend : null,
                        child: Text(
                          _canResend
                              ? 'Resend code'
                              : 'Resend in 00:${_secondsLeft.toString().padLeft(2, '0')}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _canResend
                                ? cs.secondary
                                : cs.onSurface.withOpacity(0.45),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: h * 0.03),
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

class _OtpBox extends StatelessWidget {
  final double size;
  final double radius;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool error;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  const _OtpBox({
    required this.size,
    required this.radius,
    required this.controller,
    required this.focusNode,
    required this.error,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final isLight = theme.brightness == Brightness.light;

    final border = error
        ? cs.error.withOpacity(0.8)
        : cs.outline.withOpacity(isLight ? 0.25 : 0.35);

    final fill = isLight
        ? cs.surfaceContainerHighest.withOpacity(0.55)
        : cs.surfaceContainerHighest.withOpacity(0.20);

    return SizedBox(
      width: size,
      height: size,
      child: Focus(
        onKeyEvent: (node, event) {
          if (event.logicalKey.keyLabel == 'Backspace') {
            onBackspace();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: fill,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(color: border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(color: cs.secondary, width: size * 0.03),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
