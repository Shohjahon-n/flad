const inputTemplate = '''
import 'package:flutter/material.dart';

enum FladInputSize { sm, md, lg }

@immutable
class FladInputTheme extends ThemeExtension<FladInputTheme> {
  final Color background;
  final Color text;
  final Color placeholder;
  final Color label;
  final Color helper;
  final Color border;
  final Color focusBorder;
  final Color errorBorder;
  final Color disabledBackground;
  final Color disabledText;
  final Color cursor;
  final double radius;
  final double borderWidth;

  const FladInputTheme({
    required this.background,
    required this.text,
    required this.placeholder,
    required this.label,
    required this.helper,
    required this.border,
    required this.focusBorder,
    required this.errorBorder,
    required this.disabledBackground,
    required this.disabledText,
    required this.cursor,
    required this.radius,
    required this.borderWidth,
  });

  factory FladInputTheme.fromScheme(ColorScheme scheme) {
    return FladInputTheme(
      background: scheme.surface,
      text: scheme.onSurface,
      placeholder: scheme.onSurfaceVariant,
      label: scheme.onSurface,
      helper: scheme.onSurfaceVariant,
      border: scheme.outline,
      focusBorder: scheme.primary,
      errorBorder: scheme.error,
      disabledBackground: scheme.onSurface.withOpacity(0.04),
      disabledText: scheme.onSurface.withOpacity(0.38),
      cursor: scheme.primary,
      radius: 12,
      borderWidth: 1,
    );
  }

  @override
  FladInputTheme copyWith({
    Color? background,
    Color? text,
    Color? placeholder,
    Color? label,
    Color? helper,
    Color? border,
    Color? focusBorder,
    Color? errorBorder,
    Color? disabledBackground,
    Color? disabledText,
    Color? cursor,
    double? radius,
    double? borderWidth,
  }) {
    return FladInputTheme(
      background: background ?? this.background,
      text: text ?? this.text,
      placeholder: placeholder ?? this.placeholder,
      label: label ?? this.label,
      helper: helper ?? this.helper,
      border: border ?? this.border,
      focusBorder: focusBorder ?? this.focusBorder,
      errorBorder: errorBorder ?? this.errorBorder,
      disabledBackground: disabledBackground ?? this.disabledBackground,
      disabledText: disabledText ?? this.disabledText,
      cursor: cursor ?? this.cursor,
      radius: radius ?? this.radius,
      borderWidth: borderWidth ?? this.borderWidth,
    );
  }

  @override
  FladInputTheme lerp(ThemeExtension<FladInputTheme>? other, double t) {
    if (other is! FladInputTheme) return this;
    return FladInputTheme(
      background: Color.lerp(background, other.background, t)!,
      text: Color.lerp(text, other.text, t)!,
      placeholder: Color.lerp(placeholder, other.placeholder, t)!,
      label: Color.lerp(label, other.label, t)!,
      helper: Color.lerp(helper, other.helper, t)!,
      border: Color.lerp(border, other.border, t)!,
      focusBorder: Color.lerp(focusBorder, other.focusBorder, t)!,
      errorBorder: Color.lerp(errorBorder, other.errorBorder, t)!,
      disabledBackground:
          Color.lerp(disabledBackground, other.disabledBackground, t)!,
      disabledText: Color.lerp(disabledText, other.disabledText, t)!,
      cursor: Color.lerp(cursor, other.cursor, t)!,
      radius: radius + (other.radius - radius) * t,
      borderWidth: borderWidth + (other.borderWidth - borderWidth) * t,
    );
  }
}

class FladInput extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final bool enabled;
  final bool obscureText;
  final int maxLines;
  final int? minLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final Widget? prefix;
  final Widget? suffix;
  final FladInputSize size;

  const FladInput({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.prefix,
    this.suffix,
    this.size = FladInputSize.md,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladInputTheme>() ??
        FladInputTheme.fromScheme(theme.colorScheme);
    final sizing = _FladInputSizing.from(size);

    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(tokens.radius),
      borderSide: BorderSide(color: tokens.border, width: tokens.borderWidth),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(tokens.radius),
      borderSide: BorderSide(color: tokens.focusBorder, width: tokens.borderWidth),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(tokens.radius),
      borderSide: BorderSide(color: tokens.errorBorder, width: tokens.borderWidth),
    );

    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      obscureText: obscureText,
      maxLines: maxLines,
      minLines: minLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      cursorColor: tokens.cursor,
      style: TextStyle(
        color: enabled ? tokens.text : tokens.disabledText,
        fontSize: sizing.fontSize,
        height: 1.2,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: tokens.label),
        hintText: hint,
        hintStyle: TextStyle(color: tokens.placeholder),
        helperText: helperText,
        helperStyle: TextStyle(color: tokens.helper),
        errorText: errorText,
        filled: true,
        fillColor: enabled ? tokens.background : tokens.disabledBackground,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          vertical: sizing.verticalPadding,
          horizontal: sizing.horizontalPadding,
        ),
        prefixIcon: prefix == null
            ? null
            : Padding(
                padding: EdgeInsets.only(left: sizing.iconPadding),
                child: IconTheme(
                  data: IconThemeData(
                    color: tokens.placeholder,
                    size: sizing.iconSize,
                  ),
                  child: prefix!,
                ),
              ),
        prefixIconConstraints: BoxConstraints(
          minWidth: sizing.iconSize + sizing.iconPadding * 2,
          minHeight: sizing.iconSize,
        ),
        suffixIcon: suffix == null
            ? null
            : Padding(
                padding: EdgeInsets.only(right: sizing.iconPadding),
                child: IconTheme(
                  data: IconThemeData(
                    color: tokens.placeholder,
                    size: sizing.iconSize,
                  ),
                  child: suffix!,
                ),
              ),
        suffixIconConstraints: BoxConstraints(
          minWidth: sizing.iconSize + sizing.iconPadding * 2,
          minHeight: sizing.iconSize,
        ),
        enabledBorder: baseBorder,
        disabledBorder: baseBorder,
        focusedBorder: focusedBorder,
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder,
      ),
    );
  }
}

class _FladInputSizing {
  final double fontSize;
  final double verticalPadding;
  final double horizontalPadding;
  final double iconSize;
  final double iconPadding;

  const _FladInputSizing({
    required this.fontSize,
    required this.verticalPadding,
    required this.horizontalPadding,
    required this.iconSize,
    required this.iconPadding,
  });

  factory _FladInputSizing.from(FladInputSize size) {
    switch (size) {
      case FladInputSize.sm:
        return const _FladInputSizing(
          fontSize: 12,
          verticalPadding: 10,
          horizontalPadding: 12,
          iconSize: 16,
          iconPadding: 8,
        );
      case FladInputSize.md:
        return const _FladInputSizing(
          fontSize: 14,
          verticalPadding: 12,
          horizontalPadding: 14,
          iconSize: 18,
          iconPadding: 10,
        );
      case FladInputSize.lg:
        return const _FladInputSizing(
          fontSize: 16,
          verticalPadding: 14,
          horizontalPadding: 16,
          iconSize: 20,
          iconPadding: 12,
        );
    }
  }
}
''';
