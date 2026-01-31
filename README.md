# flad

Flutter UI component copier for Flutter projects.

## What is flad?
flad is a tiny CLI that **copies** UI components into your Flutter project as
plain Dart files. No runtime package dependency. You own the code.

## Why use it?
- Source-first: components are **files**, not a package import.
- Fully customizable: edit the copied files however you want.
- Minimal & unopinionated: no magic config, no lock‑in.

## Requirements
- Dart SDK (>= 3.3.0)
- A Flutter project (must have a `lib/` directory)

## Install
Project-local (recommended):
```
flutter pub add flad_cli
```

Global install:
```
dart pub global activate flad_cli
```

## Quickstart
```
flad init
flad add button
flad add input
flad add select
```

If installed locally:
```
dart run flad_cli init
dart run flad_cli add button
```

## How it works
flad selects a component template and:
- verifies `lib/` exists
- creates the target directory
- prevents overwriting existing files
- prints clear console messages

Copied files are **independent** of the CLI and work on their own.

## Commands
```
flad init
flad add <component>
flad add <component> --path <custom_path>
```

## Init-time path prompt
When you run `flad init`, the CLI asks for a target directory. Default:
```
lib/ui
```
The chosen path is saved to `.flad.json` and used by future `add` commands.

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

## Current components
- button (variants, sizes, loading, leading/trailing)
- input (label/helper/error, prefix/suffix, sizes)
- select (custom dropdown, overlay menu, checkmark, sizes)
- card (elevated container with border + radius)
- badge (solid/outline/soft variants)
- checkbox (custom UI with tristate support)
- switch (adaptive, sizes, label support)
- textarea (multiline input, adaptive iOS styling)
- radio (custom UI with label support)
- tabs (segmented style tabs + views)
- toast (snackbar-based toast helper)
- dialog (adaptive alert dialog)

## Theming
Each component includes a `ThemeExtension` for styling. No hardcoded colors.
You can override tokens via `ThemeData.extensions` in your app.

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

## Run locally (CLI dev)
```
dart pub get
dart run bin/flad_cli.dart --help
```
