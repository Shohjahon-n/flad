/// Template for the Bottom Sheet component source file.
const bottomSheetTemplate = '''
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

@immutable
class FladBottomSheetTheme extends ThemeExtension<FladBottomSheetTheme> {
  final Color background;
  final Color handle;
  final double radius;

  const FladBottomSheetTheme({
    required this.background,
    required this.handle,
    required this.radius,
  });

  factory FladBottomSheetTheme.fromScheme(ColorScheme scheme) {
    return FladBottomSheetTheme(
      background: scheme.surface,
      handle: scheme.onSurface.withOpacity(0.2),
      radius: 16,
    );
  }

  @override
  FladBottomSheetTheme copyWith({
    Color? background,
    Color? handle,
    double? radius,
  }) {
    return FladBottomSheetTheme(
      background: background ?? this.background,
      handle: handle ?? this.handle,
      radius: radius ?? this.radius,
    );
  }

  @override
  FladBottomSheetTheme lerp(
      ThemeExtension<FladBottomSheetTheme>? other, double t) {
    if (other is! FladBottomSheetTheme) return this;
    return FladBottomSheetTheme(
      background: Color.lerp(background, other.background, t)!,
      handle: Color.lerp(handle, other.handle, t)!,
      radius: radius + (other.radius - radius) * t,
    );
  }
}

class FladBottomSheet {
  const FladBottomSheet._();

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    bool adaptive = true,
    bool isScrollControlled = true,
  }) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladBottomSheetTheme>() ??
        FladBottomSheetTheme.fromScheme(theme.colorScheme);

    final isCupertino = adaptive &&
        (theme.platform == TargetPlatform.iOS ||
            theme.platform == TargetPlatform.macOS);

    if (isCupertino) {
      return showCupertinoModalPopup<T>(
        context: context,
        builder: (context) {
          return SafeArea(
            top: false,
            child: Container(
              decoration: BoxDecoration(
                color: tokens.background,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(tokens.radius),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: tokens.handle,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Flexible(child: child),
                ],
              ),
            ),
          );
        },
      );
    }

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: tokens.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(tokens.radius),
        ),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: tokens.handle,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(child: child),
          ],
        );
      },
    );
  }
}
''';
