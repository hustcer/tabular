///|
pub struct IterGridDimension {
  mut widths : Array[Int]
}

///|
pub fn IterGridDimension::default() -> IterGridDimension {
  { widths: [] }
}

///|
pub fn IterGridDimension::estimate(
  self : IterGridDimension,
  records : IterRecords,
  cfg : SpannedConfig,
) -> Unit {
  let count = records.count_columns()
  let widths = Array::make(count, 0)
  let spanned = []
  for row = 0; row < records.count_rows(); row = row + 1 {
    for column = 0; column < count; column = column + 1 {
      if !cfg.is_cell_visible(row, column) {
        continue
      }
      let colspan = cfg.column_span_at(row, column)
      processed_lines(
        records.get_cell(row, column),
        cfg.width_mode_at(row, column),
        cfg.height_mode_at(row, column),
      ).each(line => {
        let (padding_left, padding_right, _, _) = cfg.padding_at(row, column)
        let width = line.length() + padding_left + padding_right
        if colspan <= 1 && width > widths[column] {
          widths[column] = width
        } else if colspan > 1 {
          spanned.push((column, colspan, width))
        }
      })
    }
  }
  spanned.each(item => {
    let end_ = if item.0 + item.1 < count { item.0 + item.1 } else { count }
    let mut current = 0
    for column = item.0; column < end_; column = column + 1 {
      current = current + widths[column]
    }
    if end_ - item.0 > 1 {
      current = current + (end_ - item.0 - 1)
    }
    if item.2 > current && end_ > item.0 {
      widths[end_ - 1] = widths[end_ - 1] + (item.2 - current)
    }
  })
  self.widths = widths
}

///|
pub fn IterGridDimension::widths(self : IterGridDimension) -> Array[Int] {
  self.widths
}
