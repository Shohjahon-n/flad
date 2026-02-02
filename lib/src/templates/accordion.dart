/// Template for the Accordion component source file.
const accordionTemplate = '''
import 'package:flutter/material.dart';

@immutable
class FladAccordionTheme extends ThemeExtension<FladAccordionTheme> {
  final Color background;
  final Color collapsedBackground;
  final Color titleColor;
  final Color contentColor;
  final Color iconColor;
  final Color borderColor;
  final Color dividerColor;
  final double radius;

  const FladAccordionTheme({
    required this.background,
    required this.collapsedBackground,
    required this.titleColor,
    required this.contentColor,
    required this.iconColor,
    required this.borderColor,
    required this.dividerColor,
    required this.radius,
  });

  factory FladAccordionTheme.fromScheme(ColorScheme scheme) {
    return FladAccordionTheme(
      background: scheme.surface,
      collapsedBackground: scheme.surface,
      titleColor: scheme.onSurface,
      contentColor: scheme.onSurfaceVariant,
      iconColor: scheme.onSurfaceVariant,
      borderColor: scheme.outlineVariant,
      dividerColor: scheme.outlineVariant,
      radius: 12,
    );
  }

  @override
  FladAccordionTheme copyWith({
    Color? background,
    Color? collapsedBackground,
    Color? titleColor,
    Color? contentColor,
    Color? iconColor,
    Color? borderColor,
    Color? dividerColor,
    double? radius,
  }) {
    return FladAccordionTheme(
      background: background ?? this.background,
      collapsedBackground: collapsedBackground ?? this.collapsedBackground,
      titleColor: titleColor ?? this.titleColor,
      contentColor: contentColor ?? this.contentColor,
      iconColor: iconColor ?? this.iconColor,
      borderColor: borderColor ?? this.borderColor,
      dividerColor: dividerColor ?? this.dividerColor,
      radius: radius ?? this.radius,
    );
  }

  @override
  FladAccordionTheme lerp(ThemeExtension<FladAccordionTheme>? other, double t) {
    if (other is! FladAccordionTheme) return this;
    return FladAccordionTheme(
      background: Color.lerp(background, other.background, t)!,
      collapsedBackground:
          Color.lerp(collapsedBackground, other.collapsedBackground, t)!,
      titleColor: Color.lerp(titleColor, other.titleColor, t)!,
      contentColor: Color.lerp(contentColor, other.contentColor, t)!,
      iconColor: Color.lerp(iconColor, other.iconColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t)!,
      radius: radius + (other.radius - radius) * t,
    );
  }
}

class FladAccordion extends StatefulWidget {
  final Widget title;
  final Widget content;
  final bool initiallyExpanded;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsets? padding;
  final EdgeInsets? contentPadding;

  const FladAccordion({
    super.key,
    required this.title,
    required this.content,
    this.initiallyExpanded = false,
    this.leading,
    this.trailing,
    this.padding,
    this.contentPadding,
  });

  @override
  State<FladAccordion> createState() => _FladAccordionState();
}

class _FladAccordionState extends State<FladAccordion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotationAnimation;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: _isExpanded ? 1.0 : 0.0,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladAccordionTheme>() ??
        FladAccordionTheme.fromScheme(theme.colorScheme);
    final headerPadding = widget.padding ??
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    final bodyPadding = widget.contentPadding ??
        const EdgeInsets.fromLTRB(16, 0, 16, 16);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _isExpanded ? tokens.background : tokens.collapsedBackground,
        borderRadius: BorderRadius.circular(tokens.radius),
        border: Border.all(color: tokens.borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggle,
              borderRadius: BorderRadius.circular(tokens.radius),
              child: Padding(
                padding: headerPadding,
                child: Row(
                  children: [
                    if (widget.leading != null) ...[
                      IconTheme(
                        data: IconThemeData(
                          color: tokens.iconColor,
                          size: 20,
                        ),
                        child: widget.leading!,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: DefaultTextStyle.merge(
                        style: TextStyle(
                          color: tokens.titleColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        child: widget.title,
                      ),
                    ),
                    widget.trailing ??
                        RotationTransition(
                          turns: _rotationAnimation,
                          child: Icon(
                            Icons.expand_more,
                            color: tokens.iconColor,
                            size: 20,
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ),
          ClipRect(
            child: SizeTransition(
              sizeFactor: _expandAnimation,
              child: Column(
                children: [
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: tokens.dividerColor,
                  ),
                  Padding(
                    padding: bodyPadding,
                    child: SizedBox(
                      width: double.infinity,
                      child: DefaultTextStyle.merge(
                        style: TextStyle(
                          color: tokens.contentColor,
                          fontSize: 14,
                          height: 1.5,
                        ),
                        child: widget.content,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
''';
