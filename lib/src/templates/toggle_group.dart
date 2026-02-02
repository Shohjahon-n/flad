/// Template for the Toggle Group component source file.
const toggleGroupTemplate = '''
import 'package:flutter/material.dart';

enum FladToggleGroupSize { sm, md, lg }

@immutable
class FladToggleGroupTheme extends ThemeExtension<FladToggleGroupTheme> {
  final Color background;
  final Color selectedBackground;
  final Color foreground;
  final Color selectedForeground;
  final Color borderColor;
  final Color dividerColor;
  final double radius;

  const FladToggleGroupTheme({
    required this.background,
    required this.selectedBackground,
    required this.foreground,
    required this.selectedForeground,
    required this.borderColor,
    required this.dividerColor,
    required this.radius,
  });

  factory FladToggleGroupTheme.fromScheme(ColorScheme scheme) {
    return FladToggleGroupTheme(
      background: scheme.surfaceContainerHighest,
      selectedBackground: scheme.primary,
      foreground: scheme.onSurfaceVariant,
      selectedForeground: scheme.onPrimary,
      borderColor: scheme.outlineVariant,
      dividerColor: scheme.outlineVariant,
      radius: 10,
    );
  }

  @override
  FladToggleGroupTheme copyWith({
    Color? background,
    Color? selectedBackground,
    Color? foreground,
    Color? selectedForeground,
    Color? borderColor,
    Color? dividerColor,
    double? radius,
  }) {
    return FladToggleGroupTheme(
      background: background ?? this.background,
      selectedBackground: selectedBackground ?? this.selectedBackground,
      foreground: foreground ?? this.foreground,
      selectedForeground: selectedForeground ?? this.selectedForeground,
      borderColor: borderColor ?? this.borderColor,
      dividerColor: dividerColor ?? this.dividerColor,
      radius: radius ?? this.radius,
    );
  }

  @override
  FladToggleGroupTheme lerp(
      ThemeExtension<FladToggleGroupTheme>? other, double t) {
    if (other is! FladToggleGroupTheme) return this;
    return FladToggleGroupTheme(
      background: Color.lerp(background, other.background, t)!,
      selectedBackground:
          Color.lerp(selectedBackground, other.selectedBackground, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      selectedForeground:
          Color.lerp(selectedForeground, other.selectedForeground, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t)!,
      radius: radius + (other.radius - radius) * t,
    );
  }
}

class FladToggleItem {
  final String label;
  final IconData? icon;

  const FladToggleItem({
    required this.label,
    this.icon,
  });
}

class FladToggleGroup extends StatelessWidget {
  final List<FladToggleItem> items;
  final int selectedIndex;
  final Set<int>? selectedIndices;
  final ValueChanged<int>? onChanged;
  final bool multiSelect;
  final FladToggleGroupSize size;

  const FladToggleGroup({
    super.key,
    required this.items,
    this.selectedIndex = 0,
    this.selectedIndices,
    this.onChanged,
    this.multiSelect = false,
    this.size = FladToggleGroupSize.md,
  });

  bool _isSelected(int index) {
    if (multiSelect && selectedIndices != null) {
      return selectedIndices!.contains(index);
    }
    return index == selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladToggleGroupTheme>() ??
        FladToggleGroupTheme.fromScheme(theme.colorScheme);
    final sizing = _FladToggleGroupSizing.from(size);

    return Container(
      decoration: BoxDecoration(
        color: tokens.background,
        borderRadius: BorderRadius.circular(tokens.radius),
        border: Border.all(color: tokens.borderColor),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(items.length, (index) {
          final selected = _isSelected(index);
          final item = items[index];

          return GestureDetector(
            onTap: onChanged != null ? () => onChanged!(index) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(
                horizontal: sizing.horizontalPadding,
                vertical: sizing.verticalPadding,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? tokens.selectedBackground
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(tokens.radius - 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.icon != null) ...[
                    Icon(
                      item.icon,
                      size: sizing.iconSize,
                      color: selected
                          ? tokens.selectedForeground
                          : tokens.foreground,
                    ),
                    SizedBox(width: sizing.gap),
                  ],
                  Text(
                    item.label,
                    style: TextStyle(
                      color: selected
                          ? tokens.selectedForeground
                          : tokens.foreground,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: sizing.fontSize,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _FladToggleGroupSizing {
  final double fontSize;
  final double iconSize;
  final double gap;
  final double verticalPadding;
  final double horizontalPadding;

  const _FladToggleGroupSizing({
    required this.fontSize,
    required this.iconSize,
    required this.gap,
    required this.verticalPadding,
    required this.horizontalPadding,
  });

  factory _FladToggleGroupSizing.from(FladToggleGroupSize size) {
    switch (size) {
      case FladToggleGroupSize.sm:
        return const _FladToggleGroupSizing(
          fontSize: 12,
          iconSize: 14,
          gap: 4,
          verticalPadding: 4,
          horizontalPadding: 10,
        );
      case FladToggleGroupSize.md:
        return const _FladToggleGroupSizing(
          fontSize: 14,
          iconSize: 16,
          gap: 6,
          verticalPadding: 6,
          horizontalPadding: 14,
        );
      case FladToggleGroupSize.lg:
        return const _FladToggleGroupSizing(
          fontSize: 16,
          iconSize: 18,
          gap: 8,
          verticalPadding: 8,
          horizontalPadding: 18,
        );
    }
  }
}
''';
