/// Template for the Alert component source file.
const alertTemplate = '''
import 'package:flutter/material.dart';

enum FladAlertVariant { info, success, warning, danger }

@immutable
class FladAlertTheme extends ThemeExtension<FladAlertTheme> {
  final Color info;
  final Color success;
  final Color warning;
  final Color danger;
  final Color background;
  final double radius;

  const FladAlertTheme({
    required this.info,
    required this.success,
    required this.warning,
    required this.danger,
    required this.background,
    required this.radius,
  });

  factory FladAlertTheme.fromScheme(ColorScheme scheme) {
    return FladAlertTheme(
      info: scheme.primary,
      success: scheme.tertiary,
      warning: scheme.secondary,
      danger: scheme.error,
      background: scheme.surface,
      radius: 12,
    );
  }

  @override
  FladAlertTheme copyWith({
    Color? info,
    Color? success,
    Color? warning,
    Color? danger,
    Color? background,
    double? radius,
  }) {
    return FladAlertTheme(
      info: info ?? this.info,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      background: background ?? this.background,
      radius: radius ?? this.radius,
    );
  }

  @override
  FladAlertTheme lerp(ThemeExtension<FladAlertTheme>? other, double t) {
    if (other is! FladAlertTheme) return this;
    return FladAlertTheme(
      info: Color.lerp(info, other.info, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      background: Color.lerp(background, other.background, t)!,
      radius: radius + (other.radius - radius) * t,
    );
  }

  Color colorFor(FladAlertVariant variant) {
    switch (variant) {
      case FladAlertVariant.info:
        return info;
      case FladAlertVariant.success:
        return success;
      case FladAlertVariant.warning:
        return warning;
      case FladAlertVariant.danger:
        return danger;
    }
  }
}

class FladAlert extends StatelessWidget {
  final FladAlertVariant variant;
  final String title;
  final String? message;
  final Widget? leading;
  final Widget? action;
  final bool filled;
  final EdgeInsetsGeometry padding;

  const FladAlert({
    super.key,
    required this.title,
    this.message,
    this.leading,
    this.action,
    this.variant = FladAlertVariant.info,
    this.filled = false,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladAlertTheme>() ??
        FladAlertTheme.fromScheme(theme.colorScheme);

    final accent = tokens.colorFor(variant);
    final background = filled
        ? accent.withOpacity(0.12)
        : tokens.background.withOpacity(0.6);

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(tokens.radius),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(tokens.radius),
          border: Border.all(color: accent.withOpacity(0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leading != null) ...[
              IconTheme(
                data: IconThemeData(color: accent),
                child: leading!,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      message!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (action != null) ...[
              const SizedBox(width: 12),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
''';
