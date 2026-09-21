///|
/// Compatibility conversion for the original render-time height setters.
pub(open) trait HeightOption {
  fn to_mode(Self) -> @papergrid.HeightMode
}

///|
pub impl HeightOption for @papergrid.HeightMode with fn to_mode(self) {
  self
}

///|
/// Increase cell text height with `modify`, or total table height with `with_`.
///
/// ```mbt check
/// test {
///   let table = @tabular.Table::from_rows([["a"], ["b"]])
///   table.modify((0, 0), @tabular.Height::increase(3)) |> ignore
///   assert_eq(table.rows[0], ["a\n\n"])
///   table.with_(@tabular.Height::increase(10)) |> ignore
///   assert_eq(table.total_height(), 10)
/// }
/// ```
pub struct CellHeightIncrease[M] {
  height : M
} derive(Eq, Debug)

///|
pub fn[M] CellHeightIncrease::new(height : M) -> CellHeightIncrease[M] {
  { height, }
}

///|
pub fn[M, P] CellHeightIncrease::priority(
  self : CellHeightIncrease[M],
  priority : P,
) -> TableHeightIncrease[M, P] {
  { height: self.height, priority, }
}

///|
pub impl HeightOption for CellHeightIncrease[Int] with fn to_mode(self) {
  @papergrid.HeightMode::increase(self.height)
}

///|
pub impl[M : Measurement] CellOption for CellHeightIncrease[M] with fn change(
  self,
  table,
  entity,
) {
  let height = Measurement::measure(self.height, table, Attribute::Height)
  for position in entity.iter(table.count_rows(), table.count_cols()) {
    let (row, col) = position
    if col >= table.rows[row].length() {
      continue
    }
    let text = table.rows[row][col]
    let current = @papergrid.count_lines(text)
    if current < height {
      table.rows[row][col] = text + String::make(height - current, '\n')
    }
  }
}

///|
pub impl[M : Measurement] TableOption for CellHeightIncrease[M] with fn change(
  self,
  table,
) {
  let height = Measurement::measure(self.height, table, Attribute::Height)
  TableOption::change(TableHeightIncrease::new(height), table)
}

///|
pub impl[M : Measurement] TableOption for CellHeightIncrease[M] with fn hint_change(
  _self,
) {
  None
}

///|
/// Limit the number of text lines. ANSI styles remain balanced on retained lines.
pub struct CellHeightLimit[M] {
  height : M
} derive(Eq, Debug)

///|
pub fn[M] CellHeightLimit::new(height : M) -> CellHeightLimit[M] {
  { height, }
}

///|
pub fn[M, P] CellHeightLimit::priority(
  self : CellHeightLimit[M],
  priority : P,
) -> TableHeightLimit[M, P] {
  { height: self.height, priority, }
}

///|
pub impl HeightOption for CellHeightLimit[Int] with fn to_mode(self) {
  @papergrid.HeightMode::limit(self.height)
}

///|
pub impl[M : Measurement] CellOption for CellHeightLimit[M] with fn change(
  self,
  table,
  entity,
) {
  let height = Measurement::measure(self.height, table, Attribute::Height)
  for position in entity.iter(table.count_rows(), table.count_cols()) {
    let (row, col) = position
    if col >= table.rows[row].length() {
      continue
    }
    let text = table.rows[row][col]
    if @papergrid.count_lines(text) > height {
      table.rows[row][col] = height_limit_lines(text, height)
    }
  }
}

///|
pub impl[M : Measurement] TableOption for CellHeightLimit[M] with fn change(
  self,
  table,
) {
  let height = Measurement::measure(self.height, table, Attribute::Height)
  TableOption::change(TableHeightLimit::new(height), table)
}

///|
pub impl[M : Measurement] TableOption for CellHeightLimit[M] with fn hint_change(
  _self,
) {
  None
}

///|
fn height_limit_lines(text : String, height : Int) -> String {
  @papergrid.get_lines(text).iter().take(Int::max(0, height)).join("\n")
}

///|
pub extend CellHeightIncrease with Eq::{not_equal, equal}

///|
pub extend CellHeightIncrease with @debug.Debug::{to_repr}

///|
pub extend CellHeightIncrease with HeightOption::{to_mode}

///|
pub extend CellHeightIncrease with CellOption::{
  change as change_cell,
  hint_change as hint_change_cell,
}

///|
pub extend CellHeightIncrease with TableOption::{change, hint_change}

///|
pub extend CellHeightLimit with Eq::{not_equal, equal}

///|
pub extend CellHeightLimit with @debug.Debug::{to_repr}

///|
pub extend CellHeightLimit with HeightOption::{to_mode}

///|
pub extend CellHeightLimit with CellOption::{
  change as change_cell,
  hint_change as hint_change_cell,
}

///|
pub extend CellHeightLimit with TableOption::{change, hint_change}
