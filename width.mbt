///|
/// Compatibility conversion for the original render-time width setters.
pub(open) trait WidthOption {
  fn to_mode(Self) -> @papergrid.WidthMode
}

///|
pub impl WidthOption for @papergrid.WidthMode with fn to_mode(self) {
  self
}

///|
pub struct Wrap[M, P] {
  width : M
  keep_words : Bool
  priority : P
  placeholder : String
}

///|
pub fn[M] Wrap::new(width : M) -> Wrap[M, PriorityRoundRobin] {
  {
    width,
    keep_words: false,
    priority: PriorityRoundRobin::new(),
    placeholder: "�",
  }
}

///|
pub fn[M, P] Wrap::keep_words(self : Wrap[M, P], enabled : Bool) -> Wrap[M, P] {
  { ..self, keep_words: enabled, }
}

///|
pub fn[M, P, Q] Wrap::priority(self : Wrap[M, P], priority : Q) -> Wrap[M, Q] {
  {
    width: self.width,
    keep_words: self.keep_words,
    placeholder: self.placeholder,
    priority,
  }
}

///|
pub fn Wrap::wrap(text : String, width : Int, keep_words~ : Bool) -> String {
  @papergrid.wrap_text(text, width, keep_words~)
}

///|
pub impl[P] WidthOption for Wrap[Int, P] with fn to_mode(self) {
  @papergrid.WidthMode::wrap_with(self.width, self.placeholder)
}

///|
pub impl[M : Measurement, P] CellOption for Wrap[M, P] with fn change(
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
    if @papergrid.get_text_dimension(text).1 > width {
      table.rows[row][col] = @papergrid.wrap_text(
        text,
        width,
        keep_words=self.keep_words,
        placeholder=self.placeholder,
      )
    }
  }
}

///|
pub impl[M : Measurement, P : ResizeSelector] TableOption for Wrap[M, P] with fn change(
  self,
  table,
) {
  if table.is_empty() {
    return
  }
  let target = Measurement::measure(self.width, table, Attribute::Width)
  let widths = table.column_widths()
  let total = table_width(table, widths)
  if total <= target {
    return
  }
  let mins = minimum_widths(table)
  decrease_widths(widths, mins, total - target, self.priority)
  for point in decrease_cells(table, widths, mins) {
    let (row, col, width) = point
    table.rows[row][col] = @papergrid.wrap_text(
      table.rows[row][col],
      width,
      keep_words=self.keep_words,
      placeholder=self.placeholder,
    )
  }
  table.set_column_widths(widths)
}

///|
pub impl[M : Measurement, P : ResizeSelector] TableOption for Wrap[M, P] with fn hint_change(
  _self,
) {
  Some(Entity::Row(0))
}
