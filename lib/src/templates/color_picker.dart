/// Template for the Color Picker component source file.
const colorPickerTemplate = '''
import 'package:flutter/material.dart';

@immutable
class FladColorPickerTheme extends ThemeExtension<FladColorPickerTheme> {
  final Color background;
  final Color borderColor;
  final Color selectedBorderColor;
  final Color checkmarkColor;
  final double radius;
  final double itemRadius;

  const FladColorPickerTheme({
    required this.background,
    required this.borderColor,
    required this.selectedBorderColor,
    required this.checkmarkColor,
    required this.radius,
    required this.itemRadius,
  });

  factory FladColorPickerTheme.fromScheme(ColorScheme scheme) {
    return FladColorPickerTheme(
      background: scheme.surface,
      borderColor: scheme.outlineVariant,
      selectedBorderColor: scheme.primary,
      checkmarkColor: Colors.white,
      radius: 12,
      itemRadius: 8,
    );
  }

  @override
  FladColorPickerTheme copyWith({
    Color? background,
    Color? borderColor,
    Color? selectedBorderColor,
    Color? checkmarkColor,
    double? radius,
    double? itemRadius,
  }) {
    return FladColorPickerTheme(
      background: background ?? this.background,
      borderColor: borderColor ?? this.borderColor,
      selectedBorderColor: selectedBorderColor ?? this.selectedBorderColor,
      checkmarkColor: checkmarkColor ?? this.checkmarkColor,
      radius: radius ?? this.radius,
      itemRadius: itemRadius ?? this.itemRadius,
    );
  }

  @override
  FladColorPickerTheme lerp(
      ThemeExtension<FladColorPickerTheme>? other, double t) {
    if (other is! FladColorPickerTheme) return this;
    return FladColorPickerTheme(
      background: Color.lerp(background, other.background, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      selectedBorderColor:
          Color.lerp(selectedBorderColor, other.selectedBorderColor, t)!,
      checkmarkColor: Color.lerp(checkmarkColor, other.checkmarkColor, t)!,
      radius: radius + (other.radius - radius) * t,
      itemRadius: itemRadius + (other.itemRadius - itemRadius) * t,
    );
  }
}

class FladColorPicker extends StatelessWidget {
  final List<Color> colors;
  final Color? selectedColor;
  final ValueChanged<Color>? onColorChanged;
  final double itemSize;
  final int crossAxisCount;
  final double spacing;
  final EdgeInsets? padding;

  const FladColorPicker({
    super.key,
    this.colors = _defaultColors,
    this.selectedColor,
    this.onColorChanged,
    this.itemSize = 36,
    this.crossAxisCount = 6,
    this.spacing = 8,
    this.padding,
  });

  static const List<Color> _defaultColors = [
    Color(0xFFEF4444),
    Color(0xFFF97316),
    Color(0xFFF59E0B),
    Color(0xFF84CC16),
    Color(0xFF22C55E),
    Color(0xFF14B8A6),
    Color(0xFF06B6D4),
    Color(0xFF3B82F6),
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFFA855F7),
    Color(0xFFEC4899),
    Color(0xFFF43F5E),
    Color(0xFF78716C),
    Color(0xFF6B7280),
    Color(0xFF64748B),
    Color(0xFF000000),
    Color(0xFFFFFFFF),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladColorPickerTheme>() ??
        FladColorPickerTheme.fromScheme(theme.colorScheme);
    final effectivePadding = padding ?? const EdgeInsets.all(12);

    return Container(
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: tokens.background,
        borderRadius: BorderRadius.circular(tokens.radius),
        border: Border.all(color: tokens.borderColor),
      ),
      child: Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: colors.map((color) {
          final isSelected = selectedColor == color;
          return _FladColorItem(
            color: color,
            isSelected: isSelected,
            size: itemSize,
            tokens: tokens,
            onTap: onColorChanged != null
                ? () => onColorChanged!(color)
                : null,
          );
        }).toList(),
      ),
    );
  }
}

class _FladColorItem extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final double size;
  final FladColorPickerTheme tokens;
  final VoidCallback? onTap;

  const _FladColorItem({
    required this.color,
    required this.isSelected,
    required this.size,
    required this.tokens,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLight =
        ThemeData.estimateBrightnessForColor(color) == Brightness.light;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(tokens.itemRadius),
          border: Border.all(
            color: isSelected
                ? tokens.selectedBorderColor
                : tokens.borderColor,
            width: isSelected ? 2.5 : 1,
          ),
        ),
        child: isSelected
            ? Center(
                child: Icon(
                  Icons.check,
                  size: size * 0.5,
                  color: isLight ? Colors.black87 : tokens.checkmarkColor,
                ),
              )
            : null,
      ),
    );
  }
}
''';
