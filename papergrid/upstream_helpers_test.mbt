///|
// Equivalent to papergrid/tests/util/grid_builder.rs::Grid::new defaults.
fn upstream_formatting_config() -> @papergrid.SpannedConfig {
  let config = @papergrid.SpannedConfig::default()
  config.set_borders(@papergrid.Borders::ascii())
  config
}

///|
fn upstream_formatting_render(
  rows : Array[Array[String]],
  config : @papergrid.SpannedConfig,
) -> String {
  let records = @papergrid.IterRecords::new(rows)
  let dimension = @papergrid.IterGridDimension::default()
  dimension.estimate(records, config)
  @papergrid.IterGrid::new(records, config, dimension).to_string()
}
