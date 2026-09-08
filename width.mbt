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
  words : Bool
  priority : P
  placeholder : String
}

///|
pub fn[M] Wrap::new(width : M) -> Wrap[M, PriorityNone] {
  { width, words: false, priority: PriorityNone::new(), placeholder: "�", }
}

///|
pub fn[M, P] Wrap::keep_words(self : Wrap[M, P], on : Bool) -> Wrap[M, P] {
  { ..self, words: on, }
}

///|
pub fn[M, P, Q] Wrap::priority(self : Wrap[M, P], priority : Q) -> Wrap[M, Q] {
  {
    width: self.width,
    words: self.words,
    placeholder: self.placeholder,
    priority,
  }
}

///|
pub fn Wrap::wrap(text : String, width : Int, keeping_words : Bool) -> String {
  @papergrid.wrap_text(text, width, keep_words=keeping_words)
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
  for position in entity.iter(table.count_rows(), table.count_columns()) {
    let (row, col) = position
    if col >= table.rows[row].length() {
      continue
    }
    let text = table.rows[row][col]
    if @papergrid.get_text_dimension(text).1 > width {
      table.rows[row][col] = @papergrid.wrap_text(
        text,
        width,
        keep_words=self.words,
        placeholder=self.placeholder,
      )
    }
  }
}

///|
pub impl[M : Measurement, P : Peaker] TableOption for Wrap[M, P] with fn change(
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
      keep_words=self.words,
      placeholder=self.placeholder,
    )
  }
  table.set_column_widths(widths)
}

///|
pub impl[M : Measurement, P : Peaker] TableOption for Wrap[M, P] with fn hint_change(
  _self,
) {
  Some(Entity::Row(0))
}
