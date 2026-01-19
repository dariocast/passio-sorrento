/// App typography definitions following Material Design 3.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography scale for the app.
///
/// Uses Inter for body text (readability) and Outfit for display/headings (modern feel).
abstract final class AppTextTheme {
  /// Creates the complete text theme for light mode.
  static TextTheme get lightTextTheme => _createTextTheme(Colors.black);

  /// Creates the complete text theme for dark mode.
  static TextTheme get darkTextTheme => _createTextTheme(Colors.white);

  static TextTheme _createTextTheme(Color textColor) {
    final textColorMuted = textColor.withAlpha(180);

    return TextTheme(
      // Display styles - for very large text (Outfit)
      displayLarge: GoogleFonts.outfit(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: textColor,
        height: 1.12,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: textColor,
        height: 1.16,
      ),
      displaySmall: GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: textColor,
        height: 1.22,
      ),

      // Headline styles - for section headings (Outfit)
      headlineLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.29,
      ),
      headlineSmall: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.33,
      ),

      // Title styles - for card titles, list items (Outfit)
      titleLarge: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.27,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: textColor,
        height: 1.5,
      ),
      titleSmall: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: textColor,
        height: 1.43,
      ),

      // Body styles - for general text (Inter)
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: textColor,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: textColor,
        height: 1.43,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: textColorMuted,
        height: 1.33,
      ),

      // Label styles - for buttons, chips, form fields (Inter)
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: textColor,
        height: 1.43,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: textColor,
        height: 1.33,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: textColorMuted,
        height: 1.45,
      ),
    );
  }
}

/// Text style extensions for special use cases.
extension AppTextStyles on TextTheme {
  /// Live badge text style.
  TextStyle get liveBadge => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: Colors.white,
  );

  /// Temperature display style.
  TextStyle get temperature =>
      GoogleFonts.outfit(fontSize: 72, fontWeight: FontWeight.w200, height: 1);

  /// Municipality tag style.
  TextStyle get municipalityTag => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.25,
  );
}
