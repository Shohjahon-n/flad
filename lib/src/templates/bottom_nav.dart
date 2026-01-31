/// Template for the Bottom Navigation component source file.
const bottomNavTemplate = '''
import 'package:flutter/material.dart';

@immutable
class FladBottomNavTheme extends ThemeExtension<FladBottomNavTheme> {
  final Color background;
  final Color active;
  final Color inactive;
  final double elevation;

  const FladBottomNavTheme({
    required this.background,
    required this.active,
    required this.inactive,
    required this.elevation,
  });

  factory FladBottomNavTheme.fromScheme(ColorScheme scheme) {
    return FladBottomNavTheme(
      background: scheme.surface,
      active: scheme.primary,
      inactive: scheme.onSurfaceVariant,
      elevation: 6,
    );
  }

  @override
  FladBottomNavTheme copyWith({
    Color? background,
    Color? active,
    Color? inactive,
    double? elevation,
  }) {
    return FladBottomNavTheme(
      background: background ?? this.background,
      active: active ?? this.active,
      inactive: inactive ?? this.inactive,
      elevation: elevation ?? this.elevation,
    );
  }

  @override
  FladBottomNavTheme lerp(
    ThemeExtension<FladBottomNavTheme>? other,
    double t,
  ) {
    if (other is! FladBottomNavTheme) return this;
    return FladBottomNavTheme(
      background: Color.lerp(background, other.background, t)!,
      active: Color.lerp(active, other.active, t)!,
      inactive: Color.lerp(inactive, other.inactive, t)!,
      elevation: elevation + (other.elevation - elevation) * t,
    );
  }
}

class FladBottomNav extends StatelessWidget {
  final List<BottomNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final bool showLabels;
  final double? iconSize;
  final BottomNavigationBarType type;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;

  const FladBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    this.onTap,
    this.showLabels = true,
    this.iconSize,
    this.type = BottomNavigationBarType.fixed,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladBottomNavTheme>() ??
        FladBottomNavTheme.fromScheme(theme.colorScheme);

    return Material(
      elevation: tokens.elevation,
      color: backgroundColor ?? tokens.background,
      child: BottomNavigationBar(
        items: items,
        currentIndex: currentIndex,
        onTap: onTap,
        showSelectedLabels: showLabels,
        showUnselectedLabels: showLabels,
        iconSize: iconSize ?? 24,
        type: type,
        backgroundColor: backgroundColor ?? tokens.background,
        selectedItemColor: activeColor ?? tokens.active,
        unselectedItemColor: inactiveColor ?? tokens.inactive,
      ),
    );
  }
}
''';
