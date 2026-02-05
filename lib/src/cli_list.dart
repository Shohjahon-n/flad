part of 'cli.dart';

// -- List command --

void _listComponents({bool asJson = false, bool plain = false}) {
  final keys = componentTemplates.keys.toList()..sort();
  if (asJson) {
    final items = keys
        .map(
          (key) => {
            'name': key,
            'description': componentDescriptions[key] ?? '',
            'category': _categoryFor(key),
          },
        )
        .toList();
    const encoder = JsonEncoder.withIndent('  ');
    stdout.writeln(encoder.convert(items));
    return;
  }

  if (plain) {
    for (final key in keys) {
      stdout.writeln(key);
    }
    return;
  }

  _printInfo('Available components (${keys.length}):');
  stdout.writeln('');
  for (final entry in componentCategories.entries) {
    stdout.writeln(_style('  ${entry.key}', [1]));
    final sorted = entry.value.toList()..sort();
    for (final name in sorted) {
      final desc = componentDescriptions[name];
      if (desc == null) {
        stdout.writeln('    - $name');
      } else {
        stdout.writeln('    - $name: $desc');
      }
    }
    stdout.writeln('');
  }
}
