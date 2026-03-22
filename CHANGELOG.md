# CHANGELOG

All notable changes to this project will be documented in this file.

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
