/// Template for the OTP Input component source file.
const otpInputTemplate = '''
import 'package:flutter/material.dart';

@immutable
class FladOtpInputTheme extends ThemeExtension<FladOtpInputTheme> {
  final Color focusedBorderColor;
  final Color defaultBorderColor;
  final Color filledBg;
  final Color textColor;
  final Color errorColor;
  final double radius;
  final double borderWidth;

  const FladOtpInputTheme({
    required this.focusedBorderColor,
    required this.defaultBorderColor,
    required this.filledBg,
    required this.textColor,
    required this.errorColor,
    required this.radius,
    required this.borderWidth,
  });

  factory FladOtpInputTheme.fromScheme(ColorScheme scheme) {
    return FladOtpInputTheme(
      focusedBorderColor: scheme.primary,
      defaultBorderColor: scheme.outline,
      filledBg: scheme.surfaceContainerHighest,
      textColor: scheme.onSurface,
      errorColor: scheme.error,
      radius: 12,
      borderWidth: 1,
    );
  }

  @override
  FladOtpInputTheme copyWith({
    Color? focusedBorderColor,
    Color? defaultBorderColor,
    Color? filledBg,
    Color? textColor,
    Color? errorColor,
    double? radius,
    double? borderWidth,
  }) {
    return FladOtpInputTheme(
      focusedBorderColor: focusedBorderColor ?? this.focusedBorderColor,
      defaultBorderColor: defaultBorderColor ?? this.defaultBorderColor,
      filledBg: filledBg ?? this.filledBg,
      textColor: textColor ?? this.textColor,
      errorColor: errorColor ?? this.errorColor,
      radius: radius ?? this.radius,
      borderWidth: borderWidth ?? this.borderWidth,
    );
  }

  @override
  FladOtpInputTheme lerp(ThemeExtension<FladOtpInputTheme>? other, double t) {
    if (other is! FladOtpInputTheme) return this;
    return FladOtpInputTheme(
      focusedBorderColor:
          Color.lerp(focusedBorderColor, other.focusedBorderColor, t)!,
      defaultBorderColor:
          Color.lerp(defaultBorderColor, other.defaultBorderColor, t)!,
      filledBg: Color.lerp(filledBg, other.filledBg, t)!,
      textColor: Color.lerp(textColor, other.textColor, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      radius: radius + (other.radius - radius) * t,
      borderWidth: borderWidth + (other.borderWidth - borderWidth) * t,
    );
  }
}

class FladOtpInput extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final String? errorText;

  const FladOtpInput({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.obscureText = false,
    this.errorText,
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
    _controllers =
        List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
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

  String get _value => _controllers.map((c) => c.text).join();

  void _handleInput(int index, String value) {
    if (value.length == 1 && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.length == 1 && index == widget.length - 1) {
      _focusNodes[index].unfocus();
    }
    setState(() {});
    widget.onChanged?.call(_value);
    if (_value.length == widget.length) {
      widget.onCompleted?.call(_value);
    }
  }

  void _handleBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
      setState(() {});
      widget.onChanged?.call(_value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladOtpInputTheme>() ??
        FladOtpInputTheme.fromScheme(theme.colorScheme);
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < widget.length; i++) ...[
              _OtpCell(
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                obscureText: widget.obscureText,
                tokens: tokens,
                hasError: hasError,
                onChanged: (v) => _handleInput(i, v),
                onBackspace: () => _handleBackspace(i),
              ),
              if (i < widget.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText!,
            style: TextStyle(
              color: tokens.errorColor,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}

class _OtpCell extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool obscureText;
  final FladOtpInputTheme tokens;
  final bool hasError;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  const _OtpCell({
    required this.controller,
    required this.focusNode,
    required this.obscureText,
    required this.tokens,
    required this.hasError,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 56,
      child: Focus(
        onKeyEvent: (_, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              controller.text.isEmpty) {
            onBackspace();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          style: TextStyle(
            color: tokens.textColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: controller.text.isNotEmpty,
            fillColor: controller.text.isNotEmpty ? tokens.filledBg : null,
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(tokens.radius),
              borderSide: BorderSide(
                color: hasError
                    ? tokens.errorColor
                    : tokens.defaultBorderColor,
                width: tokens.borderWidth,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(tokens.radius),
              borderSide: BorderSide(
                color: hasError
                    ? tokens.errorColor
                    : tokens.focusedBorderColor,
                width: tokens.borderWidth + 1,
              ),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
''';
