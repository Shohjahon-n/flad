/// Template for the Tabs component source file.
const tabsTemplate = '''
import 'package:flutter/material.dart';

enum FladTabsSize { sm, md, lg }

@immutable
class FladTabsTheme extends ThemeExtension<FladTabsTheme> {
  final Color background;
  final Color border;
  final Color indicator;
  final Color label;
  final Color unselectedLabel;
  final double radius;
  final double borderWidth;

  const FladTabsTheme({
    required this.background,
    required this.border,
    required this.indicator,
    required this.label,
    required this.unselectedLabel,
    required this.radius,
    required this.borderWidth,
  });

  factory FladTabsTheme.fromScheme(ColorScheme scheme) {
    return FladTabsTheme(
      background: scheme.surface,
      border: scheme.outlineVariant,
      indicator: scheme.primary.withOpacity(0.12),
      label: scheme.primary,
      unselectedLabel: scheme.onSurfaceVariant,
      radius: 12,
      borderWidth: 1,
    );
  }

  @override
  FladTabsTheme copyWith({
    Color? background,
    Color? border,
    Color? indicator,
    Color? label,
    Color? unselectedLabel,
    double? radius,
    double? borderWidth,
  }) {
    return FladTabsTheme(
      background: background ?? this.background,
      border: border ?? this.border,
      indicator: indicator ?? this.indicator,
      label: label ?? this.label,
      unselectedLabel: unselectedLabel ?? this.unselectedLabel,
      radius: radius ?? this.radius,
      borderWidth: borderWidth ?? this.borderWidth,
    );
  }

  @override
  FladTabsTheme lerp(ThemeExtension<FladTabsTheme>? other, double t) {
    if (other is! FladTabsTheme) return this;
    return FladTabsTheme(
      background: Color.lerp(background, other.background, t)!,
      border: Color.lerp(border, other.border, t)!,
      indicator: Color.lerp(indicator, other.indicator, t)!,
      label: Color.lerp(label, other.label, t)!,
      unselectedLabel: Color.lerp(unselectedLabel, other.unselectedLabel, t)!,
      radius: radius + (other.radius - radius) * t,
      borderWidth: borderWidth + (other.borderWidth - borderWidth) * t,
    );
  }
}

class FladTabItem {
  final String label;
  final Widget? leading;
  final Widget? trailing;

  const FladTabItem({
    required this.label,
    this.leading,
    this.trailing,
  });
}

class FladTabs extends StatelessWidget {
  final List<FladTabItem> tabs;
  final List<Widget> views;
  final int initialIndex;
  final FladTabsSize size;
  final bool isScrollable;
  final EdgeInsetsGeometry? padding;

  const FladTabs({
    super.key,
    required this.tabs,
    required this.views,
    this.initialIndex = 0,
    this.size = FladTabsSize.md,
    this.isScrollable = false,
    this.padding,
  }) : assert(tabs.length == views.length, 'tabs and views must match.');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladTabsTheme>() ??
        FladTabsTheme.fromScheme(theme.colorScheme);
    final sizing = _FladTabsSizing.from(size);
    final radius = BorderRadius.circular(tokens.radius);

    return DefaultTabController(
      length: tabs.length,
      initialIndex: initialIndex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: tokens.background,
              borderRadius: radius,
              border: Border.all(color: tokens.border, width: tokens.borderWidth),
            ),
            padding: padding ?? const EdgeInsets.all(4),
            child: TabBar(
              isScrollable: isScrollable,
              labelColor: tokens.label,
              unselectedLabelColor: tokens.unselectedLabel,
              indicator: BoxDecoration(
                color: tokens.indicator,
                borderRadius: BorderRadius.circular(tokens.radius - 4),
              ),
              labelStyle: TextStyle(
                fontSize: sizing.fontSize,
                fontWeight: FontWeight.w600,
              ),
              tabs: [
                for (final tab in tabs)
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (tab.leading != null) ...[
                          IconTheme(
                            data: IconThemeData(size: sizing.iconSize),
                            child: tab.leading!,
                          ),
                          SizedBox(width: sizing.gap),
                        ],
                        Text(tab.label),
                        if (tab.trailing != null) ...[
                          SizedBox(width: sizing.gap),
                          IconTheme(
                            data: IconThemeData(size: sizing.iconSize),
                            child: tab.trailing!,
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TabBarView(children: views),
          ),
        ],
      ),
    );
  }
}

class _FladTabsSizing {
  final double fontSize;
  final double iconSize;
  final double gap;

  const _FladTabsSizing({
    required this.fontSize,
    required this.iconSize,
    required this.gap,
  });

  factory _FladTabsSizing.from(FladTabsSize size) {
    switch (size) {
      case FladTabsSize.sm:
        return const _FladTabsSizing(fontSize: 12, iconSize: 16, gap: 6);
      case FladTabsSize.md:
        return const _FladTabsSizing(fontSize: 14, iconSize: 18, gap: 8);
      case FladTabsSize.lg:
        return const _FladTabsSizing(fontSize: 16, iconSize: 20, gap: 10);
    }
  }
}
''';
