<h1 align="center">Flad</h1>
<p align="center">Flutter UI component copier for Flutter projects</p>

<p align="center">
  <img src="https://img.shields.io/badge/dart-%3E%3D3.3.0-0175C2?style=flat&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Flutter-Ready-02569B?style=flat&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/license-MIT-2ea44f?style=flat" alt="License" />
</p>

---

## What is Flad?

Flad is a tiny CLI that **copies** UI components into your Flutter project as
plain Dart files. No runtime package dependency. You own the code.

## Why use it?

<table>
  <tr>
    <td><strong>Source-first</strong><br/>Components are files, not imports.</td>
    <td><strong>Fully customizable</strong><br/>Edit the copied files however you want.</td>
    <td><strong>Minimal</strong><br/>No magic config or lock-in.</td>
  </tr>
</table>

## Requirements

- Dart SDK (>= 3.3.0)
- A Flutter project (must have a `lib/` directory)

## Install (project-local)

```
flutter pub add flad_cli
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

| Command                             | Description                                      |
| ----------------------------------- | ------------------------------------------------ |
| `flad init`                         | Create/save target directory (default `lib/ui`). |
| `flad add <component>`              | Add a single component.                          |
| `flad add <component> <component>`  | Add multiple components at once.                 |
| `flad add --all`                    | Add all components.                              |
| `flad add <component> --path <dir>` | Add to a custom directory.                       |
| `flad list`                         | List available components.                       |
| `flad list --plain`                 | List only component names.                       |
| `flad list --json`                  | List as JSON for scripts.                        |
| `flad preview <component>`          | Preview component details.                       |
| `flad config`                       | Show saved config.                               |
| `flad doctor`                       | Check project + config health.                   |

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
flad add button card input
flad add button --path lib/shared/ui
flad preview button
```

## Current components

| Component       | Description                                         |
| --------------- | --------------------------------------------------- |
| button          | Buttons with variants, sizes, and loading states.   |
| input           | Text input with labels, helpers, and prefix/suffix. |
| select          | Custom dropdown select with overlay menu.           |
| card            | Elevated surface with border and radius.            |
| badge           | Small status label (solid/outline/soft).            |
| checkbox        | Custom checkbox with tristate support.              |
| switch          | Adaptive switch with label support.                 |
| textarea        | Multiline input with iOS adaptive mode.             |
| radio           | Custom radio button with label support.             |
| tabs            | Segmented-style tabs with views.                    |
| toast           | Snackbar-based toast helper.                        |
| dialog          | Adaptive alert dialog helper.                       |
| dropdown_menu   | Popup menu anchored to any widget.                  |
| date_picker     | Adaptive date picker helper.                        |
| slider          | Adaptive slider with theme tokens.                  |
| avatar          | Avatar with image or initials.                      |
| list_tile       | Custom list tile with hover and border.             |
| progress        | Linear or circular progress indicator.              |
| table           | Lightweight data table widget.                      |
| chip            | Tag/chip with variants and delete.                  |
| tooltip         | Themed tooltip wrapper.                             |
| bottom_sheet    | Adaptive bottom sheet helper.                       |
| snackbar        | Snackbar helper with variants.                      |
| app_bar         | App bar wrapper with theming tokens.                |
| bottom_nav      | Bottom navigation bar wrapper.                      |
| navigation_rail | Navigation rail wrapper.                            |
| drawer          | Drawer with header/footer slots.                    |
| search_bar      | Search input with icons and theming.                |
| alert           | Alert/banner with variants.                         |
| empty_state     | Empty state with icon, message, and action.         |
| skeleton        | Animated skeleton loader block.                     |
| divider         | Horizontal or vertical divider.                     |
| pagination      | Page navigation control.                            |
| breadcrumb      | Breadcrumb trail with separators.                   |
| rating          | Star rating display and input.                      |

## Theming

Each component includes a `ThemeExtension` for styling. No hardcoded colors.
You can override tokens via `ThemeData.extensions` in your app.
