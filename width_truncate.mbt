///|
pub(all) enum SuffixLimit {
  Cut
  Ignore
  Replace(Char)
} derive(Eq, Debug)

///|
pub struct Truncate[M, P] {
  width : M
  suffix : String
  limit : SuffixLimit
  lines : Bool
  color : Bool
  priority : P
}

///|
pub fn[M] Truncate::new(width : M) -> Truncate[M, PriorityNone] {
  {
    width,
    suffix: "",
    limit: Cut,
    lines: false,
    color: false,
    priority: PriorityNone::new(),
  }
}

///|
pub fn[M, P] Truncate::suffix(
  self : Truncate[M, P],
  suffix : String,
) -> Truncate[M, P] {
  { ..self, suffix, }
}

///|
pub fn[M, P] Truncate::suffix_limit(
  self : Truncate[M, P],
  limit : SuffixLimit,
) -> Truncate[M, P] {
  { ..self, limit, }
}

///|
pub fn[M, P] Truncate::suffix_try_color(
  self : Truncate[M, P],
  color : Bool,
) -> Truncate[M, P] {
  { ..self, color, }
}

///|
pub fn[M, P] Truncate::multiline(
  self : Truncate[M, P],
  on : Bool,
) -> Truncate[M, P] {
  { ..self, lines: on, }
}

///|
pub fn[M, P, Q] Truncate::priority(
  self : Truncate[M, P],
  priority : Q,
) -> Truncate[M, Q] {
  {
    width: self.width,
    suffix: self.suffix,
    limit: self.limit,
    lines: self.lines,
    color: self.color,
    priority,
  }
}

///|
pub fn Truncate::truncate(text : String, width : Int) -> String {
  @papergrid.cut_str(text, width)
}

///|
pub impl[P] WidthOption for Truncate[Int, P] with fn to_mode(self) {
  @papergrid.WidthMode::truncate(self.width, self.suffix)
}

///|
pub impl[M : Measurement, P] CellOption for Truncate[M, P] with fn change(
  self,
  table,
  entity,
) {
  let available = Measurement::measure(self.width, table, Attribute::Width)
  let (suffix, width) = truncation_suffix(self.suffix, self.limit, available)
  for position in entity.iter(table.count_rows(), table.count_columns()) {
    let (row, col) = position
    if col >= table.rows[row].length() {
      continue
    }
    let text = table.rows[row][col]
    if @papergrid.get_text_dimension(text).1 > available {
      table.rows[row][col] = truncate_content(
        text,
        width,
        available,
        suffix,
        self.color,
        self.lines,
      )
    }
  }
}

///|
pub impl[M : Measurement, P : Peaker] TableOption for Truncate[M, P] with fn change(
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
    let (row, col, available) = point
    let text = table.rows[row][col]
    let text_width = @papergrid.get_text_dimension(text).1
    if available >= text_width {
      continue
    }
    let (suffix, width) = truncation_suffix(self.suffix, self.limit, available)
    table.rows[row][col] = truncate_content(
      text,
      width,
      text_width,
      suffix,
      self.color,
      self.lines,
    )
  }
  table.set_column_widths(widths)
  table.dimension.clear_height()
}

///|
pub impl[M : Measurement, P : Peaker] TableOption for Truncate[M, P] with fn hint_change(
  _self,
) {
  None
}

///|
fn truncation_suffix(
  suffix : String,
  limit : SuffixLimit,
  width : Int,
) -> (String, Int) {
  let size = @papergrid.get_line_width(suffix)
  if width > size {
    return (suffix, width - size)
  }
  match limit {
    Ignore => ("", width)
    Cut => (@papergrid.cut_str(suffix, width), 0)
    Replace(ch) => (String::make(width, ch), 0)
  }
}

///|
fn truncate_content(
  text : String,
  width : Int,
  total : Int,
  suffix : String,
  color : Bool,
  lines : Bool,
) -> String {
  fn truncate(line : String) -> String {
    if width == 0 {
      return if total == 0 { "" } else { suffix }
    }
    let ending = if color {
      @papergrid.colorize_suffix(line, suffix)
    } else {
      suffix
    }
    @papergrid.cut_str(line, width) + ending
  }
  if lines {
    @papergrid.get_lines(text).map(truncate).join("\n")
  } else {
    truncate(text)
  }
}
