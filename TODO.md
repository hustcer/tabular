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
- Global settings:
  - horizontal alignment
  - vertical alignment
  - padding
  - width wrap / truncate
  - height increase / limit
  - header-only horizontal separators
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
- First-pass `Format`:
  - `Format::surround`
  - `Format::value`
- Test count: `62`

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

Status: minimal subset only

Remaining work:

- Add closure-like content transforms if MoonBit function values make this practical
- Add positioned formatting variants
  - format based on `(row, column)`
- Add multiline-aware formatting behavior
- Verify formatting interacts correctly with:
  - width wrap
  - width truncate
  - height limit / increase
  - padding
  - alignment
- Add formatting composition tests
  - segment + row + column + cell
  - union/intersection/inverse selectors

Acceptance:

- Port the non-ANSI subset of upstream `format_test.rs`
- Keep width/padding behavior stable after formatting

### Phase 3: Richer Style Builder Surface

Status: presets only

Remaining work:

- Add style builder APIs closer to upstream:
  - horizontal-line toggles
  - vertical-line toggles
  - top/bottom/left/right border controls
  - custom line insertion / removal
- Add partial border customization helpers
- Add more style presets if upstream coverage depends on them
- Ensure style changes work after:
  - removal
  - extraction
  - selector-scoped settings

Acceptance:

- Port meaningful non-ANSI portions of upstream `style_test.rs`
- No regressions in current preset snapshots

### Phase 4: Width / Height / Layout Parity

Status: basic subset done

Remaining work:

- Add selector-scoped width changes if practical
- Add selector-scoped height changes if practical
- Review upstream width tests for gaps:
  - width by object
  - width after selector combinations
  - width after formatting
  - width after extraction / removal
- Review layout behavior for:
  - empty tables
  - one-column tables
  - one-row tables
  - multiline mixed-height rows

Acceptance:

- Port more upstream `width_test.rs` / relevant render tests
- No warning-producing hacks in dimension logic

### Phase 5: Spans

Status: not started

This is likely the largest renderer change still missing.

Remaining work:

- Add column span support in `papergrid`
- Add row span support if feasible
- Update dimension estimation for spans
- Update line rendering and border junction logic for spans
- Add APIs mirroring upstream span settings as closely as MoonBit allows
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
