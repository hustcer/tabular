///|
pub struct IterGridDimension {
  mut widths : Array[Int]
  mut heights : Array[Int]?
}

///|
pub fn IterGridDimension::default() -> IterGridDimension {
  { widths: [], heights: None, }
}

///|
pub fn IterGridDimension::estimate(
  self : IterGridDimension,
  records : IterRecords,
  cfg : SpannedConfig,
) -> Unit {
  let count = records.count_cols()
  let widths = Array::make(count, 0)
  let spanned = []
  for row in 0..<records.count_rows() {
    for col in 0..<count {
      if !cfg.is_cell_visible(row, col) {
        continue
      }
      let source = cfg.span_source_at(row, col)
      let colspan = cfg.col_span_at(row, col)
      processed_lines(
        records.get_cell(source.0, source.1),
        cfg.width_mode_at(source.0, source.1),
        cfg.height_mode_at(source.0, source.1),
      ).each(line => {
        let (padding_left, padding_right, _, _) = cfg.padding_at(
          source.0,
          source.1,
        )
        let width = string_display_width(line) + padding_left + padding_right
        if colspan <= 1 && width > widths[col] {
          widths[col] = width
        } else if colspan > 1 {
          spanned.push((col, colspan, width, row))
        }
      })
    }
  }
  spanned.sort_by((a, b) => {
    if a.1 != b.1 {
      a.1.compare(b.1)
    } else if a.3 != b.3 {
      a.3.compare(b.3)
    } else {
      a.0.compare(b.0)
    }
  })
  spanned.each(item => {
    let end_ = if item.0 + item.1 < count { item.0 + item.1 } else { count }
    let mut current = 0
    for col = item.0; col < end_; col = col + 1 {
      current = current + widths[col]
      if col > item.0 && cfg.has_vertical(col, count) {
        current += 1
      }
    }
    if item.2 > current && end_ > item.0 {
      let extra = item.2 - current
      let each = extra / (end_ - item.0)
      let rest = extra % (end_ - item.0)
      for col in item.0..<end_ {
        widths[col] += each + (if col == item.0 { rest } else { 0 })
      }
    }
  })
  self.widths = widths
}

///|
pub fn IterGridDimension::widths(self : IterGridDimension) -> Array[Int] {
  self.widths
}

///|
/// Measure the dimensions used by IterGrid, including render-time width and
/// height modes. Explicit dimension overrides are applied by the caller.
/// Unlike the static width/height helpers, this measures processed cell lines.
///
/// ```mbt check
/// test {
///   let records = IterRecords::new([["abcdef"]])
///   let config = SpannedConfig::default()
///   config.set_width_mode(WidthMode::wrap(2))
///   config.set_height_mode(HeightMode::increase(5))
///   assert_eq(IterGridDimension::measure_rendered(records, config), ([2], [5]))
/// }
/// ```
pub fn IterGridDimension::measure_rendered(
  records : IterRecords,
  config : SpannedConfig,
) -> (Array[Int], Array[Int]) {
  let dims = IterGridDimension::default()
  dims.estimate(records, config)
  (dims.widths(), row_metrics(records, records.count_cols(), config))
}

///|
pub fn IterGridDimension::set_widths(
  self : IterGridDimension,
  widths : Array[Int],
) -> Unit {
  self.widths = widths.copy()
}

///|
pub fn IterGridDimension::measure_widths(
  records : IterRecords,
  config : SpannedConfig,
) -> Array[Int] {
  measure_axis(records, config, true)
}

///|
pub fn IterGridDimension::measure_heights(
  records : IterRecords,
  config : SpannedConfig,
) -> Array[Int] {
  measure_axis(records, config, false)
}

///|
pub fn IterGridDimension::total_width(
  records : IterRecords,
  config : SpannedConfig,
) -> Int {
  IterGridDimension::measure_widths(records, config).fold(init=0, (sum, width) => {
    sum + width
  }) +
  config.count_vertical(records.count_cols())
}

///|
pub fn IterGridDimension::total_height(
  records : IterRecords,
  config : SpannedConfig,
) -> Int {
  IterGridDimension::measure_heights(records, config).fold(init=0, (sum, height) => {
    sum + height
  }) +
  config.count_horizontal(records.count_rows())
}

///|
fn measure_axis(
  records : IterRecords,
  config : SpannedConfig,
  horizontal : Bool,
  cached? : Bool = false,
) -> Array[Int] {
  let count = if horizontal {
    records.count_cols()
  } else {
    records.count_rows()
  }
  let values = Array::make(count, 0)
  let spans : Array[(Int, Int, Int, Int)] = []
  let spanned = if cached {
    config.col_spans.any(entry => entry.2 > 1) ||
    config.row_spans.any(entry => entry.2 > 1)
  } else if horizontal {
    config.col_spans.any(entry => entry.2 > 1)
  } else {
    config.row_spans.any(entry => entry.2 > 1)
  }
  for row in 0..<records.count_rows() {
    for col in 0..<records.count_cols() {
      if spanned && !config.is_cell_visible(row, col) {
        continue
      }
      let source = if spanned {
        config.span_source_at(row, col)
      } else {
        (row, col)
      }
      let text = records.get_cell(source.0, source.1)
      let (left, right, top, bottom) = config.padding_at(source.0, source.1)
      let size = if horizontal {
        (if cached { get_text_dimension(text).1 } else { get_text_width(text) }) +
        left +
        right
      } else {
        count_lines(text) + top + bottom
      }
      let span = if horizontal {
        config.col_span_at(row, col)
      } else {
        config.row_span_at(row, col)
      }
      if span > 1 {
        spans.push((row, col, span, size))
      } else {
        let index = if horizontal { col } else { row }
        values[index] = Int::max(values[index], size)
      }
    }
  }
  spans.sort_by((a, b) => {
    let span_order = if horizontal { a.2.compare(b.2) } else { 0 }
    if span_order != 0 {
      span_order
    } else if a.0 != b.0 {
      a.0.compare(b.0)
    } else {
      a.1.compare(b.1)
    }
  })
  for entry in spans {
    let start = if horizontal { entry.1 } else { entry.0 }
    let end_ = Int::min(count, start + entry.2)
    let mut current = 0
    for index in start..<end_ {
      current += values[index]
      if index > start &&
        (if horizontal {
          config.has_vertical(index, count)
        } else {
          config.has_horizontal(index, count)
        }) {
        current += 1
      }
    }
    if entry.3 > current && end_ > start {
      let extra = entry.3 - current
      let each = extra / (end_ - start)
      let rest = extra % (end_ - start)
      for index in start..<end_ {
        values[index] += each + (if index == start { rest } else { 0 })
      }
    }
  }
  values
}
