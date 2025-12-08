// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AppColors {
  // ?????? ????????
  static const navy = Color(0xFF1B2559); // Primary
  static const teal = Color(0xFF2CCECE); // Secondary
  static const purple = Color(0xFF8E44AD); // Tertiary
  static const orange = Color(
    0xFFF58222,
  ); // Accent (????? ??????? ?? ?? ????? ????)
}

/// Extension ????? ???? ?????? (????? ?????????)
class ShoofhaTheme extends ThemeExtension<ShoofhaTheme> {
  final LinearGradient primaryButtonGradient;
  final LinearGradient primaryHeaderGradient;

  const ShoofhaTheme({
    required this.primaryButtonGradient,
    required this.primaryHeaderGradient,
  });

  @override
  ShoofhaTheme copyWith({
    LinearGradient? primaryButtonGradient,
    LinearGradient? primaryHeaderGradient,
  }) {
    return ShoofhaTheme(
      primaryButtonGradient:
          primaryButtonGradient ?? this.primaryButtonGradient,
      primaryHeaderGradient:
          primaryHeaderGradient ?? this.primaryHeaderGradient,
    );
  }

  @override
  ShoofhaTheme lerp(ThemeExtension<ShoofhaTheme>? other, double t) {
    if (other is! ShoofhaTheme) return this;

    return ShoofhaTheme(
      primaryButtonGradient:
          LinearGradient.lerp(
            primaryButtonGradient,
            other.primaryButtonGradient,
            t,
          ) ??
          primaryButtonGradient,
      primaryHeaderGradient:
          LinearGradient.lerp(
            primaryHeaderGradient,
            other.primaryHeaderGradient,
            t,
          ) ??
          primaryHeaderGradient,
    );
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.navy,
      brightness: Brightness.light,
      primary: AppColors.navy,
      secondary: AppColors.teal,
      tertiary: AppColors.purple,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: colorScheme.primary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: const Color(0xFF212121),
        displayColor: const Color(0xFF212121),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: Colors.grey.shade100,
        selectedColor: colorScheme.secondary,
        labelStyle: base.textTheme.bodyMedium?.copyWith(
          color: const Color(0xFF212121),
        ),
        secondaryLabelStyle: base.textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: colorScheme.primary,
          textStyle: base.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.2),
          textStyle: base.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      iconTheme: base.iconTheme.copyWith(color: colorScheme.primary),
      extensions: const [
        ShoofhaTheme(
          primaryButtonGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.navy, AppColors.purple],
          ),
          primaryHeaderGradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.navy, AppColors.purple],
          ),
        ),
      ],
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.navy,
      brightness: Brightness.dark,
      primary: AppColors.navy,
      secondary: AppColors.teal,
      tertiary: AppColors.purple,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF050816),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF050816),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0E1224),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.12),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.12),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.secondary, width: 1.2),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        color: const Color(0xFF0E1224),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: const Color(0xFF0E1224),
        selectedColor: colorScheme.secondary,
        labelStyle: base.textTheme.bodyMedium?.copyWith(
          color: Colors.white.withOpacity(0.85),
        ),
        secondaryLabelStyle: base.textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: colorScheme.primary,
          textStyle: base.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withOpacity(0.8), width: 1.2),
          textStyle: base.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      iconTheme: base.iconTheme.copyWith(color: colorScheme.secondary),
      extensions: const [
        ShoofhaTheme(
          primaryButtonGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.navy, AppColors.purple],
          ),
          primaryHeaderGradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.navy, AppColors.purple],
          ),
        ),
      ],
    );
  }
}
