/// Template for the Button component source file.
const buttonTemplate = '''
import 'package:flutter/material.dart';

enum FladButtonVariant { solid, outline, ghost }
enum FladButtonSize { sm, md, lg }

@immutable
class FladButtonTheme extends ThemeExtension<FladButtonTheme> {
  final Color solidBackground;
  final Color solidForeground;
  final Color outlineForeground;
  final Color outlineBorder;
  final Color ghostForeground;
  final Color disabledBackground;
  final Color disabledForeground;
  final Color pressedOverlay;
  final double radius;

  const FladButtonTheme({
    required this.solidBackground,
    required this.solidForeground,
    required this.outlineForeground,
    required this.outlineBorder,
    required this.ghostForeground,
    required this.disabledBackground,
    required this.disabledForeground,
    required this.pressedOverlay,
    required this.radius,
  });

  factory FladButtonTheme.fromScheme(ColorScheme scheme) {
    return FladButtonTheme(
      solidBackground: scheme.primary,
      solidForeground: scheme.onPrimary,
      outlineForeground: scheme.onSurface,
      outlineBorder: scheme.outline,
      ghostForeground: scheme.onSurface,
      disabledBackground: scheme.onSurface.withOpacity(0.08),
      disabledForeground: scheme.onSurface.withOpacity(0.38),
      pressedOverlay: scheme.onSurface.withOpacity(0.10),
      radius: 12,
    );
  }

  @override
  FladButtonTheme copyWith({
    Color? solidBackground,
    Color? solidForeground,
    Color? outlineForeground,
    Color? outlineBorder,
    Color? ghostForeground,
    Color? disabledBackground,
    Color? disabledForeground,
    Color? pressedOverlay,
    double? radius,
  }) {
    return FladButtonTheme(
      solidBackground: solidBackground ?? this.solidBackground,
      solidForeground: solidForeground ?? this.solidForeground,
      outlineForeground: outlineForeground ?? this.outlineForeground,
      outlineBorder: outlineBorder ?? this.outlineBorder,
      ghostForeground: ghostForeground ?? this.ghostForeground,
      disabledBackground: disabledBackground ?? this.disabledBackground,
      disabledForeground: disabledForeground ?? this.disabledForeground,
      pressedOverlay: pressedOverlay ?? this.pressedOverlay,
      radius: radius ?? this.radius,
    );
  }

  @override
  FladButtonTheme lerp(ThemeExtension<FladButtonTheme>? other, double t) {
    if (other is! FladButtonTheme) return this;
    return FladButtonTheme(
      solidBackground: Color.lerp(solidBackground, other.solidBackground, t)!,
      solidForeground: Color.lerp(solidForeground, other.solidForeground, t)!,
      outlineForeground:
          Color.lerp(outlineForeground, other.outlineForeground, t)!,
      outlineBorder: Color.lerp(outlineBorder, other.outlineBorder, t)!,
      ghostForeground: Color.lerp(ghostForeground, other.ghostForeground, t)!,
      disabledBackground:
          Color.lerp(disabledBackground, other.disabledBackground, t)!,
      disabledForeground:
          Color.lerp(disabledForeground, other.disabledForeground, t)!,
      pressedOverlay: Color.lerp(pressedOverlay, other.pressedOverlay, t)!,
      radius: radius + (other.radius - radius) * t,
    );
  }
}

class FladButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final FladButtonVariant variant;
  final FladButtonSize size;
  final EdgeInsets? padding;
  final bool fullWidth;
  final bool loading;
  final Widget? leading;
  final Widget? trailing;
  final BorderRadius? borderRadius;

  const FladButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = FladButtonVariant.solid,
    this.size = FladButtonSize.md,
    this.padding,
    this.fullWidth = false,
    this.loading = false,
    this.leading,
    this.trailing,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladButtonTheme>() ??
        FladButtonTheme.fromScheme(theme.colorScheme);
    final radius = borderRadius ?? BorderRadius.circular(tokens.radius);
    final transparent = theme.colorScheme.surface.withOpacity(0);
    final isDisabled = onPressed == null || loading;
    final sizing = _FladButtonSizing.from(size);
    final effectivePadding = padding ??
        EdgeInsets.symmetric(
          vertical: sizing.verticalPadding,
          horizontal: sizing.horizontalPadding,
        );

    Color bg;
    Color fg;
    BorderSide? side;

    switch (variant) {
      case FladButtonVariant.solid:
        bg = isDisabled ? tokens.disabledBackground : tokens.solidBackground;
        fg = isDisabled ? tokens.disabledForeground : tokens.solidForeground;
        side = BorderSide.none;
        break;
      case FladButtonVariant.outline:
        bg = transparent;
        fg = isDisabled ? tokens.disabledForeground : tokens.outlineForeground;
        side = BorderSide(
          color: isDisabled ? tokens.disabledForeground : tokens.outlineBorder,
          width: 1,
        );
        break;
      case FladButtonVariant.ghost:
        bg = transparent;
        fg = isDisabled ? tokens.disabledForeground : tokens.ghostForeground;
        side = BorderSide.none;
        break;
    }

    final content = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[
          IconTheme(
            data: IconThemeData(color: fg, size: sizing.iconSize),
            child: leading!,
          ),
          SizedBox(width: sizing.gap),
        ],
        if (loading) ...[
          SizedBox(
            width: sizing.spinnerSize,
            height: sizing.spinnerSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
          SizedBox(width: sizing.gap),
        ],
        Flexible(
          child: DefaultTextStyle.merge(
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w600,
              fontSize: sizing.fontSize,
              height: 1.1,
            ),
            child: child,
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

    final body = fullWidth
        ? SizedBox(width: double.infinity, child: content)
        : content;

    return Material(
      color: bg,
      borderRadius: radius,
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: radius,
        overlayColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return tokens.pressedOverlay;
          }
          return null;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: effectivePadding,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: side == BorderSide.none ? null : Border.fromBorderSide(side),
          ),
          child: Center(child: body),
        ),
      ),
    );
  }
}

class _FladButtonSizing {
  final double fontSize;
  final double iconSize;
  final double spinnerSize;
  final double gap;
  final double verticalPadding;
  final double horizontalPadding;

  const _FladButtonSizing({
    required this.fontSize,
    required this.iconSize,
    required this.spinnerSize,
    required this.gap,
    required this.verticalPadding,
    required this.horizontalPadding,
  });

  factory _FladButtonSizing.from(FladButtonSize size) {
    switch (size) {
      case FladButtonSize.sm:
        return const _FladButtonSizing(
          fontSize: 12,
          iconSize: 16,
          spinnerSize: 14,
          gap: 6,
          verticalPadding: 8,
          horizontalPadding: 12,
        );
      case FladButtonSize.md:
        return const _FladButtonSizing(
          fontSize: 14,
          iconSize: 18,
          spinnerSize: 16,
          gap: 8,
          verticalPadding: 10,
          horizontalPadding: 14,
        );
      case FladButtonSize.lg:
        return const _FladButtonSizing(
          fontSize: 16,
          iconSize: 20,
          spinnerSize: 18,
          gap: 10,
          verticalPadding: 12,
          horizontalPadding: 18,
        );
    }
  }
}
''';
