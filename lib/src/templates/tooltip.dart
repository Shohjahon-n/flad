/// Template for the Tooltip component source file.
const tooltipTemplate = '''
import 'package:flutter/material.dart';

@immutable
class FladTooltipTheme extends ThemeExtension<FladTooltipTheme> {
  final Color background;
  final Color text;
  final double radius;

  const FladTooltipTheme({
    required this.background,
    required this.text,
    required this.radius,
  });

  factory FladTooltipTheme.fromScheme(ColorScheme scheme) {
    return FladTooltipTheme(
      background: scheme.onSurface,
      text: scheme.surface,
      radius: 8,
    );
  }

  @override
  FladTooltipTheme copyWith({
    Color? background,
    Color? text,
    double? radius,
  }) {
    return FladTooltipTheme(
      background: background ?? this.background,
      text: text ?? this.text,
      radius: radius ?? this.radius,
    );
  }

  @override
  FladTooltipTheme lerp(ThemeExtension<FladTooltipTheme>? other, double t) {
    if (other is! FladTooltipTheme) return this;
    return FladTooltipTheme(
      background: Color.lerp(background, other.background, t)!,
      text: Color.lerp(text, other.text, t)!,
      radius: radius + (other.radius - radius) * t,
    );
  }
}

class FladTooltip extends StatelessWidget {
  final String message;
  final Widget child;

  const FladTooltip({
    super.key,
    required this.message,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladTooltipTheme>() ??
        FladTooltipTheme.fromScheme(theme.colorScheme);

    return Tooltip(
      message: message,
      decoration: BoxDecoration(
        color: tokens.background,
        borderRadius: BorderRadius.circular(tokens.radius),
      ),
      textStyle: TextStyle(color: tokens.text),
      child: child,
    );
  }
}
''';
