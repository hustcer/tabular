///|
test "height measurement applies render modes only when requested" {
  let records = @papergrid.IterRecords::new([["abcdef"], ["x"]])
  let config = @papergrid.SpannedConfig::default()
  config.set_width_mode(@papergrid.WidthMode::wrap(2))
  config.set_height_mode(@papergrid.HeightMode::increase(2))
  assert_eq(@papergrid.IterGridDimension::measure_heights(records, config), [
    1, 1,
  ])
  assert_eq(
    @papergrid.IterGridDimension::measure_heights(
      records,
      config,
      apply_modes=true,
    ),
    [3, 2],
  )
  config.set_height_mode(@papergrid.HeightMode::limit(0))
  assert_eq(
    @papergrid.IterGridDimension::measure_heights(
      records,
      config,
      apply_modes=true,
    ),
    [0, 0],
  )
}

///|
test "height measurement retains raw column-span rules with render modes" {
  let records = @papergrid.IterRecords::new([["x", "abcdef"]])
  let config = @papergrid.SpannedConfig::default()
  config.set_col_span(0, 0, 2)
  config.set_width_mode(@papergrid.WidthMode::wrap(2))
  assert_eq(
    @papergrid.IterGridDimension::measure_heights(
      records,
      config,
      apply_modes=true,
    ),
    [3],
  )
  assert_eq(@papergrid.IterGridDimension::measure_rendered(records, config).1, [
    1,
  ])
}
