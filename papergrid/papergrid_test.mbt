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
  cfg.set_alignment_for_cell(1, 1, AlignmentHorizontal::center())
  cfg.set_vertical_alignment_for_cell(1, 1, AlignmentVertical::center())
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
test "iter grid row span boundary content with centered vertical alignment" {
  let cfg = SpannedConfig::default()
  cfg.set_borders(Borders::ascii())
  cfg.set_row_span(0, 0, 2)
  cfg.set_row_span(0, 1, 2)
  cfg.set_vertical_alignment_for_all(AlignmentVertical::center())
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
test "iter grid row span boundary content with bottom vertical alignment" {
  let cfg = SpannedConfig::default()
  cfg.set_borders(Borders::ascii())
  cfg.set_row_span(0, 0, 2)
  cfg.set_row_span(0, 1, 2)
  cfg.set_vertical_alignment_for_all(AlignmentVertical::bottom())
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
