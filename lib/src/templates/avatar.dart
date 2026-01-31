/// Template for the Avatar component source file.
const avatarTemplate = '''
import 'package:flutter/material.dart';

enum FladAvatarShape { circle, rounded }

@immutable
class FladAvatarTheme extends ThemeExtension<FladAvatarTheme> {
  final Color background;
  final Color foreground;
  final Color border;
  final double radius;
  final double borderWidth;

  const FladAvatarTheme({
    required this.background,
    required this.foreground,
    required this.border,
    required this.radius,
    required this.borderWidth,
  });

  factory FladAvatarTheme.fromScheme(ColorScheme scheme) {
    return FladAvatarTheme(
      background: scheme.primary.withOpacity(0.12),
      foreground: scheme.primary,
      border: scheme.outlineVariant,
      radius: 12,
      borderWidth: 1,
    );
  }

  @override
  FladAvatarTheme copyWith({
    Color? background,
    Color? foreground,
    Color? border,
    double? radius,
    double? borderWidth,
  }) {
    return FladAvatarTheme(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      border: border ?? this.border,
      radius: radius ?? this.radius,
      borderWidth: borderWidth ?? this.borderWidth,
    );
  }

  @override
  FladAvatarTheme lerp(ThemeExtension<FladAvatarTheme>? other, double t) {
    if (other is! FladAvatarTheme) return this;
    return FladAvatarTheme(
      background: Color.lerp(background, other.background, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      border: Color.lerp(border, other.border, t)!,
      radius: radius + (other.radius - radius) * t,
      borderWidth: borderWidth + (other.borderWidth - borderWidth) * t,
    );
  }
}

class FladAvatar extends StatelessWidget {
  final ImageProvider? image;
  final String? initials;
  final double size;
  final FladAvatarShape shape;
  final Color? background;
  final Color? foreground;
  final bool bordered;

  const FladAvatar({
    super.key,
    this.image,
    this.initials,
    this.size = 40,
    this.shape = FladAvatarShape.circle,
    this.background,
    this.foreground,
    this.bordered = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladAvatarTheme>() ??
        FladAvatarTheme.fromScheme(theme.colorScheme);

    final bg = background ?? tokens.background;
    final fg = foreground ?? tokens.foreground;
    final radius = shape == FladAvatarShape.circle
        ? BorderRadius.circular(size / 2)
        : BorderRadius.circular(tokens.radius);

    final content = image != null
        ? Image(image: image!, width: size, height: size, fit: BoxFit.cover)
        : Center(
            child: Text(
              (initials ?? '').toUpperCase(),
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w700,
                fontSize: size * 0.35,
              ),
            ),
          );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
        border: bordered
            ? Border.all(color: tokens.border, width: tokens.borderWidth)
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: content,
    );
  }
}
''';
