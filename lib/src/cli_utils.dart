part of 'cli.dart';

// -- Shared utilities --

enum _AddResult { added, exists, unknown, dryRun }

String _promptForTargetDir() {
  stdout.write(_style('Target directory [$defaultTargetDir]: ', [36]));
  final input = stdin.readLineSync();
  final trimmed = input?.trim() ?? '';
  return trimmed.isEmpty ? defaultTargetDir : trimmed;
}

Future<void> _ensureDirectory(String path, {bool dryRun = false}) async {
  final resolvedDir = p.normalize(path);
  final dir = Directory(resolvedDir);
  if (await dir.exists()) {
    _printInfo('Using existing directory: ${dir.path}');
    return;
  }
  if (dryRun) {
    _printInfo('Would create directory: ${dir.path}');
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

Future<String> _resolvePreviewTargetDir(String? overridePath) async {
  if (overridePath != null && overridePath.trim().isNotEmpty) {
    return overridePath.trim();
  }
  try {
    final config = await readConfig();
    if (config != null) {
      return config.targetDir;
    }
  } on FormatException catch (error) {
    _printWarn('Invalid $configFileName: ${error.message}');
    _printWarn('Using default target directory.');
  }
  return defaultTargetDir;
}

Future<_AddResult> _writeComponent(
  String component,
  String targetDir, {
  bool dryRun = false,
  bool overwrite = false,
}) async {
  final template = componentTemplates[component];
  if (template == null) {
    return _AddResult.unknown;
  }

  final outputPath = p.join(targetDir, '$component.dart');
  final outputFile = File(outputPath);
  final exists = await outputFile.exists();
  if (exists && !overwrite) {
    _printWarn('Exists: ${p.normalize(outputFile.path)}');
    return _AddResult.exists;
  }

  if (dryRun) {
    final verb = exists ? 'Would overwrite' : 'Would add';
    _printInfo('$verb: ${p.normalize(outputFile.path)}');
    return _AddResult.dryRun;
  }

  await outputFile.writeAsString(template);
  final verb = exists ? 'Overwritten' : 'Added';
  _printSuccess('$verb: ${p.normalize(outputFile.path)}');
  return _AddResult.added;
}

/// Expands a list of components to include their dependencies (deps first).
List<String> _expandDependencies(List<String> components) {
  final result = <String>[];
  final seen = <String>{};

  void visit(String component) {
    if (seen.contains(component)) return;
    seen.add(component);
    final deps = componentDependencies[component];
    if (deps != null) {
      for (final dep in deps) {
        visit(dep);
      }
    }
    result.add(component);
  }

  for (final component in components) {
    visit(component);
  }
  return result;
}

String _categoryFor(String component) {
  for (final entry in componentCategories.entries) {
    if (entry.value.contains(component)) {
      return entry.key;
    }
  }
  return 'Other';
}

List<String> _suggestComponents(String input) {
  final normalized = input.trim().toLowerCase();
  if (normalized.isEmpty) {
    return const [];
  }

  final keys = componentTemplates.keys.toList();
  final scored = <String, int>{};
  for (final key in keys) {
    final distance = _editDistance(normalized, key.toLowerCase());
    scored[key] = distance;
  }

  final sorted = scored.entries.toList()
    ..sort((a, b) => a.value.compareTo(b.value));

  final threshold = normalized.length <= 4 ? 1 : 2;
  return sorted
      .where((entry) => entry.value <= threshold)
      .take(3)
      .map((entry) => entry.key)
      .toList();
}

int _editDistance(String a, String b) {
  if (a == b) {
    return 0;
  }
  if (a.isEmpty) {
    return b.length;
  }
  if (b.isEmpty) {
    return a.length;
  }

  final rows = List.generate(
    a.length + 1,
    (_) => List<int>.filled(b.length + 1, 0),
  );

  for (var i = 0; i <= a.length; i++) {
    rows[i][0] = i;
  }
  for (var j = 0; j <= b.length; j++) {
    rows[0][j] = j;
  }

  for (var i = 1; i <= a.length; i++) {
    for (var j = 1; j <= b.length; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      rows[i][j] = [
        rows[i - 1][j] + 1,
        rows[i][j - 1] + 1,
        rows[i - 1][j - 1] + cost,
      ].reduce((value, element) => value < element ? value : element);
    }
  }

  return rows[a.length][b.length];
}

String _toPascalCase(String value) {
  final parts =
      value.split(RegExp(r'[_\\s-]+')).where((part) => part.isNotEmpty);
  return parts
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join();
}
