/// Template for the Breadcrumb component source file.
const breadcrumbTemplate = '''
import 'package:flutter/material.dart';

@immutable
class FladBreadcrumbTheme extends ThemeExtension<FladBreadcrumbTheme> {
  final Color active;
  final Color inactive;
  final Color separator;
  final double spacing;

  const FladBreadcrumbTheme({
    required this.active,
    required this.inactive,
    required this.separator,
    required this.spacing,
  });

  factory FladBreadcrumbTheme.fromScheme(ColorScheme scheme) {
    return FladBreadcrumbTheme(
      active: scheme.onSurface,
      inactive: scheme.onSurfaceVariant,
      separator: scheme.outline,
      spacing: 8,
    );
  }

  @override
  FladBreadcrumbTheme copyWith({
    Color? active,
    Color? inactive,
    Color? separator,
    double? spacing,
  }) {
    return FladBreadcrumbTheme(
      active: active ?? this.active,
      inactive: inactive ?? this.inactive,
      separator: separator ?? this.separator,
      spacing: spacing ?? this.spacing,
    );
  }

  @override
  FladBreadcrumbTheme lerp(
    ThemeExtension<FladBreadcrumbTheme>? other,
    double t,
  ) {
    if (other is! FladBreadcrumbTheme) return this;
    return FladBreadcrumbTheme(
      active: Color.lerp(active, other.active, t)!,
      inactive: Color.lerp(inactive, other.inactive, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
      spacing: spacing + (other.spacing - spacing) * t,
    );
  }
}

class FladBreadcrumbItem {
  final String label;
  final VoidCallback? onTap;

  const FladBreadcrumbItem(this.label, {this.onTap});
}

class FladBreadcrumb extends StatelessWidget {
  final List<FladBreadcrumbItem> items;
  final Widget? separator;
  final bool wrap;

  const FladBreadcrumb({
    super.key,
    required this.items,
    this.separator,
    this.wrap = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladBreadcrumbTheme>() ??
        FladBreadcrumbTheme.fromScheme(theme.colorScheme);

    final childItems = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final isLast = i == items.length - 1;
      final style = theme.textTheme.bodyMedium?.copyWith(
        color: isLast ? tokens.active : tokens.inactive,
        fontWeight: isLast ? FontWeight.w600 : FontWeight.w500,
      );

      childItems.add(
        InkWell(
          onTap: item.onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.spacing / 2),
            child: Text(item.label, style: style),
          ),
        ),
      );

      if (!isLast) {
        childItems.add(
          separator ??
              Padding(
                padding: EdgeInsets.symmetric(horizontal: tokens.spacing / 2),
                child: Icon(Icons.chevron_right,
                    size: 16, color: tokens.separator),
              ),
        );
      }
    }

    if (wrap) {
      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: childItems,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: childItems,
    );
  }
}
''';
