/// Template for the Drawer component source file.
const drawerTemplate = '''
import 'package:flutter/material.dart';

@immutable
class FladDrawerTheme extends ThemeExtension<FladDrawerTheme> {
  final Color background;
  final Color divider;
  final double width;
  final EdgeInsetsGeometry padding;

  const FladDrawerTheme({
    required this.background,
    required this.divider,
    required this.width,
    required this.padding,
  });

  factory FladDrawerTheme.fromScheme(ColorScheme scheme) {
    return FladDrawerTheme(
      background: scheme.surface,
      divider: scheme.outlineVariant,
      width: 304,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  FladDrawerTheme copyWith({
    Color? background,
    Color? divider,
    double? width,
    EdgeInsetsGeometry? padding,
  }) {
    return FladDrawerTheme(
      background: background ?? this.background,
      divider: divider ?? this.divider,
      width: width ?? this.width,
      padding: padding ?? this.padding,
    );
  }

  @override
  FladDrawerTheme lerp(ThemeExtension<FladDrawerTheme>? other, double t) {
    if (other is! FladDrawerTheme) return this;
    return FladDrawerTheme(
      background: Color.lerp(background, other.background, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      width: width + (other.width - width) * t,
      padding: EdgeInsetsGeometry.lerp(padding, other.padding, t)!,
    );
  }
}

class FladDrawer extends StatelessWidget {
  final Widget? header;
  final List<Widget> children;
  final Widget? footer;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final Color? backgroundColor;
  final bool showDividers;

  const FladDrawer({
    super.key,
    this.header,
    this.children = const [],
    this.footer,
    this.padding,
    this.width,
    this.backgroundColor,
    this.showDividers = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladDrawerTheme>() ??
        FladDrawerTheme.fromScheme(theme.colorScheme);

    final divider = Divider(height: 1, color: tokens.divider);
    final listChildren = <Widget>[];
    if (header != null) {
      listChildren.add(header!);
      if (showDividers && children.isNotEmpty) {
        listChildren.add(divider);
      }
    }
    listChildren.addAll(children);
    if (footer != null) {
      if (showDividers && listChildren.isNotEmpty) {
        listChildren.add(divider);
      }
      listChildren.add(footer!);
    }

    return Drawer(
      width: width ?? tokens.width,
      backgroundColor: backgroundColor ?? tokens.background,
      child: SafeArea(
        child: ListView(
          padding: padding ?? tokens.padding,
          children: listChildren,
        ),
      ),
    );
  }
}
''';
