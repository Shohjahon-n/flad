## 0.1.1 - 2026-02-02
- Publish Netlify docs link and update package documentation metadata.

## 0.1.0 - 2026-02-02
- Add GitHub Pages documentation site in `docs/`.
- Add new components: icon_button, banner, page_header, stat_card, timeline.
- Add tests for `flad init --style` and interactive `flad add` selection.
- Update README with docs link and refreshed component catalog.

## 0.0.7 - 2026-02-03
- Add `flad init --style` with design presets (default, brutalist, soft).
- Add `flad diff` to compare local files against bundled versions.
- Add `flad remove` and `flad remove --all` to delete component files.
- Add `flad add --overwrite` to replace existing files.
- Add `flad add --registry` to fetch components from a remote registry.
- Add interactive component selection when running `flad add` without arguments.
- Add component dependency resolution (auto-adds required components).
- Add component categories (Inputs, Layout, Feedback, Display) to `flad list`.
- Add category field to `flad list --json` output.
- Add new components: accordion, stepper, otp_input, toggle_group, popover,
  shimmer, color_picker, time_picker.
- Add theme generation on `flad init` with `FladTheme` helper class.
- Add `style` field to `.flad.json` config.
- Add `dart test` step to CI pipeline.
- Expand test suite from 5 to 23 integration tests.
- Update README with full command reference and usage examples.

## 0.0.6 - 2026-01-31
- Add `flad preview` for component details.
- Refresh docs and examples.

## 0.0.5 - 2026-01-31
- Trim README to user-focused content.

## 0.0.4 - 2026-01-31
- Add multi-component `flad add` support with typo suggestions.
- Add list output modes (`--plain`, `--json`).
- Add new UI templates: app_bar, bottom_nav, navigation_rail, drawer, search_bar,
  alert, empty_state, skeleton, divider, pagination, breadcrumb, rating.
- Add CLI test coverage.

## 0.0.3
- Add core UI components: select, card, badge, checkbox, switch, textarea, radio,
  tabs, toast, dialog.

## 0.0.2
- Add minimal example documentation for pub.dev scoring.
- Add dartdoc comments for public API items.

## 0.0.1
- Initial release with CLI commands `init` and `add`.
- Adds `button` and `input` component templates.
- Supports persistent target path via `.flad.json`.
