///|
// Preserve the initial configuration of the existing grid snapshot scenarios.
// A bare papergrid config now follows upstream: no borders/padding, left aligned.
fn centered_grid_config() -> SpannedConfig {
  let cfg = SpannedConfig::default()
  cfg.set_borders(Borders::ascii())
  cfg.set_padding(1, 1, 0, 0)
  cfg.set_align(HAlign::center())
  cfg.set_line_alignment(Entity::Global, true)
  cfg
}
