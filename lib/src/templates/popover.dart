/// Template for the Popover component source file.
const popoverTemplate = '''
import 'package:flutter/material.dart';

enum FladPopoverAlignment { top, bottom, left, right }

@immutable
class FladPopoverTheme extends ThemeExtension<FladPopoverTheme> {
  final Color background;
  final Color shadowColor;
  final Color barrierColor;
  final Color borderColor;
  final double radius;
  final double elevation;

  const FladPopoverTheme({
    required this.background,
    required this.shadowColor,
    required this.barrierColor,
    required this.borderColor,
    required this.radius,
    required this.elevation,
  });

  factory FladPopoverTheme.fromScheme(ColorScheme scheme) {
    return FladPopoverTheme(
      background: scheme.surface,
      shadowColor: scheme.shadow.withOpacity(0.12),
      barrierColor: Colors.transparent,
      borderColor: scheme.outlineVariant,
      radius: 12,
      elevation: 8,
    );
  }

  @override
  FladPopoverTheme copyWith({
    Color? background,
    Color? shadowColor,
    Color? barrierColor,
    Color? borderColor,
    double? radius,
    double? elevation,
  }) {
    return FladPopoverTheme(
      background: background ?? this.background,
      shadowColor: shadowColor ?? this.shadowColor,
      barrierColor: barrierColor ?? this.barrierColor,
      borderColor: borderColor ?? this.borderColor,
      radius: radius ?? this.radius,
      elevation: elevation ?? this.elevation,
    );
  }

  @override
  FladPopoverTheme lerp(ThemeExtension<FladPopoverTheme>? other, double t) {
    if (other is! FladPopoverTheme) return this;
    return FladPopoverTheme(
      background: Color.lerp(background, other.background, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
      barrierColor: Color.lerp(barrierColor, other.barrierColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      radius: radius + (other.radius - radius) * t,
      elevation: elevation + (other.elevation - elevation) * t,
    );
  }
}

class FladPopover extends StatefulWidget {
  final Widget child;
  final Widget content;
  final FladPopoverAlignment alignment;
  final double offset;
  final EdgeInsets contentPadding;

  const FladPopover({
    super.key,
    required this.child,
    required this.content,
    this.alignment = FladPopoverAlignment.bottom,
    this.offset = 8,
    this.contentPadding = const EdgeInsets.all(12),
  });

  @override
  State<FladPopover> createState() => _FladPopoverState();
}

class _FladPopoverState extends State<FladPopover> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isVisible = false;

  void _show() {
    if (_isVisible) return;
    _overlayEntry = _createOverlay();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isVisible = true);
  }

  void _hide() {
    if (!_isVisible) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isVisible = false);
  }

  void _toggle() {
    if (_isVisible) {
      _hide();
    } else {
      _show();
    }
  }

  @override
  void dispose() {
    _hide();
    super.dispose();
  }

  Offset _getOffset() {
    switch (widget.alignment) {
      case FladPopoverAlignment.top:
        return Offset(0, -widget.offset);
      case FladPopoverAlignment.bottom:
        return Offset(0, widget.offset);
      case FladPopoverAlignment.left:
        return Offset(-widget.offset, 0);
      case FladPopoverAlignment.right:
        return Offset(widget.offset, 0);
    }
  }

  Alignment _getTargetAnchor() {
    switch (widget.alignment) {
      case FladPopoverAlignment.top:
        return Alignment.topCenter;
      case FladPopoverAlignment.bottom:
        return Alignment.bottomCenter;
      case FladPopoverAlignment.left:
        return Alignment.centerLeft;
      case FladPopoverAlignment.right:
        return Alignment.centerRight;
    }
  }

  Alignment _getFollowerAnchor() {
    switch (widget.alignment) {
      case FladPopoverAlignment.top:
        return Alignment.bottomCenter;
      case FladPopoverAlignment.bottom:
        return Alignment.topCenter;
      case FladPopoverAlignment.left:
        return Alignment.centerRight;
      case FladPopoverAlignment.right:
        return Alignment.centerLeft;
    }
  }

  OverlayEntry _createOverlay() {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladPopoverTheme>() ??
        FladPopoverTheme.fromScheme(theme.colorScheme);

    return OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              onTap: _hide,
              behavior: HitTestBehavior.translucent,
              child: Container(color: tokens.barrierColor),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              targetAnchor: _getTargetAnchor(),
              followerAnchor: _getFollowerAnchor(),
              offset: _getOffset(),
              child: Material(
                color: tokens.background,
                elevation: tokens.elevation,
                shadowColor: tokens.shadowColor,
                borderRadius: BorderRadius.circular(tokens.radius),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(tokens.radius),
                    border: Border.all(color: tokens.borderColor),
                  ),
                  padding: widget.contentPadding,
                  child: widget.content,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggle,
        child: widget.child,
      ),
    );
  }
}
''';
