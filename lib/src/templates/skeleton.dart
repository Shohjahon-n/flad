/// Template for the Skeleton component source file.
const skeletonTemplate = '''
import 'package:flutter/material.dart';

@immutable
class FladSkeletonTheme extends ThemeExtension<FladSkeletonTheme> {
  final Color base;
  final Color highlight;
  final double radius;
  final Duration duration;

  const FladSkeletonTheme({
    required this.base,
    required this.highlight,
    required this.radius,
    required this.duration,
  });

  factory FladSkeletonTheme.fromScheme(ColorScheme scheme) {
    return FladSkeletonTheme(
      base: scheme.onSurface.withOpacity(0.08),
      highlight: scheme.onSurface.withOpacity(0.18),
      radius: 12,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  FladSkeletonTheme copyWith({
    Color? base,
    Color? highlight,
    double? radius,
    Duration? duration,
  }) {
    return FladSkeletonTheme(
      base: base ?? this.base,
      highlight: highlight ?? this.highlight,
      radius: radius ?? this.radius,
      duration: duration ?? this.duration,
    );
  }

  @override
  FladSkeletonTheme lerp(
    ThemeExtension<FladSkeletonTheme>? other,
    double t,
  ) {
    if (other is! FladSkeletonTheme) return this;
    return FladSkeletonTheme(
      base: Color.lerp(base, other.base, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
      radius: radius + (other.radius - radius) * t,
      duration: Duration(
        milliseconds: (duration.inMilliseconds +
                (other.duration.inMilliseconds - duration.inMilliseconds) * t)
            .round(),
      ),
    );
  }
}

class FladSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;
  final bool animate;

  const FladSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius,
    this.margin,
    this.animate = true,
  });

  @override
  State<FladSkeleton> createState() => _FladSkeletonState();
}

class _FladSkeletonState extends State<FladSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladSkeletonTheme>() ??
        FladSkeletonTheme.fromScheme(theme.colorScheme);

    _controller.duration = tokens.duration;

    if (!widget.animate) {
      if (_controller.isAnimating) {
        _controller.stop();
      }
      return _buildBox(tokens, 0.5);
    }

    if (!_controller.isAnimating) {
      _controller.repeat(min: 0, max: 1, period: tokens.duration);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return _buildBox(tokens, _controller.value);
      },
    );
  }

  Widget _buildBox(FladSkeletonTheme tokens, double t) {
    final radius = widget.borderRadius ?? BorderRadius.circular(tokens.radius);
    final alignment = Alignment(-1 + 3 * t, 0);
    final end = Alignment(alignment.x + 1, alignment.y);

    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: alignment,
          end: end,
          colors: [
            tokens.base,
            tokens.highlight,
            tokens.base,
          ],
        ),
      ),
    );
  }
}
''';
