import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Primary Palette (derived from TuneBox logo) ──
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color primaryGradientStart = Color(0xFF9333EA);
  static const Color primaryGradientEnd = Color(0xFF2563EB);

  // ── Accent ──
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentCyan = Color(0xFF06B6D4);

  // ── Dark Theme ──
  static const Color darkBackground = Color(0xFF0A0A1A);
  static const Color darkSurface = Color(0xFF12122A);
  static const Color darkSurfaceVariant = Color(0xFF1A1A3E);
  static const Color darkCard = Color(0xFF16162E);
  static const Color darkElevated = Color(0xFF1E1E42);
  static const Color darkBorder = Color(0xFF2A2A52);

  // ── Light Theme ──
  static const Color lightBackground = Color(0xFFF8F9FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F3F9);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightElevated = Color(0xFFF5F6FA);
  static const Color lightBorder = Color(0xFFE2E5F1);

  // ── Text Colors ──
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFFE8E8F0);
  static const Color textSecondary = Color(0xFF9CA3BF);
  static const Color textTertiary = Color(0xFF6B7194);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textDarkSecondary = Color(0xFF6B7280);

  // ── Status Colors ──
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ── Misc ──
  static const Color divider = Color(0xFF1E1E3A);
  static const Color dividerLight = Color(0xFFE5E7EB);
  static const Color shimmerBase = Color(0xFF1A1A3E);
  static const Color shimmerHighlight = Color(0xFF252550);
  static const Color shimmerBaseLight = Color(0xFFE5E7EB);
  static const Color shimmerHighlightLight = Color(0xFFF3F4F6);
  static const Color overlay = Color(0x80000000);
  static const Color playerGradientStart = Color(0xFF1A0533);
  static const Color playerGradientEnd = Color(0xFF0A0A1A);

  // ── Gradients ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGradientStart, primaryGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleBlueGradient = LinearGradient(
    colors: [primaryPurple, primaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [darkBackground, darkSurface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient playerGradient = LinearGradient(
    colors: [playerGradientStart, playerGradientEnd],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [darkCard, darkSurfaceVariant],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [shimmerBase, shimmerHighlight, shimmerBase],
    stops: [0.1, 0.5, 0.9],
  );
}
