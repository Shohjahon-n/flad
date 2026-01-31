/// Template for the Textarea component source file.
const textareaTemplate = '''
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum FladTextareaSize { sm, md, lg }

@immutable
class FladTextareaTheme extends ThemeExtension<FladTextareaTheme> {
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

  const FladTextareaTheme({
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

  factory FladTextareaTheme.fromScheme(ColorScheme scheme) {
    return FladTextareaTheme(
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
  FladTextareaTheme copyWith({
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
    return FladTextareaTheme(
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
  FladTextareaTheme lerp(ThemeExtension<FladTextareaTheme>? other, double t) {
    if (other is! FladTextareaTheme) return this;
    return FladTextareaTheme(
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

class FladTextarea extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final bool enabled;
  final int minLines;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final FladTextareaSize size;
  final bool adaptive;

  const FladTextarea({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.minLines = 4,
    this.maxLines = 8,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.size = FladTextareaSize.md,
    this.adaptive = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladTextareaTheme>() ??
        FladTextareaTheme.fromScheme(theme.colorScheme);
    final sizing = _FladTextareaSizing.from(size);

    final labelWidget = label == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              label!,
              style: TextStyle(
                color: tokens.label,
                fontWeight: FontWeight.w600,
              ),
            ),
          );

    final helperWidget = (helperText == null && errorText == null)
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              errorText ?? helperText!,
              style: TextStyle(
                color: errorText == null ? tokens.helper : tokens.errorBorder,
                fontSize: 12,
              ),
            ),
          );

    final borderColor = errorText == null ? tokens.border : tokens.errorBorder;
    final focusedBorderColor =
        errorText == null ? tokens.focusBorder : tokens.errorBorder;

    final input = _buildInput(
      context,
      tokens,
      sizing,
      borderColor,
      focusedBorderColor,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        labelWidget,
        input,
        helperWidget,
      ],
    );
  }

  Widget _buildInput(
    BuildContext context,
    FladTextareaTheme tokens,
    _FladTextareaSizing sizing,
    Color borderColor,
    Color focusedBorderColor,
  ) {
    final theme = Theme.of(context);
    final isCupertino = adaptive &&
        (theme.platform == TargetPlatform.iOS ||
            theme.platform == TargetPlatform.macOS);

    if (isCupertino) {
      return CupertinoTextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        minLines: minLines,
        maxLines: maxLines,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: onChanged,
        cursorColor: tokens.cursor,
        style: TextStyle(
          color: enabled ? tokens.text : tokens.disabledText,
          fontSize: sizing.fontSize,
          height: 1.3,
        ),
        placeholder: hint,
        placeholderStyle: TextStyle(color: tokens.placeholder),
        padding: EdgeInsets.symmetric(
          vertical: sizing.verticalPadding,
          horizontal: sizing.horizontalPadding,
        ),
        decoration: BoxDecoration(
          color: enabled ? tokens.background : tokens.disabledBackground,
          borderRadius: BorderRadius.circular(tokens.radius),
          border: Border.all(
            color: focusNode?.hasFocus == true
                ? focusedBorderColor
                : borderColor,
            width: tokens.borderWidth,
          ),
        ),
      );
    }

    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(tokens.radius),
      borderSide: BorderSide(color: borderColor, width: tokens.borderWidth),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(tokens.radius),
      borderSide:
          BorderSide(color: focusedBorderColor, width: tokens.borderWidth),
    );

    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      cursorColor: tokens.cursor,
      style: TextStyle(
        color: enabled ? tokens.text : tokens.disabledText,
        fontSize: sizing.fontSize,
        height: 1.3,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: tokens.placeholder),
        filled: true,
        fillColor: enabled ? tokens.background : tokens.disabledBackground,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          vertical: sizing.verticalPadding,
          horizontal: sizing.horizontalPadding,
        ),
        enabledBorder: baseBorder,
        disabledBorder: baseBorder,
        focusedBorder: focusedBorder,
        errorBorder: baseBorder.copyWith(
          borderSide:
              BorderSide(color: tokens.errorBorder, width: tokens.borderWidth),
        ),
        focusedErrorBorder: baseBorder.copyWith(
          borderSide:
              BorderSide(color: tokens.errorBorder, width: tokens.borderWidth),
        ),
      ),
    );
  }
}

class _FladTextareaSizing {
  final double fontSize;
  final double verticalPadding;
  final double horizontalPadding;

  const _FladTextareaSizing({
    required this.fontSize,
    required this.verticalPadding,
    required this.horizontalPadding,
  });

  factory _FladTextareaSizing.from(FladTextareaSize size) {
    switch (size) {
      case FladTextareaSize.sm:
        return const _FladTextareaSizing(
          fontSize: 12,
          verticalPadding: 10,
          horizontalPadding: 12,
        );
      case FladTextareaSize.md:
        return const _FladTextareaSizing(
          fontSize: 14,
          verticalPadding: 12,
          horizontalPadding: 14,
        );
      case FladTextareaSize.lg:
        return const _FladTextareaSizing(
          fontSize: 16,
          verticalPadding: 14,
          horizontalPadding: 16,
        );
    }
  }
}
''';
