part of 'cli.dart';

// -- Remove command --

Future<void> _removeMany(
  List<String> components,
  String? overridePath,
) async {
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

  var removed = 0;
  var notFound = 0;

  final seen = <String>{};
  for (final component in components) {
    if (!seen.add(component)) continue;

    if (!componentTemplates.containsKey(component)) {
      _printError('Unknown component: $component');
      final suggestions = _suggestComponents(component);
      if (suggestions.isNotEmpty) {
        _printInfo('Did you mean: ${suggestions.join(', ')}');
      }
      continue;
    }

    final filePath = p.join(targetDir, '$component.dart');
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      _printSuccess('Removed: ${p.normalize(filePath)}');
      removed++;
    } else {
      _printWarn('Not found: ${p.normalize(filePath)}');
      notFound++;
    }
  }

  if (components.length > 1) {
    _printSuccess('Removed $removed component(s).');
    if (notFound > 0) {
      _printWarn('$notFound file(s) not found.');
    }
  }
}

Future<void> _removeAll(String? overridePath) async {
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

  var removed = 0;
  final components = componentTemplates.keys.toList()..sort();
  for (final component in components) {
    final filePath = p.join(targetDir, '$component.dart');
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      _printSuccess('Removed: ${p.normalize(filePath)}');
      removed++;
    }
  }

  if (removed == 0) {
    _printWarn('No component files found to remove.');
  } else {
    _printSuccess('Removed $removed component(s).');
  }
}
