/// Template for the Stat Card component source file.
const statCardTemplate = '''
import 'package:flutter/material.dart';

@immutable
class FladStatCardTheme extends ThemeExtension<FladStatCardTheme> {
  final Color background;
  final Color borderColor;
  final Color labelColor;
  final Color valueColor;
  final Color captionColor;
  final Color positiveColor;
  final Color negativeColor;
  final double radius;

  const FladStatCardTheme({
    required this.background,
    required this.borderColor,
    required this.labelColor,
    required this.valueColor,
    required this.captionColor,
    required this.positiveColor,
    required this.negativeColor,
    required this.radius,
  });

  factory FladStatCardTheme.fromScheme(ColorScheme scheme) {
    return FladStatCardTheme(
      background: scheme.surfaceContainerLow,
      borderColor: scheme.outlineVariant,
      labelColor: scheme.onSurfaceVariant,
      valueColor: scheme.onSurface,
      captionColor: scheme.onSurfaceVariant,
      positiveColor: scheme.primary,
      negativeColor: scheme.error,
      radius: 14,
    );
  }

  @override
  FladStatCardTheme copyWith({
    Color? background,
    Color? borderColor,
    Color? labelColor,
    Color? valueColor,
    Color? captionColor,
    Color? positiveColor,
    Color? negativeColor,
    double? radius,
  }) {
    return FladStatCardTheme(
      background: background ?? this.background,
      borderColor: borderColor ?? this.borderColor,
      labelColor: labelColor ?? this.labelColor,
      valueColor: valueColor ?? this.valueColor,
      captionColor: captionColor ?? this.captionColor,
      positiveColor: positiveColor ?? this.positiveColor,
      negativeColor: negativeColor ?? this.negativeColor,
      radius: radius ?? this.radius,
    );
  }

  @override
  FladStatCardTheme lerp(
      ThemeExtension<FladStatCardTheme>? other, double t) {
    if (other is! FladStatCardTheme) return this;
    return FladStatCardTheme(
      background: Color.lerp(background, other.background, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      labelColor: Color.lerp(labelColor, other.labelColor, t)!,
      valueColor: Color.lerp(valueColor, other.valueColor, t)!,
      captionColor: Color.lerp(captionColor, other.captionColor, t)!,
      positiveColor: Color.lerp(positiveColor, other.positiveColor, t)!,
      negativeColor: Color.lerp(negativeColor, other.negativeColor, t)!,
      radius: radius + (other.radius - radius) * t,
    );
  }
}

class FladStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? caption;
  final String? delta;
  final bool? isPositive;
  final Widget? leading;
  final EdgeInsetsGeometry? padding;
  final bool showBorder;

  const FladStatCard({
    super.key,
    required this.label,
    required this.value,
    this.caption,
    this.delta,
    this.isPositive,
    this.leading,
    this.padding,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladStatCardTheme>() ??
        FladStatCardTheme.fromScheme(theme.colorScheme);

    Color? deltaColor;
    if (delta != null) {
      if (isPositive == true) {
        deltaColor = tokens.positiveColor;
      } else if (isPositive == false) {
        deltaColor = tokens.negativeColor;
      } else {
        deltaColor = tokens.valueColor;
      }
    }

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.background,
        borderRadius: BorderRadius.circular(tokens.radius),
        border: showBorder ? Border.all(color: tokens.borderColor) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: tokens.labelColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (delta != null)
                Text(
                  delta!,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: deltaColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: tokens.valueColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: 6),
            Text(
              caption!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: tokens.captionColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
''';
