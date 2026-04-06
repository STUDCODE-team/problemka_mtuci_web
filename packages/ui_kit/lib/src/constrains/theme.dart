import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';
import 'radius.dart';
import 'typography.dart';

class AppTheme {
  // ─── Light ─────────────────────────────────────────────────────────────────
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primaryLight,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE8E3FF),
      onPrimaryContainer: AppColors.primaryLight,
      secondary: AppColors.cardLight,
      onSecondary: AppColors.foregroundLight,
      secondaryContainer: AppColors.elevatedCardLight,
      onSecondaryContainer: AppColors.foregroundLight,
      tertiary: AppColors.accentGreenLight,
      onTertiary: Color(0xFF0A2A1A),
      tertiaryContainer: Color(0xFFDCFCE7),
      onTertiaryContainer: Color(0xFF14532D),
      surface: AppColors.backgroundLight,
      surfaceContainerLowest: AppColors.sidebarLight,
      surfaceContainerLow: AppColors.backgroundLight,
      surfaceContainer: AppColors.cardLight,
      surfaceContainerHigh: AppColors.elevatedCardLight,
      surfaceContainerHighest: AppColors.elevatedCardLight,
      onSurface: AppColors.foregroundLight,
      onSurfaceVariant: AppColors.mutedForegroundLight,
      outline: AppColors.borderLight,
      outlineVariant: Color(0x08000000),
      error: AppColors.destructiveLight,
      onError: Colors.white,
      errorContainer: Color(0xFFFFE4E6),
      onErrorContainer: Color(0xFF9B1C1C),
    ),

    scaffoldBackgroundColor: AppColors.backgroundLight,

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundLight,
      foregroundColor: AppColors.foregroundLight,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.foregroundLight,
      ),
    ),

    textTheme: AppTypography.montserratTextTheme(AppColors.foregroundLight),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.circularXl),
        minimumSize: const Size(double.infinity, 56),
        elevation: 0,
        textStyle: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.elevatedCardLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(borderRadius: AppRadius.circularXl, borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.circularXl,
        borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.circularXl,
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
      ),
      hintStyle: GoogleFonts.montserrat(fontSize: 16, color: AppColors.mutedForegroundLight),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.cardLight,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.circularXl,
        side: const BorderSide(color: AppColors.borderLight, width: 1),
      ),
    ),

    dividerTheme: const DividerThemeData(color: AppColors.borderLight, thickness: 1),

    listTileTheme: const ListTileThemeData(
      tileColor: Colors.transparent,
      iconColor: AppColors.mutedForegroundLight,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? Colors.white : AppColors.mutedForegroundLight),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? AppColors.primaryLight : AppColors.elevatedCardLight),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: AppColors.cardLight,
      selectedColor: AppColors.primaryLight,
      labelStyle: GoogleFonts.montserrat(fontSize: 14, color: AppColors.foregroundLight),
      side: const BorderSide(color: AppColors.borderLight, width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.cardLight,
      contentTextStyle: GoogleFonts.montserrat(color: AppColors.foregroundLight),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.cardLight,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.foregroundLight,
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.sidebarLight,
      selectedItemColor: AppColors.primaryLight,
      unselectedItemColor: AppColors.mutedForegroundLight,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),

    iconTheme: const IconThemeData(color: AppColors.mutedForegroundLight),
    primaryIconTheme: const IconThemeData(color: AppColors.primaryLight),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.primaryLight),
  );

  // ─── Dark — navy / indigo ──────────────────────────────────────────────────
  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryDark,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF3B2F8F),
      onPrimaryContainer: Color(0xFFD4CDFF),
      secondary: AppColors.cardDark,
      onSecondary: AppColors.foregroundDark,
      secondaryContainer: AppColors.elevatedCardDark,
      onSecondaryContainer: AppColors.foregroundDark,
      tertiary: AppColors.accentGreenDark,
      onTertiary: Color(0xFF0A2A1A),
      tertiaryContainer: Color(0xFF1A4A2E),
      onTertiaryContainer: Color(0xFFB0F4CC),
      surface: AppColors.backgroundDark,
      surfaceContainerLowest: AppColors.sidebarDark,
      surfaceContainerLow: AppColors.backgroundDark,
      surfaceContainer: AppColors.cardDark,
      surfaceContainerHigh: AppColors.elevatedCardDark,
      surfaceContainerHighest: AppColors.elevatedCardDark,
      onSurface: AppColors.foregroundDark,
      onSurfaceVariant: AppColors.mutedForegroundDark,
      outline: AppColors.borderDark,
      outlineVariant: Color(0x0AFFFFFF),
      error: AppColors.destructiveDark,
      onError: Colors.white,
      errorContainer: Color(0xFF5A1A28),
      onErrorContainer: Color(0xFFFFB3C0),
    ),

    scaffoldBackgroundColor: AppColors.backgroundDark,

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: AppColors.foregroundDark,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.foregroundDark,
      ),
    ),

    textTheme: AppTypography.montserratTextTheme(AppColors.foregroundDark),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.circularXl),
        minimumSize: const Size(double.infinity, 56),
        elevation: 0,
        textStyle: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.elevatedCardDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(borderRadius: AppRadius.circularXl, borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.circularXl,
        borderSide: const BorderSide(color: AppColors.borderDark, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.circularXl,
        borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.5),
      ),
      hintStyle: GoogleFonts.montserrat(fontSize: 16, color: AppColors.mutedForegroundDark),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.cardDark,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.circularXl,
        side: const BorderSide(color: AppColors.borderDark, width: 1),
      ),
    ),

    dividerTheme: const DividerThemeData(color: AppColors.borderDark, thickness: 1),

    listTileTheme: const ListTileThemeData(
      tileColor: Colors.transparent,
      iconColor: AppColors.mutedForegroundDark,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? Colors.white : AppColors.mutedForegroundDark),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? AppColors.primaryDark : AppColors.elevatedCardDark),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: AppColors.cardDark,
      selectedColor: AppColors.primaryDark,
      labelStyle: GoogleFonts.montserrat(fontSize: 14, color: AppColors.foregroundDark),
      side: const BorderSide(color: AppColors.borderDark, width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.cardDark,
      contentTextStyle: GoogleFonts.montserrat(color: AppColors.foregroundDark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.cardDark,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.foregroundDark,
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.sidebarDark,
      selectedItemColor: AppColors.primaryDark,
      unselectedItemColor: AppColors.mutedForegroundDark,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),

    iconTheme: const IconThemeData(color: AppColors.mutedForegroundDark),
    primaryIconTheme: const IconThemeData(color: AppColors.primaryDark),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.primaryDark),
  );
}
