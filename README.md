# flad

Flutter UI component copier for Flutter projects.

## Goal
- Copy Flutter UI components as **source files**, not as packages.
- Users can fully edit the copied code.
- Minimal, unopinionated, no vendor lock-in.

## Requirements
- Dart SDK (>= 3.3.0)
- A Flutter project (must have a `lib/` directory)

## How it works
The CLI selects a component template (Dart string) and:
- Verifies `lib/` exists
- Creates the target directory
- Prevents overwriting existing files
- Prints clear console messages

Copied files are **independent of the CLI** and work on their own.

## Commands
```
flad init
flad add <component>
flad add <component> --path <custom_path>
```

## Examples
```
flad init
flad add button
flad add button --path lib/shared/ui
```

Default target:
- `flad add button` -> `lib/ui/button.dart` (unless a custom path was set in init)

Custom target:
- `flad add button --path lib/shared/ui` -> `lib/shared/ui/button.dart`

## Init-time path prompt
When you run `flad init`, the CLI asks for a target directory. Default:
```
lib/ui
```
The chosen path is saved to `.flad.json` and used by future `add` commands.

## Current components
- button
- input

## Add a new component
Inside `lib/src/templates/`:
- create a new template string file
- register it in `lib/src/templates.dart`

Example:
```
const componentTemplates = {
  'button': buttonTemplate,
  'card': cardTemplate,
};
```

## Design philosophy
- Minimal
- Unopinionated
- No package imports for components
- Easy to read and modify

## Run locally
```
dart pub get
dart run bin/flad_cli.dart --help
```
