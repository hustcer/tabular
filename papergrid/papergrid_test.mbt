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
