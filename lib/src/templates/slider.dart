/// Template for the Slider component source file.
const sliderTemplate = '''
import 'package:flutter/material.dart';

enum FladSliderSize { sm, md, lg }

@immutable
class FladSliderTheme extends ThemeExtension<FladSliderTheme> {
  final Color activeTrack;
  final Color inactiveTrack;
  final Color thumb;
  final Color overlay;
  final Color valueIndicator;

  const FladSliderTheme({
    required this.activeTrack,
    required this.inactiveTrack,
    required this.thumb,
    required this.overlay,
    required this.valueIndicator,
  });

  factory FladSliderTheme.fromScheme(ColorScheme scheme) {
    return FladSliderTheme(
      activeTrack: scheme.primary,
      inactiveTrack: scheme.outlineVariant,
      thumb: scheme.primary,
      overlay: scheme.primary.withOpacity(0.12),
      valueIndicator: scheme.primary,
    );
  }

  @override
  FladSliderTheme copyWith({
    Color? activeTrack,
    Color? inactiveTrack,
    Color? thumb,
    Color? overlay,
    Color? valueIndicator,
  }) {
    return FladSliderTheme(
      activeTrack: activeTrack ?? this.activeTrack,
      inactiveTrack: inactiveTrack ?? this.inactiveTrack,
      thumb: thumb ?? this.thumb,
      overlay: overlay ?? this.overlay,
      valueIndicator: valueIndicator ?? this.valueIndicator,
    );
  }

  @override
  FladSliderTheme lerp(ThemeExtension<FladSliderTheme>? other, double t) {
    if (other is! FladSliderTheme) return this;
    return FladSliderTheme(
      activeTrack: Color.lerp(activeTrack, other.activeTrack, t)!,
      inactiveTrack: Color.lerp(inactiveTrack, other.inactiveTrack, t)!,
      thumb: Color.lerp(thumb, other.thumb, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      valueIndicator: Color.lerp(valueIndicator, other.valueIndicator, t)!,
    );
  }
}

class FladSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final bool enabled;
  final FladSliderSize size;
  final bool adaptive;

  const FladSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.label,
    this.enabled = true,
    this.size = FladSliderSize.md,
    this.adaptive = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladSliderTheme>() ??
        FladSliderTheme.fromScheme(theme.colorScheme);
    final sizing = _FladSliderSizing.from(size);

    final sliderTheme = SliderThemeData(
      activeTrackColor: tokens.activeTrack,
      inactiveTrackColor: tokens.inactiveTrack,
      thumbColor: tokens.thumb,
      overlayColor: tokens.overlay,
      valueIndicatorColor: tokens.valueIndicator,
      trackHeight: sizing.trackHeight,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: sizing.thumbRadius),
      overlayShape: RoundSliderOverlayShape(overlayRadius: sizing.overlayRadius),
    );

    return SliderTheme(
      data: sliderTheme,
      child: adaptive
          ? Slider.adaptive(
              value: value,
              onChanged: enabled ? onChanged : null,
              min: min,
              max: max,
              divisions: divisions,
              label: label,
            )
          : Slider(
              value: value,
              onChanged: enabled ? onChanged : null,
              min: min,
              max: max,
              divisions: divisions,
              label: label,
            ),
    );
  }
}

class _FladSliderSizing {
  final double trackHeight;
  final double thumbRadius;
  final double overlayRadius;

  const _FladSliderSizing({
    required this.trackHeight,
    required this.thumbRadius,
    required this.overlayRadius,
  });

  factory _FladSliderSizing.from(FladSliderSize size) {
    switch (size) {
      case FladSliderSize.sm:
        return const _FladSliderSizing(trackHeight: 2, thumbRadius: 8, overlayRadius: 14);
      case FladSliderSize.md:
        return const _FladSliderSizing(trackHeight: 3, thumbRadius: 10, overlayRadius: 16);
      case FladSliderSize.lg:
        return const _FladSliderSizing(trackHeight: 4, thumbRadius: 12, overlayRadius: 18);
    }
  }
}
''';
