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
        await _init();
        break;
      case 'add':
        if (command['help'] as bool) {
          _printAddUsage(parser);
          return;
        }
        final component = command.rest.isEmpty ? null : command.rest.first.trim();
        if (component == null || component.isEmpty) {
          _printError('Missing component name.');
          _printAddUsage(parser);
          exitCode = 64;
          return;
        }
        final overridePath = (command['path'] as String?)?.trim();
        await _add(component, overridePath);
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
      ..addCommand('init')
      ..addCommand(
        'add',
        ArgParser()
          ..addOption(
            'path',
            abbr: 'p',
            help: 'Target directory for the component (overrides init config).',
          )
          ..addFlag(
            'help',
            abbr: 'h',
            negatable: false,
            help: 'Show help for the add command.',
          ),
      );
  }

  void _printUsage(ArgParser parser) {
    stdout.writeln(_style('flad - Flutter UI component copier', [1, 36]));
    stdout.writeln('');
    stdout.writeln(_style('Usage:', [1]));
    stdout.writeln('  flad init');
    stdout.writeln('  flad add <component> [--path <dir>]');
    stdout.writeln('');
    stdout.writeln(_style('Examples:', [1]));
    stdout.writeln('  flad init');
    stdout.writeln('  flad add button');
    stdout.writeln('  flad add input --path lib/shared/ui');
    stdout.writeln('');
    stdout.writeln(_style('Options:', [1]));
    stdout.writeln(parser.usage);
  }

  void _printAddUsage(ArgParser parser) {
    stdout.writeln(_style('Usage:', [1]));
    stdout.writeln('  flad add <component> [--path <dir>]');
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

  Future<void> _init() async {
    final ok = await ensureFlutterProject(onError: _printError);
    if (!ok) {
      exitCode = 1;
      return;
    }

    final targetDir = _promptForTargetDir();
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

  Future<void> _add(String component, String? overridePath) async {
    final ok = await ensureFlutterProject(onError: _printError);
    if (!ok) {
      exitCode = 1;
      return;
    }

    final template = componentTemplates[component];
    if (template == null) {
      _printError('Unknown component: $component');
      _printInfo('Available components: ${componentTemplates.keys.join(', ')}');
      exitCode = 64;
      return;
    }

    final targetDir = await _resolveTargetDir(overridePath);
    if (targetDir == null) {
      exitCode = 1;
      return;
    }

    await _ensureDirectory(targetDir);

    final outputPath = p.join(targetDir, '$component.dart');
    final outputFile = File(outputPath);
    if (await outputFile.exists()) {
      _printError('File already exists: ${p.normalize(outputFile.path)}');
      exitCode = 1;
      return;
    }

    await outputFile.writeAsString(template);
    _printSuccess('Added component: $component');
    _printInfo('Path: ${p.normalize(outputFile.path)}');
    _printSuccess('Ready to ship. Happy hacking!');
  }

  String _promptForTargetDir() {
    stdout.write(_style('Target directory [$defaultTargetDir]: ', [36]));
    final input = stdin.readLineSync();
    final trimmed = input?.trim() ?? '';
    return trimmed.isEmpty ? defaultTargetDir : trimmed;
  }

  Future<void> _ensureDirectory(String path) async {
    final resolvedDir = p.normalize(path);
    final dir = Directory(resolvedDir);
    if (await dir.exists()) {
      _printInfo('Using existing directory: ${dir.path}');
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
}
