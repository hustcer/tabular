// Height allocation follows tabled's height settings; see THIRD_PARTY_NOTICES.md.

///|
pub struct TableHeightIncrease[M, P] {
  height : M
  priority : P
} derive(Debug)

///|
pub fn[M] TableHeightIncrease::new(
  height : M,
) -> TableHeightIncrease[M, PriorityRoundRobin] {
  { height, priority: PriorityRoundRobin::new(), }
}

///|
pub fn[M, P, Q] TableHeightIncrease::priority(
  self : TableHeightIncrease[M, P],
  priority : Q,
) -> TableHeightIncrease[M, Q] {
  { height: self.height, priority, }
}

///|
pub impl[M : Measurement, P : ResizeSelector] TableOption for TableHeightIncrease[
  M,
  P,
] with fn change(self, table) {
  if table.is_empty() {
    return
  }
  let target = Measurement::measure(self.height, table, Attribute::Height)
  let (total, heights) = height_table_measure(table)
  if total >= target {
    return
  }
  for _ in total..<target {
    guard ResizeSelector::select(self.priority, [], heights) is Some(row) else {
      break
    }
    heights[row] += 1
  }
  table.dimension.set_heights(heights)
}

///|
pub impl[M : Measurement, P : ResizeSelector] TableOption for TableHeightIncrease[
  M,
  P,
] with fn hint_change(_self) {
  None
}

///|
pub struct TableHeightLimit[M, P] {
  height : M
  priority : P
} derive(Debug)

///|
pub fn[M] TableHeightLimit::new(
  height : M,
) -> TableHeightLimit[M, PriorityRoundRobin] {
  { height, priority: PriorityRoundRobin::new(), }
}

///|
pub fn[M, P, Q] TableHeightLimit::priority(
  self : TableHeightLimit[M, P],
  priority : Q,
) -> TableHeightLimit[M, Q] {
  { height: self.height, priority, }
}

///|
pub impl[M : Measurement, P : ResizeSelector] TableOption for TableHeightLimit[
  M,
  P,
] with fn change(self, table) {
  if table.is_empty() {
    return
  }
  let target = Measurement::measure(self.height, table, Attribute::Height)
  let (total, heights) = height_table_measure(table)
  if total <= target {
    return
  }
  for _ in target..<total {
    guard ResizeSelector::select(self.priority, [], heights) is Some(row) else {
      break
    }
    heights[row] -= 1
  }
  for row, height in heights {
    for col in 0..<table.rows[row].length() {
      let text = table.rows[row][col]
      if @papergrid.count_lines(text) > height {
        table.rows[row][col] = height_limit_lines(text, height)
      }
    }
  }
  table.dimension.set_heights(heights)
}

///|
pub impl[M : Measurement, P : ResizeSelector] TableOption for TableHeightLimit[
  M,
  P,
] with fn hint_change(_self) {
  None
}

///|
// Upstream height operations measure records afresh, independently of cached
// dimensions, and include all horizontal borders and both vertical margins.
fn height_table_measure(table : Table) -> (Int, Array[Int]) {
  let heights = @papergrid.IterGridDimension::measure_heights(
    @papergrid.IterRecords::new(table.rows),
    table.config,
  )
  let total = heights.fold(init=0, (sum, value) => sum + value) +
    table.config.count_horizontal(table.count_rows()) +
    table.config.margin_top +
    table.config.margin_bottom
  (total, heights)
}

///|
pub struct HeightList {
  heights : Array[Int]
} derive(Debug)

///|
pub fn HeightList::new(heights : Array[Int]) -> HeightList {
  { heights: heights.copy(), }
}

///|
pub fn HeightList::from_array(heights : Array[Int]) -> HeightList {
  HeightList::new(heights)
}

///|
pub fn HeightList::from_iter(heights : Iter[Int]) -> HeightList {
  HeightList::new(heights.to_array())
}

///|
/// Fix row heights, including cell padding. A shorter list has no effect.
///
/// ```mbt check
/// test {
///   let table = Table::from_rows([["one"], ["two"]]).with_(Height::list([0, 2]))
///   assert_eq(table.to_string(), "+-----+\n+-----+\n| two |\n|     |\n+-----+")
/// }
/// ```
pub fn Height::list(heights : Array[Int]) -> HeightList {
  HeightList::new(heights)
}

///|
pub impl TableOption for HeightList with fn change(self, table) {
  if self.heights.length() >= table.count_rows() {
    table.dimension.set_heights(self.heights)
  }
}

///|
pub impl TableOption for HeightList with fn hint_change(_self) {
  None
}
