part of 'cli.dart';

// -- Init command --

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
