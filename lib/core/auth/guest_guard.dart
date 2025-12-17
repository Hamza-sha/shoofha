// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shoofha/features/auth/application/auth_notifier.dart';

/// يرجّع true لو اليوزر مسجّل دخول (مش Guest)، false لو Guest/مش مسجّل.
/// لو Guest/مش مسجّل: يفتح BottomSheet يخيّره بين Login / Signup.
Future<bool> requireLogin(BuildContext context) async {
  // ✅ مسجل دخول فعلي (مش ضيف)
  if (authNotifier.isLoggedIn && !authNotifier.isGuest) {
    return true;
  }

  final theme = Theme.of(context);

  final result = await showModalBottomSheet<_GuestAction>(
    context: context,
    isScrollControlled: true, // ✅ مهم
    backgroundColor: theme.colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(MediaQuery.sizeOf(context).height * 0.03),
      ),
    ),
    builder: (context) {
      final size = MediaQuery.sizeOf(context);
      final h = size.height;
      final w = size.width;

      return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            w * 0.06,
            h * 0.02,
            w * 0.06,
            h * 0.02 + MediaQuery.of(context).viewPadding.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: w * 0.12,
                    height: h * 0.006,
                    margin: EdgeInsets.only(bottom: h * 0.02),
                    decoration: BoxDecoration(
                      color: theme.dividerColor.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Text(
                  'تحتاج إلى حساب للاستمرار',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: h * 0.01),
                Text(
                  'سجّل دخولك أو أنشئ حساب جديد للاستفادة من هذه الميزة (حفظ، لايك، رسائل، تواصل مع المتجر).',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: h * 0.025),
                SizedBox(
                  width: double.infinity,
                  height: h * 0.06,
                  child: FilledButton(
                    onPressed: () =>
                        Navigator.of(context).pop(_GuestAction.login),
                    child: const Text('تسجيل الدخول'),
                  ),
                ),
                SizedBox(height: h * 0.012),
                SizedBox(
                  width: double.infinity,
                  height: h * 0.06,
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.of(context).pop(_GuestAction.signup),
                    child: const Text('إنشاء حساب جديد'),
                  ),
                ),
                SizedBox(height: h * 0.012),
                Center(
                  child: TextButton(
                    onPressed: () =>
                        Navigator.of(context).pop(_GuestAction.cancel),
                    child: const Text('إلغاء'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  // ✅ Navigation (بدون goNamed عشان ما نغلب على أسماء الراوتس)
  switch (result) {
    case _GuestAction.login:
      context.go('/login');
      return false;
    case _GuestAction.signup:
      context.go('/signup');
      return false;
    case _GuestAction.cancel:
    case null:
      return false;
  }
}

enum _GuestAction { login, signup, cancel }
