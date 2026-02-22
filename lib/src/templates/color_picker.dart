/// Template for the Color Picker component source file.
const colorPickerTemplate = '''
import 'package:flutter/material.dart';

@immutable
class FladColorPickerTheme extends ThemeExtension<FladColorPickerTheme> {
  final Color swatchBorderColor;
  final Color selectedBorderColor;
  final Color checkmarkColor;
  final double radius;
  final double swatchSize;

  const FladColorPickerTheme({
    required this.swatchBorderColor,
    required this.selectedBorderColor,
    required this.checkmarkColor,
    required this.radius,
    required this.swatchSize,
  });

  factory FladColorPickerTheme.fromScheme(ColorScheme scheme) {
    return FladColorPickerTheme(
      swatchBorderColor: scheme.outlineVariant,
      selectedBorderColor: scheme.primary,
      checkmarkColor: scheme.onPrimary,
      radius: 12,
      swatchSize: 36,
    );
  }

  @override
  FladColorPickerTheme copyWith({
    Color? swatchBorderColor,
    Color? selectedBorderColor,
    Color? checkmarkColor,
    double? radius,
    double? swatchSize,
  }) {
    return FladColorPickerTheme(
      swatchBorderColor: swatchBorderColor ?? this.swatchBorderColor,
      selectedBorderColor: selectedBorderColor ?? this.selectedBorderColor,
      checkmarkColor: checkmarkColor ?? this.checkmarkColor,
      radius: radius ?? this.radius,
      swatchSize: swatchSize ?? this.swatchSize,
    );
  }

  @override
  FladColorPickerTheme lerp(
    ThemeExtension<FladColorPickerTheme>? other,
    double t,
  ) {
    if (other is! FladColorPickerTheme) return this;
    return FladColorPickerTheme(
      swatchBorderColor:
          Color.lerp(swatchBorderColor, other.swatchBorderColor, t)!,
      selectedBorderColor:
          Color.lerp(selectedBorderColor, other.selectedBorderColor, t)!,
      checkmarkColor: Color.lerp(checkmarkColor, other.checkmarkColor, t)!,
      radius: radius + (other.radius - radius) * t,
      swatchSize: swatchSize + (other.swatchSize - swatchSize) * t,
    );
  }
}

class FladColorPicker extends StatefulWidget {
  final List<Color> colors;
  final Color? selectedColor;
  final ValueChanged<Color>? onColorSelected;
  final bool showCustomInput;

  const FladColorPicker({
    super.key,
    required this.colors,
    this.selectedColor,
    this.onColorSelected,
    this.showCustomInput = false,
  });

  @override
  State<FladColorPicker> createState() => _FladColorPickerState();
}

class _FladColorPickerState extends State<FladColorPicker> {
  Color? _selected;
  late TextEditingController _hexController;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedColor;
    _hexController = TextEditingController(
      text: _selected != null ? _toHex(_selected!) : '',
    );
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  String _toHex(Color color) {
    return '#' +
        color.value
            .toRadixString(16)
            .padLeft(8, '0')
            .substring(2)
            .toUpperCase();
  }

  Color? _fromHex(String hex) {
    final cleaned = hex.startsWith('#') ? hex.substring(1) : hex;
    if (cleaned.length != 6) return null;
    final value = int.tryParse('FF' + cleaned, radix: 16);
    if (value == null) return null;
    return Color(value);
  }

  void _selectColor(Color color) {
    setState(() {
      _selected = color;
      if (widget.showCustomInput) {
        _hexController.text = _toHex(color);
      }
    });
    widget.onColorSelected?.call(color);
  }

  void _applyHex() {
    final color = _fromHex(_hexController.text);
    if (color != null) {
      _selectColor(color);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladColorPickerTheme>() ??
        FladColorPickerTheme.fromScheme(theme.colorScheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.colors.map((color) {
            return _ColorSwatch(
              color: color,
              isSelected: _selected == color,
              tokens: tokens,
              onTap: () => _selectColor(color),
            );
          }).toList(),
        ),
        if (widget.showCustomInput) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: TextField(
              controller: _hexController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: '#RRGGBB',
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radius),
                  borderSide: BorderSide(color: tokens.swatchBorderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radius),
                  borderSide: BorderSide(color: tokens.swatchBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radius),
                  borderSide: BorderSide(color: tokens.selectedBorderColor),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check, size: 18),
                  onPressed: _applyHex,
                ),
              ),
              onSubmitted: (_) => _applyHex(),
            ),
          ),
        ],
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final FladColorPickerTheme tokens;
  final VoidCallback onTap;

  const _ColorSwatch({
    required this.color,
    required this.isSelected,
    required this.tokens,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: tokens.swatchSize,
        height: tokens.swatchSize,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(tokens.radius),
          border: Border.all(
            color: isSelected
                ? tokens.selectedBorderColor
                : tokens.swatchBorderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: isSelected
            ? Center(
                child: Icon(
                  Icons.check,
                  color: tokens.checkmarkColor,
                  size: 16,
                ),
              )
            : null,
      ),
    );
  }
}
''';
