/// Template for the Time Picker component source file.
const timePickerTemplate = '''
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

@immutable
class FladTimePickerTheme extends ThemeExtension<FladTimePickerTheme> {
  final Color sheetBackground;
  final Color text;
  final Color primary;
  final Color border;
  final double radius;

  const FladTimePickerTheme({
    required this.sheetBackground,
    required this.text,
    required this.primary,
    required this.border,
    required this.radius,
  });

  factory FladTimePickerTheme.fromScheme(ColorScheme scheme) {
    return FladTimePickerTheme(
      sheetBackground: scheme.surface,
      text: scheme.onSurface,
      primary: scheme.primary,
      border: scheme.outlineVariant,
      radius: 16,
    );
  }

  @override
  FladTimePickerTheme copyWith({
    Color? sheetBackground,
    Color? text,
    Color? primary,
    Color? border,
    double? radius,
  }) {
    return FladTimePickerTheme(
      sheetBackground: sheetBackground ?? this.sheetBackground,
      text: text ?? this.text,
      primary: primary ?? this.primary,
      border: border ?? this.border,
      radius: radius ?? this.radius,
    );
  }

  @override
  FladTimePickerTheme lerp(
      ThemeExtension<FladTimePickerTheme>? other, double t) {
    if (other is! FladTimePickerTheme) return this;
    return FladTimePickerTheme(
      sheetBackground: Color.lerp(sheetBackground, other.sheetBackground, t)!,
      text: Color.lerp(text, other.text, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      border: Color.lerp(border, other.border, t)!,
      radius: radius + (other.radius - radius) * t,
    );
  }
}

class FladTimePicker {
  const FladTimePicker._();

  static Future<TimeOfDay?> show(
    BuildContext context, {
    TimeOfDay? initialTime,
    bool adaptive = true,
    bool use24HourFormat = false,
  }) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladTimePickerTheme>() ??
        FladTimePickerTheme.fromScheme(theme.colorScheme);

    final initial = initialTime ?? TimeOfDay.now();

    final isCupertino = adaptive &&
        (theme.platform == TargetPlatform.iOS ||
            theme.platform == TargetPlatform.macOS);

    if (!isCupertino) {
      return showTimePicker(
        context: context,
        initialTime: initial,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: use24HourFormat,
            ),
            child: child!,
          );
        },
      );
    }

    return _showCupertino(
      context,
      tokens,
      initial,
      use24HourFormat,
    );
  }

  static Future<TimeOfDay?> _showCupertino(
    BuildContext context,
    FladTimePickerTheme tokens,
    TimeOfDay initial,
    bool use24HourFormat,
  ) async {
    final now = DateTime.now();
    DateTime selected = DateTime(
      now.year,
      now.month,
      now.day,
      initial.hour,
      initial.minute,
    );

    return showCupertinoModalPopup<TimeOfDay?>(
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
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: tokens.text),
                        ),
                      ),
                      const Spacer(),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(context).pop(
                          TimeOfDay(
                            hour: selected.hour,
                            minute: selected.minute,
                          ),
                        ),
                        child: Text(
                          'Done',
                          style: TextStyle(color: tokens.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 220,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: selected,
                    use24hFormat: use24HourFormat,
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
