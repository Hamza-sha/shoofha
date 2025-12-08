import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: size.height * 0.22,
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
          // اللوغو
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: size.height * 0.05),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // غيّر مسار الصورة حسب مشروعك
                  Image.asset(
                    'assets/logo/shoofha_logo.png',
                    height: size.height * 0.06,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
