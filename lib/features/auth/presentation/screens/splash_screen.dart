import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shoofha/app/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      context.go('/welcome');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final shoofhaTheme = theme.extension<ShoofhaTheme>();

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // خلفية دوائر / قوس gradient خفيف
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: width * 0.9,
              height: height * 0.32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(width * 0.7),
                ),
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

          // اللوجو في المنتصف
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: width * 0.32,
                  height: width * 0.32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          theme.brightness == Brightness.light ? 0.08 : 0.4,
                        ),
                        blurRadius: height * 0.028,
                        offset: Offset(0, height * 0.01),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(width * 0.06),
                    child: Image.asset(
                      'assets/logo/shoofha_icon.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: height * 0.018),
                Text(
                  'Shoofha',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
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
