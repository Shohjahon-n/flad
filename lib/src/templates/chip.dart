/// Template for the Chip component source file.
const chipTemplate = '''
import 'package:flutter/material.dart';

enum FladChipVariant { solid, outline, soft }

enum FladChipSize { sm, md, lg }

@immutable
class FladChipTheme extends ThemeExtension<FladChipTheme> {
  final Color solidBackground;
  final Color solidForeground;
  final Color outlineForeground;
  final Color outlineBorder;
  final Color softBackground;
  final Color softForeground;
  final double radius;

  const FladChipTheme({
    required this.solidBackground,
    required this.solidForeground,
    required this.outlineForeground,
    required this.outlineBorder,
    required this.softBackground,
    required this.softForeground,
    required this.radius,
  });

  factory FladChipTheme.fromScheme(ColorScheme scheme) {
    return FladChipTheme(
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
  FladChipTheme copyWith({
    Color? solidBackground,
    Color? solidForeground,
    Color? outlineForeground,
    Color? outlineBorder,
    Color? softBackground,
    Color? softForeground,
    double? radius,
  }) {
    return FladChipTheme(
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
  FladChipTheme lerp(ThemeExtension<FladChipTheme>? other, double t) {
    if (other is! FladChipTheme) return this;
    return FladChipTheme(
      solidBackground: Color.lerp(solidBackground, other.solidBackground, t)!,
      solidForeground: Color.lerp(solidForeground, other.solidForeground, t)!,
      outlineForeground: Color.lerp(outlineForeground, other.outlineForeground, t)!,
      outlineBorder: Color.lerp(outlineBorder, other.outlineBorder, t)!,
      softBackground: Color.lerp(softBackground, other.softBackground, t)!,
      softForeground: Color.lerp(softForeground, other.softForeground, t)!,
      radius: radius + (other.radius - radius) * t,
    );
  }
}

class FladChip extends StatelessWidget {
  final String label;
  final FladChipVariant variant;
  final FladChipSize size;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onDeleted;
  final EdgeInsetsGeometry? padding;

  const FladChip({
    super.key,
    required this.label,
    this.variant = FladChipVariant.soft,
    this.size = FladChipSize.md,
    this.leading,
    this.trailing,
    this.onDeleted,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladChipTheme>() ??
        FladChipTheme.fromScheme(theme.colorScheme);
    final sizing = _FladChipSizing.from(size);

    Color bg;
    Color fg;
    BorderSide? border;

    switch (variant) {
      case FladChipVariant.solid:
        bg = tokens.solidBackground;
        fg = tokens.solidForeground;
        border = BorderSide.none;
        break;
      case FladChipVariant.outline:
        bg = Colors.transparent;
        fg = tokens.outlineForeground;
        border = BorderSide(color: tokens.outlineBorder, width: 1);
        break;
      case FladChipVariant.soft:
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
        if (onDeleted != null) ...[
          SizedBox(width: sizing.gap),
          GestureDetector(
            onTap: onDeleted,
            child: Icon(Icons.close, size: sizing.iconSize, color: fg),
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

class _FladChipSizing {
  final double fontSize;
  final double iconSize;
  final double horizontalPadding;
  final double verticalPadding;
  final double gap;

  const _FladChipSizing({
    required this.fontSize,
    required this.iconSize,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.gap,
  });

  factory _FladChipSizing.from(FladChipSize size) {
    switch (size) {
      case FladChipSize.sm:
        return const _FladChipSizing(
          fontSize: 11,
          iconSize: 14,
          horizontalPadding: 8,
          verticalPadding: 4,
          gap: 4,
        );
      case FladChipSize.md:
        return const _FladChipSizing(
          fontSize: 12,
          iconSize: 16,
          horizontalPadding: 10,
          verticalPadding: 5,
          gap: 6,
        );
      case FladChipSize.lg:
        return const _FladChipSizing(
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
