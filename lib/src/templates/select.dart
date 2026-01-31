/// Template for the Select component source file.
const selectTemplate = '''
import 'package:flutter/material.dart';

enum FladSelectSize { sm, md, lg }

@immutable
class FladSelectTheme extends ThemeExtension<FladSelectTheme> {
  final Color background;
  final Color text;
  final Color placeholder;
  final Color border;
  final Color focusBorder;
  final Color disabledBackground;
  final Color disabledText;
  final Color menuBackground;
  final Color menuBorder;
  final Color menuShadow;
  final Color itemHover;
  final Color itemSelected;
  final Color itemText;
  final Color itemDisabledText;
  final double radius;
  final double borderWidth;
  final double menuElevation;

  const FladSelectTheme({
    required this.background,
    required this.text,
    required this.placeholder,
    required this.border,
    required this.focusBorder,
    required this.disabledBackground,
    required this.disabledText,
    required this.menuBackground,
    required this.menuBorder,
    required this.menuShadow,
    required this.itemHover,
    required this.itemSelected,
    required this.itemText,
    required this.itemDisabledText,
    required this.radius,
    required this.borderWidth,
    required this.menuElevation,
  });

  factory FladSelectTheme.fromScheme(ColorScheme scheme) {
    return FladSelectTheme(
      background: scheme.surface,
      text: scheme.onSurface,
      placeholder: scheme.onSurfaceVariant,
      border: scheme.outline,
      focusBorder: scheme.primary,
      disabledBackground: scheme.onSurface.withOpacity(0.04),
      disabledText: scheme.onSurface.withOpacity(0.38),
      menuBackground: scheme.surface,
      menuBorder: scheme.outlineVariant,
      menuShadow: scheme.shadow.withOpacity(0.2),
      itemHover: scheme.primary.withOpacity(0.08),
      itemSelected: scheme.primary.withOpacity(0.14),
      itemText: scheme.onSurface,
      itemDisabledText: scheme.onSurface.withOpacity(0.38),
      radius: 12,
      borderWidth: 1,
      menuElevation: 8,
    );
  }

  @override
  FladSelectTheme copyWith({
    Color? background,
    Color? text,
    Color? placeholder,
    Color? border,
    Color? focusBorder,
    Color? disabledBackground,
    Color? disabledText,
    Color? menuBackground,
    Color? menuBorder,
    Color? menuShadow,
    Color? itemHover,
    Color? itemSelected,
    Color? itemText,
    Color? itemDisabledText,
    double? radius,
    double? borderWidth,
    double? menuElevation,
  }) {
    return FladSelectTheme(
      background: background ?? this.background,
      text: text ?? this.text,
      placeholder: placeholder ?? this.placeholder,
      border: border ?? this.border,
      focusBorder: focusBorder ?? this.focusBorder,
      disabledBackground: disabledBackground ?? this.disabledBackground,
      disabledText: disabledText ?? this.disabledText,
      menuBackground: menuBackground ?? this.menuBackground,
      menuBorder: menuBorder ?? this.menuBorder,
      menuShadow: menuShadow ?? this.menuShadow,
      itemHover: itemHover ?? this.itemHover,
      itemSelected: itemSelected ?? this.itemSelected,
      itemText: itemText ?? this.itemText,
      itemDisabledText: itemDisabledText ?? this.itemDisabledText,
      radius: radius ?? this.radius,
      borderWidth: borderWidth ?? this.borderWidth,
      menuElevation: menuElevation ?? this.menuElevation,
    );
  }

  @override
  FladSelectTheme lerp(ThemeExtension<FladSelectTheme>? other, double t) {
    if (other is! FladSelectTheme) return this;
    return FladSelectTheme(
      background: Color.lerp(background, other.background, t)!,
      text: Color.lerp(text, other.text, t)!,
      placeholder: Color.lerp(placeholder, other.placeholder, t)!,
      border: Color.lerp(border, other.border, t)!,
      focusBorder: Color.lerp(focusBorder, other.focusBorder, t)!,
      disabledBackground:
          Color.lerp(disabledBackground, other.disabledBackground, t)!,
      disabledText: Color.lerp(disabledText, other.disabledText, t)!,
      menuBackground: Color.lerp(menuBackground, other.menuBackground, t)!,
      menuBorder: Color.lerp(menuBorder, other.menuBorder, t)!,
      menuShadow: Color.lerp(menuShadow, other.menuShadow, t)!,
      itemHover: Color.lerp(itemHover, other.itemHover, t)!,
      itemSelected: Color.lerp(itemSelected, other.itemSelected, t)!,
      itemText: Color.lerp(itemText, other.itemText, t)!,
      itemDisabledText:
          Color.lerp(itemDisabledText, other.itemDisabledText, t)!,
      radius: radius + (other.radius - radius) * t,
      borderWidth: borderWidth + (other.borderWidth - borderWidth) * t,
      menuElevation: menuElevation + (other.menuElevation - menuElevation) * t,
    );
  }
}

class FladSelectItem<T> {
  final T value;
  final String label;
  final Widget? leading;
  final Widget? trailing;
  final bool enabled;

  const FladSelectItem({
    required this.value,
    required this.label,
    this.leading,
    this.trailing,
    this.enabled = true,
  });
}

class FladSelect<T> extends StatefulWidget {
  final List<FladSelectItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? hint;
  final bool enabled;
  final FladSelectSize size;
  final double menuMaxHeight;
  final double menuOffset;
  final bool showCheckmark;
  final BorderRadius? borderRadius;

  const FladSelect({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.hint,
    this.enabled = true,
    this.size = FladSelectSize.md,
    this.menuMaxHeight = 320,
    this.menuOffset = 8,
    this.showCheckmark = true,
    this.borderRadius,
  });

  @override
  State<FladSelect<T>> createState() => _FladSelectState<T>();
}

class _FladSelectState<T> extends State<FladSelect<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _barrierEntry;
  OverlayEntry? _menuEntry;
  bool _isOpen = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _toggleMenu() {
    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    if (!mounted) return;
    final overlay = Overlay.of(context);
    final box = context.findRenderObject() as RenderBox;
    final size = box.size;

    _barrierEntry = OverlayEntry(
      builder: (_) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _removeOverlay,
        child: const SizedBox.expand(),
      ),
    );

    _menuEntry = OverlayEntry(
      builder: (context) {
        final tokens = Theme.of(context).extension<FladSelectTheme>() ??
            FladSelectTheme.fromScheme(Theme.of(context).colorScheme);

        return Positioned.fill(
          child: Stack(
            children: [
              CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, size.height + widget.menuOffset),
                child: Material(
                  color: tokens.menuBackground,
                  elevation: tokens.menuElevation,
                  shadowColor: tokens.menuShadow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(tokens.radius),
                    side: BorderSide(
                      color: tokens.menuBorder,
                      width: tokens.borderWidth,
                    ),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: widget.menuMaxHeight,
                      minWidth: size.width,
                      maxWidth: size.width,
                    ),
                    child: _buildMenu(tokens),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    overlay.insertAll([_barrierEntry!, _menuEntry!]);
    setState(() => _isOpen = true);
  }

  void _removeOverlay() {
    _menuEntry?.remove();
    _barrierEntry?.remove();
    _menuEntry = null;
    _barrierEntry = null;
    if (_isOpen && mounted) {
      setState(() => _isOpen = false);
    }
  }

  FladSelectItem<T>? _selectedItem() {
    for (final item in widget.items) {
      if (item.value == widget.value) {
        return item;
      }
    }
    return null;
  }

  Widget _buildMenu(FladSelectTheme tokens) {
    if (widget.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No options',
          style: TextStyle(color: tokens.placeholder),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];
        final selected = item.value == widget.value;
        final isEnabled = item.enabled;

        final fg = isEnabled ? tokens.itemText : tokens.itemDisabledText;
        final bg = selected ? tokens.itemSelected : Colors.transparent;

        return InkWell(
          onTap: isEnabled
              ? () {
                  widget.onChanged?.call(item.value);
                  _removeOverlay();
                }
              : null,
          overlayColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.hovered) ||
                states.contains(MaterialState.pressed)) {
              return tokens.itemHover;
            }
            return null;
          }),
          child: Container(
            color: bg,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                if (item.leading != null) ...[
                  IconTheme(
                    data: IconThemeData(color: fg, size: 18),
                    child: item.leading!,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(color: fg, fontWeight: FontWeight.w500),
                  ),
                ),
                if (item.trailing != null) ...[
                  const SizedBox(width: 8),
                  IconTheme(
                    data: IconThemeData(color: fg, size: 18),
                    child: item.trailing!,
                  ),
                ],
                if (widget.showCheckmark && selected) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.check, size: 18, color: fg),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladSelectTheme>() ??
        FladSelectTheme.fromScheme(theme.colorScheme);
    final sizing = _FladSelectSizing.from(widget.size);

    final selected = _selectedItem();
    final isDisabled = !widget.enabled || widget.onChanged == null;
    final showPlaceholder = selected == null;

    final borderColor = _isOpen ? tokens.focusBorder : tokens.border;
    final bgColor = isDisabled ? tokens.disabledBackground : tokens.background;
    final textColor = showPlaceholder ? tokens.placeholder : tokens.text;
    final radius = widget.borderRadius ?? BorderRadius.circular(tokens.radius);

    return CompositedTransformTarget(
      link: _layerLink,
      child: Material(
        color: bgColor,
        borderRadius: radius,
        child: InkWell(
          onTap: isDisabled ? null : _toggleMenu,
          borderRadius: radius,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: EdgeInsets.symmetric(
              vertical: sizing.verticalPadding,
              horizontal: sizing.horizontalPadding,
            ),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: borderColor, width: tokens.borderWidth),
            ),
            child: Row(
              children: [
                if (selected?.leading != null) ...[
                  IconTheme(
                    data: IconThemeData(color: textColor, size: sizing.iconSize),
                    child: selected!.leading!,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    showPlaceholder ? (widget.hint ?? 'Select') : selected!.label,
                    style: TextStyle(
                      color: isDisabled ? tokens.disabledText : textColor,
                      fontSize: sizing.fontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 120),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: sizing.iconSize,
                    color: isDisabled ? tokens.disabledText : tokens.placeholder,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FladSelectSizing {
  final double fontSize;
  final double iconSize;
  final double verticalPadding;
  final double horizontalPadding;

  const _FladSelectSizing({
    required this.fontSize,
    required this.iconSize,
    required this.verticalPadding,
    required this.horizontalPadding,
  });

  factory _FladSelectSizing.from(FladSelectSize size) {
    switch (size) {
      case FladSelectSize.sm:
        return const _FladSelectSizing(
          fontSize: 12,
          iconSize: 18,
          verticalPadding: 8,
          horizontalPadding: 12,
        );
      case FladSelectSize.md:
        return const _FladSelectSizing(
          fontSize: 14,
          iconSize: 20,
          verticalPadding: 10,
          horizontalPadding: 14,
        );
      case FladSelectSize.lg:
        return const _FladSelectSizing(
          fontSize: 16,
          iconSize: 22,
          verticalPadding: 12,
          horizontalPadding: 16,
        );
    }
  }
}
''';
