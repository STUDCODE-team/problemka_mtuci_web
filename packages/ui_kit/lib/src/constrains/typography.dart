import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class AppTypography {
  static const double fontSizeBase = 16.0;
  static const double lineHeight = 1.5;

  static const FontWeight fontWeightNormal = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;

  static TextStyle get h1Light => GoogleFonts.montserrat(
        fontSize: 24,
        fontWeight: fontWeightMedium,
        height: lineHeight,
        color: AppColors.foregroundLight,
      );

  static TextStyle get h2Light => GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: fontWeightMedium,
        height: lineHeight,
        color: AppColors.foregroundLight,
      );

  static TextStyle get bodyLight => GoogleFonts.montserrat(
        fontSize: fontSizeBase,
        fontWeight: fontWeightNormal,
        height: lineHeight,
        color: AppColors.foregroundLight,
      );

  static TextStyle get labelLight => GoogleFonts.montserrat(
        fontSize: fontSizeBase,
        fontWeight: fontWeightMedium,
        height: lineHeight,
        color: AppColors.foregroundLight,
      );

  /// Returns a [TextTheme] with all styles set to Montserrat.
  /// Pass to [ThemeData.textTheme] / [ThemeData.primaryTextTheme].
  static TextTheme montserratTextTheme([Color? color]) =>
      GoogleFonts.montserratTextTheme().apply(
        bodyColor: color,
        displayColor: color,
        decorationColor: color,
      );
}
