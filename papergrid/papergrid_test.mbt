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
