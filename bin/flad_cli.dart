import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;

const _defaultTargetDir = 'lib/ui';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show this help message.',
    )
    ..addCommand('init')
    ..addCommand(
      'add',
      ArgParser()
        ..addOption(
          'path',
          abbr: 'p',
          defaultsTo: _defaultTargetDir,
          help: 'Target directory for the component.',
        )
        ..addFlag(
          'help',
          abbr: 'h',
          negatable: false,
          help: 'Show help for the add command.',
        ),
    );

  ArgResults results;
  try {
    results = parser.parse(arguments);
  } on FormatException catch (error) {
    _printError(error.message);
    _printUsage(parser);
    exitCode = 64;
    return;
  }

  if (results['help'] as bool) {
    _printUsage(parser);
    return;
  }

  final command = results.command;
  if (command == null) {
    _printUsage(parser);
    return;
  }

  switch (command.name) {
    case 'init':
      await _init();
      break;
    case 'add':
      if (command['help'] as bool) {
        _printAddUsage(parser);
        return;
      }
      final component =
          command.rest.isEmpty ? null : command.rest.first.trim();
      if (component == null || component.isEmpty) {
        _printError('Missing component name.');
        _printAddUsage(parser);
        exitCode = 64;
        return;
      }
      final targetDir = (command['path'] as String).trim();
      if (targetDir.isEmpty) {
        _printError('Target path cannot be empty.');
        exitCode = 64;
        return;
      }
      await _add(component, targetDir);
      break;
    default:
      _printUsage(parser);
  }
}

void _printUsage(ArgParser parser) {
  stdout.writeln('flad - shadcn-style Flutter UI copier');
  stdout.writeln('');
  stdout.writeln('Usage:');
  stdout.writeln('  flad init');
  stdout.writeln('  flad add <component> [--path <dir>]');
  stdout.writeln('');
  stdout.writeln('Examples:');
  stdout.writeln('  flad init');
  stdout.writeln('  flad add button');
  stdout.writeln('  flad add button --path lib/shared/ui');
  stdout.writeln('');
  stdout.writeln('Options:');
  stdout.writeln(parser.usage);
}

void _printAddUsage(ArgParser parser) {
  stdout.writeln('Usage:');
  stdout.writeln('  flad add <component> [--path <dir>]');
  stdout.writeln('');
  stdout.writeln('Options:');
  final addCommand = parser.commands['add'];
  if (addCommand != null) {
    stdout.writeln(addCommand.usage);
  }
  stdout.writeln('Available components: ${_componentTemplates.keys.join(', ')}');
}

void _printError(String message) {
  stderr.writeln('Error: $message');
}

Future<bool> _ensureFlutterProject() async {
  final libDir = Directory('lib');
  if (!await libDir.exists()) {
    _printError('Not a Flutter project: lib/ directory not found.');
    exitCode = 1;
    return false;
  }
  return true;
}

Future<void> _init() async {
  if (!await _ensureFlutterProject()) {
    return;
  }

  final uiDir = Directory(_defaultTargetDir);
  if (await uiDir.exists()) {
    stdout.writeln('Using existing directory: ${uiDir.path}');
    return;
  }

  await uiDir.create(recursive: true);
  stdout.writeln('Created directory: ${uiDir.path}');
}

Future<void> _add(String component, String targetDir) async {
  if (!await _ensureFlutterProject()) {
    return;
  }

  final template = _componentTemplates[component];
  if (template == null) {
    _printError('Unknown component: $component');
    _printAvailableComponents();
    exitCode = 64;
    return;
  }

  final resolvedDir = p.normalize(targetDir);
  final dir = Directory(resolvedDir);
  if (await dir.exists()) {
    stdout.writeln('Using existing directory: ${dir.path}');
  } else {
    await dir.create(recursive: true);
    stdout.writeln('Created directory: ${dir.path}');
  }

  final outputPath = p.join(resolvedDir, '$component.dart');
  final outputFile = File(outputPath);
  if (await outputFile.exists()) {
    _printError('File already exists: ${p.normalize(outputFile.path)}');
    exitCode = 1;
    return;
  }

  await outputFile.writeAsString(template);
  stdout.writeln('Added: ${p.normalize(outputFile.path)}');
}

const _componentTemplates = {
  'button': _buttonDart,
  'input': _inputDart,
};

void _printAvailableComponents() {
  stdout.writeln('Available components: ${_componentTemplates.keys.join(', ')}');
}

const _buttonDart = '''
import 'package:flutter/material.dart';

enum FladButtonVariant { solid, outline, ghost }
enum FladButtonSize { sm, md, lg }

@immutable
class FladButtonTheme extends ThemeExtension<FladButtonTheme> {
  final Color solidBackground;
  final Color solidForeground;
  final Color outlineForeground;
  final Color outlineBorder;
  final Color ghostForeground;
  final Color disabledBackground;
  final Color disabledForeground;
  final Color pressedOverlay;
  final double radius;

  const FladButtonTheme({
    required this.solidBackground,
    required this.solidForeground,
    required this.outlineForeground,
    required this.outlineBorder,
    required this.ghostForeground,
    required this.disabledBackground,
    required this.disabledForeground,
    required this.pressedOverlay,
    required this.radius,
  });

  factory FladButtonTheme.fromScheme(ColorScheme scheme) {
    return FladButtonTheme(
      solidBackground: scheme.primary,
      solidForeground: scheme.onPrimary,
      outlineForeground: scheme.onSurface,
      outlineBorder: scheme.outline,
      ghostForeground: scheme.onSurface,
      disabledBackground: scheme.onSurface.withOpacity(0.08),
      disabledForeground: scheme.onSurface.withOpacity(0.38),
      pressedOverlay: scheme.onSurface.withOpacity(0.10),
      radius: 12,
    );
  }

  @override
  FladButtonTheme copyWith({
    Color? solidBackground,
    Color? solidForeground,
    Color? outlineForeground,
    Color? outlineBorder,
    Color? ghostForeground,
    Color? disabledBackground,
    Color? disabledForeground,
    Color? pressedOverlay,
    double? radius,
  }) {
    return FladButtonTheme(
      solidBackground: solidBackground ?? this.solidBackground,
      solidForeground: solidForeground ?? this.solidForeground,
      outlineForeground: outlineForeground ?? this.outlineForeground,
      outlineBorder: outlineBorder ?? this.outlineBorder,
      ghostForeground: ghostForeground ?? this.ghostForeground,
      disabledBackground: disabledBackground ?? this.disabledBackground,
      disabledForeground: disabledForeground ?? this.disabledForeground,
      pressedOverlay: pressedOverlay ?? this.pressedOverlay,
      radius: radius ?? this.radius,
    );
  }

  @override
  FladButtonTheme lerp(ThemeExtension<FladButtonTheme>? other, double t) {
    if (other is! FladButtonTheme) return this;
    return FladButtonTheme(
      solidBackground: Color.lerp(solidBackground, other.solidBackground, t)!,
      solidForeground: Color.lerp(solidForeground, other.solidForeground, t)!,
      outlineForeground:
          Color.lerp(outlineForeground, other.outlineForeground, t)!,
      outlineBorder: Color.lerp(outlineBorder, other.outlineBorder, t)!,
      ghostForeground: Color.lerp(ghostForeground, other.ghostForeground, t)!,
      disabledBackground:
          Color.lerp(disabledBackground, other.disabledBackground, t)!,
      disabledForeground:
          Color.lerp(disabledForeground, other.disabledForeground, t)!,
      pressedOverlay: Color.lerp(pressedOverlay, other.pressedOverlay, t)!,
      radius: radius + (other.radius - radius) * t,
    );
  }
}

class FladButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final FladButtonVariant variant;
  final FladButtonSize size;
  final EdgeInsets? padding;
  final bool fullWidth;
  final bool loading;
  final Widget? leading;
  final Widget? trailing;
  final BorderRadius? borderRadius;

  const FladButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = FladButtonVariant.solid,
    this.size = FladButtonSize.md,
    this.padding,
    this.fullWidth = false,
    this.loading = false,
    this.leading,
    this.trailing,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladButtonTheme>() ??
        FladButtonTheme.fromScheme(theme.colorScheme);
    final radius = borderRadius ?? BorderRadius.circular(tokens.radius);
    final transparent = theme.colorScheme.surface.withOpacity(0);
    final isDisabled = onPressed == null || loading;
    final sizing = _FladButtonSizing.from(size);
    final effectivePadding = padding ??
        EdgeInsets.symmetric(
          vertical: sizing.verticalPadding,
          horizontal: sizing.horizontalPadding,
        );

    Color bg;
    Color fg;
    BorderSide? side;

    switch (variant) {
      case FladButtonVariant.solid:
        bg = isDisabled ? tokens.disabledBackground : tokens.solidBackground;
        fg = isDisabled ? tokens.disabledForeground : tokens.solidForeground;
        side = BorderSide.none;
        break;
      case FladButtonVariant.outline:
        bg = transparent;
        fg = isDisabled ? tokens.disabledForeground : tokens.outlineForeground;
        side = BorderSide(
          color: isDisabled ? tokens.disabledForeground : tokens.outlineBorder,
          width: 1,
        );
        break;
      case FladButtonVariant.ghost:
        bg = transparent;
        fg = isDisabled ? tokens.disabledForeground : tokens.ghostForeground;
        side = BorderSide.none;
        break;
    }

    final content = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[
          IconTheme(
            data: IconThemeData(color: fg, size: sizing.iconSize),
            child: leading!,
          ),
          SizedBox(width: sizing.gap),
        ],
        if (loading) ...[
          SizedBox(
            width: sizing.spinnerSize,
            height: sizing.spinnerSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
          SizedBox(width: sizing.gap),
        ],
        Flexible(
          child: DefaultTextStyle.merge(
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w600,
              fontSize: sizing.fontSize,
              height: 1.1,
            ),
            child: child,
          ),
        ),
        if (trailing != null) ...[
          SizedBox(width: sizing.gap),
          IconTheme(
            data: IconThemeData(color: fg, size: sizing.iconSize),
            child: trailing!,
          ),
        ],
      ],
    );

    final body = fullWidth ? SizedBox(width: double.infinity, child: content) : content;

    return Material(
      color: bg,
      borderRadius: radius,
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: radius,
        overlayColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return tokens.pressedOverlay;
          }
          return null;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: effectivePadding,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: side == BorderSide.none ? null : Border.fromBorderSide(side),
          ),
          child: Center(child: body),
        ),
      ),
    );
  }
}

class _FladButtonSizing {
  final double fontSize;
  final double iconSize;
  final double spinnerSize;
  final double gap;
  final double verticalPadding;
  final double horizontalPadding;

  const _FladButtonSizing({
    required this.fontSize,
    required this.iconSize,
    required this.spinnerSize,
    required this.gap,
    required this.verticalPadding,
    required this.horizontalPadding,
  });

  factory _FladButtonSizing.from(FladButtonSize size) {
    switch (size) {
      case FladButtonSize.sm:
        return const _FladButtonSizing(
          fontSize: 12,
          iconSize: 16,
          spinnerSize: 14,
          gap: 6,
          verticalPadding: 8,
          horizontalPadding: 12,
        );
      case FladButtonSize.md:
        return const _FladButtonSizing(
          fontSize: 14,
          iconSize: 18,
          spinnerSize: 16,
          gap: 8,
          verticalPadding: 10,
          horizontalPadding: 14,
        );
      case FladButtonSize.lg:
        return const _FladButtonSizing(
          fontSize: 16,
          iconSize: 20,
          spinnerSize: 18,
          gap: 10,
          verticalPadding: 12,
          horizontalPadding: 18,
        );
    }
  }
}
''';

const _inputDart = '''
import 'package:flutter/material.dart';

enum FladInputSize { sm, md, lg }

@immutable
class FladInputTheme extends ThemeExtension<FladInputTheme> {
  final Color background;
  final Color text;
  final Color placeholder;
  final Color label;
  final Color helper;
  final Color border;
  final Color focusBorder;
  final Color errorBorder;
  final Color disabledBackground;
  final Color disabledText;
  final Color cursor;
  final double radius;
  final double borderWidth;

  const FladInputTheme({
    required this.background,
    required this.text,
    required this.placeholder,
    required this.label,
    required this.helper,
    required this.border,
    required this.focusBorder,
    required this.errorBorder,
    required this.disabledBackground,
    required this.disabledText,
    required this.cursor,
    required this.radius,
    required this.borderWidth,
  });

  factory FladInputTheme.fromScheme(ColorScheme scheme) {
    return FladInputTheme(
      background: scheme.surface,
      text: scheme.onSurface,
      placeholder: scheme.onSurfaceVariant,
      label: scheme.onSurface,
      helper: scheme.onSurfaceVariant,
      border: scheme.outline,
      focusBorder: scheme.primary,
      errorBorder: scheme.error,
      disabledBackground: scheme.onSurface.withOpacity(0.04),
      disabledText: scheme.onSurface.withOpacity(0.38),
      cursor: scheme.primary,
      radius: 12,
      borderWidth: 1,
    );
  }

  @override
  FladInputTheme copyWith({
    Color? background,
    Color? text,
    Color? placeholder,
    Color? label,
    Color? helper,
    Color? border,
    Color? focusBorder,
    Color? errorBorder,
    Color? disabledBackground,
    Color? disabledText,
    Color? cursor,
    double? radius,
    double? borderWidth,
  }) {
    return FladInputTheme(
      background: background ?? this.background,
      text: text ?? this.text,
      placeholder: placeholder ?? this.placeholder,
      label: label ?? this.label,
      helper: helper ?? this.helper,
      border: border ?? this.border,
      focusBorder: focusBorder ?? this.focusBorder,
      errorBorder: errorBorder ?? this.errorBorder,
      disabledBackground: disabledBackground ?? this.disabledBackground,
      disabledText: disabledText ?? this.disabledText,
      cursor: cursor ?? this.cursor,
      radius: radius ?? this.radius,
      borderWidth: borderWidth ?? this.borderWidth,
    );
  }

  @override
  FladInputTheme lerp(ThemeExtension<FladInputTheme>? other, double t) {
    if (other is! FladInputTheme) return this;
    return FladInputTheme(
      background: Color.lerp(background, other.background, t)!,
      text: Color.lerp(text, other.text, t)!,
      placeholder: Color.lerp(placeholder, other.placeholder, t)!,
      label: Color.lerp(label, other.label, t)!,
      helper: Color.lerp(helper, other.helper, t)!,
      border: Color.lerp(border, other.border, t)!,
      focusBorder: Color.lerp(focusBorder, other.focusBorder, t)!,
      errorBorder: Color.lerp(errorBorder, other.errorBorder, t)!,
      disabledBackground:
          Color.lerp(disabledBackground, other.disabledBackground, t)!,
      disabledText: Color.lerp(disabledText, other.disabledText, t)!,
      cursor: Color.lerp(cursor, other.cursor, t)!,
      radius: radius + (other.radius - radius) * t,
      borderWidth: borderWidth + (other.borderWidth - borderWidth) * t,
    );
  }
}

class FladInput extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final bool enabled;
  final bool obscureText;
  final int maxLines;
  final int? minLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final Widget? prefix;
  final Widget? suffix;
  final FladInputSize size;

  const FladInput({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.prefix,
    this.suffix,
    this.size = FladInputSize.md,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladInputTheme>() ??
        FladInputTheme.fromScheme(theme.colorScheme);
    final sizing = _FladInputSizing.from(size);

    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(tokens.radius),
      borderSide: BorderSide(color: tokens.border, width: tokens.borderWidth),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(tokens.radius),
      borderSide:
          BorderSide(color: tokens.focusBorder, width: tokens.borderWidth),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(tokens.radius),
      borderSide:
          BorderSide(color: tokens.errorBorder, width: tokens.borderWidth),
    );

    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      obscureText: obscureText,
      maxLines: maxLines,
      minLines: minLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      cursorColor: tokens.cursor,
      style: TextStyle(
        color: enabled ? tokens.text : tokens.disabledText,
        fontSize: sizing.fontSize,
        height: 1.2,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: tokens.label),
        hintText: hint,
        hintStyle: TextStyle(color: tokens.placeholder),
        helperText: helperText,
        helperStyle: TextStyle(color: tokens.helper),
        errorText: errorText,
        filled: true,
        fillColor: enabled ? tokens.background : tokens.disabledBackground,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          vertical: sizing.verticalPadding,
          horizontal: sizing.horizontalPadding,
        ),
        prefixIcon: prefix == null
            ? null
            : Padding(
                padding: EdgeInsets.only(left: sizing.iconPadding),
                child: IconTheme(
                  data: IconThemeData(color: tokens.placeholder, size: sizing.iconSize),
                  child: prefix!,
                ),
              ),
        prefixIconConstraints: BoxConstraints(
          minWidth: sizing.iconSize + sizing.iconPadding * 2,
          minHeight: sizing.iconSize,
        ),
        suffixIcon: suffix == null
            ? null
            : Padding(
                padding: EdgeInsets.only(right: sizing.iconPadding),
                child: IconTheme(
                  data: IconThemeData(color: tokens.placeholder, size: sizing.iconSize),
                  child: suffix!,
                ),
              ),
        suffixIconConstraints: BoxConstraints(
          minWidth: sizing.iconSize + sizing.iconPadding * 2,
          minHeight: sizing.iconSize,
        ),
        enabledBorder: baseBorder,
        disabledBorder: baseBorder,
        focusedBorder: focusedBorder,
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder,
      ),
    );
  }
}

class _FladInputSizing {
  final double fontSize;
  final double verticalPadding;
  final double horizontalPadding;
  final double iconSize;
  final double iconPadding;

  const _FladInputSizing({
    required this.fontSize,
    required this.verticalPadding,
    required this.horizontalPadding,
    required this.iconSize,
    required this.iconPadding,
  });

  factory _FladInputSizing.from(FladInputSize size) {
    switch (size) {
      case FladInputSize.sm:
        return const _FladInputSizing(
          fontSize: 12,
          verticalPadding: 10,
          horizontalPadding: 12,
          iconSize: 16,
          iconPadding: 8,
        );
      case FladInputSize.md:
        return const _FladInputSizing(
          fontSize: 14,
          verticalPadding: 12,
          horizontalPadding: 14,
          iconSize: 18,
          iconPadding: 10,
        );
      case FladInputSize.lg:
        return const _FladInputSizing(
          fontSize: 16,
          verticalPadding: 14,
          horizontalPadding: 16,
          iconSize: 20,
          iconPadding: 12,
        );
    }
  }
}
''';
