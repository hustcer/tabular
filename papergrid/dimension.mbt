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
  for row = 0; row < records.count_rows(); row = row + 1 {
    for column = 0; column < count; column = column + 1 {
      processed_lines(
        records.get_cell(row, column),
        cfg.width_mode_at(row, column),
        cfg.height_mode_at(row, column),
      ).each(line => {
        let (padding_left, padding_right, _, _) = cfg.padding_at(row, column)
        let width = line.length() + padding_left + padding_right
        if width > widths[column] {
          widths[column] = width
        }
      })
    }
  }
  self.widths = widths
}

///|
pub fn IterGridDimension::widths(self : IterGridDimension) -> Array[Int] {
  self.widths
}
