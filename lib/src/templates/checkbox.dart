/// Template for the Checkbox component source file.
const checkboxTemplate = '''
import 'package:flutter/material.dart';

enum FladCheckboxSize { sm, md, lg }

@immutable
class FladCheckboxTheme extends ThemeExtension<FladCheckboxTheme> {
  final Color activeBackground;
  final Color activeBorder;
  final Color checkmark;
  final Color inactiveBorder;
  final Color inactiveBackground;
  final Color hoverOverlay;
  final Color disabledBackground;
  final Color disabledBorder;
  final Color disabledCheckmark;
  final double radius;
  final double borderWidth;

  const FladCheckboxTheme({
    required this.activeBackground,
    required this.activeBorder,
    required this.checkmark,
    required this.inactiveBorder,
    required this.inactiveBackground,
    required this.hoverOverlay,
    required this.disabledBackground,
    required this.disabledBorder,
    required this.disabledCheckmark,
    required this.radius,
    required this.borderWidth,
  });

  factory FladCheckboxTheme.fromScheme(ColorScheme scheme) {
    return FladCheckboxTheme(
      activeBackground: scheme.primary,
      activeBorder: scheme.primary,
      checkmark: scheme.onPrimary,
      inactiveBorder: scheme.outline,
      inactiveBackground: scheme.surface.withOpacity(0),
      hoverOverlay: scheme.primary.withOpacity(0.08),
      disabledBackground: scheme.onSurface.withOpacity(0.06),
      disabledBorder: scheme.onSurface.withOpacity(0.18),
      disabledCheckmark: scheme.onSurface.withOpacity(0.38),
      radius: 6,
      borderWidth: 1.5,
    );
  }

  @override
  FladCheckboxTheme copyWith({
    Color? activeBackground,
    Color? activeBorder,
    Color? checkmark,
    Color? inactiveBorder,
    Color? inactiveBackground,
    Color? hoverOverlay,
    Color? disabledBackground,
    Color? disabledBorder,
    Color? disabledCheckmark,
    double? radius,
    double? borderWidth,
  }) {
    return FladCheckboxTheme(
      activeBackground: activeBackground ?? this.activeBackground,
      activeBorder: activeBorder ?? this.activeBorder,
      checkmark: checkmark ?? this.checkmark,
      inactiveBorder: inactiveBorder ?? this.inactiveBorder,
      inactiveBackground: inactiveBackground ?? this.inactiveBackground,
      hoverOverlay: hoverOverlay ?? this.hoverOverlay,
      disabledBackground: disabledBackground ?? this.disabledBackground,
      disabledBorder: disabledBorder ?? this.disabledBorder,
      disabledCheckmark: disabledCheckmark ?? this.disabledCheckmark,
      radius: radius ?? this.radius,
      borderWidth: borderWidth ?? this.borderWidth,
    );
  }

  @override
  FladCheckboxTheme lerp(ThemeExtension<FladCheckboxTheme>? other, double t) {
    if (other is! FladCheckboxTheme) return this;
    return FladCheckboxTheme(
      activeBackground:
          Color.lerp(activeBackground, other.activeBackground, t)!,
      activeBorder: Color.lerp(activeBorder, other.activeBorder, t)!,
      checkmark: Color.lerp(checkmark, other.checkmark, t)!,
      inactiveBorder: Color.lerp(inactiveBorder, other.inactiveBorder, t)!,
      inactiveBackground:
          Color.lerp(inactiveBackground, other.inactiveBackground, t)!,
      hoverOverlay: Color.lerp(hoverOverlay, other.hoverOverlay, t)!,
      disabledBackground:
          Color.lerp(disabledBackground, other.disabledBackground, t)!,
      disabledBorder: Color.lerp(disabledBorder, other.disabledBorder, t)!,
      disabledCheckmark:
          Color.lerp(disabledCheckmark, other.disabledCheckmark, t)!,
      radius: radius + (other.radius - radius) * t,
      borderWidth: borderWidth + (other.borderWidth - borderWidth) * t,
    );
  }
}

class FladCheckbox extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final bool tristate;
  final bool enabled;
  final FladCheckboxSize size;
  final Widget? label;
  final double gap;

  const FladCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.tristate = false,
    this.enabled = true,
    this.size = FladCheckboxSize.md,
    this.label,
    this.gap = 10,
  });

  void _handleTap() {
    if (onChanged == null || !enabled) return;
    if (!tristate) {
      onChanged!(!(value ?? false));
      return;
    }
    if (value == null) {
      onChanged!(true);
    } else if (value == true) {
      onChanged!(false);
    } else {
      onChanged!(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladCheckboxTheme>() ??
        FladCheckboxTheme.fromScheme(theme.colorScheme);
    final sizing = _FladCheckboxSizing.from(size);
    final isDisabled = !enabled || onChanged == null;
    final isChecked = value == true;
    final isIndeterminate = value == null && tristate;

    final bgColor = isDisabled
        ? tokens.disabledBackground
        : isChecked || isIndeterminate
            ? tokens.activeBackground
            : tokens.inactiveBackground;

    final borderColor = isDisabled
        ? tokens.disabledBorder
        : isChecked || isIndeterminate
            ? tokens.activeBorder
            : tokens.inactiveBorder;

    final iconColor = isDisabled ? tokens.disabledCheckmark : tokens.checkmark;

    final box = InkWell(
      onTap: isDisabled ? null : _handleTap,
      borderRadius: BorderRadius.circular(tokens.radius),
      overlayColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.pressed) ||
            states.contains(MaterialState.hovered)) {
          return tokens.hoverOverlay;
        }
        return null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: sizing.boxSize,
        height: sizing.boxSize,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(tokens.radius),
          border: Border.all(color: borderColor, width: tokens.borderWidth),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 120),
          child: isChecked || isIndeterminate
              ? Icon(
                  isIndeterminate ? Icons.remove : Icons.check,
                  size: sizing.iconSize,
                  color: iconColor,
                )
              : const SizedBox.shrink(),
        ),
      ),
    );

    if (label == null) {
      return box;
    }

    return InkWell(
      onTap: isDisabled ? null : _handleTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          box,
          SizedBox(width: gap),
          DefaultTextStyle.merge(
            style: TextStyle(
              color: isDisabled
                  ? tokens.disabledCheckmark
                  : theme.colorScheme.onSurface,
              fontSize: sizing.fontSize,
            ),
            child: label!,
          ),
        ],
      ),
    );
  }
}

class _FladCheckboxSizing {
  final double boxSize;
  final double iconSize;
  final double fontSize;

  const _FladCheckboxSizing({
    required this.boxSize,
    required this.iconSize,
    required this.fontSize,
  });

  factory _FladCheckboxSizing.from(FladCheckboxSize size) {
    switch (size) {
      case FladCheckboxSize.sm:
        return const _FladCheckboxSizing(boxSize: 18, iconSize: 14, fontSize: 12);
      case FladCheckboxSize.md:
        return const _FladCheckboxSizing(boxSize: 20, iconSize: 16, fontSize: 13);
      case FladCheckboxSize.lg:
        return const _FladCheckboxSizing(boxSize: 24, iconSize: 18, fontSize: 14);
    }
  }
}
''';
