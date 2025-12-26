import 'package:flutter/material.dart';

class InterestChip extends StatefulWidget {
  final String label;
  final IconData? icon; // ✅ NEW
  final bool selected;
  final VoidCallback onTap;

  const InterestChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  State<InterestChip> createState() => _InterestChipState();
}

class _InterestChipState extends State<InterestChip> {
  double _scale = 1.0;

  void _press(bool down) {
    setState(() => _scale = down ? 0.98 : 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    final radius = h * 0.03;

    final bg = widget.selected
        ? cs.secondary.withOpacity(
            theme.brightness == Brightness.light ? 0.16 : 0.22,
          )
        : cs.surfaceContainerHighest.withOpacity(
            theme.brightness == Brightness.light ? 0.55 : 0.16,
          );

    final border = widget.selected
        ? cs.secondary.withOpacity(0.85)
        : cs.outline.withOpacity(
            theme.brightness == Brightness.light ? 0.18 : 0.28,
          );

    final iconColor = widget.selected
        ? cs.secondary
        : cs.onSurface.withOpacity(0.75);
    final textColor = widget.selected
        ? cs.secondary
        : cs.onSurface.withOpacity(0.85);

    return GestureDetector(
      onTapDown: (_) => _press(true),
      onTapCancel: () => _press(false),
      onTapUp: (_) => _press(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal: w * 0.035,
            vertical: h * 0.012,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: w * 0.045, color: iconColor),
                SizedBox(width: w * 0.02),
              ],
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: w * 0.55),
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
