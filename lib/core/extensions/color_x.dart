import 'dart:ui';

extension ShoofhaColorX on Color {
  /// بديل آمن لـ withOpacity (بدون deprecated)
  Color o(double opacity) => withValues(alpha: opacity.clamp(0.0, 1.0));
}
