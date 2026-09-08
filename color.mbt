///|
/// A reusable ANSI text style. Predefined colors use lowercase constructors
/// in place of Rust's associated constants.
pub struct Color {
  priv ansi : @papergrid.ANSIBuf
  priv static_ : Bool
} derive(Eq, Debug)

///|
pub fn Color::new(prefix : String, suffix : String) -> Color {
  { ansi: @papergrid.ANSIBuf::new(prefix, suffix), static_: false, }
}

///|
fn Color::new_static(prefix : String, suffix : String) -> Color {
  { ansi: @papergrid.ANSIBuf::new(prefix, suffix), static_: true, }
}

///|
pub fn Color::empty() -> Color {
  Color::new_static("", "")
}

///|
pub fn Color::default() -> Color {
  Color::empty()
}

///|
/// Extract the style of the first text block; no text block produces Err.
pub fn Color::try_parse(text : String) -> Result[Color, Unit] {
  @papergrid.ANSIBuf::try_parse(text).map(Color::from_ansi_buf)
}

///|
/// Parse a style, aborting on input without a text block. Use `try_parse` when
/// a missing text block must be handled explicitly.
pub fn Color::parse_or_abort(text : String) -> Color {
  match Color::try_parse(text) {
    Ok(color) => color
    Err(_) => abort("Color::parse_or_abort requires a text block")
  }
}

///|
pub fn Color::is_empty(self : Color) -> Bool {
  self.ansi.is_empty()
}

///|
pub fn Color::get_prefix(self : Color) -> String {
  self.ansi.prefix
}

///|
pub fn Color::get_suffix(self : Color) -> String {
  self.ansi.suffix
}

///|
/// Return a style pair only for colors created from a static preset or ANSIStr.
/// Dynamically parsed or constructed colors return None; use `to_ansi_buf` for those.
pub fn Color::as_static_ansi(self : Color) -> @papergrid.ANSIStr? {
  if self.static_ {
    Some(self.ansi.as_ansi_str())
  } else {
    None
  }
}

///|
pub fn Color::to_ansi_buf(self : Color) -> @papergrid.ANSIBuf {
  self.ansi
}

///|
pub fn Color::from_ansi_buf(ansi : @papergrid.ANSIBuf) -> Color {
  { ansi, static_: false, }
}

///|
pub fn Color::from_ansi_str(ansi : @papergrid.ANSIStr) -> Color {
  { ansi: @papergrid.ANSIBuf::from_ansi_str(ansi), static_: true, }
}

///|
pub impl @papergrid.ANSIFmt for Color with fn fmt_ansi_prefix(self, out) {
  out.write_string(self.ansi.prefix)
}

///|
pub impl @papergrid.ANSIFmt for Color with fn fmt_ansi_suffix(self, out) {
  out.write_string(self.ansi.suffix)
}

///|
pub fn Color::fg_rgb(red : Byte, green : Byte, blue : Byte) -> Color {
  Color::new(
    "\u001b[38;2;\{red.to_int()};\{green.to_int()};\{blue.to_int()}m",
    "\u001b[39m",
  )
}

///|
pub fn Color::bg_rgb(red : Byte, green : Byte, blue : Byte) -> Color {
  Color::new(
    "\u001b[48;2;\{red.to_int()};\{green.to_int()};\{blue.to_int()}m",
    "\u001b[49m",
  )
}

///|
/// Combine styles in order, deduplicating identical prefixes or suffixes.
pub fn Color::combine(self : Color, other : Color) -> Color {
  Color::new(
    self.ansi.prefix +
    (if self.ansi.prefix == other.ansi.prefix { "" } else { other.ansi.prefix }),
    self.ansi.suffix +
    (if self.ansi.suffix == other.ansi.suffix { "" } else { other.ansi.suffix }),
  )
}

///|
pub impl BitOr for Color with fn lor(self, other) {
  self.combine(other)
}

///|
/// Color each logical line separately; a trailing newline is omitted, as in tabled.
pub fn Color::colorize(self : Color, text : String) -> String {
  guard !text.is_empty() else { return "" }
  let lines = @papergrid.split_lines(text)
  if text.has_suffix("\n") {
    lines.pop() |> ignore
  }
  let result = []
  for index, line in lines {
    let line = if line.has_suffix("\r") &&
      (index + 1 < lines.length() || text.has_suffix("\n")) {
      line[:line.length() - 1].to_owned()
    } else {
      line
    }
    result.push(self.ansi.prefix + line + self.ansi.suffix)
  }
  result.join("\n")
}

///|
pub impl CellOption for Color with fn change(self, table, entity) {
  table.config.set_color(entity, Some(self.ansi))
}

///|
pub impl TableOption for Color with fn change(self, table) {
  CellOption::change(self, table, Entity::Global)
}

///|
pub impl CellOption for Color with fn hint_change(_self) {
  None
}

///|
pub impl TableOption for Color with fn hint_change(_self) {
  None
}
