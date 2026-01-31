/// Template for the Dropdown Menu component source file.
const dropdownMenuTemplate = '''
import 'package:flutter/material.dart';

enum FladDropdownMenuSize { sm, md, lg }

@immutable
class FladDropdownMenuTheme extends ThemeExtension<FladDropdownMenuTheme> {
  final Color background;
  final Color border;
  final Color shadow;
  final Color itemText;
  final Color itemDisabledText;
  final Color itemHover;
  final double radius;
  final double borderWidth;
  final double elevation;

  const FladDropdownMenuTheme({
    required this.background,
    required this.border,
    required this.shadow,
    required this.itemText,
    required this.itemDisabledText,
    required this.itemHover,
    required this.radius,
    required this.borderWidth,
    required this.elevation,
  });

  factory FladDropdownMenuTheme.fromScheme(ColorScheme scheme) {
    return FladDropdownMenuTheme(
      background: scheme.surface,
      border: scheme.outlineVariant,
      shadow: scheme.shadow.withOpacity(0.2),
      itemText: scheme.onSurface,
      itemDisabledText: scheme.onSurface.withOpacity(0.38),
      itemHover: scheme.primary.withOpacity(0.08),
      radius: 12,
      borderWidth: 1,
      elevation: 8,
    );
  }

  @override
  FladDropdownMenuTheme copyWith({
    Color? background,
    Color? border,
    Color? shadow,
    Color? itemText,
    Color? itemDisabledText,
    Color? itemHover,
    double? radius,
    double? borderWidth,
    double? elevation,
  }) {
    return FladDropdownMenuTheme(
      background: background ?? this.background,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
      itemText: itemText ?? this.itemText,
      itemDisabledText: itemDisabledText ?? this.itemDisabledText,
      itemHover: itemHover ?? this.itemHover,
      radius: radius ?? this.radius,
      borderWidth: borderWidth ?? this.borderWidth,
      elevation: elevation ?? this.elevation,
    );
  }

  @override
  FladDropdownMenuTheme lerp(
      ThemeExtension<FladDropdownMenuTheme>? other, double t) {
    if (other is! FladDropdownMenuTheme) return this;
    return FladDropdownMenuTheme(
      background: Color.lerp(background, other.background, t)!,
      border: Color.lerp(border, other.border, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      itemText: Color.lerp(itemText, other.itemText, t)!,
      itemDisabledText:
          Color.lerp(itemDisabledText, other.itemDisabledText, t)!,
      itemHover: Color.lerp(itemHover, other.itemHover, t)!,
      radius: radius + (other.radius - radius) * t,
      borderWidth: borderWidth + (other.borderWidth - borderWidth) * t,
      elevation: elevation + (other.elevation - elevation) * t,
    );
  }
}

class FladDropdownMenuItem<T> {
  final T value;
  final String label;
  final Widget? leading;
  final Widget? trailing;
  final bool enabled;

  const FladDropdownMenuItem({
    required this.value,
    required this.label,
    this.leading,
    this.trailing,
    this.enabled = true,
  });
}

class FladDropdownMenu<T> extends StatelessWidget {
  final List<FladDropdownMenuItem<T>> items;
  final ValueChanged<T>? onSelected;
  final Widget child;
  final bool enabled;
  final FladDropdownMenuSize size;

  const FladDropdownMenu({
    super.key,
    required this.items,
    required this.child,
    required this.onSelected,
    this.enabled = true,
    this.size = FladDropdownMenuSize.md,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladDropdownMenuTheme>() ??
        FladDropdownMenuTheme.fromScheme(theme.colorScheme);
    final sizing = _FladDropdownMenuSizing.from(size);

    final popupTheme = PopupMenuThemeData(
      color: tokens.background,
      elevation: tokens.elevation,
      shadowColor: tokens.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius),
        side: BorderSide(color: tokens.border, width: tokens.borderWidth),
      ),
      textStyle: TextStyle(color: tokens.itemText, fontSize: sizing.fontSize),
    );

    return Theme(
      data: theme.copyWith(popupMenuTheme: popupTheme),
      child: PopupMenuButton<T>(
        enabled: enabled,
        onSelected: onSelected,
        itemBuilder: (context) {
          return items.map((item) {
            final fg = item.enabled ? tokens.itemText : tokens.itemDisabledText;
            return PopupMenuItem<T>(
              value: item.value,
              enabled: item.enabled,
              child: Row(
                children: [
                  if (item.leading != null) ...[
                    IconTheme(
                      data: IconThemeData(color: fg, size: sizing.iconSize),
                      child: item.leading!,
                    ),
                    SizedBox(width: sizing.gap),
                  ],
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(color: fg, fontSize: sizing.fontSize),
                    ),
                  ),
                  if (item.trailing != null) ...[
                    SizedBox(width: sizing.gap),
                    IconTheme(
                      data: IconThemeData(color: fg, size: sizing.iconSize),
                      child: item.trailing!,
                    ),
                  ],
                ],
              ),
            );
          }).toList();
        },
        child: child,
      ),
    );
  }
}

class _FladDropdownMenuSizing {
  final double fontSize;
  final double iconSize;
  final double gap;

  const _FladDropdownMenuSizing({
    required this.fontSize,
    required this.iconSize,
    required this.gap,
  });

  factory _FladDropdownMenuSizing.from(FladDropdownMenuSize size) {
    switch (size) {
      case FladDropdownMenuSize.sm:
        return const _FladDropdownMenuSizing(fontSize: 12, iconSize: 16, gap: 6);
      case FladDropdownMenuSize.md:
        return const _FladDropdownMenuSizing(fontSize: 14, iconSize: 18, gap: 8);
      case FladDropdownMenuSize.lg:
        return const _FladDropdownMenuSizing(fontSize: 16, iconSize: 20, gap: 10);
    }
  }
}
''';
