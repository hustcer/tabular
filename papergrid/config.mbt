///|
pub struct SpannedConfig {
  mut borders : Borders
}

///|
pub fn SpannedConfig::default() -> SpannedConfig {
  { borders: Borders::ascii() }
}

///|
pub fn SpannedConfig::set_borders(
  self : SpannedConfig,
  borders : Borders,
) -> Unit {
  self.borders = borders
}

///|
pub fn SpannedConfig::borders(self : SpannedConfig) -> Borders {
  self.borders
}
