part of 'cli.dart';

// -- Diff command --

Future<void> _diff(String component, String? overridePath) async {
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

  final template = componentTemplates[component];
  if (template == null) {
    _printError('Unknown component: $component');
    exitCode = 64;
    return;
  }

  final filePath = p.join(targetDir, '$component.dart');
  final file = File(filePath);
  if (!await file.exists()) {
    _printWarn('File not found: ${p.normalize(filePath)}');
    _printInfo('Run "flad add $component" first.');
    return;
  }

  final local = await file.readAsString();
  final bundled = template;

  if (local == bundled) {
    _printSuccess('$component is up to date (matches bundled version).');
    return;
  }

  _printWarn('$component has local modifications.');
  _printInfo('Local file: ${p.normalize(filePath)}');

  // Show simple line-count diff.
  final localLines = local.split('\n');
  final bundledLines = bundled.split('\n');
  _printInfo('Local: ${localLines.length} lines');
  _printInfo('Bundled: ${bundledLines.length} lines');

  // Show first few differing lines.
  var diffCount = 0;
  final maxDiffs = 10;
  final maxLen = localLines.length > bundledLines.length
      ? localLines.length
      : bundledLines.length;
  for (var i = 0; i < maxLen && diffCount < maxDiffs; i++) {
    final localLine = i < localLines.length ? localLines[i] : '';
    final bundledLine = i < bundledLines.length ? bundledLines[i] : '';
    if (localLine != bundledLine) {
      diffCount++;
      stdout.writeln(_style('  L${i + 1}:', [33]));
      if (bundledLine.isNotEmpty) {
        stdout.writeln(_style('    - $bundledLine', [31]));
      }
      if (localLine.isNotEmpty) {
        stdout.writeln(_style('    + $localLine', [32]));
      }
    }
  }

  final totalDiffs = _countDiffs(localLines, bundledLines);
  if (totalDiffs > maxDiffs) {
    _printInfo('... and ${totalDiffs - maxDiffs} more difference(s).');
  }

  _printInfo('To reset: flad add $component --overwrite');
}

int _countDiffs(List<String> a, List<String> b) {
  var count = 0;
  final maxLen = a.length > b.length ? a.length : b.length;
  for (var i = 0; i < maxLen; i++) {
    final aLine = i < a.length ? a[i] : '';
    final bLine = i < b.length ? b[i] : '';
    if (aLine != bLine) count++;
  }
  return count;
}
