/// Template for the Shimmer component source file.
const shimmerTemplate = '''
import 'package:flutter/material.dart';

@immutable
class FladShimmerTheme extends ThemeExtension<FladShimmerTheme> {
  final Color baseColor;
  final Color highlightColor;
  final double radius;

  const FladShimmerTheme({
    required this.baseColor,
    required this.highlightColor,
    required this.radius,
  });

  factory FladShimmerTheme.fromScheme(ColorScheme scheme) {
    return FladShimmerTheme(
      baseColor: scheme.surfaceContainerHighest,
      highlightColor: scheme.surface,
      radius: 8,
    );
  }

  @override
  FladShimmerTheme copyWith({
    Color? baseColor,
    Color? highlightColor,
    double? radius,
  }) {
    return FladShimmerTheme(
      baseColor: baseColor ?? this.baseColor,
      highlightColor: highlightColor ?? this.highlightColor,
      radius: radius ?? this.radius,
    );
  }

  @override
  FladShimmerTheme lerp(ThemeExtension<FladShimmerTheme>? other, double t) {
    if (other is! FladShimmerTheme) return this;
    return FladShimmerTheme(
      baseColor: Color.lerp(baseColor, other.baseColor, t)!,
      highlightColor: Color.lerp(highlightColor, other.highlightColor, t)!,
      radius: radius + (other.radius - radius) * t,
    );
  }
}

class FladShimmer extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;
  final Widget? child;

  const FladShimmer({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
    this.child,
  });

  const FladShimmer.circular({
    super.key,
    required double size,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
    this.child,
  })  : width = size,
        height = size,
        borderRadius = null;

  @override
  State<FladShimmer> createState() => _FladShimmerState();
}

class _FladShimmerState extends State<FladShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladShimmerTheme>() ??
        FladShimmerTheme.fromScheme(theme.colorScheme);

    final base = widget.baseColor ?? tokens.baseColor;
    final highlight = widget.highlightColor ?? tokens.highlightColor;
    final isCircular = widget.borderRadius == null &&
        widget.width == widget.height;
    final effectiveRadius = widget.borderRadius ??
        (isCircular
            ? BorderRadius.circular(widget.width / 2)
            : BorderRadius.circular(tokens.radius));

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: effectiveRadius,
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
              end: Alignment(-1.0 + 2.0 * _controller.value + 1.0, 0),
              colors: [base, highlight, base],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

class FladShimmerGroup extends StatelessWidget {
  final int lines;
  final double lineHeight;
  final double spacing;
  final bool showAvatar;
  final double avatarSize;

  const FladShimmerGroup({
    super.key,
    this.lines = 3,
    this.lineHeight = 14,
    this.spacing = 10,
    this.showAvatar = false,
    this.avatarSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showAvatar) ...[
          FladShimmer.circular(size: avatarSize),
          SizedBox(width: spacing),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(lines, (index) {
              final isLast = index == lines - 1;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: isLast ? 0 : spacing,
                ),
                child: FractionallySizedBox(
                  widthFactor: isLast ? 0.6 : 1.0,
                  child: FladShimmer(height: lineHeight),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
''';
