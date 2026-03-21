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
  _cfg : SpannedConfig,
) -> Unit {
  let count = records.count_columns()
  let widths = Array::make(count, 0)
  for row = 0; row < records.count_rows(); row = row + 1 {
    for column = 0; column < count; column = column + 1 {
      processed_lines(
        records.get_cell(row, column),
        _cfg.width_mode(),
        _cfg.height_mode(),
      ).each(line => {
        let width = line.length()
        if width > widths[column] {
          widths[column] = width
        }
      })
    }
  }
  let padding = _cfg.padding_left() + _cfg.padding_right()
  widths.eachi((index, width) => widths[index] = width + padding)
  self.widths = widths
}

///|
pub fn IterGridDimension::widths(self : IterGridDimension) -> Array[Int] {
  self.widths
}
