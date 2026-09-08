///|
/// Cached column widths and row heights. Options invalidate only affected axes.
pub struct CompleteDimension {
  mut width : Array[Int]?
  mut height : Array[Int]?
} derive(Eq, Debug)

///|
pub fn CompleteDimension::default() -> CompleteDimension {
  { width: None, height: None, }
}

///|
pub fn CompleteDimension::is_complete(self : CompleteDimension) -> Bool {
  self.width is Some(_) && self.height is Some(_)
}

///|
pub fn CompleteDimension::is_empty(self : CompleteDimension) -> Bool {
  self.width is None && self.height is None
}

///|
pub fn CompleteDimension::set_widths(
  self : CompleteDimension,
  widths : Array[Int],
) -> Unit {
  self.width = Some(widths.map(value => Int::max(0, value)))
}

///|
pub fn CompleteDimension::set_heights(
  self : CompleteDimension,
  heights : Array[Int],
) -> Unit {
  self.height = Some(heights.map(value => Int::max(0, value)))
}

///|
pub fn CompleteDimension::clear_width(self : CompleteDimension) -> Unit {
  self.width = None
}

///|
pub fn CompleteDimension::clear_height(self : CompleteDimension) -> Unit {
  self.height = None
}

///|
pub fn CompleteDimension::clear(self : CompleteDimension) -> Unit {
  self.clear_width()
  self.clear_height()
}

///|
pub fn CompleteDimension::get_widths(self : CompleteDimension) -> Array[Int]? {
  self.width.map(Array::copy)
}

///|
pub fn CompleteDimension::get_heights(self : CompleteDimension) -> Array[Int]? {
  self.height.map(Array::copy)
}

///|
pub fn CompleteDimension::get_width(
  self : CompleteDimension,
  column : Int,
) -> Int {
  self.width.unwrap()[column]
}

///|
pub fn CompleteDimension::get_height(
  self : CompleteDimension,
  row : Int,
) -> Int {
  self.height.unwrap()[row]
}

///|
pub fn CompleteDimension::reastimate(
  self : CompleteDimension,
  hint : Entity?,
) -> Unit {
  match hint {
    None => ()
    Some(Global | Cell(_, _)) => self.clear()
    Some(Column(_) | Col(_)) => self.clear_width()
    Some(Row(_)) => self.clear_height()
  }
}

///|
/// Recompute missing axes or arrays too short for the current records.
/// Longer arrays remain valid, matching explicit width and height lists.
pub fn CompleteDimension::estimate(
  self : CompleteDimension,
  table : Table,
) -> Unit {
  let records = @papergrid.IterRecords::new(table.rows)
  let missing_width = self.width is None ||
    (self.width is Some(widths) && widths.length() < records.count_cols())
  let missing_height = self.height is None ||
    (self.height is Some(heights) && heights.length() < records.count_rows())
  if !missing_width && !missing_height {
    return
  }
  let (widths, heights) = @papergrid.IterGridDimension::rendered_dimension(
    records,
    table.config,
  )
  if missing_width {
    self.width = Some(widths)
  }
  if missing_height {
    self.height = Some(heights)
  }
}

///|
pub fn Table::get_dimension(self : Table) -> CompleteDimension {
  { width: self.dimension.get_widths(), height: self.dimension.get_heights(), }
}

///|
pub fn Table::get_dimension_mut(self : Table) -> CompleteDimension {
  self.dimension
}

///|
pub fn Table::total_width(self : Table) -> Int {
  let dims = self.get_dimension()
  dims.estimate(self)
  table_width(
    self,
    dims.get_widths().unwrap()[:self.count_columns()].to_owned(),
  )
}

///|
pub fn Table::total_height(self : Table) -> Int {
  let dims = self.get_dimension()
  dims.estimate(self)
  dims
  .get_heights()
  .unwrap()
  .iter()
  .take(self.count_rows())
  .fold(init=0, (sum, value) => sum + value) +
  self.config.count_horizontal(self.count_rows()) +
  self.config.margin_top +
  self.config.margin_bottom
}

///|
// Legacy mutators are public entry points too. Raw option changes defer cache
// invalidation to the enclosing option's combined hint.
fn Table::finish_legacy_change(self : Table) -> Table {
  if self.option_depth == 0 {
    self.dimension.clear()
  }
  self
}
