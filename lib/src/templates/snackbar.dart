/// Template for the Snackbar component source file.
const snackbarTemplate = '''
import 'package:flutter/material.dart';

enum FladSnackbarVariant { info, success, warning, error }

@immutable
class FladSnackbarTheme extends ThemeExtension<FladSnackbarTheme> {
  final Color background;
  final Color text;
  final Color action;
  final Color info;
  final Color success;
  final Color warning;
  final Color error;
  final double radius;
  final double elevation;

  const FladSnackbarTheme({
    required this.background,
    required this.text,
    required this.action,
    required this.info,
    required this.success,
    required this.warning,
    required this.error,
    required this.radius,
    required this.elevation,
  });

  factory FladSnackbarTheme.fromScheme(ColorScheme scheme) {
    return FladSnackbarTheme(
      background: scheme.onSurface,
      text: scheme.surface,
      action: scheme.primary,
      info: scheme.primary,
      success: scheme.tertiary,
      warning: scheme.secondary,
      error: scheme.error,
      radius: 12,
      elevation: 6,
    );
  }

  @override
  FladSnackbarTheme copyWith({
    Color? background,
    Color? text,
    Color? action,
    Color? info,
    Color? success,
    Color? warning,
    Color? error,
    double? radius,
    double? elevation,
  }) {
    return FladSnackbarTheme(
      background: background ?? this.background,
      text: text ?? this.text,
      action: action ?? this.action,
      info: info ?? this.info,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      radius: radius ?? this.radius,
      elevation: elevation ?? this.elevation,
    );
  }

  @override
  FladSnackbarTheme lerp(ThemeExtension<FladSnackbarTheme>? other, double t) {
    if (other is! FladSnackbarTheme) return this;
    return FladSnackbarTheme(
      background: Color.lerp(background, other.background, t)!,
      text: Color.lerp(text, other.text, t)!,
      action: Color.lerp(action, other.action, t)!,
      info: Color.lerp(info, other.info, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      radius: radius + (other.radius - radius) * t,
      elevation: elevation + (other.elevation - elevation) * t,
    );
  }
}

class FladSnackbar {
  const FladSnackbar._();

  static void show(
    BuildContext context,
    String message, {
    FladSnackbarVariant variant = FladSnackbarVariant.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladSnackbarTheme>() ??
        FladSnackbarTheme.fromScheme(theme.colorScheme);

    Color accent;
    switch (variant) {
      case FladSnackbarVariant.info:
        accent = tokens.info;
        break;
      case FladSnackbarVariant.success:
        accent = tokens.success;
        break;
      case FladSnackbarVariant.warning:
        accent = tokens.warning;
        break;
      case FladSnackbarVariant.error:
        accent = tokens.error;
        break;
    }

    final snackBar = SnackBar(
      duration: duration,
      behavior: SnackBarBehavior.floating,
      backgroundColor: tokens.background,
      elevation: tokens.elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius),
      ),
      content: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: tokens.text),
            ),
          ),
        ],
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
