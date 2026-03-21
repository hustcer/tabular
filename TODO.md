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
- Test count: `95`

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

Status: in progress

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
- Expanded the test suite to `121`
- Re-verified `moon info`, `moon fmt`, `moon check -d`, `moon build -d`, and `moon test -d`

Remaining work:

- Refine border junction behavior for span-heavy `psql` / markdown edge cases
- Port more upstream `span_test.rs` coverage
- Validate interaction with:
  - padding
  - alignment
  - multiline content
  - extraction
  - removal
  - markdown / psql style edge cases

Acceptance:

- Port a focused subset of upstream `span_test.rs`
- Ensure no regressions in non-span rendering

### Phase 6: Highlight / Panel / Shadow / Merge / Split / Theme

Status: not started

Remaining work:

- Evaluate each setting area for feasibility in MoonBit:
  - `Highlight`
  - `Panel`
  - `Shadow`
  - `Merge`
  - `Split`
  - theme-like abstractions
- Implement in the lowest-risk order:
  1. panel-like structural additions
  2. highlight borders
  3. merge/split behaviors
  4. shadow/theme extras
- Add snapshot-style tests for each area

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
