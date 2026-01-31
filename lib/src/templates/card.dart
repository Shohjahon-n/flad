/// Template for the Card component source file.
const cardTemplate = '''
import 'package:flutter/material.dart';

@immutable
class FladCardTheme extends ThemeExtension<FladCardTheme> {
  final Color background;
  final Color border;
  final Color shadow;
  final double radius;
  final double borderWidth;
  final double elevation;

  const FladCardTheme({
    required this.background,
    required this.border,
    required this.shadow,
    required this.radius,
    required this.borderWidth,
    required this.elevation,
  });

  factory FladCardTheme.fromScheme(ColorScheme scheme) {
    return FladCardTheme(
      background: scheme.surface,
      border: scheme.outlineVariant,
      shadow: scheme.shadow.withOpacity(0.18),
      radius: 16,
      borderWidth: 1,
      elevation: 8,
    );
  }

  @override
  FladCardTheme copyWith({
    Color? background,
    Color? border,
    Color? shadow,
    double? radius,
    double? borderWidth,
    double? elevation,
  }) {
    return FladCardTheme(
      background: background ?? this.background,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
      radius: radius ?? this.radius,
      borderWidth: borderWidth ?? this.borderWidth,
      elevation: elevation ?? this.elevation,
    );
  }

  @override
  FladCardTheme lerp(ThemeExtension<FladCardTheme>? other, double t) {
    if (other is! FladCardTheme) return this;
    return FladCardTheme(
      background: Color.lerp(background, other.background, t)!,
      border: Color.lerp(border, other.border, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      radius: radius + (other.radius - radius) * t,
      borderWidth: borderWidth + (other.borderWidth - borderWidth) * t,
      elevation: elevation + (other.elevation - elevation) * t,
    );
  }
}

class FladCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool bordered;
  final bool elevated;
  final BorderRadius? borderRadius;
  final Color? background;

  const FladCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.bordered = true,
    this.elevated = true,
    this.borderRadius,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladCardTheme>() ??
        FladCardTheme.fromScheme(theme.colorScheme);

    final radius = borderRadius ?? BorderRadius.circular(tokens.radius);
    final shape = RoundedRectangleBorder(
      borderRadius: radius,
      side: bordered
          ? BorderSide(color: tokens.border, width: tokens.borderWidth)
          : BorderSide.none,
    );

    return Material(
      color: background ?? tokens.background,
      elevation: elevated ? tokens.elevation : 0,
      shadowColor: tokens.shadow,
      shape: shape,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
''';
