part of 'cli.dart';

// -- Preview command --

Future<void> _preview(String component, String? overridePath) async {
  final template = componentTemplates[component];
  if (template == null) {
    _printError('Unknown component: $component');
    final suggestions = _suggestComponents(component);
    if (suggestions.isNotEmpty) {
      _printInfo('Did you mean: ${suggestions.join(', ')}');
    } else {
      _printInfo(
          'Available components: ${componentTemplates.keys.join(', ')}');
    }
    exitCode = 64;
    return;
  }

  final description = componentDescriptions[component] ?? 'No description.';
  final widgetName = _toPascalCase(component);
  final targetDir = await _resolvePreviewTargetDir(overridePath);
  final outputPath = p.join(targetDir, '$component.dart');

  final deps = componentDependencies[component];

  _printInfo('Component: $component');
  _printInfo('Description: $description');
  _printInfo('Widget: Flad$widgetName');
  _printInfo('Output file: ${p.normalize(outputPath)}');
  if (deps != null && deps.isNotEmpty) {
    _printInfo('Dependencies: ${deps.join(', ')}');
  }
  stdout.writeln('');
  stdout.writeln('Example usage:');
  stdout.writeln('  Flad$widgetName(');
  stdout.writeln('    // ...');
  stdout.writeln('  );');
  stdout.writeln('');
  _printInfo('To add: flad add $component');
}
