import 'dart:ui';

extension ShoofhaColorX on Color {
  /// بديل آمن لـ withOpacity بدون مشاكل type
  Color withOpacitySafe(double opacity) {
    final o = opacity.clamp(0.0, 1.0);
    return withValues(alpha: o); // ✅ alpha = double
  }
}
