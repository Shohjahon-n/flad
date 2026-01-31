import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:flad_cli/src/cli.dart';

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
}) async {
  final stdoutCapture = _TestStdout();
  final stderrCapture = _TestStdout();
  final previousDir = Directory.current;
  Directory.current = workingDir.path;
  exitCode = 0;

  try {
    await IOOverrides.runZoned(
      () async => FladCli().run(args),
      stdout: () => stdoutCapture,
      stderr: () => stderrCapture,
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
}
