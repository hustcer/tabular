///|
/// Dimensions computed using cached cell text widths and line counts.
pub struct PeekableGridDimension {
  mut widths : Array[Int]
  mut heights : Array[Int]
} derive(Eq, Debug)

///|
pub fn PeekableGridDimension::default() -> PeekableGridDimension {
  { widths: [], heights: [], }
}

///|
pub fn PeekableGridDimension::width(
  records : IterRecords,
  config : SpannedConfig,
) -> Array[Int] {
  measure_axis(records, config, true, cached=true)
}

///|
pub fn PeekableGridDimension::height(
  records : IterRecords,
  config : SpannedConfig,
) -> Array[Int] {
  measure_axis(records, config, false, cached=true)
}

///|
pub fn PeekableGridDimension::dimension(
  records : IterRecords,
  config : SpannedConfig,
) -> (Array[Int], Array[Int]) {
  (
    PeekableGridDimension::width(records, config),
    PeekableGridDimension::height(records, config),
  )
}

///|
pub fn PeekableGridDimension::estimate(
  self : PeekableGridDimension,
  records : IterRecords,
  config : SpannedConfig,
) -> Unit {
  let (widths, heights) = PeekableGridDimension::dimension(records, config)
  self.widths = widths
  self.heights = heights
}

///|
pub fn PeekableGridDimension::get_values(
  self : PeekableGridDimension,
) -> (Array[Int], Array[Int]) {
  (self.widths.copy(), self.heights.copy())
}

///|
pub fn PeekableGridDimension::get_width(
  self : PeekableGridDimension,
  column : Int,
) -> Int {
  self.widths[column]
}

///|
pub fn PeekableGridDimension::get_height(
  self : PeekableGridDimension,
  row : Int,
) -> Int {
  self.heights[row]
}

///|
pub fn IterGridDimension::set_heights(
  self : IterGridDimension,
  heights : Array[Int],
) -> Unit {
  self.heights = Some(heights.copy())
}
