///|
pub enum Merge {
  Horizontal
  Vertical
}

///|
pub fn Merge::horizontal() -> Merge {
  Horizontal
}

///|
pub fn Merge::vertical() -> Merge {
  Vertical
}

///|
fn merge_horizontal(
  rows : Array[Array[String]],
  config : @papergrid.SpannedConfig,
  count_rows : Int,
  count_cols : Int,
) -> Unit {
  for row in 0..<count_rows {
    let mut repeat_length = 0
    let mut repeat_value = ""
    let mut repeat_is_set = false
    let mut last_is_col_span = false
    for col = count_cols - 1; col >= 0; col = col - 1 {
      if last_is_col_span {
        last_is_col_span = false
        continue
      }
      let is_cell_visible = config.is_cell_visible(row, col)
      let is_col_span_cell = config.get_row_span(row, col) is Some(_)
      if not(repeat_is_set) {
        if not(is_cell_visible) {
          continue
        }
        if is_col_span_cell {
          continue
        }
        repeat_length = 1
        repeat_value = rows[row][col]
        repeat_is_set = true
        continue
      }
      if is_col_span_cell {
        repeat_is_set = false
        last_is_col_span = true
        continue
      }
      if not(is_cell_visible) {
        repeat_is_set = false
        continue
      }
      let text = rows[row][col]
      if text == repeat_value {
        repeat_length = repeat_length + 1
        continue
      }
      if repeat_length > 1 {
        config.set_col_span(row, col + 1, repeat_length)
      }
      repeat_length = 1
      repeat_value = rows[row][col]
    }
    if repeat_length > 1 {
      config.set_col_span(row, 0, repeat_length)
    }
  }
}

///|
fn merge_vertical(
  rows : Array[Array[String]],
  config : @papergrid.SpannedConfig,
  count_rows : Int,
  count_cols : Int,
) -> Unit {
  for col in 0..<count_cols {
    let mut repeat_length = 0
    let mut repeat_value = ""
    let mut repeat_is_set = false
    let mut last_is_row_span = false
    for row = count_rows - 1; row >= 0; row = row - 1 {
      if last_is_row_span {
        last_is_row_span = false
        continue
      }
      let is_cell_visible = config.is_cell_visible(row, col)
      let is_row_span_cell = config.get_col_span(row, col) is Some(_)
      if not(repeat_is_set) {
        if not(is_cell_visible) {
          continue
        }
        if is_row_span_cell {
          continue
        }
        repeat_length = 1
        repeat_value = rows[row][col]
        repeat_is_set = true
        continue
      }
      if is_row_span_cell {
        repeat_is_set = false
        last_is_row_span = true
        continue
      }
      if not(is_cell_visible) {
        repeat_is_set = false
        continue
      }
      let text = rows[row][col]
      if text == repeat_value {
        repeat_length = repeat_length + 1
        continue
      }
      if repeat_length > 1 {
        config.set_row_span(row + 1, col, repeat_length)
      }
      repeat_length = 1
      repeat_value = rows[row][col]
    }
    if repeat_length > 1 {
      config.set_row_span(0, col, repeat_length)
    }
  }
}

///|
/// Apply merge to the table, combining adjacent duplicate cells using spans.
pub fn Table::merge(self : Table, merge : Merge) -> Table {
  let count_rows = self.rows.length()
  if count_rows == 0 {
    return self
  }
  let count_cols = self.rows[0].length()
  if count_cols == 0 {
    return self
  }
  match merge {
    Horizontal =>
      merge_horizontal(self.rows, self.config, count_rows, count_cols)
    Vertical => merge_vertical(self.rows, self.config, count_rows, count_cols)
  }
  self
}
