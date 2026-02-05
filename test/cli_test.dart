import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:flad_cli/src/cli.dart';
import 'package:flad_cli/src/templates.dart';

class _TestStdout implements Stdout {
  final StringBuffer _buffer = StringBuffer();

  @override
  Encoding encoding = utf8;

  @override
  bool get hasTerminal => false;

  @override
  bool get supportsAnsiEscapes => false;

  @override
  int get terminalColumns => 80;

  @override
  int get terminalLines => 24;

  @override
  IOSink get nonBlocking => this;

  @override
  String get lineTerminator => '\n';

  @override
  set lineTerminator(String lineTerminator) {}

  @override
  void add(List<int> data) {
    _buffer.write(encoding.decode(data));
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future addStream(Stream<List<int>> stream) async {
    await for (final chunk in stream) {
      add(chunk);
    }
  }

  @override
  Future close() async {}

  @override
  Future flush() async {}

  @override
  Future get done => Future.value();

  @override
  void write(Object? obj) {
    _buffer.write(obj ?? '');
  }

  @override
  void writeAll(Iterable objects, [String separator = '']) {
    _buffer.writeAll(objects, separator);
  }

  @override
  void writeCharCode(int charCode) {
    _buffer.writeCharCode(charCode);
  }

  @override
  void writeln([Object? obj = '']) {
    _buffer.writeln(obj ?? '');
  }

  @override
  String toString() => _buffer.toString();
}

class _TestStdin extends Stream<List<int>> implements Stdin {
  final List<String> _lines;
  int _index = 0;

  _TestStdin(String input)
      : _lines = input.isEmpty ? const [] : input.split('\n');

  bool _lineMode = true;
  bool _echoMode = false;
  bool _echoNewlineMode = false;

  @override
  bool get hasTerminal => false;

  @override
  bool get lineMode => _lineMode;

  @override
  set lineMode(bool lineMode) {
    _lineMode = lineMode;
  }

  @override
  bool get echoMode => _echoMode;

  @override
  set echoMode(bool echoMode) {
    _echoMode = echoMode;
  }

  @override
  bool get echoNewlineMode => _echoNewlineMode;

  @override
  set echoNewlineMode(bool enabled) {
    _echoNewlineMode = enabled;
  }

  @override
  bool get supportsAnsiEscapes => false;

  int get terminalColumns => 80;

  int get terminalLines => 24;

  @override
  int readByteSync() => -1;

  @override
  String? readLineSync({
    Encoding encoding = systemEncoding,
    bool retainNewlines = false,
  }) {
    if (_index >= _lines.length) return null;
    var line = _lines[_index++];
    if (retainNewlines) {
      line = '$line\n';
    }
    return line;
  }

  @override
  bool get isBroadcast => false;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final controller = StreamController<List<int>>();
    if (_lines.isNotEmpty) {
      controller.add(utf8.encode(_lines.join('\n')));
    }
    controller.close();
    return controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

class _CliResult {
  final String stdout;
  final String stderr;
  final int exitCode;

  const _CliResult({
    required this.stdout,
    required this.stderr,
    required this.exitCode,
  });
}

Future<_CliResult> _runCli(
  List<String> args, {
  required Directory workingDir,
  String? stdinInput,
}) async {
  final stdoutCapture = _TestStdout();
  final stderrCapture = _TestStdout();
  final stdinCapture = stdinInput == null ? null : _TestStdin(stdinInput);
  final previousDir = Directory.current;
  Directory.current = workingDir.path;
  exitCode = 0;

  try {
    await IOOverrides.runZoned(
      () async => FladCli().run(args),
      stdout: () => stdoutCapture,
      stderr: () => stderrCapture,
      stdin: stdinCapture == null ? null : () => stdinCapture,
    );
  } finally {
    Directory.current = previousDir;
  }

  return _CliResult(
    stdout: stdoutCapture.toString(),
    stderr: stderrCapture.toString(),
    exitCode: exitCode,
  );
}

void main() {
  // ── Existing tests ──

  test('adds multiple components in one command', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));
    await Directory(p.join(dir.path, 'lib')).create();

    final result = await _runCli(
      ['add', 'button', 'card', '--path', 'lib/ui'],
      workingDir: dir,
    );

    expect(result.exitCode, 0);
    expect(File(p.join(dir.path, 'lib/ui/button.dart')).existsSync(), isTrue);
    expect(File(p.join(dir.path, 'lib/ui/card.dart')).existsSync(), isTrue);
  });

  test('list outputs plain and json formats', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));

    final plain = await _runCli(['list', '--plain'], workingDir: dir);
    expect(plain.exitCode, 0);
    expect(plain.stdout.contains('button'), isTrue);

    final json = await _runCli(['list', '--json'], workingDir: dir);
    expect(json.exitCode, 0);
    final decoded = jsonDecode(json.stdout) as List<dynamic>;
    expect(decoded.any((item) => item['name'] == 'button'), isTrue);
  });

  test('unknown component suggests a close match', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));
    await Directory(p.join(dir.path, 'lib')).create();

    final result = await _runCli(['add', 'buton'], workingDir: dir);
    expect(result.exitCode, 64);
    expect(result.stdout.contains('Did you mean: button'), isTrue);
  });

  test('preview outputs component details', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));

    final result = await _runCli(['preview', 'button'], workingDir: dir);
    expect(result.exitCode, 0);
    expect(result.stdout.contains('Component: button'), isTrue);
    expect(result.stdout.contains('Widget: FladButton'), isTrue);
  });

  test('add does not overwrite existing files', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));
    await Directory(p.join(dir.path, 'lib')).create();
    await Directory(p.join(dir.path, 'lib/ui')).create(recursive: true);
    final file = File(p.join(dir.path, 'lib/ui/button.dart'));
    await file.writeAsString('// existing');

    final result = await _runCli(
      ['add', 'button', '--path', 'lib/ui'],
      workingDir: dir,
    );

    expect(result.exitCode, 1);
    expect(await file.readAsString(), '// existing');
  });

  test('add prompts for interactive selection', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));
    await Directory(p.join(dir.path, 'lib')).create();

    final ordered = <String>[];
    for (final entry in componentCategories.entries) {
      final sorted = entry.value.toList()..sort();
      ordered.addAll(sorted);
    }

    final buttonIndex = ordered.indexOf('button') + 1;
    final cardIndex = ordered.indexOf('card') + 1;
    expect(buttonIndex, greaterThan(0));
    expect(cardIndex, greaterThan(0));

    final result = await _runCli(
      ['add', '--path', 'lib/ui'],
      workingDir: dir,
      stdinInput: '$buttonIndex,$cardIndex',
    );

    expect(result.exitCode, 0);
    expect(File(p.join(dir.path, 'lib/ui/button.dart')).existsSync(), isTrue);
    expect(File(p.join(dir.path, 'lib/ui/card.dart')).existsSync(), isTrue);
  });

  // ── Overwrite flag tests ──

  test('add --overwrite replaces existing files', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));
    await Directory(p.join(dir.path, 'lib')).create();
    await Directory(p.join(dir.path, 'lib/ui')).create(recursive: true);
    final file = File(p.join(dir.path, 'lib/ui/button.dart'));
    await file.writeAsString('// old content');

    final result = await _runCli(
      ['add', 'button', '--path', 'lib/ui', '--overwrite'],
      workingDir: dir,
    );

    expect(result.exitCode, 0);
    final content = await file.readAsString();
    expect(content, isNot('// old content'));
    expect(content.contains('FladButton'), isTrue);
    expect(result.stdout.contains('Overwritten'), isTrue);
  });

  // ── Init style tests ──

  test('init --style generates theme and saves style', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));
    await Directory(p.join(dir.path, 'lib')).create();

    final result = await _runCli(
      ['init', '--path', 'lib/ui', '--style', 'soft'],
      workingDir: dir,
    );

    expect(result.exitCode, 0);
    final themeFile = File(p.join(dir.path, 'lib/ui/theme.dart'));
    expect(themeFile.existsSync(), isTrue);
    final content = await themeFile.readAsString();
    expect(content.contains('FladTheme'), isTrue);

    final configFile = File(p.join(dir.path, '.flad.json'));
    expect(configFile.existsSync(), isTrue);
    final json = jsonDecode(await configFile.readAsString());
    expect(json['style'], 'soft');
  });

  // ── Remove command tests ──

  test('remove deletes a component file', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));
    await Directory(p.join(dir.path, 'lib')).create();
    await Directory(p.join(dir.path, 'lib/ui')).create(recursive: true);
    final file = File(p.join(dir.path, 'lib/ui/button.dart'));
    await file.writeAsString('// button');

    final result = await _runCli(
      ['remove', 'button', '--path', 'lib/ui'],
      workingDir: dir,
    );

    expect(result.exitCode, 0);
    expect(file.existsSync(), isFalse);
    expect(result.stdout.contains('Removed'), isTrue);
  });

  test('remove warns when file not found', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));
    await Directory(p.join(dir.path, 'lib')).create();

    final result = await _runCli(
      ['remove', 'button', '--path', 'lib/ui'],
      workingDir: dir,
    );

    expect(result.exitCode, 0);
    expect(result.stdout.contains('Not found'), isTrue);
  });

  test('remove --all removes all component files', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));
    await Directory(p.join(dir.path, 'lib')).create();
    await Directory(p.join(dir.path, 'lib/ui')).create(recursive: true);
    await File(p.join(dir.path, 'lib/ui/button.dart'))
        .writeAsString('// button');
    await File(p.join(dir.path, 'lib/ui/card.dart')).writeAsString('// card');

    final result = await _runCli(
      ['remove', '--all', '--path', 'lib/ui'],
      workingDir: dir,
    );

    expect(result.exitCode, 0);
    expect(File(p.join(dir.path, 'lib/ui/button.dart')).existsSync(), isFalse);
    expect(File(p.join(dir.path, 'lib/ui/card.dart')).existsSync(), isFalse);
  });

  // ── Diff command tests ──

  test('diff shows up to date for unmodified component', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));
    await Directory(p.join(dir.path, 'lib')).create();

    // Add component first
    await _runCli(
      ['add', 'button', '--path', 'lib/ui'],
      workingDir: dir,
    );

    final result = await _runCli(
      ['diff', 'button', '--path', 'lib/ui'],
      workingDir: dir,
    );

    expect(result.exitCode, 0);
    expect(result.stdout.contains('up to date'), isTrue);
  });

  test('diff detects local modifications', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));
    await Directory(p.join(dir.path, 'lib')).create();
    await Directory(p.join(dir.path, 'lib/ui')).create(recursive: true);
    await File(p.join(dir.path, 'lib/ui/button.dart'))
        .writeAsString('// modified content');

    final result = await _runCli(
      ['diff', 'button', '--path', 'lib/ui'],
      workingDir: dir,
    );

    expect(result.exitCode, 0);
    expect(result.stdout.contains('local modifications'), isTrue);
  });

  test('diff warns when file not found', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));
    await Directory(p.join(dir.path, 'lib')).create();

    final result = await _runCli(
      ['diff', 'button', '--path', 'lib/ui'],
      workingDir: dir,
    );

    expect(result.exitCode, 0);
    expect(result.stdout.contains('not found'), isTrue);
  });

  // ── Categories tests ──

  test('list shows categories in default format', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));

    final result = await _runCli(['list'], workingDir: dir);

    expect(result.exitCode, 0);
    expect(result.stdout.contains('Inputs'), isTrue);
    expect(result.stdout.contains('Layout'), isTrue);
    expect(result.stdout.contains('Feedback'), isTrue);
    expect(result.stdout.contains('Display'), isTrue);
  });

  test('list --json includes category field', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));

    final result = await _runCli(['list', '--json'], workingDir: dir);

    expect(result.exitCode, 0);
    final decoded = jsonDecode(result.stdout) as List<dynamic>;
    final button = decoded.firstWhere((item) => item['name'] == 'button');
    expect(button['category'], isNotNull);
  });

  // ── Dependency resolution tests ──

  test('add resolves dependencies automatically', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));
    await Directory(p.join(dir.path, 'lib')).create();

    // date_picker depends on button and input
    final result = await _runCli(
      ['add', 'date_picker', '--path', 'lib/ui'],
      workingDir: dir,
    );

    expect(result.exitCode, 0);
    expect(
        File(p.join(dir.path, 'lib/ui/date_picker.dart')).existsSync(), isTrue);
    expect(File(p.join(dir.path, 'lib/ui/button.dart')).existsSync(), isTrue);
    expect(File(p.join(dir.path, 'lib/ui/input.dart')).existsSync(), isTrue);
    expect(result.stdout.contains('Including dependencies'), isTrue);
  });

  // ── Preview with dependencies ──

  test('preview shows dependencies', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));

    final result = await _runCli(['preview', 'date_picker'], workingDir: dir);

    expect(result.exitCode, 0);
    expect(result.stdout.contains('Dependencies:'), isTrue);
    expect(result.stdout.contains('button'), isTrue);
  });

  // ── Dry-run tests ──

  test('add --dry-run does not create files', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));
    await Directory(p.join(dir.path, 'lib')).create();

    final result = await _runCli(
      ['add', 'button', '--path', 'lib/ui', '--dry-run'],
      workingDir: dir,
    );

    expect(result.exitCode, 0);
    expect(File(p.join(dir.path, 'lib/ui/button.dart')).existsSync(), isFalse);
    expect(result.stdout.contains('Would add'), isTrue);
  });

  // ── Doctor tests ──

  test('doctor reports missing config', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));
    await Directory(p.join(dir.path, 'lib')).create();

    final result = await _runCli(['doctor'], workingDir: dir);

    expect(result.exitCode, 0);
    expect(result.stdout.contains('Config not found'), isTrue);
  });

  // ── Config tests ──

  test('config --set updates target directory', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));
    await Directory(p.join(dir.path, 'lib')).create();

    final result = await _runCli(
      ['config', '--set', 'lib/components'],
      workingDir: dir,
    );

    expect(result.exitCode, 0);
    expect(result.stdout.contains('Config updated'), isTrue);

    final configFile = File(p.join(dir.path, '.flad.json'));
    expect(configFile.existsSync(), isTrue);
    final json = jsonDecode(await configFile.readAsString());
    expect(json['targetDir'], 'lib/components');
  });

  test('config --reset removes config file', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));
    final configFile = File(p.join(dir.path, '.flad.json'));
    await configFile.writeAsString('{"targetDir": "lib/ui"}');

    final result = await _runCli(['config', '--reset'], workingDir: dir);

    expect(result.exitCode, 0);
    expect(configFile.existsSync(), isFalse);
  });

  // ── All templates are valid ──

  test('all registered templates are non-empty strings', () {
    for (final entry in componentTemplates.entries) {
      expect(entry.value, isNotEmpty, reason: '${entry.key} template is empty');
      expect(entry.value.contains('import'), isTrue,
          reason: '${entry.key} template missing import');
    }
  });

  test('all templates have descriptions', () {
    for (final key in componentTemplates.keys) {
      expect(componentDescriptions.containsKey(key), isTrue,
          reason: '$key missing description');
      expect(componentDescriptions[key], isNotEmpty,
          reason: '$key has empty description');
    }
  });

  test('all categorized components exist in templates', () {
    for (final entry in componentCategories.entries) {
      for (final name in entry.value) {
        expect(componentTemplates.containsKey(name), isTrue,
            reason: '$name in ${entry.key} not found in templates');
      }
    }
  });

  // ── Edge-case tests ──

  test('--help prints usage without error', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));

    final result = await _runCli(['--help'], workingDir: dir);
    expect(result.exitCode, 0);
    expect(result.stdout, contains('flad - Flutter UI component copier'));
  });

  test('no command prints usage', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));

    final result = await _runCli([], workingDir: dir);
    expect(result.exitCode, 0);
    expect(result.stdout, contains('flad - Flutter UI component copier'));
  });

  test('add --all with component names is an error', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));
    await Directory(p.join(dir.path, 'lib')).create();

    final result = await _runCli(
      ['add', '--all', 'button'],
      workingDir: dir,
    );
    expect(result.exitCode, 64);
    expect(result.stderr, contains('Do not pass component names'));
  });

  test('remove --all with component names is an error', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));
    await Directory(p.join(dir.path, 'lib')).create();

    final result = await _runCli(
      ['remove', '--all', 'button'],
      workingDir: dir,
    );
    expect(result.exitCode, 64);
    expect(result.stderr, contains('Do not pass component names'));
  });

  test('remove without component names is an error', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));
    await Directory(p.join(dir.path, 'lib')).create();

    final result = await _runCli(['remove'], workingDir: dir);
    expect(result.exitCode, 64);
    expect(result.stderr, contains('Missing component name'));
  });

  test('preview without component name is an error', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));

    final result = await _runCli(['preview'], workingDir: dir);
    expect(result.exitCode, 64);
    expect(result.stderr, contains('Missing component name'));
  });

  test('preview unknown component reports error', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));

    final result =
        await _runCli(['preview', 'nonexistent'], workingDir: dir);
    expect(result.exitCode, 64);
    expect(result.stderr, contains('Unknown component'));
  });

  test('diff without component name is an error', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));

    final result = await _runCli(['diff'], workingDir: dir);
    expect(result.exitCode, 64);
    expect(result.stderr, contains('Missing component name'));
  });

  test('diff unknown component reports error', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));
    await Directory(p.join(dir.path, 'lib')).create();

    final result = await _runCli(
      ['diff', 'nonexistent', '--path', 'lib/ui'],
      workingDir: dir,
    );
    expect(result.exitCode, 64);
    expect(result.stderr, contains('Unknown component'));
  });

  test('list --json and --plain together is an error', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));

    final result = await _runCli(
      ['list', '--json', '--plain'],
      workingDir: dir,
    );
    expect(result.exitCode, 64);
    expect(result.stderr, contains('Use either --json or --plain'));
  });

  test('add fails when not in a Flutter project', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));
    // No lib/ directory

    final result = await _runCli(
      ['add', 'button', '--path', 'lib/ui'],
      workingDir: dir,
    );
    expect(result.exitCode, 1);
    expect(result.stderr, contains('Not a Flutter project'));
  });

  test('add --all --dry-run lists all without writing files', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));
    await Directory(p.join(dir.path, 'lib')).create();

    final result = await _runCli(
      ['add', '--all', '--path', 'lib/ui', '--dry-run'],
      workingDir: dir,
    );

    expect(result.exitCode, 0);
    expect(result.stdout, contains('Would add'));
    expect(
      File(p.join(dir.path, 'lib/ui/button.dart')).existsSync(),
      isFalse,
    );
  });

  test('config shows current settings after init', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));
    await Directory(p.join(dir.path, 'lib')).create();

    await _runCli(
      ['init', '--path', 'lib/ui', '--style', 'soft'],
      workingDir: dir,
    );

    final result = await _runCli(['config'], workingDir: dir);
    expect(result.exitCode, 0);
    expect(result.stdout, contains('Target directory: lib/ui'));
  });

  test('doctor reports OK after init', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));
    await Directory(p.join(dir.path, 'lib')).create();

    await _runCli(
      ['init', '--path', 'lib/ui', '--style', 'soft'],
      workingDir: dir,
    );

    final result = await _runCli(['doctor'], workingDir: dir);
    expect(result.exitCode, 0);
    expect(result.stdout, contains('Config OK'));
    expect(result.stdout, contains('Target directory exists'));
  });

  test('config --set and --reset together is an error', () async {
    final dir = await Directory.systemTemp.createTemp('flad_cli_test');
    addTearDown(() async => dir.delete(recursive: true));

    final result = await _runCli(
      ['config', '--set', 'lib/ui', '--reset'],
      workingDir: dir,
    );
    expect(result.exitCode, 64);
    expect(result.stderr, contains('Use either --set or --reset'));
  });
}
