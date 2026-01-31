/// Template for the Empty State component source file.
const emptyStateTemplate = '''
import 'package:flutter/material.dart';

@immutable
class FladEmptyStateTheme extends ThemeExtension<FladEmptyStateTheme> {
  final Color title;
  final Color message;
  final Color icon;
  final double spacing;

  const FladEmptyStateTheme({
    required this.title,
    required this.message,
    required this.icon,
    required this.spacing,
  });

  factory FladEmptyStateTheme.fromScheme(ColorScheme scheme) {
    return FladEmptyStateTheme(
      title: scheme.onSurface,
      message: scheme.onSurfaceVariant,
      icon: scheme.onSurfaceVariant,
      spacing: 12,
    );
  }

  @override
  FladEmptyStateTheme copyWith({
    Color? title,
    Color? message,
    Color? icon,
    double? spacing,
  }) {
    return FladEmptyStateTheme(
      title: title ?? this.title,
      message: message ?? this.message,
      icon: icon ?? this.icon,
      spacing: spacing ?? this.spacing,
    );
  }

  @override
  FladEmptyStateTheme lerp(
    ThemeExtension<FladEmptyStateTheme>? other,
    double t,
  ) {
    if (other is! FladEmptyStateTheme) return this;
    return FladEmptyStateTheme(
      title: Color.lerp(title, other.title, t)!,
      message: Color.lerp(message, other.message, t)!,
      icon: Color.lerp(icon, other.icon, t)!,
      spacing: spacing + (other.spacing - spacing) * t,
    );
  }
}

class FladEmptyState extends StatelessWidget {
  final Widget? icon;
  final String title;
  final String? message;
  final Widget? action;
  final EdgeInsetsGeometry padding;
  final MainAxisAlignment alignment;

  const FladEmptyState({
    super.key,
    required this.title,
    this.icon,
    this.message,
    this.action,
    this.padding = const EdgeInsets.all(24),
    this.alignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladEmptyStateTheme>() ??
        FladEmptyStateTheme.fromScheme(theme.colorScheme);

    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: alignment,
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(color: tokens.icon, size: 48),
              child: icon!,
            ),
            SizedBox(height: tokens.spacing),
          ],
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: tokens.title,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            SizedBox(height: tokens.spacing),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: tokens.message,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[
            SizedBox(height: tokens.spacing * 1.5),
            action!,
          ],
        ],
      ),
    );
  }
}
''';
