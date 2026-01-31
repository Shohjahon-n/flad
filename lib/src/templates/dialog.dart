/// Template for the Dialog component source file.
const dialogTemplate = '''
import 'package:flutter/material.dart';

@immutable
class FladDialogTheme extends ThemeExtension<FladDialogTheme> {
  final Color background;
  final Color title;
  final Color content;
  final Color border;
  final Color shadow;
  final double radius;
  final double borderWidth;

  const FladDialogTheme({
    required this.background,
    required this.title,
    required this.content,
    required this.border,
    required this.shadow,
    required this.radius,
    required this.borderWidth,
  });

  factory FladDialogTheme.fromScheme(ColorScheme scheme) {
    return FladDialogTheme(
      background: scheme.surface,
      title: scheme.onSurface,
      content: scheme.onSurfaceVariant,
      border: scheme.outlineVariant,
      shadow: scheme.shadow.withOpacity(0.2),
      radius: 16,
      borderWidth: 1,
    );
  }

  @override
  FladDialogTheme copyWith({
    Color? background,
    Color? title,
    Color? content,
    Color? border,
    Color? shadow,
    double? radius,
    double? borderWidth,
  }) {
    return FladDialogTheme(
      background: background ?? this.background,
      title: title ?? this.title,
      content: content ?? this.content,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
      radius: radius ?? this.radius,
      borderWidth: borderWidth ?? this.borderWidth,
    );
  }

  @override
  FladDialogTheme lerp(ThemeExtension<FladDialogTheme>? other, double t) {
    if (other is! FladDialogTheme) return this;
    return FladDialogTheme(
      background: Color.lerp(background, other.background, t)!,
      title: Color.lerp(title, other.title, t)!,
      content: Color.lerp(content, other.content, t)!,
      border: Color.lerp(border, other.border, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      radius: radius + (other.radius - radius) * t,
      borderWidth: borderWidth + (other.borderWidth - borderWidth) * t,
    );
  }
}

class FladDialogAction {
  final String label;
  final VoidCallback onPressed;
  final bool isDestructive;
  final bool isDefault;

  const FladDialogAction({
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
    this.isDefault = false,
  });
}

class FladDialog {
  const FladDialog._();

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required String message,
    required List<FladDialogAction> actions,
    bool adaptive = true,
  }) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladDialogTheme>() ??
        FladDialogTheme.fromScheme(theme.colorScheme);

    final dialogActions = actions
        .map(
          (action) => TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              action.onPressed();
            },
            style: TextButton.styleFrom(
              foregroundColor: action.isDestructive
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
            child: Text(
              action.label,
              style: TextStyle(
                fontWeight: action.isDefault ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        )
        .toList();

    final dialog = adaptive
        ? AlertDialog.adaptive(
            title: Text(
              title,
              style: TextStyle(color: tokens.title, fontWeight: FontWeight.w700),
            ),
            content: Text(
              message,
              style: TextStyle(color: tokens.content),
            ),
            actions: dialogActions,
            backgroundColor: tokens.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(tokens.radius),
              side: BorderSide(color: tokens.border, width: tokens.borderWidth),
            ),
            elevation: 8,
          )
        : AlertDialog(
            title: Text(
              title,
              style: TextStyle(color: tokens.title, fontWeight: FontWeight.w700),
            ),
            content: Text(
              message,
              style: TextStyle(color: tokens.content),
            ),
            actions: dialogActions,
            backgroundColor: tokens.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(tokens.radius),
              side: BorderSide(color: tokens.border, width: tokens.borderWidth),
            ),
            elevation: 8,
          );

    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (_) => dialog,
    );
  }
}
''';
