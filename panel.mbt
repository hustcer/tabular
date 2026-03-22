///|
struct PanelConfig {
  index : Int
  text : String
  is_horizontal : Bool
}

///|
/// Insert a horizontal panel at the given row index.
/// The panel text spans all cols.
pub fn Panel::horizontal(row : Int, text : String) -> PanelConfig {
  { index: row, text, is_horizontal: true }
}

///|
/// Insert a header panel at row 0.
pub fn Panel::header(text : String) -> PanelConfig {
  { index: 0, text, is_horizontal: true }
}

///|
/// Insert a footer panel after the last row.
pub fn Panel::footer(text : String) -> PanelConfig {
  { index: -1, text, is_horizontal: true }
}

///|
/// Insert a vertical panel at the given col index.
/// The panel text spans all rows.
pub fn Panel::vertical(col : Int, text : String) -> PanelConfig {
  { index: col, text, is_horizontal: false }
}

///|
/// Apply a horizontal or vertical panel to the table.
pub fn Table::panel(self : Table, panel : PanelConfig) -> Table {
  if panel.is_horizontal {
    self.apply_horizontal_panel(panel.index, panel.text)
  } else {
    self.apply_vertical_panel(panel.index, panel.text)
  }
  self
}

///|
/// Split a string by character width, inserting newlines.
fn split_string_by_width(s : String, width : Int) -> String {
  if width <= 0 {
    return ""
  }
  let buf = StringBuilder::new()
  let mut count = 0
  for ch in s {
    if count >= width {
      buf.write_char('\n')
      count = 0
    }
    buf.write_char(ch)
    count += 1
  }
  buf.to_string()
}

///|
/// Insert a vertical panel with text split to fit a certain width.
pub fn Panel::vertical_with_width(
  col : Int,
  text : String,
  width : Int,
) -> PanelConfig {
  let split_text = split_string_by_width(text, width)
  { index: col, text: split_text, is_horizontal: false }
}

///|
fn Table::apply_horizontal_panel(
  self : Table,
  row : Int,
  text : String,
) -> Unit {
  let count_rows = self.rows.length()
  let count_cols = if count_rows > 0 { self.rows[0].length() } else { 1 }
  // Resolve special row values
  let target_row = if row < 0 { count_rows } else { row }
  // Bounds check
  if target_row > count_rows {
    return
  }
  // Check if any cell at target_row is covered by a row span
  for col in 0..<count_cols {
    if self.config.is_cell_covered_by_row_span(target_row, col) {
      return
    }
  }
  // Insert an empty row at target_row, shifting existing rows down
  let new_row = Array::make(count_cols, "")
  self.rows.insert(target_row, new_row)
  // Shift span metadata
  self.config.shift_row_spans_down(target_row)
  // Set the panel text in the first col
  self.rows[target_row][0] = text
  // Set col span to cover all cols
  if count_cols > 1 {
    self.config.set_col_span(target_row, 0, count_cols)
  }
}

///|
fn Table::apply_vertical_panel(self : Table, col : Int, text : String) -> Unit {
  let count_rows = self.rows.length()
  let count_cols = if count_rows > 0 { self.rows[0].length() } else { 0 }
  // Bounds check
  if col > count_cols {
    return
  }
  // Check if any cell at target_col is covered by a col span
  for row = 0; row <= count_rows; row = row + 1 {
    if row < count_rows && self.config.is_cell_covered_by_col_span(row, col) {
      return
    }
  }
  // Insert an empty col at target_col in each row
  self.rows.each(row => row.insert(col, ""))
  // Shift span metadata
  self.config.shift_col_spans_right(col)
  // Set the panel text in the first row
  if count_rows > 0 {
    self.rows[0][col] = text
  }
  // Set row span to cover all rows
  if count_rows > 1 {
    self.config.set_row_span(0, col, count_rows)
  }
}
