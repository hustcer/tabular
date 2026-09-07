///|
/// Clean layout-disrupting control characters and expand tabs in records.
pub struct Charset {
  priv cleaning : Bool
  priv tab : Int?
}

///|
pub fn Charset::new() -> Charset {
  { cleaning: false, tab: None, }
}

///|
pub fn Charset::default() -> Charset {
  Charset::new()
}

///|
pub fn Charset::clean(self : Charset) -> Charset {
  { ..self, cleaning: true, }
}

///|
pub fn Charset::tab_size(self : Charset, size : Int) -> Charset {
  { ..self, tab: Some(Int::max(0, size)), }
}

///|
/// Remove control characters except newlines and expand tabs to four spaces.
///
/// ```mbt check
/// test {
///   assert_eq(Charset::charset_clean("a\tb\r\nc"), "a    b\nc")
/// }
/// ```
pub fn Charset::charset_clean(text : String) -> String {
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
pub impl CellOption for Charset with fn change(self, table, entity) {
  if !self.cleaning && self.tab is None {
    return
  }
  for position in entity.iter(table.count_rows(), table.count_columns()) {
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
pub impl TableOption for Charset with fn change(self, table) {
  CellOption::change(self, table, Entity::Global)
}
