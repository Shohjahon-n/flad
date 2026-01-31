/// Template for the Navigation Rail component source file.
const navigationRailTemplate = '''
import 'package:flutter/material.dart';

@immutable
class FladNavigationRailTheme extends ThemeExtension<FladNavigationRailTheme> {
  final Color background;
  final Color indicator;
  final Color selectedIcon;
  final Color unselectedIcon;
  final Color selectedText;
  final Color unselectedText;

  const FladNavigationRailTheme({
    required this.background,
    required this.indicator,
    required this.selectedIcon,
    required this.unselectedIcon,
    required this.selectedText,
    required this.unselectedText,
  });

  factory FladNavigationRailTheme.fromScheme(ColorScheme scheme) {
    return FladNavigationRailTheme(
      background: scheme.surface,
      indicator: scheme.primary.withOpacity(0.12),
      selectedIcon: scheme.primary,
      unselectedIcon: scheme.onSurfaceVariant,
      selectedText: scheme.primary,
      unselectedText: scheme.onSurfaceVariant,
    );
  }

  @override
  FladNavigationRailTheme copyWith({
    Color? background,
    Color? indicator,
    Color? selectedIcon,
    Color? unselectedIcon,
    Color? selectedText,
    Color? unselectedText,
  }) {
    return FladNavigationRailTheme(
      background: background ?? this.background,
      indicator: indicator ?? this.indicator,
      selectedIcon: selectedIcon ?? this.selectedIcon,
      unselectedIcon: unselectedIcon ?? this.unselectedIcon,
      selectedText: selectedText ?? this.selectedText,
      unselectedText: unselectedText ?? this.unselectedText,
    );
  }

  @override
  FladNavigationRailTheme lerp(
    ThemeExtension<FladNavigationRailTheme>? other,
    double t,
  ) {
    if (other is! FladNavigationRailTheme) return this;
    return FladNavigationRailTheme(
      background: Color.lerp(background, other.background, t)!,
      indicator: Color.lerp(indicator, other.indicator, t)!,
      selectedIcon: Color.lerp(selectedIcon, other.selectedIcon, t)!,
      unselectedIcon: Color.lerp(unselectedIcon, other.unselectedIcon, t)!,
      selectedText: Color.lerp(selectedText, other.selectedText, t)!,
      unselectedText: Color.lerp(unselectedText, other.unselectedText, t)!,
    );
  }
}

class FladNavigationRail extends StatelessWidget {
  final List<NavigationRailDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;
  final bool extended;
  final double? minWidth;
  final double? minExtendedWidth;
  final Color? backgroundColor;

  const FladNavigationRail({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    this.onDestinationSelected,
    this.extended = false,
    this.minWidth,
    this.minExtendedWidth,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladNavigationRailTheme>() ??
        FladNavigationRailTheme.fromScheme(theme.colorScheme);

    return NavigationRail(
      destinations: destinations,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      extended: extended,
      minWidth: minWidth,
      minExtendedWidth: minExtendedWidth,
      backgroundColor: backgroundColor ?? tokens.background,
      indicatorColor: tokens.indicator,
      selectedIconTheme: IconThemeData(color: tokens.selectedIcon),
      unselectedIconTheme: IconThemeData(color: tokens.unselectedIcon),
      selectedLabelTextStyle: TextStyle(color: tokens.selectedText),
      unselectedLabelTextStyle: TextStyle(color: tokens.unselectedText),
    );
  }
}
''';
