/// Template for the Badge component source file.
const badgeTemplate = '''
import 'package:flutter/material.dart';

enum FladBadgeVariant { solid, outline, soft }
enum FladBadgeSize { sm, md, lg }

@immutable
class FladBadgeTheme extends ThemeExtension<FladBadgeTheme> {
  final Color solidBackground;
  final Color solidForeground;
  final Color outlineForeground;
  final Color outlineBorder;
  final Color softBackground;
  final Color softForeground;
  final double radius;

  const FladBadgeTheme({
    required this.solidBackground,
    required this.solidForeground,
    required this.outlineForeground,
    required this.outlineBorder,
    required this.softBackground,
    required this.softForeground,
    required this.radius,
  });

  factory FladBadgeTheme.fromScheme(ColorScheme scheme) {
    return FladBadgeTheme(
      solidBackground: scheme.primary,
      solidForeground: scheme.onPrimary,
      outlineForeground: scheme.onSurface,
      outlineBorder: scheme.outline,
      softBackground: scheme.primary.withOpacity(0.12),
      softForeground: scheme.primary,
      radius: 999,
    );
  }

  @override
  FladBadgeTheme copyWith({
    Color? solidBackground,
    Color? solidForeground,
    Color? outlineForeground,
    Color? outlineBorder,
    Color? softBackground,
    Color? softForeground,
    double? radius,
  }) {
    return FladBadgeTheme(
      solidBackground: solidBackground ?? this.solidBackground,
      solidForeground: solidForeground ?? this.solidForeground,
      outlineForeground: outlineForeground ?? this.outlineForeground,
      outlineBorder: outlineBorder ?? this.outlineBorder,
      softBackground: softBackground ?? this.softBackground,
      softForeground: softForeground ?? this.softForeground,
      radius: radius ?? this.radius,
    );
  }

  @override
  FladBadgeTheme lerp(ThemeExtension<FladBadgeTheme>? other, double t) {
    if (other is! FladBadgeTheme) return this;
    return FladBadgeTheme(
      solidBackground: Color.lerp(solidBackground, other.solidBackground, t)!,
      solidForeground: Color.lerp(solidForeground, other.solidForeground, t)!,
      outlineForeground:
          Color.lerp(outlineForeground, other.outlineForeground, t)!,
      outlineBorder: Color.lerp(outlineBorder, other.outlineBorder, t)!,
      softBackground: Color.lerp(softBackground, other.softBackground, t)!,
      softForeground: Color.lerp(softForeground, other.softForeground, t)!,
      radius: radius + (other.radius - radius) * t,
    );
  }
}

class FladBadge extends StatelessWidget {
  final String label;
  final FladBadgeVariant variant;
  final FladBadgeSize size;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  const FladBadge({
    super.key,
    required this.label,
    this.variant = FladBadgeVariant.soft,
    this.size = FladBadgeSize.md,
    this.leading,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladBadgeTheme>() ??
        FladBadgeTheme.fromScheme(theme.colorScheme);
    final sizing = _FladBadgeSizing.from(size);

    Color bg;
    Color fg;
    BorderSide? border;

    switch (variant) {
      case FladBadgeVariant.solid:
        bg = tokens.solidBackground;
        fg = tokens.solidForeground;
        border = BorderSide.none;
        break;
      case FladBadgeVariant.outline:
        bg = Colors.transparent;
        fg = tokens.outlineForeground;
        border = BorderSide(color: tokens.outlineBorder, width: 1);
        break;
      case FladBadgeVariant.soft:
        bg = tokens.softBackground;
        fg = tokens.softForeground;
        border = BorderSide.none;
        break;
    }

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) ...[
          IconTheme(
            data: IconThemeData(color: fg, size: sizing.iconSize),
            child: leading!,
          ),
          SizedBox(width: sizing.gap),
        ],
        Text(
          label,
          style: TextStyle(
            color: fg,
            fontSize: sizing.fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (trailing != null) ...[
          SizedBox(width: sizing.gap),
          IconTheme(
            data: IconThemeData(color: fg, size: sizing.iconSize),
            child: trailing!,
          ),
        ],
      ],
    );

    return Container(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: sizing.horizontalPadding,
            vertical: sizing.verticalPadding,
          ),
      decoration: BoxDecoration(
        color: bg,
        border: border == BorderSide.none ? null : Border.fromBorderSide(border!),
        borderRadius: BorderRadius.circular(tokens.radius),
      ),
      child: content,
    );
  }
}

class _FladBadgeSizing {
  final double fontSize;
  final double iconSize;
  final double horizontalPadding;
  final double verticalPadding;
  final double gap;

  const _FladBadgeSizing({
    required this.fontSize,
    required this.iconSize,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.gap,
  });

  factory _FladBadgeSizing.from(FladBadgeSize size) {
    switch (size) {
      case FladBadgeSize.sm:
        return const _FladBadgeSizing(
          fontSize: 11,
          iconSize: 14,
          horizontalPadding: 8,
          verticalPadding: 4,
          gap: 4,
        );
      case FladBadgeSize.md:
        return const _FladBadgeSizing(
          fontSize: 12,
          iconSize: 16,
          horizontalPadding: 10,
          verticalPadding: 5,
          gap: 6,
        );
      case FladBadgeSize.lg:
        return const _FladBadgeSizing(
          fontSize: 13,
          iconSize: 18,
          horizontalPadding: 12,
          verticalPadding: 6,
          gap: 6,
        );
    }
  }
}
''';
