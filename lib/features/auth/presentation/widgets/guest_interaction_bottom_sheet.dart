import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoofha/core/responsive/responsive.dart';

Future<void> showGuestInteractionBottomSheet(BuildContext context) async {
  final w = Responsive.width(context);
  final h = Responsive.height(context);

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: w * 0.06,
          right: w * 0.06,
          top: h * 0.02,
          bottom: MediaQuery.of(context).viewInsets.bottom + h * 0.02,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: w * 0.16,
                height: 4,
                margin: EdgeInsets.only(bottom: h * 0.016),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Text(
              'تسجيل الدخول للاستمرار',
              style: TextStyle(fontSize: w * 0.05, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: h * 0.008),
            Text(
              'هاي الميزة متاحة فقط للمستخدمين المسجّلين. '
              'سجّل دخولك عشان تقدر تعمل تفاعل، تحفظ، أو تكمل عملية الشراء.',
              style: TextStyle(
                fontSize: w * 0.035,
                height: 1.4,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.75),
              ),
            ),
            SizedBox(height: h * 0.02),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.pushNamed('login');
                },
                child: const Text('تسجيل الدخول'),
              ),
            ),
            SizedBox(height: h * 0.01),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.pushNamed('signup');
                },
                child: const Text('إنشاء حساب جديد'),
              ),
            ),
            SizedBox(height: h * 0.01),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('متابعة كضيف'),
              ),
            ),
          ],
        ),
      );
    },
  );
}
