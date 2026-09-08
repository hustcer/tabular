///|
fn table_width(table : Table, widths : Array[Int]) -> Int {
  widths
  .iter()
  .take(table.count_columns())
  .fold(init=0, (sum, value) => sum + value) +
  table.config.count_vertical(table.count_columns()) +
  table.config.margin_left +
  table.config.margin_right
}

///|
// Width lists retain surplus entries, but priorities must only see real columns.
fn Table::column_widths(self : Table) -> Array[Int] {
  self.dimension.estimate(self)
  self.dimension.get_widths().unwrap()[:self.count_columns()].to_owned()
}

///|
fn Table::set_column_widths(self : Table, widths : Array[Int]) -> Unit {
  let cached = self.dimension.get_widths().unwrap()
  for col, width in widths {
    cached[col] = width
  }
  self.dimension.set_widths(cached)
}

///|
fn minimum_widths(table : Table) -> Array[Int] {
  let rows = Array::makei(table.count_rows(), _ => {
    Array::make(table.count_columns(), "")
  })
  @papergrid.IterGridDimension::width(
    @papergrid.IterRecords::new(rows),
    table.config,
  )
}

///|
fn[P : Peaker] decrease_widths(
  widths : Array[Int],
  mins : Array[Int],
  amount : Int,
  priority : P,
) -> Unit {
  let mut remaining = amount
  let mut available = 0
  for col in 0..<widths.length() {
    available += Int::max(0, widths[col] - mins[col])
  }
  while remaining > 0 && available > 0 {
    guard Peaker::peak(priority, mins, widths) is Some(col) else { break }
    if widths[col] <= mins[col] {
      continue
    }
    widths[col] -= 1
    remaining -= 1
    available -= 1
  }
}

///|
fn decrease_cells(
  table : Table,
  widths : Array[Int],
  mins : Array[Int],
) -> Array[(Int, Int, Int)] {
  let points = []
  let cols = table.count_columns()
  for col in 0..<cols {
    for row in 0..<table.count_rows() {
      if col >= table.rows[row].length() ||
        !table.config.is_cell_visible(row, col) {
        continue
      }
      let end_ = Int::min(cols, col + table.config.col_span_at(row, col))
      let mut width = 0
      let mut minimum = 0
      for index in col..<end_ {
        width += widths[index]
        minimum += mins[index]
        if index > col && table.config.has_vertical(index, cols) {
          width += 1
          minimum += 1
        }
      }
      if width >= minimum {
        let (left, right, _, _) = table.config.padding_at(row, col)
        points.push((row, col, Int::max(0, width - left - right)))
      }
    }
  }
  points
}
