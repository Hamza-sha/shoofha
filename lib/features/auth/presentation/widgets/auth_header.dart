import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthHeader extends StatelessWidget {
  final bool showBack;
  final VoidCallback? onBack;

  const AuthHeader({super.key, this.showBack = false, this.onBack});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cs = Theme.of(context).colorScheme;
    final primaryColor = cs.primary;

    final topInset = MediaQuery.paddingOf(context).top;
    final headerHeight = size.height * 0.22;

    final backSize = size.height * 0.045;
    final backRadius = backSize * 0.45;

    return SizedBox(
      height: headerHeight,
      child: Stack(
        children: [
          // الخلفية المنحنية العلوية
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: size.width * 0.9,
              height: size.height * 0.28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(size.width * 0.6),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor.withOpacity(0.2),
                    primaryColor.withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ),

          // زر الرجوع (اختياري)
          if (showBack)
            PositionedDirectional(
              start: size.width * 0.04,
              top: topInset + size.height * 0.01,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(backRadius),
                  onTap:
                      onBack ??
                      () {
                        final router = GoRouter.of(context);
                        if (router.canPop()) {
                          router.pop();
                        } else {
                          // fallback آمن إذا الشاشة كانت أول وحدة بالمكدس
                          router.go('/welcome'); // أو '/login' إذا بدك
                        }
                      },

                  child: Container(
                    width: backSize,
                    height: backSize,
                    decoration: BoxDecoration(
                      color: cs.surface.withOpacity(
                        Theme.of(context).brightness == Brightness.light
                            ? 0.65
                            : 0.18,
                      ),
                      borderRadius: BorderRadius.circular(backRadius),
                      border: Border.all(
                        color: cs.outline.withOpacity(
                          Theme.of(context).brightness == Brightness.light
                              ? 0.25
                              : 0.18,
                        ),
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: backSize * 0.45,
                      color: cs.onSurface.withOpacity(0.9),
                    ),
                  ),
                ),
              ),
            ),

          // اللوغو
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: size.height * 0.05),
              child: Image.asset(
                'assets/logo/shoofha_logo.png',
                height: size.height * 0.06,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
