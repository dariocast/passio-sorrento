/// Color utility functions.
library;

import 'package:flutter/material.dart';

/// Utility functions for working with colors.
abstract final class ColorUtils {
  /// Parses a hex color string to a Color.
  ///
  /// Accepts formats: #RRGGBB, #AARRGGBB, RRGGBB, AARRGGBB
  static Color parseHex(String hexColor, {Color fallback = Colors.grey}) {
    try {
      String hex = hexColor.replaceFirst('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  /// Returns a contrasting color (black or white) for text on the given background.
  static Color contrastColor(Color background) {
    // Using relative luminance formula
    final luminance =
        (0.299 * background.r + 0.587 * background.g + 0.114 * background.b);
    return luminance > 128 ? Colors.black : Colors.white;
  }

  /// Darkens a color by a percentage (0.0 to 1.0).
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Lightens a color by a percentage (0.0 to 1.0).
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Creates a translucent version of the color.
  static Color withOpacity(Color color, double opacity) {
    return color.withAlpha((opacity * 255).round());
  }

  /// Mixes two colors together.
  static Color mix(Color color1, Color color2, [double ratio = 0.5]) {
    assert(ratio >= 0 && ratio <= 1);
    return Color.lerp(color1, color2, ratio)!;
  }

  /// Converts a Color to a hex string.
  static String toHex(
    Color color, {
    bool includeHash = true,
    bool includeAlpha = false,
  }) {
    final hex = includeAlpha
        ? color.toARGB32().toRadixString(16).padLeft(8, '0')
        : color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2);
    return includeHash ? '#$hex' : hex;
  }

  /// Creates a Material color swatch from a single color.
  static MaterialColor createMaterialColor(Color color) {
    final strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
    final swatch = <int, Color>{};

    for (final strength in strengths) {
      final ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromARGB(
        255,
        (color.r + ((ds < 0 ? color.r : (255 - color.r)) * ds).round())
            .clamp(0, 255)
            .toInt(),
        (color.g + ((ds < 0 ? color.g : (255 - color.g)) * ds).round())
            .clamp(0, 255)
            .toInt(),
        (color.b + ((ds < 0 ? color.b : (255 - color.b)) * ds).round())
            .clamp(0, 255)
            .toInt(),
      );
    }

    return MaterialColor(color.toARGB32(), swatch);
  }
}

/// Extension methods on Color.
extension ColorExtensions on Color {
  /// Returns a contrasting color for text on this background.
  Color get contrastColor => ColorUtils.contrastColor(this);

  /// Darkens the color by a percentage.
  Color darken([double amount = 0.1]) => ColorUtils.darken(this, amount);

  /// Lightens the color by a percentage.
  Color lighten([double amount = 0.1]) => ColorUtils.lighten(this, amount);

  /// Converts to hex string.
  String toHex({bool includeHash = true, bool includeAlpha = false}) =>
      ColorUtils.toHex(
        this,
        includeHash: includeHash,
        includeAlpha: includeAlpha,
      );

  /// Creates a translucent version.
  Color withOpacityValue(double opacity) =>
      ColorUtils.withOpacity(this, opacity);

  /// Mixes with another color.
  Color mixWith(Color other, [double ratio = 0.5]) =>
      ColorUtils.mix(this, other, ratio);

  /// Whether this is a light color (for determining text color).
  bool get isLight => ColorUtils.contrastColor(this) == Colors.black;

  /// Whether this is a dark color.
  bool get isDark => !isLight;
}
