/// Template for the Page Header component source file.
const pageHeaderTemplate = '''
import 'package:flutter/material.dart';

@immutable
class FladPageHeaderTheme extends ThemeExtension<FladPageHeaderTheme> {
  final Color titleColor;
  final Color subtitleColor;
  final Color eyebrowColor;
  final Color dividerColor;
  final double spacing;

  const FladPageHeaderTheme({
    required this.titleColor,
    required this.subtitleColor,
    required this.eyebrowColor,
    required this.dividerColor,
    required this.spacing,
  });

  factory FladPageHeaderTheme.fromScheme(ColorScheme scheme) {
    return FladPageHeaderTheme(
      titleColor: scheme.onSurface,
      subtitleColor: scheme.onSurfaceVariant,
      eyebrowColor: scheme.primary,
      dividerColor: scheme.outlineVariant,
      spacing: 12,
    );
  }

  @override
  FladPageHeaderTheme copyWith({
    Color? titleColor,
    Color? subtitleColor,
    Color? eyebrowColor,
    Color? dividerColor,
    double? spacing,
  }) {
    return FladPageHeaderTheme(
      titleColor: titleColor ?? this.titleColor,
      subtitleColor: subtitleColor ?? this.subtitleColor,
      eyebrowColor: eyebrowColor ?? this.eyebrowColor,
      dividerColor: dividerColor ?? this.dividerColor,
      spacing: spacing ?? this.spacing,
    );
  }

  @override
  FladPageHeaderTheme lerp(
      ThemeExtension<FladPageHeaderTheme>? other, double t) {
    if (other is! FladPageHeaderTheme) return this;
    return FladPageHeaderTheme(
      titleColor: Color.lerp(titleColor, other.titleColor, t)!,
      subtitleColor: Color.lerp(subtitleColor, other.subtitleColor, t)!,
      eyebrowColor: Color.lerp(eyebrowColor, other.eyebrowColor, t)!,
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t)!,
      spacing: spacing + (other.spacing - spacing) * t,
    );
  }
}

class FladPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? eyebrow;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final bool showDivider;

  const FladPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.eyebrow,
    this.leading,
    this.trailing,
    this.padding,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladPageHeaderTheme>() ??
        FladPageHeaderTheme.fromScheme(theme.colorScheme);

    final titleWidget = Text(
      title,
      style: theme.textTheme.headlineSmall?.copyWith(
        color: tokens.titleColor,
        fontWeight: FontWeight.w700,
      ),
    );

    final subtitleWidget = subtitle == null
        ? null
        : Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: tokens.subtitleColor,
            ),
          );

    final eyebrowWidget = eyebrow == null
        ? null
        : Text(
            eyebrow!,
            style: theme.textTheme.labelSmall?.copyWith(
              color: tokens.eyebrowColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          );

    final body = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null) ...[
          leading!,
          SizedBox(width: tokens.spacing),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrowWidget != null) eyebrowWidget,
              titleWidget,
              if (subtitleWidget != null) ...[
                SizedBox(height: tokens.spacing / 2),
                subtitleWidget,
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          SizedBox(width: tokens.spacing),
          trailing!,
        ],
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: padding ?? const EdgeInsets.symmetric(vertical: 12),
          child: body,
        ),
        if (showDivider)
          Container(height: 1, color: tokens.dividerColor),
      ],
    );
  }
}
''';
