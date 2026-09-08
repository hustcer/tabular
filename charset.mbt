///|
/// Clean layout-disrupting control characters and expand tabs in records.
pub struct TextCleanup {
  priv cleaning : Bool
  priv tab : Int?
}

///|
pub fn TextCleanup::new() -> TextCleanup {
  { cleaning: false, tab: None, }
}

///|
pub fn TextCleanup::default() -> TextCleanup {
  TextCleanup::new()
}

///|
/// Remove C0 controls (U+0000..U+001F), preserving newlines.
/// Tabs are removed unless `expand_tabs` supplies their replacement width.
pub fn TextCleanup::remove_control_chars(self : TextCleanup) -> TextCleanup {
  { ..self, cleaning: true, }
}

///|
/// Replace each tab with `tab_width` spaces, independently of its column.
pub fn TextCleanup::expand_tabs(
  self : TextCleanup,
  tab_width : Int,
) -> TextCleanup {
  { ..self, tab: Some(Int::max(0, tab_width)), }
}

///|
/// Remove C0 controls except newlines and expand tabs to four spaces.
///
/// ```mbt check
/// test {
///   assert_eq(TextCleanup::clean_text("a\tb\r\nc"), "a    b\nc")
/// }
/// ```
pub fn TextCleanup::clean_text(text : String) -> String {
  charset_transform(text, true, Some(4))
}

///|
fn charset_transform(text : String, clean : Bool, tab_size : Int?) -> String {
  if !clean && tab_size is None {
    return text
  }
  let out = StringBuilder()
  for ch in text {
    if ch == '\t' {
      match tab_size {
        Some(size) => out.write_string(" ".repeat(size))
        None => if !clean { out.write_char(ch) }
      }
    } else if !clean || ch == '\n' || ch >= ' ' {
      out.write_char(ch)
    }
  }
  out.to_string()
}

///|
pub impl CellOption for TextCleanup with fn change(self, table, entity) {
  if !self.cleaning && self.tab is None {
    return
  }
  for position in entity.iter(table.count_rows(), table.count_cols()) {
    let row = table.rows[position.0]
    if position.1 < row.length() {
      row[position.1] = charset_transform(
        row[position.1],
        self.cleaning,
        self.tab,
      )
    }
  }
}

///|
pub impl TableOption for TextCleanup with fn change(self, table) {
  CellOption::change(self, table, Entity::Global)
}
