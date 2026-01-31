/// Template for the Divider component source file.
const dividerTemplate = '''
import 'package:flutter/material.dart';

enum FladDividerAxis { horizontal, vertical }

@immutable
class FladDividerTheme extends ThemeExtension<FladDividerTheme> {
  final Color color;
  final double thickness;
  final double indent;
  final double endIndent;

  const FladDividerTheme({
    required this.color,
    required this.thickness,
    required this.indent,
    required this.endIndent,
  });

  factory FladDividerTheme.fromScheme(ColorScheme scheme) {
    return FladDividerTheme(
      color: scheme.outlineVariant,
      thickness: 1,
      indent: 0,
      endIndent: 0,
    );
  }

  @override
  FladDividerTheme copyWith({
    Color? color,
    double? thickness,
    double? indent,
    double? endIndent,
  }) {
    return FladDividerTheme(
      color: color ?? this.color,
      thickness: thickness ?? this.thickness,
      indent: indent ?? this.indent,
      endIndent: endIndent ?? this.endIndent,
    );
  }

  @override
  FladDividerTheme lerp(ThemeExtension<FladDividerTheme>? other, double t) {
    if (other is! FladDividerTheme) return this;
    return FladDividerTheme(
      color: Color.lerp(color, other.color, t)!,
      thickness: thickness + (other.thickness - thickness) * t,
      indent: indent + (other.indent - indent) * t,
      endIndent: endIndent + (other.endIndent - endIndent) * t,
    );
  }
}

class FladDivider extends StatelessWidget {
  final FladDividerAxis axis;
  final double? thickness;
  final double? indent;
  final double? endIndent;
  final Color? color;

  const FladDivider({
    super.key,
    this.axis = FladDividerAxis.horizontal,
    this.thickness,
    this.indent,
    this.endIndent,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladDividerTheme>() ??
        FladDividerTheme.fromScheme(theme.colorScheme);

    if (axis == FladDividerAxis.vertical) {
      return VerticalDivider(
        thickness: thickness ?? tokens.thickness,
        width: thickness ?? tokens.thickness,
        indent: indent ?? tokens.indent,
        endIndent: endIndent ?? tokens.endIndent,
        color: color ?? tokens.color,
      );
    }

    return Divider(
      thickness: thickness ?? tokens.thickness,
      indent: indent ?? tokens.indent,
      endIndent: endIndent ?? tokens.endIndent,
      color: color ?? tokens.color,
    );
  }
}
''';
