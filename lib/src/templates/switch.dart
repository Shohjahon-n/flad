/// Template for the Switch component source file.
const switchTemplate = '''
import 'package:flutter/material.dart';

enum FladSwitchSize { sm, md, lg }

@immutable
class FladSwitchTheme extends ThemeExtension<FladSwitchTheme> {
  final Color trackOn;
  final Color trackOff;
  final Color thumbOn;
  final Color thumbOff;
  final Color disabledTrack;
  final Color disabledThumb;
  final Color hoverOverlay;
  final double radius;

  const FladSwitchTheme({
    required this.trackOn,
    required this.trackOff,
    required this.thumbOn,
    required this.thumbOff,
    required this.disabledTrack,
    required this.disabledThumb,
    required this.hoverOverlay,
    required this.radius,
  });

  factory FladSwitchTheme.fromScheme(ColorScheme scheme) {
    return FladSwitchTheme(
      trackOn: scheme.primary.withOpacity(0.45),
      trackOff: scheme.outlineVariant,
      thumbOn: scheme.primary,
      thumbOff: scheme.surface,
      disabledTrack: scheme.onSurface.withOpacity(0.12),
      disabledThumb: scheme.onSurface.withOpacity(0.38),
      hoverOverlay: scheme.primary.withOpacity(0.08),
      radius: 999,
    );
  }

  @override
  FladSwitchTheme copyWith({
    Color? trackOn,
    Color? trackOff,
    Color? thumbOn,
    Color? thumbOff,
    Color? disabledTrack,
    Color? disabledThumb,
    Color? hoverOverlay,
    double? radius,
  }) {
    return FladSwitchTheme(
      trackOn: trackOn ?? this.trackOn,
      trackOff: trackOff ?? this.trackOff,
      thumbOn: thumbOn ?? this.thumbOn,
      thumbOff: thumbOff ?? this.thumbOff,
      disabledTrack: disabledTrack ?? this.disabledTrack,
      disabledThumb: disabledThumb ?? this.disabledThumb,
      hoverOverlay: hoverOverlay ?? this.hoverOverlay,
      radius: radius ?? this.radius,
    );
  }

  @override
  FladSwitchTheme lerp(ThemeExtension<FladSwitchTheme>? other, double t) {
    if (other is! FladSwitchTheme) return this;
    return FladSwitchTheme(
      trackOn: Color.lerp(trackOn, other.trackOn, t)!,
      trackOff: Color.lerp(trackOff, other.trackOff, t)!,
      thumbOn: Color.lerp(thumbOn, other.thumbOn, t)!,
      thumbOff: Color.lerp(thumbOff, other.thumbOff, t)!,
      disabledTrack: Color.lerp(disabledTrack, other.disabledTrack, t)!,
      disabledThumb: Color.lerp(disabledThumb, other.disabledThumb, t)!,
      hoverOverlay: Color.lerp(hoverOverlay, other.hoverOverlay, t)!,
      radius: radius + (other.radius - radius) * t,
    );
  }
}

class FladSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;
  final FladSwitchSize size;
  final Widget? label;
  final double gap;
  final bool adaptive;

  const FladSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.size = FladSwitchSize.md,
    this.label,
    this.gap = 10,
    this.adaptive = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladSwitchTheme>() ??
        FladSwitchTheme.fromScheme(theme.colorScheme);
    final sizing = _FladSwitchSizing.from(size);
    final isDisabled = !enabled || onChanged == null;

    final switchTheme = SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return tokens.disabledThumb;
        }
        return states.contains(MaterialState.selected)
            ? tokens.thumbOn
            : tokens.thumbOff;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return tokens.disabledTrack;
        }
        return states.contains(MaterialState.selected)
            ? tokens.trackOn
            : tokens.trackOff;
      }),
      overlayColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.hovered) ||
            states.contains(MaterialState.pressed)) {
          return tokens.hoverOverlay;
        }
        return null;
      }),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    final widgetSwitch = SwitchTheme(
      data: switchTheme,
      child: SizedBox(
        width: sizing.width,
        height: sizing.height,
        child: FittedBox(
          fit: BoxFit.contain,
          child: adaptive
              ? Switch.adaptive(
                  value: value,
                  onChanged: isDisabled ? null : onChanged,
                )
              : Switch(
                  value: value,
                  onChanged: isDisabled ? null : onChanged,
                ),
        ),
      ),
    );

    if (label == null) {
      return widgetSwitch;
    }

    return InkWell(
      onTap: isDisabled ? null : () => onChanged?.call(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          widgetSwitch,
          SizedBox(width: gap),
          DefaultTextStyle.merge(
            style: TextStyle(
              color: isDisabled
                  ? theme.colorScheme.onSurface.withOpacity(0.38)
                  : theme.colorScheme.onSurface,
              fontSize: sizing.labelSize,
            ),
            child: label!,
          ),
        ],
      ),
    );
  }
}

class _FladSwitchSizing {
  final double width;
  final double height;
  final double labelSize;

  const _FladSwitchSizing({
    required this.width,
    required this.height,
    required this.labelSize,
  });

  factory _FladSwitchSizing.from(FladSwitchSize size) {
    switch (size) {
      case FladSwitchSize.sm:
        return const _FladSwitchSizing(width: 36, height: 20, labelSize: 12);
      case FladSwitchSize.md:
        return const _FladSwitchSizing(width: 44, height: 24, labelSize: 13);
      case FladSwitchSize.lg:
        return const _FladSwitchSizing(width: 52, height: 28, labelSize: 14);
    }
  }
}
''';
