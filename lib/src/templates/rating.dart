/// Template for the Rating component source file.
const ratingTemplate = '''
import 'package:flutter/material.dart';

@immutable
class FladRatingTheme extends ThemeExtension<FladRatingTheme> {
  final Color active;
  final Color inactive;
  final double size;

  const FladRatingTheme({
    required this.active,
    required this.inactive,
    required this.size,
  });

  factory FladRatingTheme.fromScheme(ColorScheme scheme) {
    return FladRatingTheme(
      active: scheme.primary,
      inactive: scheme.onSurfaceVariant,
      size: 20,
    );
  }

  @override
  FladRatingTheme copyWith({
    Color? active,
    Color? inactive,
    double? size,
  }) {
    return FladRatingTheme(
      active: active ?? this.active,
      inactive: inactive ?? this.inactive,
      size: size ?? this.size,
    );
  }

  @override
  FladRatingTheme lerp(ThemeExtension<FladRatingTheme>? other, double t) {
    if (other is! FladRatingTheme) return this;
    return FladRatingTheme(
      active: Color.lerp(active, other.active, t)!,
      inactive: Color.lerp(inactive, other.inactive, t)!,
      size: size + (other.size - size) * t,
    );
  }
}

class FladRating extends StatelessWidget {
  final double value;
  final int max;
  final ValueChanged<double>? onChanged;
  final double? size;

  const FladRating({
    super.key,
    required this.value,
    this.max = 5,
    this.onChanged,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladRatingTheme>() ??
        FladRatingTheme.fromScheme(theme.colorScheme);
    final iconSize = size ?? tokens.size;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(max, (index) {
        final starValue = index + 1;
        final icon = value >= starValue
            ? Icons.star
            : (value > index ? Icons.star_half : Icons.star_border);
        final color = value >= index + 0.5 ? tokens.active : tokens.inactive;

        return InkWell(
          onTap: onChanged == null
              ? null
              : () => onChanged!.call(starValue.toDouble()),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(icon, size: iconSize, color: color),
          ),
        );
      }),
    );
  }
}
''';
