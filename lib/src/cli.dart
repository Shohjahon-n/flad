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

part 'cli_output.dart';
part 'cli_help.dart';
part 'cli_utils.dart';
part 'cli_init.dart';
part 'cli_add.dart';
part 'cli_list.dart';
part 'cli_preview.dart';
part 'cli_config.dart';
part 'cli_diff.dart';
part 'cli_remove.dart';
part 'cli_doctor.dart';

const _brand = 'flad';

/// CLI runner for flad commands.
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
            help:
                'Design style preset (${theme_tpl.themeStyles.join(', ')}).',
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
            help:
                'Target directory for the component (overrides init config).',
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
            help:
                'Target directory to remove from (overrides init config).',
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
}
