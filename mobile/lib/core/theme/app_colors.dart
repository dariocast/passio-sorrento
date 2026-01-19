/// App color definitions following Material Design 3.
library;

import 'package:flutter/material.dart';

/// Holy Week themed color palette.
///
/// Colors are inspired by traditional Holy Week imagery:
/// - Deep burgundy/maroon for solemnity
/// - Gold accents for sacred elements
/// - Warm neutrals for surfaces
abstract final class AppColors {
  // === Primary Colors (Burgundy/Maroon) ===
  static const Color primary = Color(0xFF5C1A1B);
  static const Color primaryLight = Color(0xFF8B3A3B);
  static const Color primaryDark = Color(0xFF3D0F10);
  static const Color onPrimary = Colors.white;

  // === Secondary Colors (Gold/Amber) ===
  static const Color secondary = Color(0xFFB8860B);
  static const Color secondaryLight = Color(0xFFDAA520);
  static const Color secondaryDark = Color(0xFF8B6914);
  static const Color onSecondary = Colors.white;

  // === Tertiary Colors (Deep Purple) ===
  static const Color tertiary = Color(0xFF4A148C);
  static const Color tertiaryLight = Color(0xFF7C43BD);
  static const Color tertiaryDark = Color(0xFF290061);
  static const Color onTertiary = Colors.white;

  // === Surface Colors (Light Theme) ===
  static const Color surface = Color(0xFFFFFBFE);
  static const Color surfaceVariant = Color(0xFFF5EDEA);
  static const Color surfaceContainer = Color(0xFFF3EAE7);
  static const Color surfaceContainerHigh = Color(0xFFEDE4E1);
  static const Color surfaceContainerHighest = Color(0xFFE7DEDB);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color onSurfaceVariant = Color(0xFF49454F);

  // === Surface Colors (Dark Theme) ===
  static const Color surfaceDark = Color(0xFF1C1B1F);
  static const Color surfaceVariantDark = Color(0xFF2E2A2D);
  static const Color surfaceContainerDark = Color(0xFF252327);
  static const Color suffaceContainerHighDark = Color(0xFF302E31);
  static const Color surfaceContainerHighestDark = Color(0xFF3B383C);
  static const Color onSurfaceDark = Color(0xFFE6E1E5);
  static const Color onSurfaceVariantDark = Color(0xFFCAC4D0);

  // === Error Colors ===
  static const Color error = Color(0xFFB3261E);
  static const Color errorLight = Color(0xFFDC362E);
  static const Color errorDark = Color(0xFF8C1D18);
  static const Color onError = Colors.white;
  static const Color errorContainer = Color(0xFFF9DEDC);
  static const Color onErrorContainer = Color(0xFF410E0B);

  // === Success Colors ===
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFF4CAF50);
  static const Color successDark = Color(0xFF1B5E20);
  static const Color onSuccess = Colors.white;
  static const Color successContainer = Color(0xFFC8E6C9);
  static const Color onSuccessContainer = Color(0xFF0D2E10);

  // === Warning Colors ===
  static const Color warning = Color(0xFFED6C02);
  static const Color warningLight = Color(0xFFFF9800);
  static const Color warningDark = Color(0xFFE65100);
  static const Color onWarning = Colors.white;
  static const Color warningContainer = Color(0xFFFFE0B2);
  static const Color onWarningContainer = Color(0xFF4E2600);

  // === Live/Active Status Colors ===
  static const Color live = Color(0xFFE53935);
  static const Color liveGlow = Color(0x40E53935);
  static const Color onLive = Colors.white;

  // === Neutral Colors ===
  static const Color outline = Color(0xFF79747E);
  static const Color outlineVariant = Color(0xFFCAC4D0);
  static const Color scrim = Color(0xFF000000);
  static const Color shadow = Color(0xFF000000);

  // === Municipality Colors ===
  /// Colors for different municipalities in the Sorrento Peninsula.
  static const Map<String, Color> municipalityColors = {
    'Sorrento': Color(0xFF1976D2),
    'Piano di Sorrento': Color(0xFF388E3C),
    'Meta': Color(0xFFE64A19),
    'Sant\'Agnello': Color(0xFF7B1FA2),
    'Massa Lubrense': Color(0xFF0097A7),
  };

  /// Get a color for a municipality, with fallback.
  static Color getMunicipalityColor(String municipality) {
    return municipalityColors[municipality] ?? primary;
  }

  // === Gradients ===
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryLight, secondary, secondaryDark],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [surface, surfaceVariant],
  );

  static const LinearGradient darkOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xCC000000)],
  );
}
