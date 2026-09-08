# CHANGELOG

All notable changes to this project will be documented in this file.

## v0.6.0 - Unreleased

This release expands the MoonBit port of `tabled`. Full workspace parity is still
in progress; see [the parity inventory](docs/tabled-parity.md) and
[the 0.6 migration guide](docs/migration-0.6.md).

### Breaking Changes

- Default tables are left aligned, multiline text uses per-cell alignment, and
  bare `papergrid.SpannedConfig` starts without borders or padding.
- `Width` and `Height` are option factories returning concrete option types.
  Update explicit type annotations and matches on the old enum variants.
- `Setting::W/H` now contain `papergrid.WidthMode/HeightMode`. Legacy setters
  accept the corresponding conversion traits; advanced options use `with_` or `modify`.
- `Entity` is re-exported from `papergrid` and adds global, column, and cell
  variants. Padding now includes fill characters for each side.
- Wide characters that cannot fit use `�` by default. Use `wrap_with(width, ".")`
  to retain the previous placeholder.
- Correct Unicode/ANSI measurement and span/padding calculations can change
  rendered widths, heights, and snapshot output.

### Features

- Add rotate, reverse, concatenation, and record duplication.
- Add composable table/cell options, settings, tuple and array composition,
  alignment and trimming strategies, character cleanup, and justification.
- Add ANSI color construction, parsing, composition, balanced line rendering,
  and style-preserving truncation and wrapping, including OSC8 links.
- Port Unicode 17 width data and the `unicode-width 0.2.2` string-width rules.
- Add measurements, resizing priorities, dimension caching, advanced width and
  height options, explicit dimension lists, suffix handling, and word wrapping.
- Add padding expansion, side fill characters, padding/margin colors, and
  directional margin offsets.

### Fixes And Validation

- Guard short dimension caches after public record growth or explicit cache edits.
- Measure borderless table margins using grid width, including CJK and ANSI text.
- Preserve original upstream expectations and track 278 of 1,387 named source
  test candidates; retain one test that upstream itself ignores.
- Add Rust differential fixtures, pinned probe dependencies, executable examples,
  and CI checks that reject warnings on all supported backends.
- Preserve upstream license notices in `THIRD_PARTY_NOTICES.md`.

## v0.5.2 - 2026-04-05

### Refactoring

- Remove deprecated `not()` usage for latest `moon`

## v0.5.1 - 2026-03-22

### Features

- Add CJK/wide character display width support for correct table column alignment
- Add zero-width character detection (combining marks, bidi controls, variation selectors, ZWJ, etc.)
- Add `Width::wrap_with(width, placeholder)` to allow custom placeholder when a wide character exceeds the available column width (default: `"."`)
- Add negative index guards for `Builder::insert_record`, `remove_record`, `insert_col`, and `remove_col`
- Add GitHub Actions CI workflow for cross-platform build and test

### Bug Fixes

- Fix `Rows`/`Cols` exclude to use recursive `Rows?`/`Cols?` instead of flat `exclude_start`/`exclude_end` range, enabling correct nested exclusion
- Fix `Truncate` mode to use display width instead of byte length for wide characters
- Fix `panel` text wrapping to use `apply_width` instead of byte-counting per character

### Refactoring

- Make `apply_skip_step` generic (`fn[T]`) to eliminate duplicated `apply_skip_step_to_cells`
- Use `HashSet` for O(1) lookups in exclude filtering, `InverseRows`, `InverseCols`, `Diff2`, and `build_remove_map`
- Simplify `unique_cells` with `HashSet[(Int, Int)]`
- Replace O(n²) `sort_indexes_desc` with stdlib `Array::sort` + `rev`
- Narrow `is_wide_char` CJK range to exclude non-wide Yijing Hexagram Symbols (U+4DC0-4DFF)

## v0.5.0 - 2026-03-22

🚀 🚀 First Public Version 🎉 🎉
