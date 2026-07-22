import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppShadows {
  static const List<BoxShadow> small = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> large = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> extraLarge = [
    BoxShadow(
      color: Color(0x24000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static List<BoxShadow> colored(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> coloredSmall(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.2),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static const List<BoxShadow> cardDark = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> glow = [
    BoxShadow(
      color: Color(0x338B5CF6),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];

  static const List<BoxShadow> playerShadow = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 30,
      offset: Offset(0, -5),
    ),
  ];
}
