import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;

import 'config.dart';
import 'constants.dart';
import 'project.dart';
import 'templates.dart';

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
        await _init(overridePath);
        break;
      case 'add':
        if (command['help'] as bool) {
          _printAddUsage(parser);
          return;
        }
        final addAll = command['all'] as bool;
        final dryRun = command['dry-run'] as bool;
        final components = command.rest
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toList();

        if (!addAll && components.isEmpty) {
          _printError('Missing component name(s).');
          _printAddUsage(parser);
          exitCode = 64;
          return;
        }

        if (addAll && components.isNotEmpty) {
          _printError('Do not pass component names with --all.');
          exitCode = 64;
          return;
        }

        final overridePath = (command['path'] as String?)?.trim();
        if (addAll) {
          await _addAll(overridePath, dryRun: dryRun);
        } else {
          await _addMany(components, overridePath, dryRun: dryRun);
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
      case 'config':
        if (command['help'] as bool) {
          _printConfigUsage(parser);
          return;
        }
        final setPath = (command['set'] as String?)?.trim();
        final reset = command['reset'] as bool;
        await _config(setPath, reset: reset);
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
    stdout.writeln('  flad list');
    stdout.writeln('  flad config [--set <dir> | --reset]');
    stdout.writeln('  flad doctor');
    stdout.writeln('');
    stdout.writeln(_style('Examples:', [1]));
    stdout.writeln('  flad init');
    stdout.writeln('  flad add button');
    stdout.writeln('  flad add button card input');
    stdout.writeln('  flad add input --path lib/shared/ui');
    stdout.writeln('  flad add --all');
    stdout.writeln('  flad list');
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

  Future<void> _init(String? overridePath) async {
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

    await _ensureDirectory(targetDir);

    await writeConfig(FladConfig(targetDir: targetDir));
    _printSuccess('Init complete. Target: $targetDir');
    _printInfo('Saved config: ${configPath()}');
    _printSuccess('All set. Happy hacking!');
  }

  Future<void> _add(
    String component,
    String? overridePath, {
    bool dryRun = false,
  }) async {
    await _addMany([component], overridePath, dryRun: dryRun);
  }

  Future<void> _addMany(
    List<String> components,
    String? overridePath, {
    bool dryRun = false,
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

    var added = 0;
    var skipped = 0;
    var unknown = 0;

    final seen = <String>{};
    for (final component in components) {
      if (!seen.add(component)) {
        _printWarn('Duplicate component ignored: $component');
        continue;
      }
      final result = await _writeComponent(
        component,
        targetDir,
        dryRun: dryRun,
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
        _printWarn('Skipped $skipped existing file(s).');
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

  Future<void> _addAll(
    String? overridePath, {
    bool dryRun = false,
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
    for (final key in keys) {
      final desc = componentDescriptions[key];
      if (desc == null) {
        stdout.writeln('  - $key');
      } else {
        stdout.writeln('  - $key: $desc');
      }
    }
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

  Future<_AddResult> _writeComponent(
    String component,
    String targetDir, {
    bool dryRun = false,
  }) async {
    final template = componentTemplates[component];
    if (template == null) {
      return _AddResult.unknown;
    }

    final outputPath = p.join(targetDir, '$component.dart');
    final outputFile = File(outputPath);
    if (await outputFile.exists()) {
      _printWarn('Exists: ${p.normalize(outputFile.path)}');
      return _AddResult.exists;
    }

    if (dryRun) {
      _printInfo('Would add: ${p.normalize(outputFile.path)}');
      return _AddResult.dryRun;
    }

    await outputFile.writeAsString(template);
    _printSuccess('Added: ${p.normalize(outputFile.path)}');
    return _AddResult.added;
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
}

enum _AddResult { added, exists, unknown, dryRun }
