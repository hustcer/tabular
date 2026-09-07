///|
// Equivalent to papergrid/tests/util/grid_builder.rs::Grid::new defaults.
fn upstream_formatting_config() -> SpannedConfig {
  let config = SpannedConfig::default()
  config.set_borders(Borders::ascii())
  config
}

///|
fn upstream_formatting_render(
  rows : Array[Array[String]],
  config : SpannedConfig,
) -> String {
  let records = IterRecords::new(rows)
  let dimension = IterGridDimension::default()
  dimension.estimate(records, config)
  IterGrid::new(records, config, dimension).to_string()
}
