part of 'cli.dart';

// -- Doctor command --

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
