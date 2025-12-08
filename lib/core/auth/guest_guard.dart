// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shoofha/features/auth/application/auth_notifier.dart';

/// يرجّع true لو اليوزر مسجّل دخول، false لو ضيف
/// لو كان ضيف: يفتح bottom sheet يخيّره بين تسجيل الدخول / إنشاء حساب
Future<bool> requireLogin(BuildContext context) async {
  // لو هو أصلاً مسجّل دخول → كمل طبيعي
  if (authNotifier.isLoggedIn) {
    return true;
  }

  final theme = Theme.of(context);

  final result = await showModalBottomSheet<_GuestAction>(
    context: context,
    backgroundColor: theme.colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      final size = MediaQuery.sizeOf(context);
      final h = size.height;
      final w = size.width;

      return Padding(
        padding: EdgeInsets.fromLTRB(
          w * 0.06,
          h * 0.02,
          w * 0.06,
          h * 0.03 + MediaQuery.of(context).viewPadding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: w * 0.12,
                height: 4,
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
              style: theme.textTheme.bodyMedium,
            ),
            SizedBox(height: h * 0.025),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(_GuestAction.login);
                },
                child: const Text('تسجيل الدخول'),
              ),
            ),
            SizedBox(height: h * 0.012),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop(_GuestAction.signup);
                },
                child: const Text('إنشاء حساب جديد'),
              ),
            ),
            SizedBox(height: h * 0.012),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(_GuestAction.cancel);
                },
                child: const Text('إلغاء'),
              ),
            ),
          ],
        ),
      );
    },
  );

  // بناءً على اختيار اليوزر
  switch (result) {
    case _GuestAction.login:
      // نستخدم GoRouter بالإسم
      context.goNamed('login');
      return false;
    case _GuestAction.signup:
      context.goNamed('signup');
      return false;
    case _GuestAction.cancel:
    case null:
      return false;
  }
}

enum _GuestAction { login, signup, cancel }
