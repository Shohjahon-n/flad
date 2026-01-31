/// Template for the Date Picker component source file.
const datePickerTemplate = '''
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

@immutable
class FladDatePickerTheme extends ThemeExtension<FladDatePickerTheme> {
  final Color sheetBackground;
  final Color text;
  final Color primary;
  final Color border;
  final double radius;

  const FladDatePickerTheme({
    required this.sheetBackground,
    required this.text,
    required this.primary,
    required this.border,
    required this.radius,
  });

  factory FladDatePickerTheme.fromScheme(ColorScheme scheme) {
    return FladDatePickerTheme(
      sheetBackground: scheme.surface,
      text: scheme.onSurface,
      primary: scheme.primary,
      border: scheme.outlineVariant,
      radius: 16,
    );
  }

  @override
  FladDatePickerTheme copyWith({
    Color? sheetBackground,
    Color? text,
    Color? primary,
    Color? border,
    double? radius,
  }) {
    return FladDatePickerTheme(
      sheetBackground: sheetBackground ?? this.sheetBackground,
      text: text ?? this.text,
      primary: primary ?? this.primary,
      border: border ?? this.border,
      radius: radius ?? this.radius,
    );
  }

  @override
  FladDatePickerTheme lerp(
      ThemeExtension<FladDatePickerTheme>? other, double t) {
    if (other is! FladDatePickerTheme) return this;
    return FladDatePickerTheme(
      sheetBackground: Color.lerp(sheetBackground, other.sheetBackground, t)!,
      text: Color.lerp(text, other.text, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      border: Color.lerp(border, other.border, t)!,
      radius: radius + (other.radius - radius) * t,
    );
  }
}

class FladDatePicker {
  const FladDatePicker._();

  static Future<DateTime?> show(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    bool adaptive = true,
  }) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladDatePickerTheme>() ??
        FladDatePickerTheme.fromScheme(theme.colorScheme);
    final now = DateTime.now();

    final initial = initialDate ?? now;
    final first = firstDate ?? DateTime(now.year - 100);
    final last = lastDate ?? DateTime(now.year + 100);

    final isCupertino = adaptive &&
        (theme.platform == TargetPlatform.iOS ||
            theme.platform == TargetPlatform.macOS);

    if (!isCupertino) {
      return showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: first,
        lastDate: last,
      );
    }

    return _showCupertino(
      context,
      tokens,
      initial,
      first,
      last,
    );
  }

  static Future<DateTime?> _showCupertino(
    BuildContext context,
    FladDatePickerTheme tokens,
    DateTime initial,
    DateTime first,
    DateTime last,
  ) async {
    DateTime selected = initial;

    return showCupertinoModalPopup<DateTime?>(
      context: context,
      builder: (context) {
        return SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: tokens.sheetBackground,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(tokens.radius),
              ),
              border: Border(
                top: BorderSide(color: tokens.border),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Cancel', style: TextStyle(color: tokens.text)),
                      ),
                      const Spacer(),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(context).pop(selected),
                        child: Text('Done', style: TextStyle(color: tokens.primary)),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 220,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: initial,
                    minimumDate: first,
                    maximumDate: last,
                    onDateTimeChanged: (value) => selected = value,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
''';
