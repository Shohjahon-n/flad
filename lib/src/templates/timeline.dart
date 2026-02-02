/// Template for the Timeline component source file.
const timelineTemplate = '''
import 'package:flutter/material.dart';

@immutable
class FladTimelineTheme extends ThemeExtension<FladTimelineTheme> {
  final Color lineColor;
  final Color dotColor;
  final Color activeDotColor;
  final Color titleColor;
  final Color subtitleColor;
  final double lineWidth;
  final double dotSize;
  final double spacing;

  const FladTimelineTheme({
    required this.lineColor,
    required this.dotColor,
    required this.activeDotColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.lineWidth,
    required this.dotSize,
    required this.spacing,
  });

  factory FladTimelineTheme.fromScheme(ColorScheme scheme) {
    return FladTimelineTheme(
      lineColor: scheme.outlineVariant,
      dotColor: scheme.outline,
      activeDotColor: scheme.primary,
      titleColor: scheme.onSurface,
      subtitleColor: scheme.onSurfaceVariant,
      lineWidth: 2,
      dotSize: 10,
      spacing: 12,
    );
  }

  @override
  FladTimelineTheme copyWith({
    Color? lineColor,
    Color? dotColor,
    Color? activeDotColor,
    Color? titleColor,
    Color? subtitleColor,
    double? lineWidth,
    double? dotSize,
    double? spacing,
  }) {
    return FladTimelineTheme(
      lineColor: lineColor ?? this.lineColor,
      dotColor: dotColor ?? this.dotColor,
      activeDotColor: activeDotColor ?? this.activeDotColor,
      titleColor: titleColor ?? this.titleColor,
      subtitleColor: subtitleColor ?? this.subtitleColor,
      lineWidth: lineWidth ?? this.lineWidth,
      dotSize: dotSize ?? this.dotSize,
      spacing: spacing ?? this.spacing,
    );
  }

  @override
  FladTimelineTheme lerp(
      ThemeExtension<FladTimelineTheme>? other, double t) {
    if (other is! FladTimelineTheme) return this;
    return FladTimelineTheme(
      lineColor: Color.lerp(lineColor, other.lineColor, t)!,
      dotColor: Color.lerp(dotColor, other.dotColor, t)!,
      activeDotColor: Color.lerp(activeDotColor, other.activeDotColor, t)!,
      titleColor: Color.lerp(titleColor, other.titleColor, t)!,
      subtitleColor: Color.lerp(subtitleColor, other.subtitleColor, t)!,
      lineWidth: lineWidth + (other.lineWidth - lineWidth) * t,
      dotSize: dotSize + (other.dotSize - dotSize) * t,
      spacing: spacing + (other.spacing - spacing) * t,
    );
  }
}

class FladTimelineItem {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool isActive;

  const FladTimelineItem({
    required this.title,
    this.subtitle,
    this.trailing,
    this.isActive = false,
  });
}

class FladTimeline extends StatelessWidget {
  final List<FladTimelineItem> items;
  final EdgeInsetsGeometry? padding;

  const FladTimeline({
    super.key,
    required this.items,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladTimelineTheme>() ??
        FladTimelineTheme.fromScheme(theme.colorScheme);

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;
          final dotColor = item.isActive ? tokens.activeDotColor : tokens.dotColor;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: tokens.dotSize,
                      height: tokens.dotSize,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: tokens.lineWidth,
                          color: tokens.lineColor,
                        ),
                      ),
                  ],
                ),
                SizedBox(width: tokens.spacing),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: isLast ? 0 : tokens.spacing * 2,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: tokens.titleColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (item.subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: tokens.subtitleColor,
                            ),
                          ),
                        ],
                        if (item.trailing != null) ...[
                          const SizedBox(height: 8),
                          item.trailing!,
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
''';
