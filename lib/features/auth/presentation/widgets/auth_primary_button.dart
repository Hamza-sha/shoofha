import 'package:flutter/material.dart';
import 'package:shoofha/app/theme/app_theme.dart';

class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final theme = Theme.of(context);

    // نجيب الإكستنشن اللي فيها الجريدينت
    final shoofhaTheme = theme.extension<ShoofhaTheme>();

    final borderRadius = BorderRadius.circular(height * 0.032);

    return SizedBox(
      width: double.infinity,
      height: height * 0.065,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: shoofhaTheme?.primaryButtonGradient,
          borderRadius: borderRadius,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: onPressed,
            child: Center(
              child: Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
