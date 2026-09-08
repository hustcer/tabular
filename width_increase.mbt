///|
pub struct MinWidth[M, P] {
  width : M
  fill : Char
  priority : P
}

///|
pub fn[M] MinWidth::new(width : M) -> MinWidth[M, PriorityNone] {
  { width, fill: ' ', priority: PriorityNone::new(), }
}

///|
pub fn[M, P] MinWidth::fill_with(
  self : MinWidth[M, P],
  fill : Char,
) -> MinWidth[M, P] {
  { ..self, fill, }
}

///|
pub fn[M, P, Q] MinWidth::priority(
  self : MinWidth[M, P],
  priority : Q,
) -> MinWidth[M, Q] {
  { width: self.width, fill: self.fill, priority, }
}

///|
/// Increase the total table width, including padding, borders, and margins.
/// Cell application pads the text itself and does not include cell padding.
///
/// ```mbt check
/// test {
///   let table = Table::from_rows([["a", "bb"]]).with_(Width::increase(20))
///   assert_eq(table.total_width(), 20)
///   assert_eq(table.rows, [["a", "bb"]])
/// }
/// ```
pub fn[M] Width::increase(width : M) -> MinWidth[M, PriorityNone] {
  MinWidth::new(width)
}

///|
pub impl[M : Measurement, P] CellOption for MinWidth[M, P] with fn change(
  self,
  table,
  entity,
) {
  let width = Measurement::measure(self.width, table, Attribute::Width)
  for position in entity.iter(table.count_rows(), table.count_columns()) {
    let (row, col) = position
    if col >= table.rows[row].length() {
      continue
    }
    let text = table.rows[row][col]
    if @papergrid.get_text_dimension(text).1 >= width {
      continue
    }
    table.rows[row][col] = @papergrid.get_lines(text)
      .map(line => {
        line +
        String::make(
          Int::max(0, width - @papergrid.get_line_width(line)),
          self.fill,
        )
      })
      .join("\n")
  }
}

///|
pub impl[M : Measurement, P : Peaker] TableOption for MinWidth[M, P] with fn change(
  self,
  table,
) {
  if table.is_empty() {
    return
  }
  let target = Measurement::measure(self.width, table, Attribute::Width)
  let widths = table.column_widths()
  let total = table_width(table, widths)
  for _ in total..<target {
    guard Peaker::peak(self.priority, [], widths) is Some(col) else { break }
    widths[col] += 1
  }
  table.set_column_widths(widths)
}

///|
pub impl[M : Measurement, P : Peaker] TableOption for MinWidth[M, P] with fn hint_change(
  _self,
) {
  None
}

///|
pub struct Justify[M] {
  width : M
}

///|
pub fn[M] Justify::new(width : M) -> Justify[M] {
  { width, }
}

///|
pub fn Justify::max() -> Justify[Max] {
  { width: Max::new(), }
}

///|
pub fn Justify::min() -> Justify[Min] {
  { width: Min::new(), }
}

///|
pub fn[M] Width::justify(width : M) -> Justify[M] {
  Justify::new(width)
}

///|
pub impl[M : Measurement] TableOption for Justify[M] with fn change(self, table) {
  let width = Measurement::measure(self.width, table, Attribute::Width)
  for row in 0..<table.count_rows() {
    for col in 0..<table.count_columns() {
      let cell = Entity::Cell(row, col)
      CellOption::change(MinWidth::new(width), table, cell)
      CellOption::change(Truncate::new(width), table, cell)
    }
  }
}

///|
pub struct WidthList {
  list : Array[Int]
}

///|
pub fn WidthList::new(list : Array[Int]) -> WidthList {
  { list: list.copy(), }
}

///|
pub fn WidthList::from_array(list : Array[Int]) -> WidthList {
  WidthList::new(list)
}

///|
pub fn WidthList::from_iter(list : Iter[Int]) -> WidthList {
  WidthList::new(list.to_array())
}

///|
pub fn Width::list(list : Array[Int]) -> WidthList {
  WidthList::new(list)
}

///|
pub impl TableOption for WidthList with fn change(self, table) {
  if self.list.length() >= table.count_columns() {
    table.dimension.set_widths(self.list)
  }
}

///|
pub impl TableOption for WidthList with fn hint_change(_self) {
  None
}
