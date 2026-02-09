import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:flad_cli/src/templates.dart';

void main() {
  late String projectRoot;

  setUpAll(() async {
    final packageUri = await Isolate.resolvePackageUri(
        Uri.parse('package:flad_cli/flad_cli.dart'));
    if (packageUri == null) {
      throw StateError('Unable to resolve package:flad_cli/flad_cli.dart');
    }
    final libDir = p.dirname(p.fromUri(packageUri));
    projectRoot = p.dirname(libDir);
  });

  test('registered templates match files on disk', () {
    final templatesDir =
        Directory(p.join(projectRoot, 'lib', 'src', 'templates'));
    final fromFiles = templatesDir
        .listSync()
        .whereType<File>()
        .map((file) => p.basenameWithoutExtension(file.path))
        .where((name) => name != 'theme')
        .toSet();

    final fromRegistry = componentTemplates.keys.toSet();

    final missingFromRegistry = fromFiles.difference(fromRegistry).toList()
      ..sort();
    final missingFromFiles = fromRegistry.difference(fromFiles).toList()
      ..sort();

    expect(
      missingFromRegistry,
      isEmpty,
      reason: 'Template files are not registered: $missingFromRegistry',
    );
    expect(
      missingFromFiles,
      isEmpty,
      reason: 'Registered templates missing files: $missingFromFiles',
    );
  });

  test('all templates are valid Dart syntax', () async {
    final tempDir =
        await Directory.systemTemp.createTemp('flad_template_check');
    addTearDown(() => tempDir.delete(recursive: true));

    for (final entry in componentTemplates.entries) {
      final file = File(p.join(tempDir.path, '${entry.key}.dart'));
      await file.writeAsString(entry.value);

      final result = await Process.run(
        Platform.resolvedExecutable,
        ['format', '--output=none', file.path],
        workingDirectory: projectRoot,
      );

      expect(
        result.exitCode,
        0,
        reason:
            'Template "${entry.key}" has invalid Dart syntax.\nstdout: ${result.stdout}\nstderr: ${result.stderr}',
      );
    }
  });

  test('registered templates avoid hardcoded hex colors', () {
    final hexColor = RegExp(r'Color\(\s*0x[0-9A-Fa-f]{6,8}\s*\)');
    for (final entry in componentTemplates.entries) {
      expect(
        hexColor.hasMatch(entry.value),
        isFalse,
        reason:
            'Template "${entry.key}" contains hardcoded hex colors. Use ColorScheme/ThemeExtension tokens.',
      );
    }
  });
}
