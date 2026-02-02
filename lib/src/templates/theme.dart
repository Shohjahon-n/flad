/// Style presets available for theme generation.
const themeStyles = ['default', 'brutalist', 'soft'];

String themeTemplate(String style) => '''
import 'package:flutter/material.dart';

/// Flad design tokens generated with the "$style" style.
///
/// Wrap your MaterialApp with [FladTheme.apply] to inject these tokens,
/// or merge them into your existing ThemeData.extensions list.
@immutable
class FladTheme {
  /// Base border radius used across all components.
  final double radius;

  /// Default border width for outlined variants.
  final double borderWidth;

  /// Seed color used to derive the color scheme.
  final Color seedColor;

  const FladTheme._({
    required this.radius,
    required this.borderWidth,
    required this.seedColor,
  });

  /// The "$style" preset.
  factory FladTheme.preset() {
    return const FladTheme._(
      radius: ${_radiusFor(style)},
      borderWidth: ${_borderWidthFor(style)},
      seedColor: ${_seedColorFor(style)},
    );
  }

  /// Generates a light [ThemeData] using the preset tokens.
  ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );
    return _build(scheme);
  }

  /// Generates a dark [ThemeData] using the preset tokens.
  ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );
    return _build(scheme);
  }

  ThemeData _build(ColorScheme scheme) {
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,${_extraThemeFor(style)}
      inputDecorationTheme: InputDecorationTheme(
        filled: ${style == 'soft' ? 'true' : 'false'},
        border: ${_inputBorderFor(style)},
        contentPadding: EdgeInsets.symmetric(horizontal: \${radius}, vertical: \${radius * 0.75}),
      ),
      cardTheme: CardThemeData(
        elevation: ${_cardElevationFor(style)},
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),${_cardBorderFor(style)}
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          textStyle: const TextStyle(fontWeight: ${_fontWeightFor(style)}),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          side: BorderSide(width: borderWidth, color: scheme.outline),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius * 1.5),
        ),
      ),
    );
  }

  /// Convenience helper — returns a [MaterialApp]-ready theme pair.
  static ({ThemeData light, ThemeData dark}) apply() {
    final theme = FladTheme.preset();
    return (light: theme.light(), dark: theme.dark());
  }
}
''';

String _radiusFor(String style) {
  switch (style) {
    case 'brutalist':
      return '0';
    case 'soft':
      return '16';
    default:
      return '8';
  }
}

String _borderWidthFor(String style) {
  switch (style) {
    case 'brutalist':
      return '2';
    case 'soft':
      return '1';
    default:
      return '1';
  }
}

String _seedColorFor(String style) {
  switch (style) {
    case 'brutalist':
      return 'Color(0xFF000000)';
    case 'soft':
      return 'Color(0xFF6750A4)';
    default:
      return 'Color(0xFF1A73E8)';
  }
}

String _fontWeightFor(String style) {
  switch (style) {
    case 'brutalist':
      return 'FontWeight.w900';
    case 'soft':
      return 'FontWeight.w500';
    default:
      return 'FontWeight.w600';
  }
}

String _cardElevationFor(String style) {
  switch (style) {
    case 'brutalist':
      return '0';
    case 'soft':
      return '0';
    default:
      return '1';
  }
}

String _cardBorderFor(String style) {
  switch (style) {
    case 'brutalist':
      return '''

          side: BorderSide(width: 2, color: scheme.outline),''';
    default:
      return '';
  }
}

String _inputBorderFor(String style) {
  switch (style) {
    case 'brutalist':
      return 'OutlineInputBorder(borderRadius: BorderRadius.zero)';
    case 'soft':
      return 'OutlineInputBorder(borderRadius: BorderRadius.circular(radius))';
    default:
      return 'OutlineInputBorder(borderRadius: BorderRadius.circular(radius))';
  }
}

String _extraThemeFor(String style) {
  switch (style) {
    case 'brutalist':
      return '''

      scaffoldBackgroundColor: scheme.surface,
      dividerTheme: DividerThemeData(thickness: 2, color: scheme.outline),''';
    default:
      return '';
  }
}
