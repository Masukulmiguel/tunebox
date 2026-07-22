import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTypography {
  static const String _fontFamily = 'Poppins';

  // ── Display ──
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 40,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.5,
    height: 1.15,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    height: 1.2,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.25,
  );

  // ── Headlines ──
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.35,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );

  // ── Titles ──
  static const TextStyle titleLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.45,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );

  // ── Body ──
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
    height: 1.5,
  );

  // ── Labels ──
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.8,
    height: 1.4,
  );

  // ── Button ──
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.4,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.4,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.4,
  );

  // ── Helpers to apply colors ──
  static TextStyle withColor(TextStyle style, Color color) =>
      style.copyWith(color: color);

  static TextStyle get displayLargeDark =>
      withColor(displayLarge, AppColors.textDark);
  static TextStyle get displayLargeLight =>
      withColor(displayLarge, AppColors.textWhite);
  static TextStyle get headlineLargeDark =>
      withColor(headlineLarge, AppColors.textDark);
  static TextStyle get headlineLargeLight =>
      withColor(headlineLarge, AppColors.textWhite);
  static TextStyle get titleLargeDark =>
      withColor(titleLarge, AppColors.textDark);
  static TextStyle get titleLargeLight =>
      withColor(titleLarge, AppColors.textWhite);
  static TextStyle get bodyLargeDark =>
      withColor(bodyLarge, AppColors.textPrimary);
  static TextStyle get bodyLargeLight =>
      withColor(bodyLarge, AppColors.textDark);
  static TextStyle get bodyMediumDark =>
      withColor(bodyMedium, AppColors.textSecondary);
  static TextStyle get bodyMediumLight =>
      withColor(bodyMedium, AppColors.textDarkSecondary);
  static TextStyle get labelLargeOnPrimary =>
      withColor(labelLarge, AppColors.textWhite);
}
