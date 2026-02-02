/// Template for the OTP Input component source file.
const otpInputTemplate = '''
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@immutable
class FladOtpInputTheme extends ThemeExtension<FladOtpInputTheme> {
  final Color background;
  final Color focusedBackground;
  final Color filledBackground;
  final Color borderColor;
  final Color focusedBorderColor;
  final Color textColor;
  final Color cursorColor;
  final Color errorBorderColor;
  final double radius;
  final double cellSize;
  final double spacing;

  const FladOtpInputTheme({
    required this.background,
    required this.focusedBackground,
    required this.filledBackground,
    required this.borderColor,
    required this.focusedBorderColor,
    required this.textColor,
    required this.cursorColor,
    required this.errorBorderColor,
    required this.radius,
    required this.cellSize,
    required this.spacing,
  });

  factory FladOtpInputTheme.fromScheme(ColorScheme scheme) {
    return FladOtpInputTheme(
      background: scheme.surface,
      focusedBackground: scheme.surface,
      filledBackground: scheme.surfaceContainerHighest,
      borderColor: scheme.outlineVariant,
      focusedBorderColor: scheme.primary,
      textColor: scheme.onSurface,
      cursorColor: scheme.primary,
      errorBorderColor: scheme.error,
      radius: 12,
      cellSize: 48,
      spacing: 8,
    );
  }

  @override
  FladOtpInputTheme copyWith({
    Color? background,
    Color? focusedBackground,
    Color? filledBackground,
    Color? borderColor,
    Color? focusedBorderColor,
    Color? textColor,
    Color? cursorColor,
    Color? errorBorderColor,
    double? radius,
    double? cellSize,
    double? spacing,
  }) {
    return FladOtpInputTheme(
      background: background ?? this.background,
      focusedBackground: focusedBackground ?? this.focusedBackground,
      filledBackground: filledBackground ?? this.filledBackground,
      borderColor: borderColor ?? this.borderColor,
      focusedBorderColor: focusedBorderColor ?? this.focusedBorderColor,
      textColor: textColor ?? this.textColor,
      cursorColor: cursorColor ?? this.cursorColor,
      errorBorderColor: errorBorderColor ?? this.errorBorderColor,
      radius: radius ?? this.radius,
      cellSize: cellSize ?? this.cellSize,
      spacing: spacing ?? this.spacing,
    );
  }

  @override
  FladOtpInputTheme lerp(ThemeExtension<FladOtpInputTheme>? other, double t) {
    if (other is! FladOtpInputTheme) return this;
    return FladOtpInputTheme(
      background: Color.lerp(background, other.background, t)!,
      focusedBackground:
          Color.lerp(focusedBackground, other.focusedBackground, t)!,
      filledBackground:
          Color.lerp(filledBackground, other.filledBackground, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      focusedBorderColor:
          Color.lerp(focusedBorderColor, other.focusedBorderColor, t)!,
      textColor: Color.lerp(textColor, other.textColor, t)!,
      cursorColor: Color.lerp(cursorColor, other.cursorColor, t)!,
      errorBorderColor:
          Color.lerp(errorBorderColor, other.errorBorderColor, t)!,
      radius: radius + (other.radius - radius) * t,
      cellSize: cellSize + (other.cellSize - cellSize) * t,
      spacing: spacing + (other.spacing - spacing) * t,
    );
  }
}

class FladOtpInput extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool obscure;
  final bool autofocus;
  final bool hasError;

  const FladOtpInput({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.obscure = false,
    this.autofocus = false,
    this.hasError = false,
  });

  @override
  State<FladOtpInput> createState() => _FladOtpInputState();
}

class _FladOtpInputState extends State<FladOtpInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.length,
      (_) => FocusNode(),
    );
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes[0].requestFocus();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _currentValue =>
      _controllers.map((c) => c.text).join();

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      _controllers[index].text = value[value.length - 1];
      _controllers[index].selection = TextSelection.fromPosition(
        TextPosition(offset: 1),
      );
    }

    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    final current = _currentValue;
    widget.onChanged?.call(current);

    if (current.length == widget.length) {
      widget.onCompleted?.call(current);
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladOtpInputTheme>() ??
        FladOtpInputTheme.fromScheme(theme.colorScheme);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.length, (index) {
        final hasValue = _controllers[index].text.isNotEmpty;

        return Padding(
          padding: EdgeInsets.only(
            right: index < widget.length - 1 ? tokens.spacing : 0,
          ),
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) => _onKeyEvent(index, event),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: tokens.cellSize,
              height: tokens.cellSize,
              decoration: BoxDecoration(
                color: hasValue
                    ? tokens.filledBackground
                    : tokens.background,
                borderRadius: BorderRadius.circular(tokens.radius),
                border: Border.all(
                  color: widget.hasError
                      ? tokens.errorBorderColor
                      : _focusNodes[index].hasFocus
                          ? tokens.focusedBorderColor
                          : tokens.borderColor,
                  width: _focusNodes[index].hasFocus ? 2 : 1,
                ),
              ),
              alignment: Alignment.center,
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                maxLength: 2,
                obscureText: widget.obscure,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: TextStyle(
                  color: tokens.textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                cursorColor: tokens.cursorColor,
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                onChanged: (value) => _onChanged(index, value),
              ),
            ),
          ),
        );
      }),
    );
  }
}
''';
