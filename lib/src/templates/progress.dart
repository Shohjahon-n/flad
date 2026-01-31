/// Template for the Progress component source file.
const progressTemplate = '''
import 'package:flutter/material.dart';

enum FladProgressVariant { linear, circular }

enum FladProgressSize { sm, md, lg }

@immutable
class FladProgressTheme extends ThemeExtension<FladProgressTheme> {
  final Color active;
  final Color track;

  const FladProgressTheme({
    required this.active,
    required this.track,
  });

  factory FladProgressTheme.fromScheme(ColorScheme scheme) {
    return FladProgressTheme(
      active: scheme.primary,
      track: scheme.outlineVariant,
    );
  }

  @override
  FladProgressTheme copyWith({
    Color? active,
    Color? track,
  }) {
    return FladProgressTheme(
      active: active ?? this.active,
      track: track ?? this.track,
    );
  }

  @override
  FladProgressTheme lerp(ThemeExtension<FladProgressTheme>? other, double t) {
    if (other is! FladProgressTheme) return this;
    return FladProgressTheme(
      active: Color.lerp(active, other.active, t)!,
      track: Color.lerp(track, other.track, t)!,
    );
  }
}

class FladProgress extends StatelessWidget {
  final FladProgressVariant variant;
  final FladProgressSize size;
  final double? value;
  final double? strokeWidth;

  const FladProgress({
    super.key,
    this.variant = FladProgressVariant.linear,
    this.size = FladProgressSize.md,
    this.value,
    this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladProgressTheme>() ??
        FladProgressTheme.fromScheme(theme.colorScheme);
    final sizing = _FladProgressSizing.from(size);

    if (variant == FladProgressVariant.circular) {
      return SizedBox(
        width: sizing.circularSize,
        height: sizing.circularSize,
        child: CircularProgressIndicator(
          value: value,
          strokeWidth: strokeWidth ?? sizing.strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(tokens.active),
          backgroundColor: tokens.track,
        ),
      );
    }

    return LinearProgressIndicator(
      value: value,
      minHeight: sizing.linearHeight,
      valueColor: AlwaysStoppedAnimation<Color>(tokens.active),
      backgroundColor: tokens.track,
    );
  }
}

class _FladProgressSizing {
  final double linearHeight;
  final double circularSize;
  final double strokeWidth;

  const _FladProgressSizing({
    required this.linearHeight,
    required this.circularSize,
    required this.strokeWidth,
  });

  factory _FladProgressSizing.from(FladProgressSize size) {
    switch (size) {
      case FladProgressSize.sm:
        return const _FladProgressSizing(linearHeight: 4, circularSize: 18, strokeWidth: 2);
      case FladProgressSize.md:
        return const _FladProgressSizing(linearHeight: 6, circularSize: 24, strokeWidth: 3);
      case FladProgressSize.lg:
        return const _FladProgressSizing(linearHeight: 8, circularSize: 32, strokeWidth: 4);
    }
  }
}
''';
