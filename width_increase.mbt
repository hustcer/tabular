///|
pub struct MinWidth[M, P] {
  width : M
  fill : Char
  priority : P
}

///|
pub fn[M] MinWidth::new(width : M) -> MinWidth[M, PriorityRoundRobin] {
  { width, fill: ' ', priority: PriorityRoundRobin::new(), }
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
pub fn[M] Width::increase(width : M) -> MinWidth[M, PriorityRoundRobin] {
  MinWidth::new(width)
}

///|
pub impl[M : Measurement, P] CellOption for MinWidth[M, P] with fn change(
  self,
  table,
  entity,
) {
  let width = Measurement::measure(self.width, table, Attribute::Width)
  for position in entity.iter(table.count_rows(), table.count_cols()) {
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
pub impl[M : Measurement, P : ResizeSelector] TableOption for MinWidth[M, P] with fn change(
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
    guard ResizeSelector::select(self.priority, [], widths) is Some(col) else {
      break
    }
    widths[col] += 1
  }
  table.set_column_widths(widths)
}

///|
pub impl[M : Measurement, P : ResizeSelector] TableOption for MinWidth[M, P] with fn hint_change(
  _self,
) {
  None
}

///|
pub struct UniformWidth[M] {
  width : M
}

///|
pub fn[M] UniformWidth::new(width : M) -> UniformWidth[M] {
  { width, }
}

///|
pub fn UniformWidth::max() -> UniformWidth[Max] {
  { width: Max::new(), }
}

///|
pub fn UniformWidth::min() -> UniformWidth[Min] {
  { width: Min::new(), }
}

///|
pub fn[M] Width::uniform(width : M) -> UniformWidth[M] {
  UniformWidth::new(width)
}

///|
pub impl[M : Measurement] TableOption for UniformWidth[M] with fn change(
  self,
  table,
) {
  let width = Measurement::measure(self.width, table, Attribute::Width)
  for row in 0..<table.count_rows() {
    for col in 0..<table.count_cols() {
      let cell = Entity::Cell(row, col)
      CellOption::change(MinWidth::new(width), table, cell)
      CellOption::change(Truncate::new(width), table, cell)
    }
  }
}

///|
pub struct WidthList {
  widths : Array[Int]
}

///|
pub fn WidthList::new(widths : Array[Int]) -> WidthList {
  { widths: widths.copy(), }
}

///|
pub fn WidthList::from_array(widths : Array[Int]) -> WidthList {
  WidthList::new(widths)
}

///|
pub fn WidthList::from_iter(widths : Iter[Int]) -> WidthList {
  WidthList::new(widths.to_array())
}

///|
pub fn Width::list(widths : Array[Int]) -> WidthList {
  WidthList::new(widths)
}

///|
pub impl TableOption for WidthList with fn change(self, table) {
  if self.widths.length() >= table.count_cols() {
    table.dimension.set_widths(self.widths)
  }
}

///|
pub impl TableOption for WidthList with fn hint_change(_self) {
  None
}
