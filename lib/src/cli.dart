import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;

import 'config.dart';
import 'constants.dart';
import 'project.dart';
import 'templates.dart';

class FladCli {
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
    stdout.writeln('flad - shadcn-style Flutter UI copier');
    stdout.writeln('');
    stdout.writeln('Usage:');
    stdout.writeln('  flad init');
    stdout.writeln('  flad add <component> [--path <dir>]');
    stdout.writeln('');
    stdout.writeln('Examples:');
    stdout.writeln('  flad init');
    stdout.writeln('  flad add button');
    stdout.writeln('  flad add input --path lib/shared/ui');
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
    stdout.writeln('Available components: ${componentTemplates.keys.join(', ')}');
  }

  void _printError(String message) {
    stderr.writeln('Error: $message');
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
    stdout.writeln('Saved config: ${configPath()}');
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
      stdout.writeln('Available components: ${componentTemplates.keys.join(', ')}');
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
    stdout.writeln('Added: ${p.normalize(outputFile.path)}');
  }

  String _promptForTargetDir() {
    stdout.write('Target directory [$defaultTargetDir]: ');
    final input = stdin.readLineSync();
    final trimmed = input?.trim() ?? '';
    return trimmed.isEmpty ? defaultTargetDir : trimmed;
  }

  Future<void> _ensureDirectory(String path) async {
    final resolvedDir = p.normalize(path);
    final dir = Directory(resolvedDir);
    if (await dir.exists()) {
      stdout.writeln('Using existing directory: ${dir.path}');
      return;
    }
    await dir.create(recursive: true);
    stdout.writeln('Created directory: ${dir.path}');
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
      return null;
    }

    return defaultTargetDir;
  }
}
