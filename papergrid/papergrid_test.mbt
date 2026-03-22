///|
test "iter grid ascii output" {
  let borders = Borders::ascii()
  let cfg = SpannedConfig::default()
  cfg.set_borders(borders)
  let records = IterRecords::new([["Hello", "World"], ["Hi", "MoonBit"]])
  let dims = IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = IterGrid::new(records, cfg, dims)
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
  let cfg = SpannedConfig::default()
  cfg.set_borders(Borders::ascii())
  let records = IterRecords::new([
    ["left\ncell", "right one"],
    ["the second column", "and\nhere"],
  ])
  let dims = IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = IterGrid::new(records, cfg, dims)
  inspect(
    grid.to_string(),
    content=(
      #|+-------------------+-----------+
      #||       left        | right one |
      #||       cell        |           |
      #|+-------------------+-----------+
      #|| the second column |    and    |
      #||                   |   here    |
      #|+-------------------+-----------+
    ),
  )
}

///|
test "iter grid column span output" {
  let cfg = SpannedConfig::default()
  cfg.set_borders(Borders::ascii())
  cfg.set_column_span(0, 0, 2)
  let records = IterRecords::new([["0-0", ""], ["1-0", "1-1"]])
  let dims = IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = IterGrid::new(records, cfg, dims)
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
  let cfg = SpannedConfig::default()
  cfg.set_borders(Borders::ascii())
  cfg.set_row_span(0, 0, 2)
  let records = IterRecords::new([["0-0", "0-1"], ["1-0", "1-1"]])
  let dims = IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = IterGrid::new(records, cfg, dims)
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
  let cfg = SpannedConfig::default()
  cfg.set_borders(Borders::ascii())
  cfg.set_row_span(0, 0, 2)
  cfg.set_row_span(1, 1, 2)
  let records = IterRecords::new([
    ["0-0", "0-1", "0-2"],
    ["1-0", "1-1\nx\nx\nxxxxx", "1-2"],
    ["2-0", "2-1", "2-2"],
  ])
  let dims = IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = IterGrid::new(records, cfg, dims)
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
test "iter grid combined row and column span multiline output" {
  let cfg = SpannedConfig::default()
  cfg.set_borders(Borders::ascii())
  cfg.set_row_span(1, 1, 2)
  cfg.set_column_span(1, 1, 2)
  cfg.set_align_for_cell(1, 1, HAlign::center())
  cfg.set_valign_for_cell(1, 1, VAlign::center())
  let records = IterRecords::new([
    ["0-0", "0-1", "0-2", "0-3"],
    ["1-0", "123\n345\n555\n333", "1-2", "1-3"],
    ["2-0", "2-1", "2-2", "2-3"],
    ["3-0", "3-1", "3-2", "3-3"],
  ])
  let dims = IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = IterGrid::new(records, cfg, dims)
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
  let cfg = SpannedConfig::default()
  cfg.set_borders(Borders::ascii())
  cfg.set_row_span(0, 0, 2)
  cfg.set_row_span(0, 1, 2)
  cfg.set_valign_for_all(VAlign::center())
  let records = IterRecords::new([["1as\nd\n", "a"], ["as\ndasdds\na", "asd"]])
  let dims = IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = IterGrid::new(records, cfg, dims)
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
  let cfg = SpannedConfig::default()
  cfg.set_borders(Borders::ascii())
  cfg.set_row_span(0, 0, 2)
  cfg.set_row_span(0, 1, 2)
  cfg.set_valign_for_all(VAlign::bottom())
  let records = IterRecords::new([["1a\ns\nd", "a"], ["as\ndasdds\na", "asd"]])
  let dims = IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = IterGrid::new(records, cfg, dims)
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
// Column span edge cases from upstream column_span.rs
// ──────────────────────────────────────────────────

///|
test "column span multilane with custom data" {
  let cfg = SpannedConfig::default()
  cfg.set_borders(Borders::ascii())
  cfg.set_column_span(0, 0, 2)
  cfg.set_column_span(3, 0, 3)
  let records = IterRecords::new([
    ["first line", "", "e.g."],
    ["0", "1", "2"],
    ["0", "1", "2"],
    ["full last line", "", ""],
  ])
  let dims = IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = IterGrid::new(records, cfg, dims)
  inspect(
    grid.to_string(),
    content=(
      #|+---+--------+------+
      #|| first line | e.g. |
      #|+---+--------+------+
      #|| 0 |   1    |  2   |
      #|+---+--------+------+
      #|| 0 |   1    |  2   |
      #|+---+--------+------+
      #||  full last line   |
      #|+---+--------+------+
    ),
  )
}

///|
test "column span collision two spans different widths" {
  let cfg = SpannedConfig::default()
  cfg.set_borders(Borders::ascii())
  cfg.set_column_span(0, 0, 2)
  cfg.set_column_span(1, 1, 2)
  let records = IterRecords::new([
    ["0-0xxxxxxx", "0-1", "0-2"],
    ["1-0", "1-1", "1-2"],
    ["2-0", "2-1", "2-2"],
  ])
  let dims = IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = IterGrid::new(records, cfg, dims)
  inspect(
    grid.to_string(),
    content=(
      #|+-----+------+-----+
      #|| 0-0xxxxxxx | 0-2 |
      #|+-----+------+-----+
      #|| 1-0 |    1-1     |
      #|+-----+------+-----+
      #|| 2-0 | 2-1  | 2-2 |
      #|+-----+------+-----+
    ),
  )
}

///|
test "column span all rows spanned" {
  let cfg = SpannedConfig::default()
  cfg.set_borders(Borders::ascii())
  cfg.set_column_span(0, 0, 2)
  cfg.set_column_span(1, 0, 2)
  cfg.set_column_span(2, 0, 2)
  let records = IterRecords::new([
    ["0-0", "0-1"],
    ["1-0", "1-1"],
    ["2-0", "2-1"],
  ])
  let dims = IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = IterGrid::new(records, cfg, dims)
  inspect(
    grid.to_string(),
    content=(
      #|++----+
      #|| 0-0 |
      #|++----+
      #|| 1-0 |
      #|++----+
      #|| 2-0 |
      #|++----+
    ),
  )
}

///|
test "column span with different length data" {
  let cfg = SpannedConfig::default()
  cfg.set_borders(Borders::ascii())
  cfg.set_column_span(0, 0, 2)
  cfg.set_column_span(2, 0, 2)
  let records = IterRecords::new([
    ["first row", ""],
    ["0", "1"],
    ["a longer second row", ""],
  ])
  let dims = IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = IterGrid::new(records, cfg, dims)
  inspect(
    grid.to_string(),
    content=(
      #|+---+-----------------+
      #||      first row      |
      #|+---+-----------------+
      #|| 0 |        1        |
      #|+---+-----------------+
      #|| a longer second row |
      #|+---+-----------------+
    ),
  )
}

///|
test "column span no split style" {
  let cfg = SpannedConfig::default()
  cfg.set_column_span(0, 0, 2)
  cfg.set_align_for_cell(0, 0, HAlign::center())
  let records = IterRecords::new([["0-0", ""], ["1-0", "1-1"]])
  let dims = IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = IterGrid::new(records, cfg, dims)
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
  let cfg = SpannedConfig::default()
  cfg.set_borders(Borders::ascii())
  cfg.set_row_span(0, 0, 2)
  cfg.set_row_span(1, 1, 2)
  let records = IterRecords::new([
    ["0-0xxxxxxx", "0-1", "0-2"],
    ["1-0", "1-1", "1-2"],
    ["2-0", "2-1", "2-2"],
  ])
  let dims = IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = IterGrid::new(records, cfg, dims)
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
  let cfg = SpannedConfig::default()
  cfg.set_borders(Borders::ascii())
  cfg.set_row_span(0, 0, 3)
  cfg.set_row_span(0, 1, 2)
  cfg.set_row_span(0, 2, 2)
  let records = IterRecords::new([
    ["0-0", "0-1", "0-2"],
    ["1-0", "1-1", "1-2"],
    ["2-0", "2-1", "2-2"],
  ])
  let dims = IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = IterGrid::new(records, cfg, dims)
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
test "row span all columns spanned" {
  let cfg = SpannedConfig::default()
  cfg.set_borders(Borders::ascii())
  cfg.set_row_span(0, 0, 2)
  cfg.set_row_span(0, 1, 2)
  cfg.set_row_span(0, 2, 2)
  let records = IterRecords::new([["0-0", "0-1", "0-2"], ["1-0", "1-1", "1-2"]])
  let dims = IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = IterGrid::new(records, cfg, dims)
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
  let cfg = SpannedConfig::default()
  cfg.set_row_span(0, 0, 2)
  cfg.set_valign_for_cell(0, 0, VAlign::center())
  let records = IterRecords::new([["1", "0-1"], ["2", "1-1"], ["3", "2-1"]])
  let dims = IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = IterGrid::new(records, cfg, dims)
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
  let cfg = SpannedConfig::default()
  cfg.set_borders(Borders::ascii())
  cfg.set_row_span(0, 0, 2)
  cfg.set_padding_for_cell(0, 0, 0, 0, 4, 4)
  let records = IterRecords::new([
    ["0-0", "0-1"],
    ["1-0", "1-1"],
    ["2-0", "2-1"],
  ])
  let dims = IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = IterGrid::new(records, cfg, dims)
  inspect(
    grid.to_string(),
    content=(
      #|+-----+-----+
      #||     |     |
      #||     |     |
      #||     |     |
      #||     |     |
      #|| 0-0 | 0-1 |
      #|+     +-----+
      #||     | 1-1 |
      #||     |     |
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
test "combined row and column span at top left corner" {
  let cfg = SpannedConfig::default()
  cfg.set_borders(Borders::ascii())
  cfg.set_row_span(0, 0, 2)
  cfg.set_column_span(0, 0, 2)
  cfg.set_align_for_cell(0, 0, HAlign::center())
  cfg.set_valign_for_cell(0, 0, VAlign::center())
  let records = IterRecords::new([
    ["123\n345\n555\n333", "0-1", "0-2", "0-3"],
    ["1-0", "1-1", "1-2", "1-3"],
    ["2-0", "2-1", "2-2", "2-3"],
    ["3-0", "3-1", "3-2", "3-3"],
  ])
  let dims = IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = IterGrid::new(records, cfg, dims)
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
test "combined row and column span at bottom right corner" {
  let cfg = SpannedConfig::default()
  cfg.set_borders(Borders::ascii())
  cfg.set_row_span(2, 2, 2)
  cfg.set_column_span(2, 2, 2)
  cfg.set_align_for_cell(2, 2, HAlign::center())
  cfg.set_valign_for_cell(2, 2, VAlign::center())
  let records = IterRecords::new([
    ["0-0", "0-1", "0-2", "0-3"],
    ["1-0", "1-1", "1-2", "1-3"],
    ["2-0", "2-1", "123\n345\n555\n333", "2-3"],
    ["3-0", "3-1", "3-2", "3-3"],
  ])
  let dims = IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = IterGrid::new(records, cfg, dims)
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
test "combined row and column span large center block" {
  let cfg = SpannedConfig::default()
  cfg.set_borders(Borders::ascii())
  cfg.set_row_span(1, 1, 3)
  cfg.set_column_span(1, 1, 3)
  cfg.set_align_for_cell(1, 1, HAlign::center())
  cfg.set_valign_for_cell(1, 1, VAlign::center())
  let records = IterRecords::new([
    ["0-0", "0-1", "0-2", "0-3"],
    ["1-0", "123\n345\n555\n333", "1-2", "1-3"],
    ["2-0", "2-1", "2-2", "2-3"],
    ["3-0", "3-1", "3-2", "3-3"],
  ])
  let dims = IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = IterGrid::new(records, cfg, dims)
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
test "mixed row and column spans complex layout" {
  let cfg = SpannedConfig::default()
  cfg.set_borders(Borders::ascii())
  cfg.set_column_span(1, 1, 2)
  cfg.set_column_span(3, 0, 3)
  cfg.set_row_span(0, 0, 2)
  cfg.set_row_span(0, 3, 3)
  let records = IterRecords::new([
    ["hello\nworld\n!\n!\n!\n!", "0-1", "0-2", "0-3"],
    ["1-0", "1-1", "1-2", "1-3"],
    ["2-0", "2-1", "2-2", "2-3"],
    ["3-0", "3-1", "3-2", "3-3"],
  ])
  let dims = IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = IterGrid::new(records, cfg, dims)
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
test "zero span in column dimension is ignored" {
  let cfg = SpannedConfig::default()
  cfg.set_borders(Borders::ascii())
  cfg.set_column_span(0, 1, 0)
  let records = IterRecords::new([["0-0", "0-1"], ["1-0", "1-1"]])
  let dims = IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = IterGrid::new(records, cfg, dims)
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
  let cfg = SpannedConfig::default()
  cfg.set_borders(Borders::ascii())
  cfg.set_row_span(0, 0, 2)
  cfg.set_row_span(0, 1, 2)
  let records = IterRecords::new([["123", "axc"], ["asd", "asd"]])
  let dims = IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = IterGrid::new(records, cfg, dims)
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
  let cfg = SpannedConfig::default()
  cfg.set_borders(Borders::ascii())
  cfg.set_row_span(1, 1, 4)
  let records = IterRecords::new([
    ["0-0", "0-1"],
    ["1-0", "1\n2\n3\n4"],
    ["2-0", "2-1"],
    ["3-0", "3-1"],
    ["4-0", "4-1"],
  ])
  let dims = IterGridDimension::default()
  dims.estimate(records, cfg)
  let grid = IterGrid::new(records, cfg, dims)
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
