///|
/// Independent colors for the four padding sides.
pub struct PaddingColor[C] {
  colors : Sides[C]
} derive(Eq, Debug)

///|
pub fn[C] PaddingColor::new(
  left : C,
  right : C,
  top : C,
  bottom : C,
) -> PaddingColor[C] {
  { colors: Sides::new(left, right, top, bottom), }
}

///|
pub fn[C] PaddingColor::filled(color : C) -> PaddingColor[C] {
  { colors: Sides::filled(color), }
}

///|
pub fn PaddingColor::empty() -> PaddingColor[@papergrid.ANSIStr] {
  PaddingColor::filled(@papergrid.ANSIStr::empty())
}

///|
pub fn[C] PaddingColor::to_sides(self : PaddingColor[C]) -> Sides[C] {
  self.colors
}

///|
pub fn[C] PaddingColor::from_sides(colors : Sides[C]) -> PaddingColor[C] {
  { colors, }
}

///|
fn[C : @papergrid.ANSIFmt] indent_ansi_buffer(color : C) -> @papergrid.ANSIBuf {
  let prefix = StringBuilder()
  let suffix = StringBuilder()
  @papergrid.ANSIFmt::fmt_ansi_prefix(color, prefix)
  @papergrid.ANSIFmt::fmt_ansi_suffix(color, suffix)
  @papergrid.ANSIBuf::new(prefix.to_string(), suffix.to_string())
}

///|
pub impl[C : @papergrid.ANSIFmt] CellOption for PaddingColor[C] with fn change(
  self,
  table,
  entity,
) {
  table.config.set_padding_color(
    entity,
    self.colors.map(color => Some(indent_ansi_buffer(color))),
  )
}

///|
pub impl[C : @papergrid.ANSIFmt] TableOption for PaddingColor[C] with fn change(
  self,
  table,
) {
  CellOption::change(self, table, Entity::Global)
}

///|
pub struct MarginColor[C] {
  colors : Sides[C]
} derive(Debug)

///|
pub fn[C] MarginColor::new(
  left : C,
  right : C,
  top : C,
  bottom : C,
) -> MarginColor[C] {
  { colors: Sides::new(left, right, top, bottom), }
}

///|
pub fn[C] MarginColor::filled(color : C) -> MarginColor[C] {
  { colors: Sides::filled(color), }
}

///|
pub fn MarginColor::empty() -> MarginColor[@papergrid.ANSIStr] {
  MarginColor::filled(@papergrid.ANSIStr::empty())
}

///|
pub impl[C : @papergrid.ANSIFmt] TableOption for MarginColor[C] with fn change(
  self,
  table,
) {
  table.config.set_margin_color(
    self.colors.map(color => Some(indent_ansi_buffer(color))),
  )
}
