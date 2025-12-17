import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoofha/app/theme/app_theme.dart';
import 'package:shoofha/features/auth/application/auth_notifier.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final shoofhaTheme = theme.extension<ShoofhaTheme>();

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final horizontalPadding = width * 0.08;
    final vSpaceSm = height * 0.015;
    final vSpaceMd = height * 0.025;
    final vSpaceLg = height * 0.04;

    final topHeight = height * 0.45;
    final cardRadius = height * 0.03;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // الخلفية العلوية (Gradient قوي مع منحنى)
          SizedBox(
            height: topHeight,
            width: double.infinity,
            child: CustomPaint(
              painter: _WelcomeBackgroundPainter(
                gradient:
                    shoofhaTheme?.primaryButtonGradient ??
                    const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.navy, AppColors.purple],
                    ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // الجزء العلوي: لوجو + نص بسيط
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: height * 0.02,
                  ),
                  child: SizedBox(
                    height: topHeight - height * 0.05,
                    child: Column(
                      children: [
                        SizedBox(
                          height: height * 0.14,
                          child: Center(
                            child: Image.asset(
                              'assets/logo/shoofha_full_orange.png',
                              height: height * 0.08,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Welcome to Shoofha',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: vSpaceSm),
                        Text(
                          'Find stores, offers, and products that match your style.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.78),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: vSpaceSm),
                      ],
                    ),
                  ),
                ),

                // ✅ الجزء السفلي صار Scrollable لحل overflow 100%
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: height * 0.02),
                      child: Column(
                        children: [
                          // Card عائم
                          Transform.translate(
                            offset: Offset(0, -height * 0.06),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: width * 0.06,
                                vertical: height * 0.022,
                              ),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(cardRadius),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      theme.brightness == Brightness.light
                                          ? 0.06
                                          : 0.4,
                                    ),
                                    blurRadius: height * 0.03,
                                    offset: Offset(0, height * 0.015),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Shop. Discover. Connect.',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: vSpaceSm),
                                  Text(
                                    'A curated world of local stores, brands and experiences in one app.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.textTheme.bodyMedium?.color
                                          ?.withOpacity(0.7),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: vSpaceMd),

                                  // 3 Features
                                  _WelcomeFeatureRow(
                                    icon: Icons.storefront_outlined,
                                    text:
                                        'Explore unique local & online stores.',
                                  ),
                                  SizedBox(height: vSpaceSm),
                                  _WelcomeFeatureRow(
                                    icon: Icons.favorite_border,
                                    text:
                                        'Save your favorite products & brands.',
                                  ),
                                  SizedBox(height: vSpaceSm),
                                  _WelcomeFeatureRow(
                                    icon: Icons.notifications_none,
                                    text:
                                        'Get notified about offers that match you.',
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // بدل Spacer: مسافة ثابتة نسبياً (Responsive)
                          SizedBox(height: vSpaceMd),

                          // زر Log in
                          SizedBox(
                            width: double.infinity,
                            height: height * 0.065,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient:
                                    shoofhaTheme?.primaryButtonGradient ??
                                    const LinearGradient(
                                      colors: [
                                        AppColors.navy,
                                        AppColors.purple,
                                      ],
                                    ),
                                borderRadius: BorderRadius.circular(
                                  height * 0.032,
                                ),
                              ),
                              child: Material(
                                type: MaterialType.transparency,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(
                                    height * 0.032,
                                  ),
                                  onTap: () => context.go('/login'),
                                  child: Center(
                                    child: Text(
                                      'Log in',
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: vSpaceSm),

                          // زر Sign up
                          SizedBox(
                            width: double.infinity,
                            height: height * 0.065,
                            child: OutlinedButton(
                              onPressed: () => context.go('/signup'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: colorScheme.outline.withOpacity(0.4),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    height * 0.032,
                                  ),
                                ),
                              ),
                              child: const Text('Sign up'),
                            ),
                          ),

                          SizedBox(height: vSpaceSm * 0.8),

                          // Continue as Guest
                          TextButton(
                            onPressed: () async {
                              await authNotifier.continueAsGuest();
                              if (context.mounted) {
                                context.go('/app');
                              }
                            },
                            style: TextButton.styleFrom(
                              minimumSize: Size(width * 0.6, height * 0.048),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  height * 0.03,
                                ),
                              ),
                            ),
                            child: Text(
                              'Continue as a guest',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.secondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),

                          SizedBox(height: vSpaceLg * 0.6),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// الرور العلوي اللي فيه الأيقونة + النص
class _WelcomeFeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _WelcomeFeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    final iconSize = height * 0.024;
    final radius = height * 0.018;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: width * 0.1,
          height: height * 0.048,
          decoration: BoxDecoration(
            color: colorScheme.secondary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Icon(icon, size: iconSize, color: colorScheme.secondary),
        ),
        SizedBox(width: width * 0.04),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }
}

/// Painter للخلفية العلوية (Gradient مع شكل منحني)
class _WelcomeBackgroundPainter extends CustomPainter {
  final Gradient gradient;

  _WelcomeBackgroundPainter({required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()..shader = gradient.createShader(rect);

    final path = Path()
      ..lineTo(0, size.height * 0.75)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 1.05,
        size.width,
        size.height * 0.75,
      )
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);

    // دوائر خفيفة للديكور
    final circlePaint = Paint()..color = Colors.white.withOpacity(0.08);
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.32),
      size.width * 0.1,
      circlePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.18),
      size.width * 0.09,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _WelcomeBackgroundPainter oldDelegate) {
    return oldDelegate.gradient != gradient;
  }
}
