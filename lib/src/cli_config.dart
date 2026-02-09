part of 'cli.dart';

// -- Config command --

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
    final trimmedPath = setPath.trim();
    await _ensureDirectory(trimmedPath);

    String? style;
    try {
      style = (await readConfig())?.style;
    } on FormatException catch (error) {
      _printWarn('Invalid $configFileName: ${error.message}');
      _printWarn('Saving target directory without style.');
    }

    await writeConfig(FladConfig(targetDir: trimmedPath, style: style));
    _printSuccess('Config updated: ${configPath()}');
    _printInfo('Target directory: $trimmedPath');
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
