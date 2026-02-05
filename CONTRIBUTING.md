# Contributing to Flad

Thanks for your interest in contributing! Flad is a small, focused CLI tool and
we welcome contributions of all sizes.

## Getting Started

```bash
# Clone the repo
git clone https://github.com/Shohjahon-n/flad.git
cd flad

# Install dependencies
dart pub get

# Run locally
dart run bin/flad_cli.dart --help

# Run tests
dart test

# Run analysis
dart analyze
```

## Adding a New Component

1. Create a template file in `lib/src/templates/your_component.dart`:

```dart
const yourComponentTemplate = '''
import 'package:flutter/material.dart';
// ... standalone widget code
''';
```

2. Register it in `lib/src/templates.dart`:
   - Add to `componentTemplates`: `'your_component': yourComponentTemplate`
   - Add to `componentDescriptions`: `'your_component': 'Short description'`
   - Add to the appropriate category in `componentCategories`
   - Add dependencies to `componentDependencies` if needed

3. Ensure the template:
   - Is a standalone Dart file (no CLI package imports)
   - Uses `ThemeExtension` for styling (no hardcoded colors)
   - Follows existing naming: `FladYourComponent` for the widget class
   - Is minimal and easy to edit by users

## Project Structure

```
bin/flad_cli.dart          Entry point (thin wrapper)
lib/flad_cli.dart          Public API
lib/src/
  cli.dart                 Main dispatcher + arg parser
  cli_add.dart             Add command logic
  cli_init.dart            Init command logic
  cli_diff.dart            Diff command logic
  cli_remove.dart          Remove command logic
  cli_list.dart            List command logic
  cli_preview.dart         Preview command logic
  cli_config.dart          Config command logic
  cli_doctor.dart          Doctor command logic
  cli_output.dart          Console output helpers
  cli_help.dart            Usage/help text
  cli_utils.dart           Shared utilities
  config.dart              Config file management
  constants.dart           Shared constants
  project.dart             Flutter project validation
  registry.dart            Remote registry client
  templates.dart           Component registry
  templates/               Individual component templates
test/cli_test.dart         Integration tests
```

## Pull Request Guidelines

- Keep changes focused and small
- Add tests for new features or bug fixes
- Run `dart analyze` and `dart test` before submitting
- Follow existing code style (enforced by `lints` package)
- Update `CHANGELOG.md` with your changes

## Design Principles

- **Source-first**: Components are copied files, not imported packages
- **No runtime dependency**: Users own the code after copying
- **Minimal**: Pure Dart, only `args` and `path` as dependencies
- **No hardcoded colors**: Always use `ThemeExtension` and `ColorScheme`

## Reporting Issues

- Use the [bug report template](https://github.com/Shohjahon-n/flad/issues/new?template=bug_report.md) for bugs
- Use the [feature request template](https://github.com/Shohjahon-n/flad/issues/new?template=feature_request.md) for ideas

## License

By contributing, you agree that your contributions will be licensed under the
[MIT License](LICENSE).
