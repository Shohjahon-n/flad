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

## Install

```
dart pub global activate flad_cli
```

Or project-local:

```
flutter pub add flad_cli
```

## Quickstart

```
flad init
flad add button
flad add input card badge
```

If installed locally:

```
dart run flad_cli init
dart run flad_cli add button
```

## Documentation website

Docs are live at:

```
https://flad-docs.netlify.app
```

## How it works

flad selects a component template and:

- verifies `lib/` exists
- creates the target directory
- resolves component dependencies automatically
- prevents overwriting existing files (unless `--overwrite`)
- prints clear console messages

Copied files are **independent** of the CLI and work on their own.

## Commands

| Command | Description |
| --- | --- |
| `flad init` | Create/save target directory and generate theme. |
| `flad init --style <name>` | Init with a design preset (`default`, `brutalist`, `soft`). |
| `flad add <component>` | Add a single component (with auto-dependency resolution). |
| `flad add <comp> <comp>` | Add multiple components at once. |
| `flad add --all` | Add all components. |
| `flad add` | Interactive component selection. |
| `flad add --overwrite` | Replace existing component files. |
| `flad add --registry` | Fetch components from the remote registry. |
| `flad add --dry-run` | Preview file writes without changes. |
| `flad diff <component>` | Compare local file against bundled version. |
| `flad remove <component>` | Remove a component file. |
| `flad remove --all` | Remove all component files. |
| `flad list` | List components by category. |
| `flad list --plain` | List only component names. |
| `flad list --json` | List as JSON (includes category field). |
| `flad preview <component>` | Preview component details and dependencies. |
| `flad config` | Show saved config. |
| `flad config --set <dir>` | Update target directory. |
| `flad config --reset` | Remove config file. |
| `flad doctor` | Check project + config health. |

## Design presets

When you run `flad init`, the CLI asks for a design style. Each style generates
a `theme.dart` file with pre-configured tokens:

| Style | Radius | Border | Seed color | Vibe |
| --- | --- | --- | --- | --- |
| `default` | 8 | 1px | Blue | Clean, balanced |
| `brutalist` | 0 | 2px | Black | Sharp, bold |
| `soft` | 16 | 1px | Purple | Rounded, pastel |

Usage in your app:

```dart
import 'ui/theme.dart';

void main() {
  final themes = FladTheme.apply();
  runApp(MaterialApp(
    theme: themes.light,
    darkTheme: themes.dark,
    home: MyApp(),
  ));
}
```

## Dependency resolution

Components can depend on other components. When you add a component, its
dependencies are added automatically:

```
$ flad add date_picker
[flad] Including dependencies: button, input
[flad] Added: lib/ui/button.dart
[flad] Added: lib/ui/input.dart
[flad] Added: lib/ui/date_picker.dart
```

## Interactive selection

Run `flad add` without arguments to pick components interactively:

```
$ flad add
Select components to add (comma-separated numbers):

  Inputs
     1. button   Buttons with variants, sizes, and loading states.
     2. checkbox  Custom checkbox with tristate support.
     ...

Components (e.g. 1,3,5 or 1-5):
```

## Diffing changes

After customizing a component, compare it against the bundled version:

```
$ flad diff button
[flad] button has local modifications.
[flad] Local: 285 lines
[flad] Bundled: 279 lines
  L42:
    - radius: 12,
    + radius: 16,
[flad] To reset: flad add button --overwrite
```

## Components

### Inputs
| Component | Description |
| --- | --- |
| button | Buttons with variants, sizes, and loading states. |
| icon_button | Icon-only button with variants and sizes. |
| input | Text input with labels, helpers, and prefix/suffix. |
| select | Custom dropdown select with overlay menu. |
| textarea | Multiline input with iOS adaptive mode. |
| checkbox | Custom checkbox with tristate support. |
| radio | Custom radio button with label support. |
| switch | Adaptive switch with label support. |
| slider | Adaptive slider with theme tokens. |
| date_picker | Adaptive date picker helper. |
| search_bar | Search input with icons and theming. |
| rating | Star rating display and input. |

### Layout
| Component | Description |
| --- | --- |
| card | Elevated surface with border and radius. |
| divider | Horizontal or vertical divider. |
| drawer | Drawer with header/footer slots. |
| tabs | Segmented-style tabs with views. |
| app_bar | App bar wrapper with theming tokens. |
| bottom_nav | Bottom navigation bar wrapper. |
| navigation_rail | Navigation rail wrapper. |
| table | Lightweight data table widget. |
| list_tile | Custom list tile with hover and border. |
| pagination | Page navigation control. |
| breadcrumb | Breadcrumb trail with separators. |
| page_header | Page header with title, subtitle, and actions. |
| timeline | Vertical timeline list with active markers. |

### Feedback
| Component | Description |
| --- | --- |
| alert | Alert/banner with variants. |
| banner | Banner callout with icon, message, and action. |
| toast | Snackbar-based toast helper. |
| snackbar | Snackbar helper with variants. |
| dialog | Adaptive alert dialog helper. |
| bottom_sheet | Adaptive bottom sheet helper. |
| progress | Linear or circular progress indicator. |
| skeleton | Animated skeleton loader block. |
| empty_state | Empty state with icon, message, and action. |

### Display
| Component | Description |
| --- | --- |
| avatar | Avatar with image or initials. |
| badge | Small status label (solid/outline/soft). |
| chip | Tag/chip with variants and delete. |
| tooltip | Themed tooltip wrapper. |
| dropdown_menu | Popup menu anchored to any widget. |
| stat_card | Metric card with label, value, and delta. |

## Theming

Each component includes a `ThemeExtension` for styling. No hardcoded colors.
You can override tokens via `ThemeData.extensions` in your app:

```dart
MaterialApp(
  theme: ThemeData(
    extensions: [
      FladButtonTheme(
        solidBackground: Colors.indigo,
        solidForeground: Colors.white,
        // ...
      ),
    ],
  ),
)
```

Or use the generated `FladTheme` from `flad init` for a cohesive look.
