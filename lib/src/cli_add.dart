part of 'cli.dart';

// -- Add command (addMany, addAll, addFromRegistry, interactiveSelect) --

List<String> _interactiveSelect() {
  stdout.writeln(
      _style('Select components to add (comma-separated numbers):', [36]));
  stdout.writeln('');

  var index = 1;
  for (final entry in componentCategories.entries) {
    stdout.writeln(_style('  ${entry.key}', [1]));
    final sorted = entry.value.toList()..sort();
    for (final name in sorted) {
      final desc = componentDescriptions[name] ?? '';
      final num = '$index'.padLeft(2);
      stdout.writeln('    $num. $name  ${_style(desc, [90])}');
      index++;
    }
    stdout.writeln('');
  }

  stdout.write(_style('Components (e.g. 1,3,5 or 1-5): ', [36]));
  final input = stdin.readLineSync()?.trim() ?? '';
  if (input.isEmpty) return [];

  // Build ordered flat list matching displayed order.
  final ordered = <String>[];
  for (final entry in componentCategories.entries) {
    final sorted = entry.value.toList()..sort();
    ordered.addAll(sorted);
  }

  final selected = <String>{};
  final parts = input.split(RegExp(r'[,\s]+'));
  for (final part in parts) {
    if (part.contains('-')) {
      final range = part.split('-');
      final start = int.tryParse(range.first.trim());
      final end = int.tryParse(range.last.trim());
      if (start != null && end != null) {
        for (var i = start; i <= end && i <= ordered.length; i++) {
          if (i >= 1) selected.add(ordered[i - 1]);
        }
      }
    } else {
      final num = int.tryParse(part.trim());
      if (num != null && num >= 1 && num <= ordered.length) {
        selected.add(ordered[num - 1]);
      }
    }
  }

  return selected.toList();
}

Future<void> _addMany(
  List<String> components,
  String? overridePath, {
  bool dryRun = false,
  bool overwrite = false,
}) async {
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

  await _ensureDirectory(targetDir, dryRun: dryRun);

  // Resolve dependencies.
  final expanded = _expandDependencies(components);
  if (expanded.length > components.length) {
    final deps = expanded.where((c) => !components.contains(c)).toList();
    _printInfo('Including dependencies: ${deps.join(', ')}');
  }

  var added = 0;
  var skipped = 0;
  var unknown = 0;

  final seen = <String>{};
  for (final component in expanded) {
    if (!seen.add(component)) {
      _printWarn('Duplicate component ignored: $component');
      continue;
    }
    final result = await _writeComponent(
      component,
      targetDir,
      dryRun: dryRun,
      overwrite: overwrite,
    );
    if (result == _AddResult.unknown) {
      unknown++;
      _printError('Unknown component: $component');
      final suggestions = _suggestComponents(component);
      if (suggestions.isNotEmpty) {
        _printInfo('Did you mean: ${suggestions.join(', ')}');
      } else {
        _printInfo(
          'Available components: ${componentTemplates.keys.join(', ')}',
        );
      }
      continue;
    }
    if (result == _AddResult.exists) {
      skipped++;
      continue;
    }
    if (result == _AddResult.added || result == _AddResult.dryRun) {
      added++;
    }
  }

  if (components.length > 1 || unknown > 0 || skipped > 0) {
    final verb = dryRun ? 'Would add' : 'Added';
    _printSuccess('$verb $added component(s).');
    if (skipped > 0) {
      _printWarn(
          'Skipped $skipped existing file(s). Use --overwrite to replace.');
    }
    if (unknown > 0) {
      _printWarn('Unknown $unknown component(s).');
      exitCode = 64;
      return;
    }
  }

  if (skipped > 0) {
    exitCode = 1;
    return;
  }

  if (!dryRun) {
    _printSuccess('Ready to ship. Happy hacking!');
  }
}

Future<void> _addFromRegistry(
  List<String> components,
  String? overridePath, {
  bool dryRun = false,
  bool overwrite = false,
}) async {
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

  _printInfo('Fetching registry index...');
  final index = await fetchRegistryIndex();
  if (index == null) {
    _printError('Failed to fetch registry. Check your connection.');
    exitCode = 1;
    return;
  }

  _printSuccess('Registry loaded (${index.components.length} components).');
  await _ensureDirectory(targetDir, dryRun: dryRun);

  var added = 0;
  var skipped = 0;

  // Resolve dependencies from registry.
  final allComponents = <String>[];
  final seen = <String>{};
  void resolve(String name) {
    if (seen.contains(name)) return;
    seen.add(name);
    final entry = index.components[name];
    if (entry != null) {
      for (final dep in entry.dependencies) {
        resolve(dep);
      }
    }
    allComponents.add(name);
  }

  for (final c in components) {
    resolve(c);
  }

  if (allComponents.length > components.length) {
    final deps = allComponents.where((c) => !components.contains(c)).toList();
    _printInfo('Including dependencies: ${deps.join(', ')}');
  }

  for (final component in allComponents) {
    final entry = index.components[component];
    if (entry == null) {
      _printError('Component not found in registry: $component');
      // Fall back to bundled template.
      final result = await _writeComponent(
        component,
        targetDir,
        dryRun: dryRun,
        overwrite: overwrite,
      );
      if (result == _AddResult.added || result == _AddResult.dryRun) added++;
      if (result == _AddResult.exists) skipped++;
      continue;
    }

    final outputPath = p.join(targetDir, '$component.dart');
    final outputFile = File(outputPath);
    final exists = await outputFile.exists();
    if (exists && !overwrite) {
      _printWarn('Exists: ${p.normalize(outputPath)}');
      skipped++;
      continue;
    }

    if (dryRun) {
      final verb = exists ? 'Would overwrite' : 'Would add';
      _printInfo('$verb: ${p.normalize(outputPath)}');
      added++;
      continue;
    }

    _printInfo('Fetching $component...');
    final source = await fetchComponent(entry.fileUrl);
    if (source == null) {
      _printError('Failed to fetch $component. Using bundled version.');
      final result = await _writeComponent(
        component,
        targetDir,
        dryRun: dryRun,
        overwrite: overwrite,
      );
      if (result == _AddResult.added) added++;
      if (result == _AddResult.exists) skipped++;
      continue;
    }

    await outputFile.writeAsString(source);
    final verb = exists ? 'Overwritten' : 'Added';
    _printSuccess('$verb: ${p.normalize(outputPath)}');
    added++;
  }

  _printSuccess('Added $added component(s) from registry.');
  if (skipped > 0) {
    _printWarn(
        'Skipped $skipped existing file(s). Use --overwrite to replace.');
  }
}

Future<void> _addAll(
  String? overridePath, {
  bool dryRun = false,
  bool overwrite = false,
}) async {
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

  await _ensureDirectory(targetDir, dryRun: dryRun);

  final components = componentTemplates.keys.toList()..sort();
  var added = 0;
  var skipped = 0;

  for (final component in components) {
    final result = await _writeComponent(
      component,
      targetDir,
      dryRun: dryRun,
      overwrite: overwrite,
    );
    if (result == _AddResult.added || result == _AddResult.dryRun) {
      added++;
    } else if (result == _AddResult.exists) {
      skipped++;
    }
  }

  final verb = dryRun ? 'Would add' : 'Added';
  _printSuccess('$verb $added component(s).');
  if (skipped > 0) {
    _printWarn('Skipped $skipped existing file(s).');
  }
}
