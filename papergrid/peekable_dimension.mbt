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
pub fn PeekableGridDimension::measure_widths(
  records : IterRecords,
  config : SpannedConfig,
) -> Array[Int] {
  measure_axis(records, config, true, cached=true)
}

///|
pub fn PeekableGridDimension::measure_heights(
  records : IterRecords,
  config : SpannedConfig,
) -> Array[Int] {
  measure_axis(records, config, false, cached=true)
}

///|
pub fn PeekableGridDimension::measure(
  records : IterRecords,
  config : SpannedConfig,
) -> (Array[Int], Array[Int]) {
  (
    PeekableGridDimension::measure_widths(records, config),
    PeekableGridDimension::measure_heights(records, config),
  )
}

///|
pub fn PeekableGridDimension::estimate(
  self : PeekableGridDimension,
  records : IterRecords,
  config : SpannedConfig,
) -> Unit {
  let (widths, heights) = PeekableGridDimension::measure(records, config)
  self.widths = widths
  self.heights = heights
}

///|
pub fn PeekableGridDimension::dimensions(
  self : PeekableGridDimension,
) -> (Array[Int], Array[Int]) {
  (self.widths.copy(), self.heights.copy())
}

///|
pub fn PeekableGridDimension::get_width(
  self : PeekableGridDimension,
  col : Int,
) -> Int {
  self.widths[col]
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
