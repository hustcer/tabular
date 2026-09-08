///|
fn[P : @tabular.ResizeSelector] priority_trace(
  priority : P,
  minimums : Array[Int],
  initial : Array[Int],
) -> Array[Int] {
  let values = initial.copy()
  Array::makei(30, _ => {
    match @tabular.ResizeSelector::select(priority, minimums, values) {
      Some(index) => {
        if values[index] > minimums.get(index).unwrap_or(0) {
          values[index] -= 1
        }
        index
      }
      None => -1
    }
  })
}

///|
fn measure_dimensions(table : @tabular.Table) -> Array[Int] {
  [
    @tabular.Measurement::measure(
      @tabular.Max::new(),
      table,
      @tabular.Attribute::Width,
    ),
    @tabular.Measurement::measure(
      @tabular.Min::new(),
      table,
      @tabular.Attribute::Width,
    ),
    @tabular.Measurement::measure(
      @tabular.Max::new(),
      table,
      @tabular.Attribute::Height,
    ),
    @tabular.Measurement::measure(
      @tabular.Min::new(),
      table,
      @tabular.Attribute::Height,
    ),
    @tabular.Measurement::measure(
      @tabular.Percent::new(37),
      table,
      @tabular.Attribute::Width,
    ),
    @tabular.Measurement::measure(
      @tabular.Percent::new(150),
      table,
      @tabular.Attribute::Height,
    ),
  ]
}
