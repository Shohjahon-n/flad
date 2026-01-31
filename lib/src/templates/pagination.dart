/// Template for the Pagination component source file.
const paginationTemplate = '''
import 'package:flutter/material.dart';

@immutable
class FladPaginationTheme extends ThemeExtension<FladPaginationTheme> {
  final Color activeBackground;
  final Color activeForeground;
  final Color inactiveForeground;
  final Color border;
  final Color hoverBackground;
  final double radius;
  final EdgeInsetsGeometry padding;

  const FladPaginationTheme({
    required this.activeBackground,
    required this.activeForeground,
    required this.inactiveForeground,
    required this.border,
    required this.hoverBackground,
    required this.radius,
    required this.padding,
  });

  factory FladPaginationTheme.fromScheme(ColorScheme scheme) {
    return FladPaginationTheme(
      activeBackground: scheme.primary,
      activeForeground: scheme.onPrimary,
      inactiveForeground: scheme.onSurface,
      border: scheme.outlineVariant,
      hoverBackground: scheme.primary.withOpacity(0.08),
      radius: 10,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    );
  }

  @override
  FladPaginationTheme copyWith({
    Color? activeBackground,
    Color? activeForeground,
    Color? inactiveForeground,
    Color? border,
    Color? hoverBackground,
    double? radius,
    EdgeInsetsGeometry? padding,
  }) {
    return FladPaginationTheme(
      activeBackground: activeBackground ?? this.activeBackground,
      activeForeground: activeForeground ?? this.activeForeground,
      inactiveForeground: inactiveForeground ?? this.inactiveForeground,
      border: border ?? this.border,
      hoverBackground: hoverBackground ?? this.hoverBackground,
      radius: radius ?? this.radius,
      padding: padding ?? this.padding,
    );
  }

  @override
  FladPaginationTheme lerp(
    ThemeExtension<FladPaginationTheme>? other,
    double t,
  ) {
    if (other is! FladPaginationTheme) return this;
    return FladPaginationTheme(
      activeBackground: Color.lerp(activeBackground, other.activeBackground, t)!,
      activeForeground: Color.lerp(activeForeground, other.activeForeground, t)!,
      inactiveForeground:
          Color.lerp(inactiveForeground, other.inactiveForeground, t)!,
      border: Color.lerp(border, other.border, t)!,
      hoverBackground: Color.lerp(hoverBackground, other.hoverBackground, t)!,
      radius: radius + (other.radius - radius) * t,
      padding: EdgeInsetsGeometry.lerp(padding, other.padding, t)!,
    );
  }
}

class FladPagination extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final ValueChanged<int>? onPageChanged;
  final int maxVisible;

  const FladPagination({
    super.key,
    required this.currentPage,
    required this.pageCount,
    this.onPageChanged,
    this.maxVisible = 5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladPaginationTheme>() ??
        FladPaginationTheme.fromScheme(theme.colorScheme);

    final pages = _visiblePages(currentPage, pageCount, maxVisible);
    final canTap = onPageChanged != null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _NavButton(
          icon: Icons.chevron_left,
          enabled: canTap && currentPage > 1,
          onTap: () => onPageChanged!.call(currentPage - 1),
          tokens: tokens,
        ),
        const SizedBox(width: 8),
        for (final page in pages) ...[
          _PageButton(
            page: page,
            isActive: page == currentPage,
            onTap: canTap ? () => onPageChanged!.call(page) : null,
            tokens: tokens,
          ),
          const SizedBox(width: 8),
        ],
        _NavButton(
          icon: Icons.chevron_right,
          enabled: canTap && currentPage < pageCount,
          onTap: () => onPageChanged!.call(currentPage + 1),
          tokens: tokens,
        ),
      ],
    );
  }

  List<int> _visiblePages(int current, int total, int max) {
    if (total <= max) {
      return List.generate(total, (index) => index + 1);
    }
    final half = max ~/ 2;
    var start = current - half;
    var end = current + half;
    if (start < 1) {
      start = 1;
      end = max;
    }
    if (end > total) {
      end = total;
      start = total - max + 1;
    }
    return List.generate(end - start + 1, (index) => start + index);
  }
}

class _PageButton extends StatelessWidget {
  final int page;
  final bool isActive;
  final VoidCallback? onTap;
  final FladPaginationTheme tokens;

  const _PageButton({
    required this.page,
    required this.isActive,
    required this.onTap,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? tokens.activeBackground : Colors.transparent,
      borderRadius: BorderRadius.circular(tokens.radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(tokens.radius),
        onTap: onTap,
        child: Container(
          padding: tokens.padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(tokens.radius),
            border: Border.all(color: tokens.border),
          ),
          child: Text(
            page.toString(),
            style: TextStyle(
              color: isActive
                  ? tokens.activeForeground
                  : tokens.inactiveForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final FladPaginationTheme tokens;

  const _NavButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(tokens.radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(tokens.radius),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: tokens.padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(tokens.radius),
            border: Border.all(color: tokens.border),
          ),
          child: Icon(
            icon,
            size: 18,
            color: enabled
                ? tokens.inactiveForeground
                : tokens.inactiveForeground.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}
''';
