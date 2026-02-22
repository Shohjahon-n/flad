/// Template for the Accordion component source file.
const accordionTemplate = '''
import 'package:flutter/material.dart';

@immutable
class FladAccordionTheme extends ThemeExtension<FladAccordionTheme> {
  final Color headerBg;
  final Color headerFg;
  final Color contentBg;
  final Color dividerColor;
  final Color iconColor;
  final double radius;
  final double borderWidth;

  const FladAccordionTheme({
    required this.headerBg,
    required this.headerFg,
    required this.contentBg,
    required this.dividerColor,
    required this.iconColor,
    required this.radius,
    required this.borderWidth,
  });

  factory FladAccordionTheme.fromScheme(ColorScheme scheme) {
    return FladAccordionTheme(
      headerBg: scheme.surface,
      headerFg: scheme.onSurface,
      contentBg: scheme.surface,
      dividerColor: scheme.outlineVariant,
      iconColor: scheme.onSurfaceVariant,
      radius: 12,
      borderWidth: 1,
    );
  }

  @override
  FladAccordionTheme copyWith({
    Color? headerBg,
    Color? headerFg,
    Color? contentBg,
    Color? dividerColor,
    Color? iconColor,
    double? radius,
    double? borderWidth,
  }) {
    return FladAccordionTheme(
      headerBg: headerBg ?? this.headerBg,
      headerFg: headerFg ?? this.headerFg,
      contentBg: contentBg ?? this.contentBg,
      dividerColor: dividerColor ?? this.dividerColor,
      iconColor: iconColor ?? this.iconColor,
      radius: radius ?? this.radius,
      borderWidth: borderWidth ?? this.borderWidth,
    );
  }

  @override
  FladAccordionTheme lerp(ThemeExtension<FladAccordionTheme>? other, double t) {
    if (other is! FladAccordionTheme) return this;
    return FladAccordionTheme(
      headerBg: Color.lerp(headerBg, other.headerBg, t)!,
      headerFg: Color.lerp(headerFg, other.headerFg, t)!,
      contentBg: Color.lerp(contentBg, other.contentBg, t)!,
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t)!,
      iconColor: Color.lerp(iconColor, other.iconColor, t)!,
      radius: radius + (other.radius - radius) * t,
      borderWidth: borderWidth + (other.borderWidth - borderWidth) * t,
    );
  }
}

class FladAccordionItem {
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? leading;

  const FladAccordionItem({
    required this.title,
    this.subtitle,
    required this.child,
    this.leading,
  });
}

class FladAccordion extends StatefulWidget {
  final List<FladAccordionItem> items;
  final bool allowMultiple;
  final Set<int> initiallyExpanded;

  const FladAccordion({
    super.key,
    required this.items,
    this.allowMultiple = false,
    this.initiallyExpanded = const <int>{},
  });

  @override
  State<FladAccordion> createState() => _FladAccordionState();
}

class _FladAccordionState extends State<FladAccordion> {
  late Set<int> _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = Set<int>.from(widget.initiallyExpanded);
  }

  void _toggle(int index) {
    setState(() {
      if (_expanded.contains(index)) {
        _expanded.remove(index);
      } else {
        if (!widget.allowMultiple) {
          _expanded.clear();
        }
        _expanded.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladAccordionTheme>() ??
        FladAccordionTheme.fromScheme(theme.colorScheme);

    return Column(
      children: [
        for (int i = 0; i < widget.items.length; i++)
          _AccordionPanel(
            item: widget.items[i],
            isExpanded: _expanded.contains(i),
            onToggle: () => _toggle(i),
            tokens: tokens,
            theme: theme,
            hasPrevious: i > 0,
          ),
      ],
    );
  }
}

class _AccordionPanel extends StatelessWidget {
  final FladAccordionItem item;
  final bool isExpanded;
  final VoidCallback onToggle;
  final FladAccordionTheme tokens;
  final ThemeData theme;
  final bool hasPrevious;

  const _AccordionPanel({
    required this.item,
    required this.isExpanded,
    required this.onToggle,
    required this.tokens,
    required this.theme,
    required this.hasPrevious,
  });

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(tokens.radius);

    return Container(
      margin: EdgeInsets.only(top: hasPrevious ? 8 : 0),
      decoration: BoxDecoration(
        color: tokens.headerBg,
        borderRadius: br,
        border: Border.all(
          color: tokens.dividerColor,
          width: tokens.borderWidth,
        ),
      ),
      child: ClipRRect(
        borderRadius: br,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: onToggle,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    if (item.leading != null) ...[
                      IconTheme(
                        data: IconThemeData(
                          color: tokens.iconColor,
                          size: 20,
                        ),
                        child: item.leading!,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: tokens.headerFg,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (item.subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              item.subtitle!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: tokens.iconColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 120),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: tokens.iconColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(height: 0),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Divider(
                    height: tokens.borderWidth,
                    thickness: tokens.borderWidth,
                    color: tokens.dividerColor,
                  ),
                  Container(
                    color: tokens.contentBg,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: item.child,
                  ),
                ],
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 120),
            ),
          ],
        ),
      ),
    );
  }
}
''';
