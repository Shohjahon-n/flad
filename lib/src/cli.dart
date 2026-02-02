import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;

import 'config.dart';
import 'constants.dart';
import 'project.dart';
import 'registry.dart';
import 'templates.dart';
import 'templates/theme.dart' as theme_tpl;

/// CLI runner for flad commands.
class FladCli {
  static const _brand = 'flad';

  Future<void> run(List<String> arguments) async {
    final parser = _buildParser();

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
        if (command['help'] as bool) {
          _printInitUsage(parser);
          return;
        }
        final overridePath = (command['path'] as String?)?.trim();
        final style = (command['style'] as String?)?.trim();
        await _init(overridePath, style: style);
        break;
      case 'add':
        if (command['help'] as bool) {
          _printAddUsage(parser);
          return;
        }
        final addAll = command['all'] as bool;
        final dryRun = command['dry-run'] as bool;
        final overwrite = command['overwrite'] as bool;
        final useRegistry = command['registry'] as bool;
        var components = command.rest
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toList();

        if (!addAll && components.isEmpty) {
          final selected = _interactiveSelect();
          if (selected.isEmpty) {
            _printWarn('No components selected.');
            return;
          }
          components = selected;
        }

        if (addAll && components.isNotEmpty) {
          _printError('Do not pass component names with --all.');
          exitCode = 64;
          return;
        }

        final overridePath = (command['path'] as String?)?.trim();
        if (addAll) {
          await _addAll(overridePath, dryRun: dryRun, overwrite: overwrite);
        } else if (useRegistry) {
          await _addFromRegistry(components, overridePath,
              dryRun: dryRun, overwrite: overwrite);
        } else {
          await _addMany(components, overridePath,
              dryRun: dryRun, overwrite: overwrite);
        }
        break;
      case 'list':
        if (command['help'] as bool? ?? false) {
          _printListUsage(parser);
          return;
        }
        final asJson = command['json'] as bool? ?? false;
        final plain = command['plain'] as bool? ?? false;
        if (asJson && plain) {
          _printError('Use either --json or --plain, not both.');
          exitCode = 64;
          return;
        }
        _listComponents(asJson: asJson, plain: plain);
        break;
      case 'preview':
        if (command['help'] as bool? ?? false) {
          _printPreviewUsage(parser);
          return;
        }
        final component =
            command.rest.isEmpty ? null : command.rest.first.trim();
        if (component == null || component.isEmpty) {
          _printError('Missing component name.');
          _printPreviewUsage(parser);
          exitCode = 64;
          return;
        }
        final overridePath = (command['path'] as String?)?.trim();
        await _preview(component, overridePath);
        break;
      case 'config':
        if (command['help'] as bool) {
          _printConfigUsage(parser);
          return;
        }
        final setPath = (command['set'] as String?)?.trim();
        final reset = command['reset'] as bool;
        await _config(setPath, reset: reset);
        break;
      case 'diff':
        if (command['help'] as bool) {
          _printDiffUsage(parser);
          return;
        }
        final diffComponent =
            command.rest.isEmpty ? null : command.rest.first.trim();
        if (diffComponent == null || diffComponent.isEmpty) {
          _printError('Missing component name.');
          _printDiffUsage(parser);
          exitCode = 64;
          return;
        }
        final diffOverridePath = (command['path'] as String?)?.trim();
        await _diff(diffComponent, diffOverridePath);
        break;
      case 'remove':
        if (command['help'] as bool) {
          _printRemoveUsage(parser);
          return;
        }
        final removeAll = command['all'] as bool;
        final removeComponents = command.rest
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toList();

        if (!removeAll && removeComponents.isEmpty) {
          _printError('Missing component name(s).');
          _printRemoveUsage(parser);
          exitCode = 64;
          return;
        }

        if (removeAll && removeComponents.isNotEmpty) {
          _printError('Do not pass component names with --all.');
          exitCode = 64;
          return;
        }

        final removeOverridePath = (command['path'] as String?)?.trim();
        if (removeAll) {
          await _removeAll(removeOverridePath);
        } else {
          await _removeMany(removeComponents, removeOverridePath);
        }
        break;
      case 'doctor':
        await _doctor();
        break;
      default:
        _printUsage(parser);
    }
  }

  ArgParser _buildParser() {
    return ArgParser()
      ..addFlag(
        'help',
        abbr: 'h',
        negatable: false,
        help: 'Show this help message.',
      )
      ..addCommand(
        'init',
        ArgParser()
          ..addOption(
            'path',
            abbr: 'p',
            help: 'Target directory to save in config (skips prompt).',
          )
          ..addOption(
            'style',
            abbr: 's',
            help: 'Design style preset (${theme_tpl.themeStyles.join(', ')}).',
            allowed: theme_tpl.themeStyles,
          )
          ..addFlag(
            'help',
            abbr: 'h',
            negatable: false,
            help: 'Show help for the init command.',
          ),
      )
      ..addCommand(
        'add',
        ArgParser()
          ..addOption(
            'path',
            abbr: 'p',
            help: 'Target directory for the component (overrides init config).',
          )
          ..addFlag(
            'all',
            negatable: false,
            help: 'Add all components.',
          )
          ..addFlag(
            'dry-run',
            negatable: false,
            help: 'Preview file writes without changes.',
          )
          ..addFlag(
            'overwrite',
            abbr: 'f',
            negatable: false,
            help: 'Overwrite existing component files.',
          )
          ..addFlag(
            'registry',
            abbr: 'r',
            negatable: false,
            help: 'Fetch components from the remote registry.',
          )
          ..addFlag(
            'help',
            abbr: 'h',
            negatable: false,
            help: 'Show help for the add command.',
          ),
      )
      ..addCommand(
        'list',
        ArgParser()
          ..addFlag(
            'json',
            abbr: 'j',
            negatable: false,
            help: 'Output list as JSON.',
          )
          ..addFlag(
            'plain',
            negatable: false,
            help: 'Output only component names.',
          )
          ..addFlag(
            'help',
            abbr: 'h',
            negatable: false,
            help: 'Show help for the list command.',
          ),
      )
      ..addCommand(
        'preview',
        ArgParser()
          ..addOption(
            'path',
            abbr: 'p',
            help: 'Target directory hint for the output file.',
          )
          ..addFlag(
            'help',
            abbr: 'h',
            negatable: false,
            help: 'Show help for the preview command.',
          ),
      )
      ..addCommand(
        'config',
        ArgParser()
          ..addOption(
            'set',
            abbr: 's',
            help: 'Set the default target directory.',
          )
          ..addFlag(
            'reset',
            negatable: false,
            help: 'Remove the saved config file.',
          )
          ..addFlag(
            'help',
            abbr: 'h',
            negatable: false,
            help: 'Show help for the config command.',
          ),
      )
      ..addCommand(
        'diff',
        ArgParser()
          ..addOption(
            'path',
            abbr: 'p',
            help: 'Target directory to check against.',
          )
          ..addFlag(
            'help',
            abbr: 'h',
            negatable: false,
            help: 'Show help for the diff command.',
          ),
      )
      ..addCommand(
        'remove',
        ArgParser()
          ..addOption(
            'path',
            abbr: 'p',
            help: 'Target directory to remove from (overrides init config).',
          )
          ..addFlag(
            'all',
            negatable: false,
            help: 'Remove all previously added components.',
          )
          ..addFlag(
            'help',
            abbr: 'h',
            negatable: false,
            help: 'Show help for the remove command.',
          ),
      )
      ..addCommand('doctor');
  }

  void _printUsage(ArgParser parser) {
    stdout.writeln(_style('flad - Flutter UI component copier', [1, 36]));
    stdout.writeln('');
    stdout.writeln(_style('Usage:', [1]));
    stdout.writeln('  flad init');
    stdout.writeln('  flad add <component> [--path <dir>]');
    stdout.writeln('  flad add <component> <component> [--path <dir>]');
    stdout.writeln('  flad add --all [--path <dir>]');
    stdout.writeln('  flad diff <component> [--path <dir>]');
    stdout.writeln('  flad remove <component> [--path <dir>]');
    stdout.writeln('  flad remove --all [--path <dir>]');
    stdout.writeln('  flad list');
    stdout.writeln('  flad preview <component>');
    stdout.writeln('  flad config [--set <dir> | --reset]');
    stdout.writeln('  flad doctor');
    stdout.writeln('');
    stdout.writeln(_style('Examples:', [1]));
    stdout.writeln('  flad init');
    stdout.writeln('  flad add button');
    stdout.writeln('  flad add button card input');
    stdout.writeln('  flad add input --path lib/shared/ui');
    stdout.writeln('  flad add --all');
    stdout.writeln('  flad add button --overwrite');
    stdout.writeln('  flad add button --registry');
    stdout.writeln('  flad diff button');
    stdout.writeln('  flad remove button');
    stdout.writeln('  flad remove --all');
    stdout.writeln('  flad list');
    stdout.writeln('  flad preview button');
    stdout.writeln('');
    stdout.writeln(_style('Options:', [1]));
    stdout.writeln(parser.usage);
  }

  void _printInitUsage(ArgParser parser) {
    stdout.writeln(_style('Usage:', [1]));
    stdout.writeln('  flad init [--path <dir>]');
    stdout.writeln('');
    stdout.writeln(_style('Options:', [1]));
    final initCommand = parser.commands['init'];
    if (initCommand != null) {
      stdout.writeln(initCommand.usage);
    }
  }

  void _printAddUsage(ArgParser parser) {
    stdout.writeln(_style('Usage:', [1]));
    stdout.writeln('  flad add <component> [--path <dir>]');
    stdout.writeln('  flad add <component> <component> [--path <dir>]');
    stdout.writeln('  flad add --all [--path <dir>]');
    stdout.writeln('');
    stdout.writeln(_style('Options:', [1]));
    final addCommand = parser.commands['add'];
    if (addCommand != null) {
      stdout.writeln(addCommand.usage);
    }
    _printInfo(
      'Available components: ${componentTemplates.keys.join(', ')}',
    );
  }

  void _printConfigUsage(ArgParser parser) {
    stdout.writeln(_style('Usage:', [1]));
    stdout.writeln('  flad config');
    stdout.writeln('  flad config --set <dir>');
    stdout.writeln('  flad config --reset');
    stdout.writeln('');
    stdout.writeln(_style('Options:', [1]));
    final configCommand = parser.commands['config'];
    if (configCommand != null) {
      stdout.writeln(configCommand.usage);
    }
  }

  void _printListUsage(ArgParser parser) {
    stdout.writeln(_style('Usage:', [1]));
    stdout.writeln('  flad list');
    stdout.writeln('  flad list --plain');
    stdout.writeln('  flad list --json');
    stdout.writeln('');
    stdout.writeln(_style('Options:', [1]));
    final listCommand = parser.commands['list'];
    if (listCommand != null) {
      stdout.writeln(listCommand.usage);
    }
  }

  void _printPreviewUsage(ArgParser parser) {
    stdout.writeln(_style('Usage:', [1]));
    stdout.writeln('  flad preview <component>');
    stdout.writeln('  flad preview <component> --path <dir>');
    stdout.writeln('');
    stdout.writeln(_style('Options:', [1]));
    final previewCommand = parser.commands['preview'];
    if (previewCommand != null) {
      stdout.writeln(previewCommand.usage);
    }
  }

  void _printError(String message) {
    stderr.writeln(_style('[$_brand] $message', [31], isStderr: true));
  }

  void _printInfo(String message) {
    stdout.writeln(_style('[$_brand] $message', [36]));
  }

  void _printSuccess(String message) {
    stdout.writeln(_style('[$_brand] $message', [32]));
  }

  void _printWarn(String message) {
    stdout.writeln(_style('[$_brand] $message', [33]));
  }

  String _style(String text, List<int> codes, {bool isStderr = false}) {
    final useColor =
        isStderr ? stderr.supportsAnsiEscapes : stdout.supportsAnsiEscapes;
    if (!useColor) {
      return text;
    }
    final sequence = codes.join(';');
    return '\x1B[${sequence}m$text\x1B[0m';
  }

  Future<void> _init(String? overridePath, {String? style}) async {
    final ok = await ensureFlutterProject(onError: _printError);
    if (!ok) {
      exitCode = 1;
      return;
    }

    final targetDir = (overridePath != null && overridePath.trim().isNotEmpty)
        ? overridePath.trim()
        : _promptForTargetDir();
    if (targetDir.trim().isEmpty) {
      _printError('Target path cannot be empty.');
      exitCode = 64;
      return;
    }

    final chosenStyle =
        (style != null && style.isNotEmpty) ? style : _promptForStyle();

    await _ensureDirectory(targetDir);

    // Generate theme file.
    final themeFile = File(p.join(targetDir, 'theme.dart'));
    if (await themeFile.exists()) {
      _printWarn('Theme file already exists: ${p.normalize(themeFile.path)}');
    } else {
      await themeFile.writeAsString(theme_tpl.themeTemplate(chosenStyle));
      _printSuccess(
          'Generated theme: ${p.normalize(themeFile.path)} ($chosenStyle)');
    }

    await writeConfig(FladConfig(targetDir: targetDir, style: chosenStyle));
    _printSuccess('Init complete. Target: $targetDir');
    _printInfo('Saved config: ${configPath()}');
    _printSuccess('All set. Happy hacking!');
  }

  List<String> _interactiveSelect() {
    stdout.writeln(
        _style('Select components to add (comma-separated numbers):', [36]));
    stdout.writeln('');

    var index = 1;
    for (final entry in componentCategories.entries) {
      stdout.writeln(_style('  ${entry.key}', [1]));
      final sorted = entry.value.toList()..sort();
      for (final name in sorted) {
        final desc = componentDescriptions[name] ?? '';
        final num = '$index'.padLeft(2);
        stdout.writeln('    $num. $name  ${_style(desc, [90])}');
        index++;
      }
      stdout.writeln('');
    }

    stdout.write(_style('Components (e.g. 1,3,5 or 1-5): ', [36]));
    final input = stdin.readLineSync()?.trim() ?? '';
    if (input.isEmpty) return [];

    // Build ordered flat list matching displayed order.
    final ordered = <String>[];
    for (final entry in componentCategories.entries) {
      final sorted = entry.value.toList()..sort();
      ordered.addAll(sorted);
    }

    final selected = <String>{};
    final parts = input.split(RegExp(r'[,\s]+'));
    for (final part in parts) {
      if (part.contains('-')) {
        final range = part.split('-');
        final start = int.tryParse(range.first.trim());
        final end = int.tryParse(range.last.trim());
        if (start != null && end != null) {
          for (var i = start; i <= end && i <= ordered.length; i++) {
            if (i >= 1) selected.add(ordered[i - 1]);
          }
        }
      } else {
        final num = int.tryParse(part.trim());
        if (num != null && num >= 1 && num <= ordered.length) {
          selected.add(ordered[num - 1]);
        }
      }
    }

    return selected.toList();
  }

  String _promptForStyle() {
    final styles = theme_tpl.themeStyles;
    stdout.writeln(_style('Choose a style:', [36]));
    for (var i = 0; i < styles.length; i++) {
      final label = i == 0 ? '${styles[i]} (default)' : styles[i];
      stdout.writeln('  ${i + 1}. $label');
    }
    stdout.write(_style('Style [1]: ', [36]));
    final input = stdin.readLineSync()?.trim() ?? '';
    if (input.isEmpty) return styles.first;
    final index = int.tryParse(input);
    if (index != null && index >= 1 && index <= styles.length) {
      return styles[index - 1];
    }
    // Try by name.
    if (styles.contains(input)) return input;
    _printWarn('Unknown style "$input", using default.');
    return styles.first;
  }

  Future<void> _addMany(
    List<String> components,
    String? overridePath, {
    bool dryRun = false,
    bool overwrite = false,
  }) async {
    final ok = await ensureFlutterProject(onError: _printError);
    if (!ok) {
      exitCode = 1;
      return;
    }

    final targetDir = await _resolveTargetDir(overridePath);
    if (targetDir == null) {
      exitCode = 1;
      return;
    }

    await _ensureDirectory(targetDir, dryRun: dryRun);

    // Resolve dependencies.
    final expanded = _expandDependencies(components);
    if (expanded.length > components.length) {
      final deps = expanded.where((c) => !components.contains(c)).toList();
      _printInfo('Including dependencies: ${deps.join(', ')}');
    }

    var added = 0;
    var skipped = 0;
    var unknown = 0;

    final seen = <String>{};
    for (final component in expanded) {
      if (!seen.add(component)) {
        _printWarn('Duplicate component ignored: $component');
        continue;
      }
      final result = await _writeComponent(
        component,
        targetDir,
        dryRun: dryRun,
        overwrite: overwrite,
      );
      if (result == _AddResult.unknown) {
        unknown++;
        _printError('Unknown component: $component');
        final suggestions = _suggestComponents(component);
        if (suggestions.isNotEmpty) {
          _printInfo('Did you mean: ${suggestions.join(', ')}');
        } else {
          _printInfo(
            'Available components: ${componentTemplates.keys.join(', ')}',
          );
        }
        continue;
      }
      if (result == _AddResult.exists) {
        skipped++;
        continue;
      }
      if (result == _AddResult.added || result == _AddResult.dryRun) {
        added++;
      }
    }

    if (components.length > 1 || unknown > 0 || skipped > 0) {
      final verb = dryRun ? 'Would add' : 'Added';
      _printSuccess('$verb $added component(s).');
      if (skipped > 0) {
        _printWarn(
            'Skipped $skipped existing file(s). Use --overwrite to replace.');
      }
      if (unknown > 0) {
        _printWarn('Unknown $unknown component(s).');
        exitCode = 64;
        return;
      }
    }

    if (skipped > 0) {
      exitCode = 1;
      return;
    }

    if (!dryRun) {
      _printSuccess('Ready to ship. Happy hacking!');
    }
  }

  Future<void> _addFromRegistry(
    List<String> components,
    String? overridePath, {
    bool dryRun = false,
    bool overwrite = false,
  }) async {
    final ok = await ensureFlutterProject(onError: _printError);
    if (!ok) {
      exitCode = 1;
      return;
    }

    final targetDir = await _resolveTargetDir(overridePath);
    if (targetDir == null) {
      exitCode = 1;
      return;
    }

    _printInfo('Fetching registry index...');
    final index = await fetchRegistryIndex();
    if (index == null) {
      _printError('Failed to fetch registry. Check your connection.');
      exitCode = 1;
      return;
    }

    _printSuccess('Registry loaded (${index.components.length} components).');
    await _ensureDirectory(targetDir, dryRun: dryRun);

    var added = 0;
    var skipped = 0;

    // Resolve dependencies from registry.
    final allComponents = <String>[];
    final seen = <String>{};
    void resolve(String name) {
      if (seen.contains(name)) return;
      seen.add(name);
      final entry = index.components[name];
      if (entry != null) {
        for (final dep in entry.dependencies) {
          resolve(dep);
        }
      }
      allComponents.add(name);
    }

    for (final c in components) {
      resolve(c);
    }

    if (allComponents.length > components.length) {
      final deps = allComponents.where((c) => !components.contains(c)).toList();
      _printInfo('Including dependencies: ${deps.join(', ')}');
    }

    for (final component in allComponents) {
      final entry = index.components[component];
      if (entry == null) {
        _printError('Component not found in registry: $component');
        // Fall back to bundled template.
        final result = await _writeComponent(
          component,
          targetDir,
          dryRun: dryRun,
          overwrite: overwrite,
        );
        if (result == _AddResult.added || result == _AddResult.dryRun) added++;
        if (result == _AddResult.exists) skipped++;
        continue;
      }

      final outputPath = p.join(targetDir, '$component.dart');
      final outputFile = File(outputPath);
      final exists = await outputFile.exists();
      if (exists && !overwrite) {
        _printWarn('Exists: ${p.normalize(outputPath)}');
        skipped++;
        continue;
      }

      if (dryRun) {
        final verb = exists ? 'Would overwrite' : 'Would add';
        _printInfo('$verb: ${p.normalize(outputPath)}');
        added++;
        continue;
      }

      _printInfo('Fetching $component...');
      final source = await fetchComponent(entry.fileUrl);
      if (source == null) {
        _printError('Failed to fetch $component. Using bundled version.');
        final result = await _writeComponent(
          component,
          targetDir,
          dryRun: dryRun,
          overwrite: overwrite,
        );
        if (result == _AddResult.added) added++;
        if (result == _AddResult.exists) skipped++;
        continue;
      }

      await outputFile.writeAsString(source);
      final verb = exists ? 'Overwritten' : 'Added';
      _printSuccess('$verb: ${p.normalize(outputPath)}');
      added++;
    }

    _printSuccess('Added $added component(s) from registry.');
    if (skipped > 0) {
      _printWarn(
          'Skipped $skipped existing file(s). Use --overwrite to replace.');
    }
  }

  Future<void> _preview(String component, String? overridePath) async {
    final template = componentTemplates[component];
    if (template == null) {
      _printError('Unknown component: $component');
      final suggestions = _suggestComponents(component);
      if (suggestions.isNotEmpty) {
        _printInfo('Did you mean: ${suggestions.join(', ')}');
      } else {
        _printInfo(
            'Available components: ${componentTemplates.keys.join(', ')}');
      }
      exitCode = 64;
      return;
    }

    final description = componentDescriptions[component] ?? 'No description.';
    final widgetName = _toPascalCase(component);
    final targetDir = await _resolvePreviewTargetDir(overridePath);
    final outputPath = p.join(targetDir, '$component.dart');

    final deps = componentDependencies[component];

    _printInfo('Component: $component');
    _printInfo('Description: $description');
    _printInfo('Widget: Flad$widgetName');
    _printInfo('Output file: ${p.normalize(outputPath)}');
    if (deps != null && deps.isNotEmpty) {
      _printInfo('Dependencies: ${deps.join(', ')}');
    }
    stdout.writeln('');
    stdout.writeln('Example usage:');
    stdout.writeln('  Flad$widgetName(');
    stdout.writeln('    // ...');
    stdout.writeln('  );');
    stdout.writeln('');
    _printInfo('To add: flad add $component');
  }

  Future<void> _addAll(
    String? overridePath, {
    bool dryRun = false,
    bool overwrite = false,
  }) async {
    final ok = await ensureFlutterProject(onError: _printError);
    if (!ok) {
      exitCode = 1;
      return;
    }

    final targetDir = await _resolveTargetDir(overridePath);
    if (targetDir == null) {
      exitCode = 1;
      return;
    }

    await _ensureDirectory(targetDir, dryRun: dryRun);

    final components = componentTemplates.keys.toList()..sort();
    var added = 0;
    var skipped = 0;

    for (final component in components) {
      final result = await _writeComponent(
        component,
        targetDir,
        dryRun: dryRun,
        overwrite: overwrite,
      );
      if (result == _AddResult.added || result == _AddResult.dryRun) {
        added++;
      } else if (result == _AddResult.exists) {
        skipped++;
      }
    }

    final verb = dryRun ? 'Would add' : 'Added';
    _printSuccess('$verb $added component(s).');
    if (skipped > 0) {
      _printWarn('Skipped $skipped existing file(s).');
    }
  }

  void _listComponents({bool asJson = false, bool plain = false}) {
    final keys = componentTemplates.keys.toList()..sort();
    if (asJson) {
      final items = keys
          .map(
            (key) => {
              'name': key,
              'description': componentDescriptions[key] ?? '',
              'category': _categoryFor(key),
            },
          )
          .toList();
      const encoder = JsonEncoder.withIndent('  ');
      stdout.writeln(encoder.convert(items));
      return;
    }

    if (plain) {
      for (final key in keys) {
        stdout.writeln(key);
      }
      return;
    }

    _printInfo('Available components (${keys.length}):');
    stdout.writeln('');
    for (final entry in componentCategories.entries) {
      stdout.writeln(_style('  ${entry.key}', [1]));
      final sorted = entry.value.toList()..sort();
      for (final name in sorted) {
        final desc = componentDescriptions[name];
        if (desc == null) {
          stdout.writeln('    - $name');
        } else {
          stdout.writeln('    - $name: $desc');
        }
      }
      stdout.writeln('');
    }
  }

  /// Expands a list of components to include their dependencies (deps first).
  List<String> _expandDependencies(List<String> components) {
    final result = <String>[];
    final seen = <String>{};

    void visit(String component) {
      if (seen.contains(component)) return;
      seen.add(component);
      final deps = componentDependencies[component];
      if (deps != null) {
        for (final dep in deps) {
          visit(dep);
        }
      }
      result.add(component);
    }

    for (final component in components) {
      visit(component);
    }
    return result;
  }

  String _categoryFor(String component) {
    for (final entry in componentCategories.entries) {
      if (entry.value.contains(component)) {
        return entry.key;
      }
    }
    return 'Other';
  }

  Future<void> _config(String? setPath, {bool reset = false}) async {
    if (reset && setPath != null && setPath.isNotEmpty) {
      _printError('Use either --set or --reset, not both.');
      exitCode = 64;
      return;
    }

    if (reset) {
      final file = File(configPath());
      if (await file.exists()) {
        await file.delete();
        _printSuccess('Config removed: ${file.path}');
      } else {
        _printWarn('No config file found.');
      }
      return;
    }

    if (setPath != null && setPath.trim().isNotEmpty) {
      await _ensureDirectory(setPath);
      await writeConfig(FladConfig(targetDir: setPath.trim()));
      _printSuccess('Config updated: ${configPath()}');
      _printInfo('Target directory: ${setPath.trim()}');
      return;
    }

    try {
      final config = await readConfig();
      if (config == null) {
        _printWarn('No config found. Run "flad init".');
        return;
      }
      _printInfo('Target directory: ${config.targetDir}');
      _printInfo('Config path: ${configPath()}');
    } on FormatException catch (error) {
      _printError('Invalid $configFileName: ${error.message}');
      exitCode = 1;
    }
  }

  Future<void> _doctor() async {
    _printInfo('Running diagnostics...');
    final isFlutter = await ensureFlutterProject(onError: _printError);
    if (!isFlutter) {
      exitCode = 1;
      return;
    }

    try {
      final config = await readConfig();
      if (config == null) {
        _printWarn('Config not found. Run "flad init".');
      } else {
        _printSuccess('Config OK: ${config.targetDir}');
        final dir = Directory(config.targetDir);
        if (await dir.exists()) {
          _printSuccess('Target directory exists.');
        } else {
          _printWarn('Target directory missing.');
        }
      }
    } on FormatException catch (error) {
      _printError('Invalid $configFileName: ${error.message}');
      exitCode = 1;
      return;
    }

    _printSuccess('Doctor finished.');
  }

  String _promptForTargetDir() {
    stdout.write(_style('Target directory [$defaultTargetDir]: ', [36]));
    final input = stdin.readLineSync();
    final trimmed = input?.trim() ?? '';
    return trimmed.isEmpty ? defaultTargetDir : trimmed;
  }

  Future<void> _ensureDirectory(String path, {bool dryRun = false}) async {
    final resolvedDir = p.normalize(path);
    final dir = Directory(resolvedDir);
    if (await dir.exists()) {
      _printInfo('Using existing directory: ${dir.path}');
      return;
    }
    if (dryRun) {
      _printInfo('Would create directory: ${dir.path}');
      return;
    }
    await dir.create(recursive: true);
    _printSuccess('Created directory: ${dir.path}');
  }

  Future<String?> _resolveTargetDir(String? overridePath) async {
    if (overridePath != null && overridePath.trim().isNotEmpty) {
      return overridePath.trim();
    }

    try {
      final config = await readConfig();
      if (config != null) {
        return config.targetDir;
      }
    } on FormatException catch (error) {
      _printError('Invalid $configFileName: ${error.message}');
      _printWarn('Run "flad init" to recreate the config.');
      return null;
    }

    return defaultTargetDir;
  }

  Future<String> _resolvePreviewTargetDir(String? overridePath) async {
    if (overridePath != null && overridePath.trim().isNotEmpty) {
      return overridePath.trim();
    }
    try {
      final config = await readConfig();
      if (config != null) {
        return config.targetDir;
      }
    } on FormatException catch (error) {
      _printWarn('Invalid $configFileName: ${error.message}');
      _printWarn('Using default target directory.');
    }
    return defaultTargetDir;
  }

  Future<_AddResult> _writeComponent(
    String component,
    String targetDir, {
    bool dryRun = false,
    bool overwrite = false,
  }) async {
    final template = componentTemplates[component];
    if (template == null) {
      return _AddResult.unknown;
    }

    final outputPath = p.join(targetDir, '$component.dart');
    final outputFile = File(outputPath);
    final exists = await outputFile.exists();
    if (exists && !overwrite) {
      _printWarn('Exists: ${p.normalize(outputFile.path)}');
      return _AddResult.exists;
    }

    if (dryRun) {
      final verb = exists ? 'Would overwrite' : 'Would add';
      _printInfo('$verb: ${p.normalize(outputFile.path)}');
      return _AddResult.dryRun;
    }

    await outputFile.writeAsString(template);
    final verb = exists ? 'Overwritten' : 'Added';
    _printSuccess('$verb: ${p.normalize(outputFile.path)}');
    return _AddResult.added;
  }

  void _printDiffUsage(ArgParser parser) {
    stdout.writeln(_style('Usage:', [1]));
    stdout.writeln('  flad diff <component> [--path <dir>]');
    stdout.writeln('');
    stdout.writeln(_style('Options:', [1]));
    final diffCommand = parser.commands['diff'];
    if (diffCommand != null) {
      stdout.writeln(diffCommand.usage);
    }
  }

  Future<void> _diff(String component, String? overridePath) async {
    final ok = await ensureFlutterProject(onError: _printError);
    if (!ok) {
      exitCode = 1;
      return;
    }

    final targetDir = await _resolveTargetDir(overridePath);
    if (targetDir == null) {
      exitCode = 1;
      return;
    }

    final template = componentTemplates[component];
    if (template == null) {
      _printError('Unknown component: $component');
      exitCode = 64;
      return;
    }

    final filePath = p.join(targetDir, '$component.dart');
    final file = File(filePath);
    if (!await file.exists()) {
      _printWarn('File not found: ${p.normalize(filePath)}');
      _printInfo('Run "flad add $component" first.');
      return;
    }

    final local = await file.readAsString();
    final bundled = template;

    if (local == bundled) {
      _printSuccess('$component is up to date (matches bundled version).');
      return;
    }

    _printWarn('$component has local modifications.');
    _printInfo('Local file: ${p.normalize(filePath)}');

    // Show simple line-count diff.
    final localLines = local.split('\n');
    final bundledLines = bundled.split('\n');
    _printInfo('Local: ${localLines.length} lines');
    _printInfo('Bundled: ${bundledLines.length} lines');

    // Show first few differing lines.
    var diffCount = 0;
    final maxDiffs = 10;
    final maxLen = localLines.length > bundledLines.length
        ? localLines.length
        : bundledLines.length;
    for (var i = 0; i < maxLen && diffCount < maxDiffs; i++) {
      final localLine = i < localLines.length ? localLines[i] : '';
      final bundledLine = i < bundledLines.length ? bundledLines[i] : '';
      if (localLine != bundledLine) {
        diffCount++;
        stdout.writeln(_style('  L${i + 1}:', [33]));
        if (bundledLine.isNotEmpty) {
          stdout.writeln(_style('    - $bundledLine', [31]));
        }
        if (localLine.isNotEmpty) {
          stdout.writeln(_style('    + $localLine', [32]));
        }
      }
    }

    final totalDiffs = _countDiffs(localLines, bundledLines);
    if (totalDiffs > maxDiffs) {
      _printInfo('... and ${totalDiffs - maxDiffs} more difference(s).');
    }

    _printInfo('To reset: flad add $component --overwrite');
  }

  int _countDiffs(List<String> a, List<String> b) {
    var count = 0;
    final maxLen = a.length > b.length ? a.length : b.length;
    for (var i = 0; i < maxLen; i++) {
      final aLine = i < a.length ? a[i] : '';
      final bLine = i < b.length ? b[i] : '';
      if (aLine != bLine) count++;
    }
    return count;
  }

  void _printRemoveUsage(ArgParser parser) {
    stdout.writeln(_style('Usage:', [1]));
    stdout.writeln('  flad remove <component> [--path <dir>]');
    stdout.writeln('  flad remove <component> <component> [--path <dir>]');
    stdout.writeln('  flad remove --all [--path <dir>]');
    stdout.writeln('');
    stdout.writeln(_style('Options:', [1]));
    final removeCommand = parser.commands['remove'];
    if (removeCommand != null) {
      stdout.writeln(removeCommand.usage);
    }
  }

  Future<void> _removeMany(
    List<String> components,
    String? overridePath,
  ) async {
    final ok = await ensureFlutterProject(onError: _printError);
    if (!ok) {
      exitCode = 1;
      return;
    }

    final targetDir = await _resolveTargetDir(overridePath);
    if (targetDir == null) {
      exitCode = 1;
      return;
    }

    var removed = 0;
    var notFound = 0;

    final seen = <String>{};
    for (final component in components) {
      if (!seen.add(component)) continue;

      if (!componentTemplates.containsKey(component)) {
        _printError('Unknown component: $component');
        final suggestions = _suggestComponents(component);
        if (suggestions.isNotEmpty) {
          _printInfo('Did you mean: ${suggestions.join(', ')}');
        }
        continue;
      }

      final filePath = p.join(targetDir, '$component.dart');
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        _printSuccess('Removed: ${p.normalize(filePath)}');
        removed++;
      } else {
        _printWarn('Not found: ${p.normalize(filePath)}');
        notFound++;
      }
    }

    if (components.length > 1) {
      _printSuccess('Removed $removed component(s).');
      if (notFound > 0) {
        _printWarn('$notFound file(s) not found.');
      }
    }
  }

  Future<void> _removeAll(String? overridePath) async {
    final ok = await ensureFlutterProject(onError: _printError);
    if (!ok) {
      exitCode = 1;
      return;
    }

    final targetDir = await _resolveTargetDir(overridePath);
    if (targetDir == null) {
      exitCode = 1;
      return;
    }

    var removed = 0;
    final components = componentTemplates.keys.toList()..sort();
    for (final component in components) {
      final filePath = p.join(targetDir, '$component.dart');
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        _printSuccess('Removed: ${p.normalize(filePath)}');
        removed++;
      }
    }

    if (removed == 0) {
      _printWarn('No component files found to remove.');
    } else {
      _printSuccess('Removed $removed component(s).');
    }
  }

  List<String> _suggestComponents(String input) {
    final normalized = input.trim().toLowerCase();
    if (normalized.isEmpty) {
      return const [];
    }

    final keys = componentTemplates.keys.toList();
    final scored = <String, int>{};
    for (final key in keys) {
      final distance = _editDistance(normalized, key.toLowerCase());
      scored[key] = distance;
    }

    final sorted = scored.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final threshold = normalized.length <= 4 ? 1 : 2;
    return sorted
        .where((entry) => entry.value <= threshold)
        .take(3)
        .map((entry) => entry.key)
        .toList();
  }

  int _editDistance(String a, String b) {
    if (a == b) {
      return 0;
    }
    if (a.isEmpty) {
      return b.length;
    }
    if (b.isEmpty) {
      return a.length;
    }

    final rows = List.generate(
      a.length + 1,
      (_) => List<int>.filled(b.length + 1, 0),
    );

    for (var i = 0; i <= a.length; i++) {
      rows[i][0] = i;
    }
    for (var j = 0; j <= b.length; j++) {
      rows[0][j] = j;
    }

    for (var i = 1; i <= a.length; i++) {
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        rows[i][j] = [
          rows[i - 1][j] + 1,
          rows[i][j - 1] + 1,
          rows[i - 1][j - 1] + cost,
        ].reduce((value, element) => value < element ? value : element);
      }
    }

    return rows[a.length][b.length];
  }

  String _toPascalCase(String value) {
    final parts =
        value.split(RegExp(r'[_\\s-]+')).where((part) => part.isNotEmpty);
    return parts
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join();
  }
}

enum _AddResult { added, exists, unknown, dryRun }
