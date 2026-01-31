/// Template for the Search Bar component source file.
const searchBarTemplate = '''
import 'package:flutter/material.dart';

@immutable
class FladSearchBarTheme extends ThemeExtension<FladSearchBarTheme> {
  final Color background;
  final Color border;
  final Color focusedBorder;
  final Color text;
  final Color hint;
  final Color icon;
  final double radius;

  const FladSearchBarTheme({
    required this.background,
    required this.border,
    required this.focusedBorder,
    required this.text,
    required this.hint,
    required this.icon,
    required this.radius,
  });

  factory FladSearchBarTheme.fromScheme(ColorScheme scheme) {
    return FladSearchBarTheme(
      background: scheme.surface,
      border: scheme.outlineVariant,
      focusedBorder: scheme.primary,
      text: scheme.onSurface,
      hint: scheme.onSurfaceVariant,
      icon: scheme.onSurfaceVariant,
      radius: 14,
    );
  }

  @override
  FladSearchBarTheme copyWith({
    Color? background,
    Color? border,
    Color? focusedBorder,
    Color? text,
    Color? hint,
    Color? icon,
    double? radius,
  }) {
    return FladSearchBarTheme(
      background: background ?? this.background,
      border: border ?? this.border,
      focusedBorder: focusedBorder ?? this.focusedBorder,
      text: text ?? this.text,
      hint: hint ?? this.hint,
      icon: icon ?? this.icon,
      radius: radius ?? this.radius,
    );
  }

  @override
  FladSearchBarTheme lerp(ThemeExtension<FladSearchBarTheme>? other, double t) {
    if (other is! FladSearchBarTheme) return this;
    return FladSearchBarTheme(
      background: Color.lerp(background, other.background, t)!,
      border: Color.lerp(border, other.border, t)!,
      focusedBorder: Color.lerp(focusedBorder, other.focusedBorder, t)!,
      text: Color.lerp(text, other.text, t)!,
      hint: Color.lerp(hint, other.hint, t)!,
      icon: Color.lerp(icon, other.icon, t)!,
      radius: radius + (other.radius - radius) * t,
    );
  }
}

class FladSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final Widget? leading;
  final Widget? trailing;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final Color? backgroundColor;

  const FladSearchBar({
    super.key,
    this.controller,
    this.hintText,
    this.leading,
    this.trailing,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladSearchBarTheme>() ??
        FladSearchBarTheme.fromScheme(theme.colorScheme);

    final radius = BorderRadius.circular(tokens.radius);

    return TextField(
      controller: controller,
      autofocus: autofocus,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: TextStyle(color: tokens.text),
      decoration: InputDecoration(
        filled: true,
        fillColor: backgroundColor ?? tokens.background,
        hintText: hintText ?? 'Search',
        hintStyle: TextStyle(color: tokens.hint),
        prefixIcon: leading ?? Icon(Icons.search, color: tokens.icon),
        suffixIcon: trailing,
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: tokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: tokens.focusedBorder, width: 1.5),
        ),
      ),
    );
  }
}
''';
