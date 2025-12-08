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
    final primaryColor = Theme.of(context).colorScheme.primary;
    final size = MediaQuery.of(context).size;

    return InkWell(
      borderRadius: BorderRadius.circular(size.height * 0.028),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.05,
          vertical: size.height * 0.012,
        ),
        decoration: BoxDecoration(
          color: selected ? primaryColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(size.height * 0.028),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
