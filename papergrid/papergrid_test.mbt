///|
test "iter grid ascii output" {
  let borders = @papergrid.Borders::ascii()
  let cfg = centered_grid_config()
  cfg.set_borders(borders)
  let records = @papergrid.IterRecords::new([
    ["Hello", "World"],
    ["Hi", "MoonBit"],
  ])
  let dims = @papergrid.IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = @papergrid.IterGrid::new(records, cfg, dims)
  inspect(
    grid.to_string(),
    content=(
      #|+-------+---------+
      #|| Hello |  World  |
      #|+-------+---------+
      #||  Hi   | MoonBit |
      #|+-------+---------+
    ),
  )
}

///|
test "iter grid multiline output" {
  let cfg = centered_grid_config()
  cfg.set_borders(@papergrid.Borders::ascii())
  let records = @papergrid.IterRecords::new([
    ["left\ncell", "right one"],
    ["the second col", "and\nhere"],
  ])
  let dims = @papergrid.IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = @papergrid.IterGrid::new(records, cfg, dims)
  inspect(
    grid.to_string(),
    content=(
      #|+----------------+-----------+
      #||      left      | right one |
      #||      cell      |           |
      #|+----------------+-----------+
      #|| the second col |    and    |
      #||                |   here    |
      #|+----------------+-----------+
    ),
  )
}

///|
test "iter grid col span output" {
  let cfg = centered_grid_config()
  cfg.set_borders(@papergrid.Borders::ascii())
  cfg.set_col_span(0, 0, 2)
  let records = @papergrid.IterRecords::new([["0-0", ""], ["1-0", "1-1"]])
  let dims = @papergrid.IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = @papergrid.IterGrid::new(records, cfg, dims)
  inspect(
    grid.to_string(),
    content=(
      #|+-----+-----+
      #||    0-0    |
      #|+-----+-----+
      #|| 1-0 | 1-1 |
      #|+-----+-----+
    ),
  )
}

///|
test "iter grid row span output" {
  let cfg = centered_grid_config()
  cfg.set_borders(@papergrid.Borders::ascii())
  cfg.set_row_span(0, 0, 2)
  let records = @papergrid.IterRecords::new([["0-0", "0-1"], ["1-0", "1-1"]])
  let dims = @papergrid.IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = @papergrid.IterGrid::new(records, cfg, dims)
  inspect(
    grid.to_string(),
    content=(
      #|+-----+-----+
      #|| 0-0 | 0-1 |
      #|+     +-----+
      #||     | 1-1 |
      #|+-----+-----+
    ),
  )
}

///|
test "iter grid row span collision multiline output" {
  let cfg = centered_grid_config()
  cfg.set_borders(@papergrid.Borders::ascii())
  cfg.set_row_span(0, 0, 2)
  cfg.set_row_span(1, 1, 2)
  let records = @papergrid.IterRecords::new([
    ["0-0", "0-1", "0-2"],
    ["1-0", "1-1\nx\nx\nxxxxx", "1-2"],
    ["2-0", "2-1", "2-2"],
  ])
  let dims = @papergrid.IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = @papergrid.IterGrid::new(records, cfg, dims)
  inspect(
    grid.to_string(),
    content=(
      #|+-----+-------+-----+
      #|| 0-0 |  0-1  | 0-2 |
      #|+     +-------+-----+
      #||     |  1-1  | 1-2 |
      #||     |   x   |     |
      #|+-----+   x   +-----+
      #|| 2-0 | xxxxx | 2-2 |
      #|+-----+-------+-----+
    ),
  )
}

///|
test "iter grid combined row and col span multiline output" {
  let cfg = centered_grid_config()
  cfg.set_borders(@papergrid.Borders::ascii())
  cfg.set_row_span(1, 1, 2)
  cfg.set_col_span(1, 1, 2)
  cfg.set_align_for_cell(1, 1, @papergrid.HAlign::center())
  cfg.set_valign_for_cell(1, 1, @papergrid.VAlign::center())
  let records = @papergrid.IterRecords::new([
    ["0-0", "0-1", "0-2", "0-3"],
    ["1-0", "123\n345\n555\n333", "1-2", "1-3"],
    ["2-0", "2-1", "2-2", "2-3"],
    ["3-0", "3-1", "3-2", "3-3"],
  ])
  let dims = @papergrid.IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = @papergrid.IterGrid::new(records, cfg, dims)
  inspect(
    grid.to_string(),
    content=(
      #|+-----+-----+-----+-----+
      #|| 0-0 | 0-1 | 0-2 | 0-3 |
      #|+-----+-----+-----+-----+
      #|| 1-0 |    123    | 1-3 |
      #||     |    345    |     |
      #|+-----+    555    +-----+
      #|| 2-0 |    333    | 2-3 |
      #|+-----+-----+-----+-----+
      #|| 3-0 | 3-1 | 3-2 | 3-3 |
      #|+-----+-----+-----+-----+
    ),
  )
}

///|
test "iter grid row span boundary content with centered vertical align" {
  let cfg = centered_grid_config()
  cfg.set_borders(@papergrid.Borders::ascii())
  cfg.set_row_span(0, 0, 2)
  cfg.set_row_span(0, 1, 2)
  cfg.set_valign_for_all(@papergrid.VAlign::center())
  let records = @papergrid.IterRecords::new([
    ["1as\nd\n", "a"],
    ["as\ndasdds\na", "asd"],
  ])
  let dims = @papergrid.IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = @papergrid.IterGrid::new(records, cfg, dims)
  inspect(
    grid.to_string(),
    content=(
      #|+-----+---+
      #|| 1as |   |
      #|+  d  + a +
      #||     |   |
      #|+-----+---+
    ),
  )
}

///|
test "iter grid row span boundary content with bottom vertical align" {
  let cfg = centered_grid_config()
  cfg.set_borders(@papergrid.Borders::ascii())
  cfg.set_row_span(0, 0, 2)
  cfg.set_row_span(0, 1, 2)
  cfg.set_valign_for_all(@papergrid.VAlign::bottom())
  let records = @papergrid.IterRecords::new([
    ["1a\ns\nd", "a"],
    ["as\ndasdds\na", "asd"],
  ])
  let dims = @papergrid.IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = @papergrid.IterGrid::new(records, cfg, dims)
  inspect(
    grid.to_string(),
    content=(
      #|+----+---+
      #|| 1a |   |
      #|+ s  +   +
      #|| d  | a |
      #|+----+---+
    ),
  )
}

// ──────────────────────────────────────────────────
// Col span edge cases from upstream col_span.rs
// ──────────────────────────────────────────────────

///|
test "col span multilane with custom data" {
  let cfg = centered_grid_config()
  cfg.set_borders(@papergrid.Borders::ascii())
  cfg.set_col_span(0, 0, 2)
  cfg.set_col_span(3, 0, 3)
  let records = @papergrid.IterRecords::new([
    ["first line", "", "e.g."],
    ["0", "1", "2"],
    ["0", "1", "2"],
    ["full last line", "", ""],
  ])
  let dims = @papergrid.IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = @papergrid.IterGrid::new(records, cfg, dims)
  inspect(
    grid.to_string(),
    content=(
      #|+------+-----+------+
      #|| first line | e.g. |
      #|+------+-----+------+
      #||  0   |  1  |  2   |
      #|+------+-----+------+
      #||  0   |  1  |  2   |
      #|+------+-----+------+
      #||  full last line   |
      #|+------+-----+------+
    ),
  )
}

///|
test "col span collision two spans different widths" {
  let cfg = centered_grid_config()
  cfg.set_borders(@papergrid.Borders::ascii())
  cfg.set_col_span(0, 0, 2)
  cfg.set_col_span(1, 1, 2)
  let records = @papergrid.IterRecords::new([
    ["0-0xxxxxxx", "0-1", "0-2"],
    ["1-0", "1-1", "1-2"],
    ["2-0", "2-1", "2-2"],
  ])
  let dims = @papergrid.IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = @papergrid.IterGrid::new(records, cfg, dims)
  inspect(
    grid.to_string(),
    content=(
      #|+------+-----+-----+
      #|| 0-0xxxxxxx | 0-2 |
      #|+------+-----+-----+
      #|| 1-0  |    1-1    |
      #|+------+-----+-----+
      #|| 2-0  | 2-1 | 2-2 |
      #|+------+-----+-----+
    ),
  )
}

///|
test "wrap preserves the legacy dot placeholder when wide char exceeds width" {
  assert_eq(
    @papergrid.apply_width("中", @papergrid.WidthMode::wrap_with(1, ".")),
    ["."],
  )
}

///|
test "wrap supports custom placeholder when wide char exceeds width" {
  assert_eq(
    @papergrid.apply_width("中", @papergrid.WidthMode::wrap_with(1, "?")),
    ["?"],
  )
}

///|
test "combining marks do not increase display width wrapping" {
  assert_eq(
    @papergrid.apply_width("a\u{0301}", @papergrid.WidthMode::wrap(1)),
    ["a\u{0301}"],
  )
}

///|
test "bidi controls do not affect display width wrapping" {
  assert_eq(
    @papergrid.apply_width("\u{2066}ab\u{2069}", @papergrid.WidthMode::wrap(2)),
    ["\u{2066}ab\u{2069}"],
  )
}

///|
test "col span all rows spanned" {
  let cfg = centered_grid_config()
  cfg.set_borders(@papergrid.Borders::ascii())
  cfg.set_col_span(0, 0, 2)
  cfg.set_col_span(1, 0, 2)
  cfg.set_col_span(2, 0, 2)
  let records = @papergrid.IterRecords::new([
    ["0-0", "0-1"],
    ["1-0", "1-1"],
    ["2-0", "2-1"],
  ])
  let dims = @papergrid.IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = @papergrid.IterGrid::new(records, cfg, dims)
  inspect(
    grid.to_string(),
    content=(
      #|+--+--+
      #|| 0-0 |
      #|+--+--+
      #|| 1-0 |
      #|+--+--+
      #|| 2-0 |
      #|+--+--+
    ),
  )
}

///|
test "col span with different length data" {
  let cfg = centered_grid_config()
  cfg.set_borders(@papergrid.Borders::ascii())
  cfg.set_col_span(0, 0, 2)
  cfg.set_col_span(2, 0, 2)
  let records = @papergrid.IterRecords::new([
    ["first row", ""],
    ["0", "1"],
    ["a longer second row", ""],
  ])
  let dims = @papergrid.IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = @papergrid.IterGrid::new(records, cfg, dims)
  inspect(
    grid.to_string(),
    content=(
      #|+----------+----------+
      #||      first row      |
      #|+----------+----------+
      #||    0     |    1     |
      #|+----------+----------+
      #|| a longer second row |
      #|+----------+----------+
    ),
  )
}

///|
test "col span no split style" {
  let cfg = centered_grid_config()
  cfg.set_col_span(0, 0, 2)
  cfg.set_align_for_cell(0, 0, @papergrid.HAlign::center())
  let records = @papergrid.IterRecords::new([["0-0", ""], ["1-0", "1-1"]])
  let dims = @papergrid.IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = @papergrid.IterGrid::new(records, cfg, dims)
  inspect(
    grid.to_string(),
    content=(
      #|+-----+-----+
      #||    0-0    |
      #|+-----+-----+
      #|| 1-0 | 1-1 |
      #|+-----+-----+
    ),
  )
}

// ──────────────────────────────────────────────────
// Row span edge cases from upstream row_span.rs
// ──────────────────────────────────────────────────

///|
test "row span collision with multiline content" {
  let cfg = centered_grid_config()
  cfg.set_borders(@papergrid.Borders::ascii())
  cfg.set_row_span(0, 0, 2)
  cfg.set_row_span(1, 1, 2)
  let records = @papergrid.IterRecords::new([
    ["0-0xxxxxxx", "0-1", "0-2"],
    ["1-0", "1-1", "1-2"],
    ["2-0", "2-1", "2-2"],
  ])
  let dims = @papergrid.IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = @papergrid.IterGrid::new(records, cfg, dims)
  inspect(
    grid.to_string(),
    content=(
      #|+------------+-----+-----+
      #|| 0-0xxxxxxx | 0-1 | 0-2 |
      #|+            +-----+-----+
      #||            | 1-1 | 1-2 |
      #|+------------+     +-----+
      #||    2-0     |     | 2-2 |
      #|+------------+-----+-----+
    ),
  )
}

///|
test "row span 3x3 render with multiple row spans" {
  let cfg = centered_grid_config()
  cfg.set_borders(@papergrid.Borders::ascii())
  cfg.set_row_span(0, 0, 3)
  cfg.set_row_span(0, 1, 2)
  cfg.set_row_span(0, 2, 2)
  let records = @papergrid.IterRecords::new([
    ["0-0", "0-1", "0-2"],
    ["1-0", "1-1", "1-2"],
    ["2-0", "2-1", "2-2"],
  ])
  let dims = @papergrid.IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = @papergrid.IterGrid::new(records, cfg, dims)
  inspect(
    grid.to_string(),
    content=(
      #|+-----+-----+-----+
      #|+ 0-0 + 0-1 + 0-2 +
      #|+     +-----+-----+
      #||     | 2-1 | 2-2 |
      #|+-----+-----+-----+
    ),
  )
}

///|
test "row span all cols spanned" {
  let cfg = centered_grid_config()
  cfg.set_borders(@papergrid.Borders::ascii())
  cfg.set_row_span(0, 0, 2)
  cfg.set_row_span(0, 1, 2)
  cfg.set_row_span(0, 2, 2)
  let records = @papergrid.IterRecords::new([
    ["0-0", "0-1", "0-2"],
    ["1-0", "1-1", "1-2"],
  ])
  let dims = @papergrid.IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = @papergrid.IterGrid::new(records, cfg, dims)
  inspect(
    grid.to_string(),
    content=(
      #|+-----+-----+-----+
      #|+ 0-0 + 0-1 + 0-2 +
      #|+-----+-----+-----+
    ),
  )
}

///|
test "row span no split style" {
  let cfg = centered_grid_config()
  cfg.set_row_span(0, 0, 2)
  cfg.set_valign_for_cell(0, 0, @papergrid.VAlign::center())
  let records = @papergrid.IterRecords::new([
    ["1", "0-1"],
    ["2", "1-1"],
    ["3", "2-1"],
  ])
  let dims = @papergrid.IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = @papergrid.IterGrid::new(records, cfg, dims)
  inspect(
    grid.to_string(),
    content=(
      #|+---+-----+
      #||   | 0-1 |
      #|+ 1 +-----+
      #||   | 1-1 |
      #|+---+-----+
      #|| 3 | 2-1 |
      #|+---+-----+
    ),
  )
}

///|
test "row span with vertical padding" {
  let cfg = centered_grid_config()
  cfg.set_borders(@papergrid.Borders::ascii())
  cfg.set_row_span(0, 0, 2)
  cfg.set_padding_for_cell(0, 0, 0, 0, 4, 4)
  let records = @papergrid.IterRecords::new([
    ["0-0", "0-1"],
    ["1-0", "1-1"],
    ["2-0", "2-1"],
  ])
  let dims = @papergrid.IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = @papergrid.IterGrid::new(records, cfg, dims)
  inspect(
    grid.to_string(),
    content=(
      #|+-----+-----+
      #||     | 0-1 |
      #||     |     |
      #||     |     |
      #||     |     |
      #|+ 0-0 +-----+
      #||     | 1-1 |
      #||     |     |
      #||     |     |
      #||     |     |
      #|+-----+-----+
      #|| 2-0 | 2-1 |
      #|+-----+-----+
    ),
  )
}

///|
test "combined row and col span at top left corner" {
  let cfg = centered_grid_config()
  cfg.set_borders(@papergrid.Borders::ascii())
  cfg.set_row_span(0, 0, 2)
  cfg.set_col_span(0, 0, 2)
  cfg.set_align_for_cell(0, 0, @papergrid.HAlign::center())
  cfg.set_valign_for_cell(0, 0, @papergrid.VAlign::center())
  let records = @papergrid.IterRecords::new([
    ["123\n345\n555\n333", "0-1", "0-2", "0-3"],
    ["1-0", "1-1", "1-2", "1-3"],
    ["2-0", "2-1", "2-2", "2-3"],
    ["3-0", "3-1", "3-2", "3-3"],
  ])
  let dims = @papergrid.IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = @papergrid.IterGrid::new(records, cfg, dims)
  inspect(
    grid.to_string(),
    content=(
      #|+-----+-----+-----+-----+
      #||    123    | 0-2 | 0-3 |
      #||    345    |     |     |
      #|+    555    +-----+-----+
      #||    333    | 1-2 | 1-3 |
      #|+-----+-----+-----+-----+
      #|| 2-0 | 2-1 | 2-2 | 2-3 |
      #|+-----+-----+-----+-----+
      #|| 3-0 | 3-1 | 3-2 | 3-3 |
      #|+-----+-----+-----+-----+
    ),
  )
}

///|
test "combined row and col span at bottom right corner" {
  let cfg = centered_grid_config()
  cfg.set_borders(@papergrid.Borders::ascii())
  cfg.set_row_span(2, 2, 2)
  cfg.set_col_span(2, 2, 2)
  cfg.set_align_for_cell(2, 2, @papergrid.HAlign::center())
  cfg.set_valign_for_cell(2, 2, @papergrid.VAlign::center())
  let records = @papergrid.IterRecords::new([
    ["0-0", "0-1", "0-2", "0-3"],
    ["1-0", "1-1", "1-2", "1-3"],
    ["2-0", "2-1", "123\n345\n555\n333", "2-3"],
    ["3-0", "3-1", "3-2", "3-3"],
  ])
  let dims = @papergrid.IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = @papergrid.IterGrid::new(records, cfg, dims)
  inspect(
    grid.to_string(),
    content=(
      #|+-----+-----+-----+-----+
      #|| 0-0 | 0-1 | 0-2 | 0-3 |
      #|+-----+-----+-----+-----+
      #|| 1-0 | 1-1 | 1-2 | 1-3 |
      #|+-----+-----+-----+-----+
      #|| 2-0 | 2-1 |    123    |
      #||     |     |    345    |
      #|+-----+-----+    555    +
      #|| 3-0 | 3-1 |    333    |
      #|+-----+-----+-----+-----+
    ),
  )
}

///|
test "combined row and col span large center block" {
  let cfg = centered_grid_config()
  cfg.set_borders(@papergrid.Borders::ascii())
  cfg.set_row_span(1, 1, 3)
  cfg.set_col_span(1, 1, 3)
  cfg.set_align_for_cell(1, 1, @papergrid.HAlign::center())
  cfg.set_valign_for_cell(1, 1, @papergrid.VAlign::center())
  let records = @papergrid.IterRecords::new([
    ["0-0", "0-1", "0-2", "0-3"],
    ["1-0", "123\n345\n555\n333", "1-2", "1-3"],
    ["2-0", "2-1", "2-2", "2-3"],
    ["3-0", "3-1", "3-2", "3-3"],
  ])
  let dims = @papergrid.IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = @papergrid.IterGrid::new(records, cfg, dims)
  inspect(
    grid.to_string(),
    content=(
      #|+-----+-----+-----+-----+
      #|| 0-0 | 0-1 | 0-2 | 0-3 |
      #|+-----+-----+-----+-----+
      #|| 1-0 |       123       |
      #|+-----+       345       +
      #|| 2-0 |       555       |
      #|+-----+       333       +
      #|| 3-0 |                 |
      #|+-----+-----+-----+-----+
    ),
  )
}

///|
test "mixed row and col spans complex layout" {
  let cfg = centered_grid_config()
  cfg.set_borders(@papergrid.Borders::ascii())
  cfg.set_col_span(1, 1, 2)
  cfg.set_col_span(3, 0, 3)
  cfg.set_row_span(0, 0, 2)
  cfg.set_row_span(0, 3, 3)
  let records = @papergrid.IterRecords::new([
    ["hello\nworld\n!\n!\n!\n!", "0-1", "0-2", "0-3"],
    ["1-0", "1-1", "1-2", "1-3"],
    ["2-0", "2-1", "2-2", "2-3"],
    ["3-0", "3-1", "3-2", "3-3"],
  ])
  let dims = @papergrid.IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = @papergrid.IterGrid::new(records, cfg, dims)
  inspect(
    grid.to_string(),
    content=(
      #|+-------+-----+-----+-----+
      #|| hello | 0-1 | 0-2 | 0-3 |
      #|| world |     |     |     |
      #||   !   |     |     |     |
      #|+   !   +-----+-----+     +
      #||   !   |    1-1    |     |
      #||   !   |           |     |
      #|+-------+-----+-----+     +
      #||  2-0  | 2-1 | 2-2 |     |
      #|+-------+-----+-----+-----+
      #||        3-0        | 3-3 |
      #|+-------+-----+-----+-----+
    ),
  )
}

///|
test "zero span in col dimension is ignored" {
  let cfg = centered_grid_config()
  cfg.set_borders(@papergrid.Borders::ascii())
  cfg.set_col_span(0, 1, 0)
  let records = @papergrid.IterRecords::new([["0-0", "0-1"], ["1-0", "1-1"]])
  let dims = @papergrid.IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = @papergrid.IterGrid::new(records, cfg, dims)
  inspect(
    grid.to_string(),
    content=(
      #|+-----+-----+
      #|| 0-0 | 0-1 |
      #|+-----+-----+
      #|| 1-0 | 1-1 |
      #|+-----+-----+
    ),
  )
}

///|
test "zero span grid all rows and cols spanned" {
  let cfg = centered_grid_config()
  cfg.set_borders(@papergrid.Borders::ascii())
  cfg.set_row_span(0, 0, 2)
  cfg.set_row_span(0, 1, 2)
  let records = @papergrid.IterRecords::new([["123", "axc"], ["asd", "asd"]])
  let dims = @papergrid.IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = @papergrid.IterGrid::new(records, cfg, dims)
  inspect(
    grid.to_string(),
    content=(
      #|+-----+-----+
      #|+ 123 + axc +
      #|+-----+-----+
    ),
  )
}

///|
test "5x2 row span spanning 4 rows" {
  let cfg = centered_grid_config()
  cfg.set_borders(@papergrid.Borders::ascii())
  cfg.set_row_span(1, 1, 4)
  let records = @papergrid.IterRecords::new([
    ["0-0", "0-1"],
    ["1-0", "1\n2\n3\n4"],
    ["2-0", "2-1"],
    ["3-0", "3-1"],
    ["4-0", "4-1"],
  ])
  let dims = @papergrid.IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = @papergrid.IterGrid::new(records, cfg, dims)
  inspect(
    grid.to_string(),
    content=(
      #|+-----+-----+
      #|| 0-0 | 0-1 |
      #|+-----+-----+
      #|| 1-0 |  1  |
      #|+-----+  2  +
      #|| 2-0 |  3  |
      #|+-----+  4  +
      #|| 3-0 |     |
      #|+-----+     +
      #|| 4-0 |     |
      #|+-----+-----+
    ),
  )
}
