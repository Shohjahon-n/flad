/// Template for the List Tile component source file.
const listTileTemplate = '''
import 'package:flutter/material.dart';

@immutable
class FladListTileTheme extends ThemeExtension<FladListTileTheme> {
  final Color background;
  final Color hover;
  final Color border;
  final Color title;
  final Color subtitle;
  final double radius;
  final double borderWidth;

  const FladListTileTheme({
    required this.background,
    required this.hover,
    required this.border,
    required this.title,
    required this.subtitle,
    required this.radius,
    required this.borderWidth,
  });

  factory FladListTileTheme.fromScheme(ColorScheme scheme) {
    return FladListTileTheme(
      background: scheme.surface,
      hover: scheme.primary.withOpacity(0.06),
      border: scheme.outlineVariant,
      title: scheme.onSurface,
      subtitle: scheme.onSurfaceVariant,
      radius: 12,
      borderWidth: 1,
    );
  }

  @override
  FladListTileTheme copyWith({
    Color? background,
    Color? hover,
    Color? border,
    Color? title,
    Color? subtitle,
    double? radius,
    double? borderWidth,
  }) {
    return FladListTileTheme(
      background: background ?? this.background,
      hover: hover ?? this.hover,
      border: border ?? this.border,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      radius: radius ?? this.radius,
      borderWidth: borderWidth ?? this.borderWidth,
    );
  }

  @override
  FladListTileTheme lerp(ThemeExtension<FladListTileTheme>? other, double t) {
    if (other is! FladListTileTheme) return this;
    return FladListTileTheme(
      background: Color.lerp(background, other.background, t)!,
      hover: Color.lerp(hover, other.hover, t)!,
      border: Color.lerp(border, other.border, t)!,
      title: Color.lerp(title, other.title, t)!,
      subtitle: Color.lerp(subtitle, other.subtitle, t)!,
      radius: radius + (other.radius - radius) * t,
      borderWidth: borderWidth + (other.borderWidth - borderWidth) * t,
    );
  }
}

class FladListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? trailing;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final bool bordered;
  final BorderRadius? borderRadius;

  const FladListTile({
    super.key,
    this.leading,
    this.trailing,
    required this.title,
    this.subtitle,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.bordered = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladListTileTheme>() ??
        FladListTileTheme.fromScheme(theme.colorScheme);
    final radius = borderRadius ?? BorderRadius.circular(tokens.radius);

    return Material(
      color: tokens.background,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        overlayColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.hovered) ||
              states.contains(MaterialState.pressed)) {
            return tokens.hover;
          }
          return null;
        }),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: bordered
                ? Border.all(color: tokens.border, width: tokens.borderWidth)
                : null,
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: tokens.title,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(color: tokens.subtitle),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
''';
