///|
/// Cached column widths and row heights. Options invalidate only affected axes.
pub struct CompleteDimension {
  mut widths : Array[Int]?
  mut heights : Array[Int]?
} derive(Eq, Debug)

///|
pub fn CompleteDimension::default() -> CompleteDimension {
  { widths: None, heights: None, }
}

///|
pub fn CompleteDimension::is_complete(self : CompleteDimension) -> Bool {
  self.widths is Some(_) && self.heights is Some(_)
}

///|
pub fn CompleteDimension::is_empty(self : CompleteDimension) -> Bool {
  self.widths is None && self.heights is None
}

///|
pub fn CompleteDimension::set_widths(
  self : CompleteDimension,
  widths : Array[Int],
) -> Unit {
  self.widths = Some(widths.map(value => Int::max(0, value)))
}

///|
pub fn CompleteDimension::set_heights(
  self : CompleteDimension,
  heights : Array[Int],
) -> Unit {
  self.heights = Some(heights.map(value => Int::max(0, value)))
}

///|
pub fn CompleteDimension::clear_width(self : CompleteDimension) -> Unit {
  self.widths = None
}

///|
pub fn CompleteDimension::clear_height(self : CompleteDimension) -> Unit {
  self.heights = None
}

///|
pub fn CompleteDimension::clear(self : CompleteDimension) -> Unit {
  self.clear_width()
  self.clear_height()
}

///|
pub fn CompleteDimension::get_widths(self : CompleteDimension) -> Array[Int]? {
  self.widths.map(Array::copy)
}

///|
pub fn CompleteDimension::get_heights(self : CompleteDimension) -> Array[Int]? {
  self.heights.map(Array::copy)
}

///|
pub fn CompleteDimension::get_width(self : CompleteDimension, col : Int) -> Int {
  self.widths.unwrap()[col]
}

///|
pub fn CompleteDimension::get_height(
  self : CompleteDimension,
  row : Int,
) -> Int {
  self.heights.unwrap()[row]
}

///|
/// Invalidate the cached axes affected by an option's change hint.
/// None keeps the cache; row hints clear heights, column hints clear widths,
/// and cell/global hints clear both. Measurement is deferred until `estimate`.
pub fn CompleteDimension::invalidate(
  self : CompleteDimension,
  hint : Entity?,
) -> Unit {
  match hint {
    None => ()
    Some(Global | Cell(_, _)) => self.clear()
    Some(Col(_)) => self.clear_width()
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
  let missing_width = self.widths is None ||
    (self.widths is Some(widths) && widths.length() < records.count_cols())
  let missing_height = self.heights is None ||
    (self.heights is Some(heights) && heights.length() < records.count_rows())
  if !missing_width && !missing_height {
    return
  }
  let (widths, heights) = @papergrid.IterGridDimension::measure_rendered(
    records,
    table.config,
  )
  if missing_width {
    self.widths = Some(widths)
  }
  if missing_height {
    self.heights = Some(heights)
  }
}

///|
/// Return an independent snapshot of the dimension cache without measuring.
pub fn Table::dimension_snapshot(self : Table) -> CompleteDimension {
  {
    widths: self.dimension.get_widths(),
    heights: self.dimension.get_heights(),
  }
}

///|
/// Return the shared dimension cache. Changes affect this table directly.
/// Clear it after changing records or configuration through raw mutable access.
pub fn Table::dimension_cache(self : Table) -> CompleteDimension {
  self.dimension
}

///|
pub fn Table::total_width(self : Table) -> Int {
  let dims = self.dimension_snapshot()
  dims.estimate(self)
  table_width(self, dims.get_widths().unwrap()[:self.count_cols()].to_owned())
}

///|
pub fn Table::total_height(self : Table) -> Int {
  let dims = self.dimension_snapshot()
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
