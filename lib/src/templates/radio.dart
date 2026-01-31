/// Template for the Radio component source file.
const radioTemplate = '''
import 'package:flutter/material.dart';

enum FladRadioSize { sm, md, lg }

@immutable
class FladRadioTheme extends ThemeExtension<FladRadioTheme> {
  final Color activeBorder;
  final Color activeDot;
  final Color inactiveBorder;
  final Color hoverOverlay;
  final Color disabledBorder;
  final Color disabledDot;
  final double borderWidth;

  const FladRadioTheme({
    required this.activeBorder,
    required this.activeDot,
    required this.inactiveBorder,
    required this.hoverOverlay,
    required this.disabledBorder,
    required this.disabledDot,
    required this.borderWidth,
  });

  factory FladRadioTheme.fromScheme(ColorScheme scheme) {
    return FladRadioTheme(
      activeBorder: scheme.primary,
      activeDot: scheme.primary,
      inactiveBorder: scheme.outline,
      hoverOverlay: scheme.primary.withOpacity(0.08),
      disabledBorder: scheme.onSurface.withOpacity(0.18),
      disabledDot: scheme.onSurface.withOpacity(0.38),
      borderWidth: 1.5,
    );
  }

  @override
  FladRadioTheme copyWith({
    Color? activeBorder,
    Color? activeDot,
    Color? inactiveBorder,
    Color? hoverOverlay,
    Color? disabledBorder,
    Color? disabledDot,
    double? borderWidth,
  }) {
    return FladRadioTheme(
      activeBorder: activeBorder ?? this.activeBorder,
      activeDot: activeDot ?? this.activeDot,
      inactiveBorder: inactiveBorder ?? this.inactiveBorder,
      hoverOverlay: hoverOverlay ?? this.hoverOverlay,
      disabledBorder: disabledBorder ?? this.disabledBorder,
      disabledDot: disabledDot ?? this.disabledDot,
      borderWidth: borderWidth ?? this.borderWidth,
    );
  }

  @override
  FladRadioTheme lerp(ThemeExtension<FladRadioTheme>? other, double t) {
    if (other is! FladRadioTheme) return this;
    return FladRadioTheme(
      activeBorder: Color.lerp(activeBorder, other.activeBorder, t)!,
      activeDot: Color.lerp(activeDot, other.activeDot, t)!,
      inactiveBorder: Color.lerp(inactiveBorder, other.inactiveBorder, t)!,
      hoverOverlay: Color.lerp(hoverOverlay, other.hoverOverlay, t)!,
      disabledBorder: Color.lerp(disabledBorder, other.disabledBorder, t)!,
      disabledDot: Color.lerp(disabledDot, other.disabledDot, t)!,
      borderWidth: borderWidth + (other.borderWidth - borderWidth) * t,
    );
  }
}

class FladRadio<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final bool enabled;
  final FladRadioSize size;
  final Widget? label;
  final double gap;

  const FladRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.enabled = true,
    this.size = FladRadioSize.md,
    this.label,
    this.gap = 10,
  });

  void _handleTap() {
    if (onChanged == null || !enabled) return;
    onChanged!(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladRadioTheme>() ??
        FladRadioTheme.fromScheme(theme.colorScheme);
    final sizing = _FladRadioSizing.from(size);
    final isSelected = value == groupValue;
    final isDisabled = !enabled || onChanged == null;

    final borderColor = isDisabled
        ? tokens.disabledBorder
        : isSelected
            ? tokens.activeBorder
            : tokens.inactiveBorder;

    final dotColor = isDisabled ? tokens.disabledDot : tokens.activeDot;

    final radio = InkWell(
      onTap: isDisabled ? null : _handleTap,
      borderRadius: BorderRadius.circular(999),
      overlayColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.hovered) ||
            states.contains(MaterialState.pressed)) {
          return tokens.hoverOverlay;
        }
        return null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: sizing.outerSize,
        height: sizing.outerSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: tokens.borderWidth),
        ),
        child: AnimatedScale(
          scale: isSelected ? 1 : 0,
          duration: const Duration(milliseconds: 120),
          child: Center(
            child: Container(
              width: sizing.innerSize,
              height: sizing.innerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
              ),
            ),
          ),
        ),
      ),
    );

    if (label == null) {
      return radio;
    }

    return InkWell(
      onTap: isDisabled ? null : _handleTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          radio,
          SizedBox(width: gap),
          DefaultTextStyle.merge(
            style: TextStyle(
              color: isDisabled
                  ? theme.colorScheme.onSurface.withOpacity(0.38)
                  : theme.colorScheme.onSurface,
              fontSize: sizing.labelSize,
            ),
            child: label!,
          ),
        ],
      ),
    );
  }
}

class _FladRadioSizing {
  final double outerSize;
  final double innerSize;
  final double labelSize;

  const _FladRadioSizing({
    required this.outerSize,
    required this.innerSize,
    required this.labelSize,
  });

  factory _FladRadioSizing.from(FladRadioSize size) {
    switch (size) {
      case FladRadioSize.sm:
        return const _FladRadioSizing(outerSize: 18, innerSize: 8, labelSize: 12);
      case FladRadioSize.md:
        return const _FladRadioSizing(outerSize: 20, innerSize: 9, labelSize: 13);
      case FladRadioSize.lg:
        return const _FladRadioSizing(outerSize: 24, innerSize: 10, labelSize: 14);
    }
  }
}
''';
