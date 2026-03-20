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
      let width = records.get_cell(row, column).length()
      if width > widths[column] {
        widths[column] = width
      }
    }
  }
  widths.eachi((index, width) => if width == 0 { widths[index] = 1 })
  self.widths = widths
}

///|
pub fn IterGridDimension::widths(self : IterGridDimension) -> Array[Int] {
  self.widths
}
