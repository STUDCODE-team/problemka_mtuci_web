import 'package:flutter/material.dart';

class AppColors {
  // ─── Light — cool blue-grey / indigo ───────────────────────────────────────

  /// Page scaffold — very light blue-grey tint
  static const Color backgroundLight = Color(0xFFEEEFF6);

  /// Sidebar / rail background
  static const Color sidebarLight = Color(0xFFFFFFFF);

  /// Card / panel surface
  static const Color cardLight = Color(0xFFFFFFFF);

  /// Input fill (slightly off-white)
  static const Color elevatedCardLight = Color(0xFFF4F5FC);

  /// Deep indigo-purple primary accent
  static const Color primaryLight = Color(0xFF372678);

  /// Primary text
  static const Color foregroundLight = Color(0xFF1A1A2E);

  /// Muted / secondary text
  static const Color mutedForegroundLight = Color(0xFF6B7280);

  /// Subtle border (6 % black)
  static const Color borderLight = Color(0x0F000000);

  /// Green accent for icon backgrounds
  static const Color accentGreenLight = Color(0xFF4ADE80);

  /// Destructive / error red
  static const Color destructiveLight = Color(0xFFD4183D);

  // Legacy aliases
  static const Color secondaryLight = cardLight;
  static const Color mutedLight = elevatedCardLight;
  static const Color accentLight = elevatedCardLight;

  // ─── Dark — navy / indigo ──────────────────────────────────────────────────

  /// Main scaffold background — deepest layer
  static const Color backgroundDark = Color(0xFF161929);

  /// Sidebar / rail background
  static const Color sidebarDark = Color(0xFF0D0F1A);

  /// Card / panel surface
  static const Color cardDark = Color(0xFF1C2035);

  /// Elevated card / input fill
  static const Color elevatedCardDark = Color(0xFF252A42);

  /// Indigo-purple primary accent
  static const Color primaryDark = Color(0xFF5B4FCF);

  /// Primary text — near-white with cool tint
  static const Color foregroundDark = Color(0xFFF0F2FF);

  /// Muted / secondary text
  static const Color mutedForegroundDark = Color(0xFF8892A4);

  /// Subtle white border (8 % opacity)
  static const Color borderDark = Color(0x14FFFFFF);

  /// Green accent
  static const Color accentGreenDark = Color(0xFF4ADE80);

  /// Destructive / error red
  static const Color destructiveDark = Color(0xFFF04060);

  // Legacy aliases
  static const Color secondaryDark = cardDark;
  static const Color mutedDark = elevatedCardDark;
  static const Color accentDark = elevatedCardDark;
}
