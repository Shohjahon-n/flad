/// Template for the Icon Button component source file.
const iconButtonTemplate = '''
import 'package:flutter/material.dart';

enum FladIconButtonVariant { solid, outline, ghost }
enum FladIconButtonSize { sm, md, lg }

@immutable
class FladIconButtonTheme extends ThemeExtension<FladIconButtonTheme> {
  final Color solidBackground;
  final Color solidForeground;
  final Color outlineForeground;
  final Color outlineBorder;
  final Color ghostForeground;
  final Color disabledBackground;
  final Color disabledForeground;
  final Color pressedOverlay;
  final double radius;

  const FladIconButtonTheme({
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

  factory FladIconButtonTheme.fromScheme(ColorScheme scheme) {
    return FladIconButtonTheme(
      solidBackground: scheme.primary,
      solidForeground: scheme.onPrimary,
      outlineForeground: scheme.onSurface,
      outlineBorder: scheme.outline,
      ghostForeground: scheme.onSurface,
      disabledBackground: scheme.onSurface.withOpacity(0.08),
      disabledForeground: scheme.onSurface.withOpacity(0.38),
      pressedOverlay: scheme.onSurface.withOpacity(0.12),
      radius: 10,
    );
  }

  @override
  FladIconButtonTheme copyWith({
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
    return FladIconButtonTheme(
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
  FladIconButtonTheme lerp(
      ThemeExtension<FladIconButtonTheme>? other, double t) {
    if (other is! FladIconButtonTheme) return this;
    return FladIconButtonTheme(
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

class FladIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final FladIconButtonVariant variant;
  final FladIconButtonSize size;
  final String? semanticLabel;
  final bool loading;
  final BorderRadius? borderRadius;

  const FladIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.variant = FladIconButtonVariant.solid,
    this.size = FladIconButtonSize.md,
    this.semanticLabel,
    this.loading = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladIconButtonTheme>() ??
        FladIconButtonTheme.fromScheme(theme.colorScheme);
    final sizing = _FladIconButtonSizing.from(size);
    final radius = borderRadius ?? BorderRadius.circular(tokens.radius);
    final transparent = theme.colorScheme.surface.withOpacity(0);
    final isDisabled = onPressed == null || loading;

    Color bg;
    Color fg;
    BorderSide side;

    switch (variant) {
      case FladIconButtonVariant.solid:
        bg = isDisabled ? tokens.disabledBackground : tokens.solidBackground;
        fg = isDisabled ? tokens.disabledForeground : tokens.solidForeground;
        side = BorderSide.none;
        break;
      case FladIconButtonVariant.outline:
        bg = transparent;
        fg = isDisabled ? tokens.disabledForeground : tokens.outlineForeground;
        side = BorderSide(
          color: isDisabled ? tokens.disabledForeground : tokens.outlineBorder,
          width: 1,
        );
        break;
      case FladIconButtonVariant.ghost:
        bg = transparent;
        fg = isDisabled ? tokens.disabledForeground : tokens.ghostForeground;
        side = BorderSide.none;
        break;
    }

    final iconWidget = loading
        ? SizedBox(
            width: sizing.iconSize,
            height: sizing.iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : Icon(
            icon,
            size: sizing.iconSize,
            color: fg,
            semanticLabel: semanticLabel,
          );

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: !isDisabled,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(borderRadius: radius, side: side),
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: radius,
          overlayColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return tokens.pressedOverlay;
            }
            return null;
          }),
          child: SizedBox(
            width: sizing.dimension,
            height: sizing.dimension,
            child: Center(child: iconWidget),
          ),
        ),
      ),
    );
  }
}

class _FladIconButtonSizing {
  final double dimension;
  final double iconSize;

  const _FladIconButtonSizing({
    required this.dimension,
    required this.iconSize,
  });

  factory _FladIconButtonSizing.from(FladIconButtonSize size) {
    switch (size) {
      case FladIconButtonSize.sm:
        return const _FladIconButtonSizing(dimension: 34, iconSize: 18);
      case FladIconButtonSize.lg:
        return const _FladIconButtonSizing(dimension: 50, iconSize: 26);
      case FladIconButtonSize.md:
      default:
        return const _FladIconButtonSizing(dimension: 42, iconSize: 22);
    }
  }
}
''';
