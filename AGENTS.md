# AGENTS.md

This file is for other AI agents working on this repo. It explains the goal,
architecture, and how to extend the CLI without breaking the design
requirements.

## Project Goal
Build a Dart CLI tool for Flutter:
- Components are copied into the user’s Flutter project as source files.
- No runtime dependency on this CLI after copy.
- Minimal, unopinionated, and fully customizable by the user.

## Core Requirements (must keep)
- Commands:
  - `flad init`
  - `flad add <component>`
  - `flad add <component> --path <custom_path>`
- Default target directory: `lib/ui/`
- If `--path` is provided, use that directory.
- Validate current dir is a Flutter project: `lib/` must exist.
- Create target directories if missing.
- Do not overwrite existing files.
- Print clear console messages for each action.
- CLI is pure Dart; uses `args` and `path`.

## Current Implementation Overview
Main entrypoint: `bin/flad_cli.dart` (thin wrapper).

Key ideas:
- The CLI builds all component files from template strings.
- Component templates are stored in `componentTemplates` map.
- Each component is written to `<targetDir>/<component>.dart`.
- `init` only ensures the default directory exists.

## File Layout
- `bin/flad_cli.dart`: minimal wrapper that calls the library entrypoint.
- `lib/flad_cli.dart`: public entrypoint (`run()`).
- `lib/src/cli.dart`:
  - Arg parsing (`args` package).
  - Command dispatch (`init`, `add`).
  - Validation for Flutter project (`lib/`).
  - File creation + no-overwrite checks.
  - Config load/save and prompt logic.
- `lib/src/config.dart`: reads/writes `.flad.json`.
- `lib/src/constants.dart`: shared constants.
- `lib/src/templates/`: component templates as strings.
- `README.md`: end-user docs.

## How to Add a Component
1. Add a new template string in `bin/flad_cli.dart`:
   - Example name: `_cardDart`.
2. Register it in `componentTemplates`:
   - `'card': cardTemplate`
3. Ensure it is a standalone Dart file.
4. Use ThemeExtension for styling (no hardcoded colors).

## Template Requirements
- Standalone Dart file.
- Must not import the CLI package.
- Uses ThemeExtension and/or ColorScheme derived tokens.
- No hardcoded colors (use `ColorScheme`, theme extensions, or params).
- Minimal and easy to edit by the user.

## Console UX Expectations
- Errors go to stderr using clear wording.
- Use simple, short status messages:
  - Created directory
  - Using existing directory
  - Added file
  - File already exists (no overwrite)
  - Not a Flutter project

## Command Behavior Details
`flad init`
- Verifies `lib/` exists.
- Creates `lib/ui` if it doesn’t exist.

`flad add <component> [--path <dir>]`
- Verifies `lib/` exists.
- Creates target directory if missing.
- Writes `<component>.dart` only if it does not exist.
- Prints the final file path.

## Extensibility Rules
- Prefer small, explicit helper functions.
- Avoid extra abstraction layers.
- Keep templates in the same file unless it grows too large.
- If templates move to separate files, document the new structure here.

## Things to Avoid
- Turning this into a Flutter package (no runtime package imports).
- Hidden config or magic behavior.
- Overwriting user files.
- Introducing hardcoded colors or locked-in design tokens.

## Quick Local Run
```
dart pub get
dart run bin/flad_cli.dart --help
```
