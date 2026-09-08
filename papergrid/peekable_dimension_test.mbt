///|
test "cached cell dimensions preserve CRLF widths and hide both span axes" {
  let config = SpannedConfig::default()
  let records = IterRecords::new([["a\r\nb", "x"], ["hidden value", "z"]])
  config.set_row_span(0, 0, 2)
  let dims = PeekableGridDimension::default()
  dims.estimate(records, config)
  assert_eq(dims.dimensions(), ([2, 1], [1, 1]))
  assert_eq(dims.get_width(0), 2)
  assert_eq(dims.get_height(0), 1)
  assert_eq(PeekableGridDimension::measure(records, config), dims.dimensions())
  // Iterable single-axis width measurement has a distinct upstream rule.
  assert_eq(IterGridDimension::measure_widths(records, config), [12, 1])
}
