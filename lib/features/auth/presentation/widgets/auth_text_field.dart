import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final bool obscure;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final VoidCallback? onToggleObscure;

  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.onToggleObscure,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        SizedBox(height: size.height * 0.008),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(size.height * 0.025),
          ),
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              prefixIcon: prefixIcon == null
                  ? null
                  : Icon(prefixIcon, size: size.height * 0.024),
              suffixIcon: onToggleObscure == null
                  ? null
                  : IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                        size: size.height * 0.024,
                      ),
                      onPressed: onToggleObscure,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
