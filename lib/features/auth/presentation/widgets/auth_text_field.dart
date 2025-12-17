import 'package:flutter/material.dart';
import 'package:shoofha/core/responsive/responsive.dart';

class AuthTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData prefixIcon;
  final TextEditingController controller;

  final bool obscure;
  final VoidCallback? onToggleObscure;

  // ✅ NEW
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;

  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    required this.controller,
    this.obscure = false,
    this.onToggleObscure,
    this.errorText,
    this.onChanged,
    this.textInputAction,
    this.onSubmitted,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);
    final h = Responsive.height(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final borderRadius = BorderRadius.circular(h * 0.02);

    // ✅ Background مناسب Light/Dark
    final fill = theme.brightness == Brightness.light
        ? cs.surfaceContainerHighest.withOpacity(0.55)
        : cs.surfaceContainerHighest.withOpacity(0.20);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: h * 0.01),
        TextField(
          controller: controller,
          obscureText: obscure,
          onChanged: onChanged,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          keyboardType: keyboardType,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: cs.onSurface, // ✅ واضح 100% بالدارك
          ),
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            filled: true,
            fillColor: fill,
            prefixIcon: Icon(prefixIcon, color: cs.onSurface.withOpacity(0.75)),
            suffixIcon: onToggleObscure == null
                ? null
                : IconButton(
                    onPressed: onToggleObscure,
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                      color: cs.onSurface.withOpacity(0.70),
                    ),
                  ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: w * 0.04,
              vertical: h * 0.018,
            ),
            border: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: cs.outline.withOpacity(0.18)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: cs.outline.withOpacity(0.18)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: cs.secondary, width: h * 0.0018),
            ),
          ),
        ),
      ],
    );
  }
}
