/// Template for the Banner component source file.
const bannerTemplate = '''
import 'package:flutter/material.dart';

enum FladBannerVariant { info, success, warning, danger, neutral }

@immutable
class FladBannerTheme extends ThemeExtension<FladBannerTheme> {
  final Color infoBackground;
  final Color infoForeground;
  final Color successBackground;
  final Color successForeground;
  final Color warningBackground;
  final Color warningForeground;
  final Color dangerBackground;
  final Color dangerForeground;
  final Color neutralBackground;
  final Color neutralForeground;
  final Color borderColor;
  final double radius;

  const FladBannerTheme({
    required this.infoBackground,
    required this.infoForeground,
    required this.successBackground,
    required this.successForeground,
    required this.warningBackground,
    required this.warningForeground,
    required this.dangerBackground,
    required this.dangerForeground,
    required this.neutralBackground,
    required this.neutralForeground,
    required this.borderColor,
    required this.radius,
  });

  factory FladBannerTheme.fromScheme(ColorScheme scheme) {
    return FladBannerTheme(
      infoBackground: scheme.primaryContainer,
      infoForeground: scheme.onPrimaryContainer,
      successBackground: scheme.secondaryContainer,
      successForeground: scheme.onSecondaryContainer,
      warningBackground: scheme.tertiaryContainer,
      warningForeground: scheme.onTertiaryContainer,
      dangerBackground: scheme.errorContainer,
      dangerForeground: scheme.onErrorContainer,
      neutralBackground: scheme.surfaceContainerHigh,
      neutralForeground: scheme.onSurface,
      borderColor: scheme.outlineVariant,
      radius: 12,
    );
  }

  @override
  FladBannerTheme copyWith({
    Color? infoBackground,
    Color? infoForeground,
    Color? successBackground,
    Color? successForeground,
    Color? warningBackground,
    Color? warningForeground,
    Color? dangerBackground,
    Color? dangerForeground,
    Color? neutralBackground,
    Color? neutralForeground,
    Color? borderColor,
    double? radius,
  }) {
    return FladBannerTheme(
      infoBackground: infoBackground ?? this.infoBackground,
      infoForeground: infoForeground ?? this.infoForeground,
      successBackground: successBackground ?? this.successBackground,
      successForeground: successForeground ?? this.successForeground,
      warningBackground: warningBackground ?? this.warningBackground,
      warningForeground: warningForeground ?? this.warningForeground,
      dangerBackground: dangerBackground ?? this.dangerBackground,
      dangerForeground: dangerForeground ?? this.dangerForeground,
      neutralBackground: neutralBackground ?? this.neutralBackground,
      neutralForeground: neutralForeground ?? this.neutralForeground,
      borderColor: borderColor ?? this.borderColor,
      radius: radius ?? this.radius,
    );
  }

  @override
  FladBannerTheme lerp(ThemeExtension<FladBannerTheme>? other, double t) {
    if (other is! FladBannerTheme) return this;
    return FladBannerTheme(
      infoBackground: Color.lerp(infoBackground, other.infoBackground, t)!,
      infoForeground: Color.lerp(infoForeground, other.infoForeground, t)!,
      successBackground:
          Color.lerp(successBackground, other.successBackground, t)!,
      successForeground:
          Color.lerp(successForeground, other.successForeground, t)!,
      warningBackground:
          Color.lerp(warningBackground, other.warningBackground, t)!,
      warningForeground:
          Color.lerp(warningForeground, other.warningForeground, t)!,
      dangerBackground:
          Color.lerp(dangerBackground, other.dangerBackground, t)!,
      dangerForeground:
          Color.lerp(dangerForeground, other.dangerForeground, t)!,
      neutralBackground:
          Color.lerp(neutralBackground, other.neutralBackground, t)!,
      neutralForeground:
          Color.lerp(neutralForeground, other.neutralForeground, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      radius: radius + (other.radius - radius) * t,
    );
  }
}

class FladBanner extends StatelessWidget {
  final String title;
  final String? message;
  final FladBannerVariant variant;
  final IconData? icon;
  final Widget? action;
  final EdgeInsetsGeometry? padding;

  const FladBanner({
    super.key,
    required this.title,
    this.message,
    this.variant = FladBannerVariant.info,
    this.icon,
    this.action,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladBannerTheme>() ??
        FladBannerTheme.fromScheme(theme.colorScheme);
    final colors = _FladBannerColors.fromVariant(tokens, variant);

    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(tokens.radius),
        border: Border.all(color: tokens.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: colors.foreground),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    message!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.foreground.withOpacity(0.85),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 12),
            IconTheme(
              data: IconThemeData(color: colors.foreground),
              child: action!,
            ),
          ],
        ],
      ),
    );
  }
}

class _FladBannerColors {
  final Color background;
  final Color foreground;

  const _FladBannerColors({
    required this.background,
    required this.foreground,
  });

  static _FladBannerColors fromVariant(
    FladBannerTheme tokens,
    FladBannerVariant variant,
  ) {
    switch (variant) {
      case FladBannerVariant.success:
        return _FladBannerColors(
          background: tokens.successBackground,
          foreground: tokens.successForeground,
        );
      case FladBannerVariant.warning:
        return _FladBannerColors(
          background: tokens.warningBackground,
          foreground: tokens.warningForeground,
        );
      case FladBannerVariant.danger:
        return _FladBannerColors(
          background: tokens.dangerBackground,
          foreground: tokens.dangerForeground,
        );
      case FladBannerVariant.neutral:
        return _FladBannerColors(
          background: tokens.neutralBackground,
          foreground: tokens.neutralForeground,
        );
      case FladBannerVariant.info:
      default:
        return _FladBannerColors(
          background: tokens.infoBackground,
          foreground: tokens.infoForeground,
        );
    }
  }
}
''';
