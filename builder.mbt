///|
pub struct Builder {
  rows : Array[Array[String]]
  mut empty_cell : String
}

///|
pub fn Builder::default() -> Builder {
  { rows: [], empty_cell: "" }
}

///|
pub fn Builder::from_rows(rows : Array[Array[String]]) -> Builder {
  { rows, empty_cell: "" }
}

///|
pub fn Builder::push_record(self : Builder, row : Array[String]) -> Unit {
  self.rows.push(row)
}

///|
pub fn Builder::extend(self : Builder, row : Array[String]) -> Unit {
  self.push_record(row)
}

///|
pub fn Builder::insert_record(
  self : Builder,
  index : Int,
  row : Array[String],
) -> Unit {
  if index < 0 || index > self.rows.length() {
    return
  }
  self.rows.insert(index, row)
}

///|
pub fn Builder::remove_record(self : Builder, index : Int) -> Unit {
  if index >= 0 && index < self.rows.length() {
    self.rows.remove(index) |> ignore
  }
}

///|
pub fn Builder::insert_col(
  self : Builder,
  index : Int,
  col : Array[String],
) -> Unit {
  if index < 0 {
    return
  }
  let row_count = if self.rows.length() > col.length() {
    self.rows.length()
  } else {
    col.length()
  }

  while self.rows.length() < row_count {
    self.rows.push([])
  }

  for row_index in 0..<row_count {
    let row = self.rows[row_index]
    while row.length() < index {
      row.push("")
    }
    row.insert(
      index,
      if row_index < col.length() {
        col[row_index]
      } else {
        ""
      },
    )
  }
}

///|
pub fn Builder::push_col(self : Builder, col : Array[String]) -> Unit {
  let mut index = 0
  self.rows.each(row => if row.length() > index { index = row.length() })
  self.insert_col(index, col)
}

///|
pub fn Builder::remove_col(self : Builder, index : Int) -> Unit {
  if index < 0 {
    return
  }
  self.rows.each(row => if index < row.length() { row.remove(index) |> ignore })
}

///|
pub fn Builder::set_empty(self : Builder, value : String) -> Unit {
  self.empty_cell = value
}

///|
pub fn Builder::clear(self : Builder) -> Unit {
  self.rows.clear()
}

///|
pub fn Builder::clean(self : Builder) -> Unit {
  let mut max_cols = 0
  self.rows.each(row => if row.length() > max_cols { max_cols = row.length() })
  if max_cols == 0 {
    return
  }
  // Determine which cols to keep (at least one non-empty cell)
  let keep_col = Array::make(max_cols, false)
  self.rows.each(row => {
    for col in 0..<max_cols {
      if col < row.length() && row[col] != "" {
        keep_col[col] = true
      }
    }
  })
  // Filter cols in-place
  self.rows.each(row => {
    let next = []
    for col in 0..<max_cols {
      if keep_col[col] {
        next.push(if col < row.length() { row[col] } else { "" })
      }
    }
    row.clear()
    next.each(value => row.push(value))
  })
  // Remove empty rows (all cells empty or no cells)
  let kept_rows : Array[Array[String]] = []
  self.rows.each(row => {
    let mut has_content = false
    row.each(cell => if cell != "" { has_content = true })
    if has_content || row.length() == 0 {
      // Keep rows with content; drop all-empty rows
      if has_content {
        kept_rows.push(row)
      }
    }
  })
  self.rows.clear()
  kept_rows.each(row => self.rows.push(row))
}

///|
pub fn Builder::build(self : Builder) -> Table {
  Table::from_rows(normalize_rows(self.rows, self.empty_cell))
}

///|
pub fn Builder::count_records(self : Builder) -> Int {
  self.rows.length()
}

///|
pub fn Builder::count_cols(self : Builder) -> Int {
  let mut max = 0
  self.rows.each(row => if row.length() > max { max = row.length() })
  max
}

///|
pub struct IndexBuilder {
  rows : Array[Array[String]]
  empty_cell : String
  mut index_col : Int?
  mut index_name : String?
  mut show_index : Bool
}
