///|
// Preserve the initial configuration of the existing grid snapshot scenarios.
// A bare papergrid config now follows upstream: no borders/padding, left aligned.
fn centered_grid_config() -> @papergrid.SpannedConfig {
  let cfg = @papergrid.SpannedConfig::default()
  cfg.set_borders(@papergrid.Borders::ascii())
  cfg.set_padding(1, 1, 0, 0)
  cfg.set_align(@papergrid.HAlign::center())
  cfg.set_line_alignment(@papergrid.Entity::Global, true)
  cfg
}
