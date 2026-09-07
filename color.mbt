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
pub fn Color::as_ansi_str(self : Color) -> @papergrid.ANSIBuf? {
  if self.static_ {
    Some(self.ansi)
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
pub fn Color::rgb_fg(red : Byte, green : Byte, blue : Byte) -> Color {
  Color::new(
    "\u001b[38;2;\{red.to_int()};\{green.to_int()};\{blue.to_int()}m",
    "\u001b[39m",
  )
}

///|
pub fn Color::rgb_bg(red : Byte, green : Byte, blue : Byte) -> Color {
  Color::new(
    "\u001b[48;2;\{red.to_int()};\{green.to_int()};\{blue.to_int()}m",
    "\u001b[49m",
  )
}

///|
/// Combine styles in order, deduplicating identical prefixes or suffixes.
pub fn Color::bitor(self : Color, other : Color) -> Color {
  Color::new(
    self.ansi.prefix +
    (if self.ansi.prefix == other.ansi.prefix { "" } else { other.ansi.prefix }),
    self.ansi.suffix +
    (if self.ansi.suffix == other.ansi.suffix { "" } else { other.ansi.suffix }),
  )
}

///|
pub impl BitOr for Color with fn lor(self, other) {
  self.bitor(other)
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
