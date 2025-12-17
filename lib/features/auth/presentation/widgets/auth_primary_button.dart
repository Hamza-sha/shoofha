import 'package:flutter/material.dart';
import 'package:shoofha/app/theme/app_theme.dart';

class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed; // ✅ nullable
  final bool enabled; // ✅ explicit

  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final theme = Theme.of(context);

    final shoofhaTheme = theme.extension<ShoofhaTheme>();
    final borderRadius = BorderRadius.circular(height * 0.032);

    final isEnabled = enabled && onPressed != null;

    return SizedBox(
      width: double.infinity,
      height: height * 0.065,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.45,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: shoofhaTheme?.primaryButtonGradient,
            borderRadius: borderRadius,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: borderRadius,
              onTap: isEnabled ? onPressed : null,
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
      ),
    );
  }
}
