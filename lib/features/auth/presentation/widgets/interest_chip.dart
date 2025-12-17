import 'package:flutter/material.dart';

class InterestChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const InterestChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    final isLight = theme.brightness == Brightness.light;

    final bg = selected
        ? cs.primary
        : cs.surfaceContainerHighest.withOpacity(isLight ? 0.55 : 0.18);

    final border = selected
        ? Colors.transparent
        : cs.outline.withOpacity(isLight ? 0.22 : 0.16);

    final textColor = selected ? cs.onPrimary : cs.onSurface.withOpacity(0.9);

    return InkWell(
      borderRadius: BorderRadius.circular(size.height * 0.028),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.05,
          vertical: size.height * 0.012,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(size.height * 0.028),
          border: Border.all(color: border, width: size.height * 0.0012),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
