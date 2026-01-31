/// Template for the AppBar component source file.
const appBarTemplate = '''
import 'package:flutter/material.dart';

@immutable
class FladAppBarTheme extends ThemeExtension<FladAppBarTheme> {
  final Color background;
  final Color foreground;
  final Color shadow;
  final double elevation;
  final double height;

  const FladAppBarTheme({
    required this.background,
    required this.foreground,
    required this.shadow,
    required this.elevation,
    required this.height,
  });

  factory FladAppBarTheme.fromScheme(ColorScheme scheme) {
    return FladAppBarTheme(
      background: scheme.surface,
      foreground: scheme.onSurface,
      shadow: scheme.shadow.withOpacity(0.24),
      elevation: 1,
      height: kToolbarHeight,
    );
  }

  @override
  FladAppBarTheme copyWith({
    Color? background,
    Color? foreground,
    Color? shadow,
    double? elevation,
    double? height,
  }) {
    return FladAppBarTheme(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      shadow: shadow ?? this.shadow,
      elevation: elevation ?? this.elevation,
      height: height ?? this.height,
    );
  }

  @override
  FladAppBarTheme lerp(ThemeExtension<FladAppBarTheme>? other, double t) {
    if (other is! FladAppBarTheme) return this;
    return FladAppBarTheme(
      background: Color.lerp(background, other.background, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      elevation: elevation + (other.elevation - elevation) * t,
      height: height + (other.height - height) * t,
    );
  }
}

class FladAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final double? height;
  final double? elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final PreferredSizeWidget? bottom;

  const FladAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.height,
    this.elevation,
    this.backgroundColor,
    this.foregroundColor,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladAppBarTheme>() ??
        FladAppBarTheme.fromScheme(theme.colorScheme);

    return AppBar(
      title: title,
      leading: leading,
      actions: actions,
      centerTitle: centerTitle,
      toolbarHeight: height ?? tokens.height,
      backgroundColor: backgroundColor ?? tokens.background,
      foregroundColor: foregroundColor ?? tokens.foreground,
      elevation: elevation ?? tokens.elevation,
      shadowColor: tokens.shadow,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize {
    final toolbarHeight = height ?? kToolbarHeight;
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(toolbarHeight + bottomHeight);
  }
}
''';
