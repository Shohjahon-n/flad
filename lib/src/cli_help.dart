part of 'cli.dart';

// -- Help / usage printing --

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
