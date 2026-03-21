# TODO

## Goal

Bring this MoonBit port as close as practical to upstream Rust `tabled`, while keeping:

- `moon fmt`
- `moon check -d`
- `moon build -d`
- `moon test -d`

green at every milestone and free of warnings.

## Current Baseline

Already implemented and passing:

- Core rendering primitives under `papergrid`
- Styles: `ascii`, `modern`, `rounded`, `markdown`, `psql`
- Additional style presets: `empty`, `blank`, `extended`, `dots`, `re_structured_text`, `ascii_rounded`
- Style builder surface:
  - `top`, `bottom`, `left`, `right`
  - `horizontal`, `vertical`
  - `corner_top_left`, `corner_top_right`, `corner_bottom_left`, `corner_bottom_right`
  - `intersection_top`, `intersection_bottom`, `intersection_left`, `intersection_right`, `intersection`
  - `remove_top`, `remove_bottom`, `remove_left`, `remove_right`
  - `remove_horizontal`, `remove_horizontals`, `remove_vertical`
  - `horizontals` with custom inserted horizontal lines
- Global settings:
  - horizontal alignment
  - vertical alignment
  - padding
  - width wrap / truncate
  - height increase / limit
  - header-only horizontal separators
- Selector-scoped width / height:
  - row / column / segment / cell targeting
  - stable under extraction / removal remapping
- Builder operations:
  - `push_record`, `extend`, `insert_record`, `remove_record`
  - `insert_column`, `push_column`, `remove_column`
  - `set_empty`, `clear`, `clean`, `from_rows`
- Selector/object foundation:
  - `Rows`, `Columns`, `Cell`, `Segment`
  - `one`, `all`, `first_offset`, `last`, `last_offset`
  - `skip`, `step_by`, same-type `not`, `filter`
  - `intersect`, `inverse`
  - `as_segment`, `and_`, `not_`, mixed `and_*` / `not_*`
  - `ByColumnName`
- Table mutation APIs:
  - `modify_rows`, `modify_columns`, `modify_segment`, `modify_cell`
  - `modify_by_column_name`
  - `remove_rows`, `remove_columns`, `remove_by_column_name`
  - `extract_rows`, `extract_columns`, `extract_segment`
- `Format`:
  - `Format::surround`
  - `Format::value`
  - `Format::content`
  - `Format::positioned`
  - `Format::multiline`
- Test count: `253`

## Constraints

- MoonBit syntax prevents exact parity for some Rust APIs.
  - `with` cannot be used directly; current substitute is `apply(...)` or explicit mutation methods.
  - `and` is reserved; current substitute is `and_(...)`.
- Keep API drift explicit and minimal.
- Prefer shipping small green increments over large unverified drops.

## Priority Plan

### Phase 1: Finish Selector/Object Parity

Status: complete

Completed in this phase:

- Added friendlier object composition helpers so callers do not need explicit `as_segment()`
  - `Rows.and_`, `Rows.and_columns`, `Rows.and_cell`
  - `Columns.and_`, `Columns.and_rows`, `Columns.and_cell`
  - `Cell.and_`
  - `Segment.and_rows`, `Segment.and_columns`, `Segment.and_cell`
- Added cross-type `not` variants
  - `Columns.not_rows`
  - `Rows.not_columns`
  - `Rows.not_cell`
  - `Columns.not_cell`
  - `Segment.not`
  - `Segment.not_cell`
  - `Cell.not`
- Added `filter`-style selection support
  - `Rows.filter`
  - `Columns.filter`
- Added missing selector constructors still useful for parity
  - `Rows.first_offset`
  - `Columns.first_offset`
- Ported the remaining meaningful behavior from upstream `object_test.rs`
  - `skip`
  - `step_by`
  - `filter`

Acceptance:

- Port the remaining meaningful object/selector tests from upstream `object_test.rs`
- Keep current selector tests green

### Phase 2: Expand `Format` Toward Upstream

Status: complete

Completed in this phase:

- Added closure-like content transforms
  - `Format::content((String) -> String)`
  - supports lambdas and named functions
- Added positioned formatting variants
  - `Format::positioned((String, Int, Int) -> String)`
  - format based on `(row, column)`
- Added multiline-aware formatting behavior
  - `Format::multiline()`
- Verified formatting interacts correctly with:
  - width wrap
  - width truncate
  - height limit
  - padding
  - alignment
- Added formatting composition tests covering:
  - segment + row + cell
  - union / difference / intersection / inverse selectors
  - function-based and positioned formatting

Acceptance:

- Port the non-ANSI subset of upstream `format_test.rs`
- Keep width/padding behavior stable after formatting

### Phase 3: Richer Style Builder Surface

Status: complete

Completed in this phase:

- Added style builder APIs closer to upstream:
  - horizontal-line toggles
  - vertical-line toggles
  - top/bottom/left/right border controls
  - custom horizontal line insertion
- Added partial border customization helpers
  - corners
  - intersections
  - directional removers
- Added more style presets needed for meaningful upstream coverage:
  - `empty`
  - `blank`
  - `extended`
  - `dots`
  - `re_structured_text`
  - `ascii_rounded`
- Ported a focused non-ANSI subset of upstream `style_test.rs`
  - preset rendering
  - remove/top/bottom/frame behavior
  - custom horizontal lines
  - empty-style border composition
  - vertical removal on a custom frame

Acceptance:

- Port meaningful non-ANSI portions of upstream `style_test.rs`
- No regressions in current preset snapshots

### Phase 4: Width / Height / Layout Parity

Status: complete

Completed in this phase:

- Added selector-scoped width changes
  - row / column / segment / cell targeting via `Setting::width`
- Added selector-scoped height changes
  - row / column / segment / cell targeting via `Setting::height`
- Extended `papergrid` config with scoped width/height rules and per-cell resolution at render/dimension time
- Added config remapping on structural mutations so scoped width/height/alignment/padding rules stay attached to the correct rows/columns after:
  - row removal
  - column removal
  - row extraction
  - column extraction
  - segment extraction
- Ported a focused subset of upstream `width_test.rs` / related render behavior:
  - width by object
  - width after selector combinations
  - width after formatting
  - width after extraction / removal
  - one-column layout
  - one-row layout
  - multiline mixed-height rows

Acceptance:

- Port more upstream `width_test.rs` / relevant render tests
- No warning-producing hacks in dimension logic

### Phase 5: Spans

Status: complete

This is likely the largest renderer change still missing.

Completed in this phase:

- Added focused column span support in `papergrid`
  - span storage and remapping in `SpannedConfig`
  - visibility checks for covered cells
  - dimension estimation aware of `colspan`
  - row rendering aware of merged cell widths and hidden covered cells
- Added focused row span support in `papergrid`
  - row-span storage and remapping in `SpannedConfig`
  - visibility checks for cells covered from rows above
  - row-block height estimation aware of merged vertical content
  - split-line rendering that suppresses horizontal rules through active row spans
- Added MoonBit-friendly public span entrypoints for the completed slice
  - `Span::column(size)` returns a setting usable with existing `modify_*` APIs
  - supports `1` for span removal, `>1` for rightward column spans, `0` for full-row span, and negative values for leftward spans
  - `Span::row(size)` returns a setting usable with existing `modify_*` APIs
  - supports `1` for span removal, `>1` for downward row spans, `0` for full-column span, and negative values for upward spans
- Ported a focused non-ANSI subset of upstream span behavior
  - low-level `papergrid` column span rendering
  - low-level `papergrid` row span rendering
  - table-level cell/segment column and row spans
  - span remapping after column extraction and row extraction
- Added a first border-junction refinement for row-span split lines
  - fully covered split lines are suppressed
  - internal junctions inside the same combined row+column span are suppressed
- Extended rowspan rendering so content can continue across visible split lines
  - rowspan height accounting now treats visible crossed boundaries as usable vertical slots
  - extra rowspan height is distributed across the full span range instead of being pushed only into the last row
  - split-line rendering can now paint spanned-cell content in partially covered boundaries
- Extended rowspan rendering further so fully covered boundaries can render content too
  - split lines no longer disappear when every column is row-spanned but at least one spanned cell still has boundary content to paint
  - added focused vertical-alignment coverage for boundary-rendered content
  - updated the current `psql` header-row span snapshot to reflect boundary-carried content under the new renderer behavior
- Ported a second focused span batch from upstream-inspired cases
  - low-level multiline rowspan collision behavior
  - low-level multiline combined row+column span behavior
  - invalid-position no-op coverage at the table layer
- Added a source-mapped safe span layer for non-forward spans
  - negative and zero spans normalize to a visible top/left anchor without destructively moving stored cell values
  - `Span::column(1)` / `Span::row(1)` can remove earlier negative/zero spans through the original source cell
  - dimension and render paths now resolve span content from the stored source cell when anchor and source differ
  - source-mapped spans now remap correctly across `extract_*` and `remove_*` even when the original anchor is discarded but the covered run survives
- Added focused high-level coverage for:
  - `Span::column(-1)`
  - `Span::column(0)` plus removal
  - `Span::row(-1)`
  - `Span::row(0)` plus removal
  - negative/zero span remapping through extraction and removal
- Fixed zero-span logic bug in `apply_column_span` / `apply_row_span`
  - `Span::column(0)` at non-last column now correctly covers the full row width
  - `Span::row(0)` at non-last row now correctly covers the full column height
- Fixed psql border junction rendering
  - removed erroneous `left_intersection` / `right_intersection` from psql borders
  - fixed `render_split_line` and `build_line` fallback chains to not fall back to `borders.horizontal` for left/right positions
  - psql separator lines now match upstream output exactly (no extra `-` at edges)
- Ported upstream cell_span_test (row span positions)
  - 12 cell-level row span position tests covering all column/row combinations under psql
  - tests match upstream output exactly
- Ported upstream span_row_test (whole-row row spans)
  - whole-row row span under ascii and psql styles
  - data-row range row span under psql
  - full-table row span under psql
  - all match upstream output exactly
- Ported upstream multiline / padding / collision span tests
  - `span_multiline`: multiline content in spanned columns matches upstream
  - `indent_works_in_spaned_columns`: custom padding interaction with column spans matches upstream
  - `spaned_columns_with_collision`: complex multi-span collision with modern style matches upstream
- Ported upstream `span_row_negative_0` / `span_row_zero_0`
  - multiple simultaneous row negative spans (`row(-1)`, `row(-2)`, `row(-100)`)
  - multiple simultaneous row zero spans (`row(0)`, `row(-0)`)
- Ported upstream column/row span invalid position tests
  - column span at invalid row, column, and both
  - row span at invalid column and both row+column
- Ported extensive papergrid-level edge case tests from upstream `column_span.rs` / `row_span.rs`
  - column span multilane with custom data
  - column span collision with two spans at different widths
  - column span all rows spanned
  - column span with different length data
  - column span no split style
  - row span collision with multiline content
  - row span 3x3 render with multiple row spans
  - row span all columns spanned
  - row span no split style
  - row span with vertical padding
  - combined row+column span at top-left corner
  - combined row+column span at bottom-right corner
  - combined row+column span large center block
  - mixed row and column spans complex layout
  - zero span in column dimension is ignored
  - zero span grid all rows and cols spanned
  - 5x2 row span spanning 4 rows
- Expanded the test suite to `182`
- Re-verified `moon fmt`, `moon check -d`, `moon build -d`, and `moon test -d`

Remaining work deferred to Phase 6:

- Port remaining upstream `span_test.rs` tests that need Panel/Highlight/BorderCorrection

Acceptance:

- Port a focused subset of upstream `span_test.rs` ✓
- Ensure no regressions in non-span rendering ✓

### Phase 6: Highlight / Panel / Shadow / Merge / Split / Theme

Status: complete

Completed in this phase:

- Added `Panel` for structural table additions
  - `Panel::header(text)` inserts full-width row at top
  - `Panel::footer(text)` inserts full-width row at bottom
  - `Panel::horizontal(row, text)` inserts at arbitrary row
  - `Panel::vertical(col, text)` inserts full-height column
  - `Panel::vertical_with_width(col, text, width)` with text wrapping
  - Row/column span metadata shifts correctly on insertion
- Added `Merge` for duplicate cell merging
  - `Merge::horizontal()` merges adjacent duplicate cells across columns
  - `Merge::vertical()` merges adjacent duplicate cells across rows
- Added `Highlight` for per-cell border outlines
  - `Highlight::new(segment, border)` outlines arbitrary cell regions
  - Supports all border characters (top, bottom, left, right, corners)
  - Works with any style preset and selector combination
- Added `Shadow` for table shadow effects
  - `Shadow::right(size, offset, fill)` adds right shadow margin
  - `Shadow::left(size, offset, fill)` adds left shadow margin
  - `Shadow::top(size, offset, fill)` adds top shadow margin
  - `Shadow::bottom(size, offset, fill)` adds bottom shadow margin
  - Shadow renders via margin config in papergrid
- Added `BorderCorrection` for span-aware border fix-up
  - 3-phase algorithm: column spans → row spans → combined spans
  - `get_cell_border()` resolves effective borders with overrides
  - `has_left_border()` / `has_top_border()` for neighbor checks
  - Fixed `is_cell_covered_by_both_spans` for combined span detection
  - Fixed `render_split_line` to honor intersection overrides at left, middle, and right junctions
- Added `Split` for table reshaping
  - `Split::column(index)` / `Split::row(index)` split by direction
  - `Split::concat()` pushes redistributed cells to end
  - `Split::zip()` interleaves cells (default)
  - `Split::clean()` filters empty rows/cols (default)
  - `Split::retain()` keeps all cells
  - `Table::apply_split(split)` applies the split transformation
  - Handles edge cases: zero index, beyond-size index, empty table, blank cells
- Theme support already covered by Style presets (ascii, modern, rounded, etc.)
- Expanded test suite from 182 to 253 tests
  - 9 Panel tests (header, footer, horizontal, vertical, with spans)
  - 3 Merge tests (horizontal, vertical, combined)
  - 11 Highlight tests (cell, row, column, segment, custom borders)
  - 5 Shadow tests (all 4 directions + combined)
  - 9 BorderCorrection tests (column spans, row spans, combined spans)
  - 18 Split tests (column, row, zip, concat, clean, retain, edge cases)
- Re-verified `moon fmt`, `moon check`, `moon build`, and `moon test`

Acceptance:

- Port a meaningful subset of upstream tests from each module
- Keep border math consistent with spans and custom styles

### Phase 7: Extraction / Removal by Richer Selectors

Status: range + column-name subset done

Remaining work:

- Add extraction/removal APIs driven by richer object selections if practical
- Support extraction/removal after selector composition
- Ensure selection semantics are stable after prior mutations

Acceptance:

- Port more of upstream `extract_test.rs` and `disable_test.rs`

### Phase 8: Data Derive / Runtime Table Construction Parity

Status: not started

Remaining work:

- Decide scope of derive/macro parity in MoonBit
- If full derive parity is unrealistic, define the best runtime alternative:
  - record-to-row helpers
  - declarative schema mapping
  - convenience constructors
- Add examples and tests for MoonBit-idiomatic data-to-table conversion

Acceptance:

- Clear documented stance on derive parity
- Working runtime alternative if derive is not feasible

### Phase 9: Examples / Docs / API Cleanup

Status: not started

Remaining work:

- Add README examples reflecting the actual MoonBit API
- Document intentional API differences from Rust upstream
  - `apply` vs `with`
  - `and_` / `not_`
  - any explicit `as_segment()` bridging
- Add examples for:
  - builder usage
  - selector composition
  - formatting
  - removal / extraction

Acceptance:

- README examples compile or are kept in sync with tests
- Differences from upstream are explicit, not accidental

## Suggested Execution Order

1. Finish selector/object ergonomics
2. Expand `Format`
3. Expand style builder surface
4. Fill width/height/layout gaps
5. Implement spans
6. Add highlight/panel/merge/split/theme families
7. Finish extraction/removal parity
8. Decide derive/runtime data API strategy
9. Final docs and cleanup

## Verification Checklist Per Milestone

For every completed sub-phase:

- Add or port tests first where possible
- Run:
  - `moon fmt`
  - `moon check -d`
  - `moon build -d`
  - `moon test -d`
- Confirm no warnings
- Update:
  - `task_plan.md`
  - `progress.md`
  - `findings.md`

## Final Parity Exit Criteria

The port can be considered "feature-complete enough" when:

- The highest-value upstream non-ANSI test surface is covered
- Remaining gaps are explicitly documented and justified
- Major settings families are present or intentionally declined
- API differences caused by MoonBit syntax are minimized and documented
- `moon fmt`, `moon check -d`, `moon build -d`, `moon test -d` remain clean
