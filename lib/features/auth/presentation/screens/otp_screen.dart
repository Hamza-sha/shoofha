import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoofha/features/auth/application/auth_notifier.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_primary_button.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _controllers = List.generate(
    6,
    (_) => TextEditingController(),
    growable: false,
  );
  final _focusNodes = List.generate(6, (_) => FocusNode(), growable: false);

  int _seconds = 60;
  Timer? _timer;
  bool _verifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _seconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_seconds == 0) {
          timer.cancel();
        } else {
          _seconds--;
        }
      });
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String get _otp => _controllers.map((c) => c.text.trim()).join();

  Future<void> _onConfirm() async {
    if (_verifying) return;
    if (_otp.length != 6) {
      // TODO: ممكن تعرض رسالة "أدخل كود مكوّن من ٦ أرقام"
      return;
    }

    setState(() => _verifying = true);

    try {
      // TODO: تحقق فعلي من الكود مع API
      await Future<void>.delayed(const Duration(milliseconds: 700));

      authNotifier.verifyOtpSuccess();

      if (mounted) {
        context.go('/choose-interests');
      }
    } catch (e) {
      debugPrint('OTP verify error: $e');
    } finally {
      if (mounted) {
        setState(() => _verifying = false);
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
    final vSpaceSm = height * 0.015;
    final vSpaceMd = height * 0.025;
    final vSpaceLg = height * 0.04;

    final boxWidth = width * 0.11;
    final boxRadius = height * 0.018;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const AuthHeader(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: vSpaceSm),
                    Text(
                      'OTP Verification',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: vSpaceSm),
                    Text(
                      'Enter the 6-digit code sent to your phone or email.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: vSpaceLg),

                    // مربعات الكود
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: boxWidth,
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            onChanged: (v) => _onChanged(index, v),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: theme.cardColor,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: height * 0.016,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(boxRadius),
                                borderSide: BorderSide(
                                  color: colorScheme.outline.withOpacity(0.25),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(boxRadius),
                                borderSide: BorderSide(
                                  color: colorScheme.outline.withOpacity(0.25),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(boxRadius),
                                borderSide: BorderSide(
                                  color: colorScheme.secondary,
                                  width: 1.4,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    const Spacer(),

                    // Re-code + التايمر
                    TextButton(
                      onPressed: _seconds == 0 ? _startTimer : null,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Re-code ',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '0:${_seconds.toString().padLeft(2, '0')}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: vSpaceSm),

                    // زر التأكيد (Gradient)
                    _verifying
                        ? SizedBox(
                            width: double.infinity,
                            height: height * 0.065,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : AuthPrimaryButton(
                            label: 'Confirm',
                            onPressed: _onConfirm,
                          ),

                    SizedBox(height: vSpaceMd),
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
