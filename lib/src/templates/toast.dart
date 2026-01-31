/// Template for the Toast component source file.
const toastTemplate = '''
import 'package:flutter/material.dart';

@immutable
class FladToastTheme extends ThemeExtension<FladToastTheme> {
  final Color background;
  final Color text;
  final Color action;
  final Color shadow;
  final double radius;
  final double elevation;

  const FladToastTheme({
    required this.background,
    required this.text,
    required this.action,
    required this.shadow,
    required this.radius,
    required this.elevation,
  });

  factory FladToastTheme.fromScheme(ColorScheme scheme) {
    return FladToastTheme(
      background: scheme.onSurface,
      text: scheme.surface,
      action: scheme.primary,
      shadow: scheme.shadow.withOpacity(0.2),
      radius: 12,
      elevation: 6,
    );
  }

  @override
  FladToastTheme copyWith({
    Color? background,
    Color? text,
    Color? action,
    Color? shadow,
    double? radius,
    double? elevation,
  }) {
    return FladToastTheme(
      background: background ?? this.background,
      text: text ?? this.text,
      action: action ?? this.action,
      shadow: shadow ?? this.shadow,
      radius: radius ?? this.radius,
      elevation: elevation ?? this.elevation,
    );
  }

  @override
  FladToastTheme lerp(ThemeExtension<FladToastTheme>? other, double t) {
    if (other is! FladToastTheme) return this;
    return FladToastTheme(
      background: Color.lerp(background, other.background, t)!,
      text: Color.lerp(text, other.text, t)!,
      action: Color.lerp(action, other.action, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      radius: radius + (other.radius - radius) * t,
      elevation: elevation + (other.elevation - elevation) * t,
    );
  }
}

class FladToast {
  const FladToast._();

  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    Widget? leading,
    String? actionLabel,
    VoidCallback? onAction,
    EdgeInsetsGeometry? margin,
  }) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladToastTheme>() ??
        FladToastTheme.fromScheme(theme.colorScheme);

    final content = Row(
      children: [
        if (leading != null) ...[
          IconTheme(data: IconThemeData(color: tokens.text), child: leading),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            message,
            style: TextStyle(color: tokens.text),
          ),
        ),
      ],
    );

    final snackBar = SnackBar(
      content: content,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      margin: margin ?? const EdgeInsets.all(16),
      backgroundColor: tokens.background,
      elevation: tokens.elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius),
      ),
      action: actionLabel == null
          ? null
          : SnackBarAction(
              label: actionLabel,
              textColor: tokens.action,
              onPressed: onAction ?? () {},
            ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
''';
