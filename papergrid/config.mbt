///|
pub enum AlignmentHorizontal {
  Left
  Right
  Center
}

///|
pub enum AlignmentVertical {
  Top
  Bottom
  Center
}

///|
pub enum HorizontalLines {
  All
  HeaderOnly
  None
}

///|
pub struct HorizontalLine {
  main : Char?
  left : Char?
  intersection : Char?
  right : Char?
}

///|
pub fn AlignmentHorizontal::left() -> AlignmentHorizontal {
  Left
}

///|
pub fn AlignmentHorizontal::right() -> AlignmentHorizontal {
  Right
}

///|
pub fn AlignmentHorizontal::center() -> AlignmentHorizontal {
  Center
}

///|
pub fn AlignmentVertical::top() -> AlignmentVertical {
  Top
}

///|
pub fn AlignmentVertical::bottom() -> AlignmentVertical {
  Bottom
}

///|
pub fn AlignmentVertical::center() -> AlignmentVertical {
  Center
}

///|
pub fn HorizontalLines::all() -> HorizontalLines {
  All
}

///|
pub fn HorizontalLines::header_only() -> HorizontalLines {
  HeaderOnly
}

///|
pub fn HorizontalLines::none() -> HorizontalLines {
  None
}

///|
pub fn HorizontalLine::new(ch : Char) -> HorizontalLine {
  { main: Some(ch), left: None, intersection: None, right: None }
}

///|
pub fn HorizontalLine::filled(ch : Char) -> HorizontalLine {
  HorizontalLine::new(ch)
}

///|
pub fn HorizontalLine::full(
  main : Char,
  left : Char,
  intersection : Char,
  right : Char,
) -> HorizontalLine {
  {
    main: Some(main),
    left: Some(left),
    intersection: Some(intersection),
    right: Some(right),
  }
}

///|
pub fn HorizontalLine::from_chars(
  main : Char?,
  left : Char?,
  intersection : Char?,
  right : Char?,
) -> HorizontalLine {
  { main, left, intersection, right }
}

///|
pub fn HorizontalLine::with_left(
  self : HorizontalLine,
  ch : Char,
) -> HorizontalLine {
  { ..self, left: Some(ch) }
}

///|
pub fn HorizontalLine::with_intersection(
  self : HorizontalLine,
  ch : Char,
) -> HorizontalLine {
  { ..self, intersection: Some(ch) }
}

///|
pub fn HorizontalLine::with_right(
  self : HorizontalLine,
  ch : Char,
) -> HorizontalLine {
  { ..self, right: Some(ch) }
}

///|
pub struct SpannedConfig {
  mut borders : Borders
  mut padding_left : Int
  mut padding_right : Int
  mut padding_top : Int
  mut padding_bottom : Int
  mut alignment : AlignmentHorizontal
  mut vertical_alignment : AlignmentVertical
  mut width_mode : WidthMode
  mut height_mode : HeightMode
  mut horizontal_lines : HorizontalLines
  custom_horizontal_lines : Array[(Int, HorizontalLine)]
  width_rules : Array[(Int, Int, Int, WidthMode)]
  height_rules : Array[(Int, Int, Int, HeightMode)]
  alignment_rules : Array[(Int, Int, Int, AlignmentHorizontal)]
  vertical_alignment_rules : Array[(Int, Int, Int, AlignmentVertical)]
  padding_rules : Array[(Int, Int, Int, Int, Int, Int, Int)]
  column_spans : Array[(Int, Int, Int)]
  row_spans : Array[(Int, Int, Int)]
  span_sources : Array[(Int, Int, Int, Int)]
}

///|
pub fn SpannedConfig::default() -> SpannedConfig {
  {
    borders: Borders::ascii(),
    padding_left: 1,
    padding_right: 1,
    padding_top: 0,
    padding_bottom: 0,
    alignment: AlignmentHorizontal::center(),
    vertical_alignment: AlignmentVertical::top(),
    width_mode: WidthMode::none(),
    height_mode: HeightMode::none(),
    horizontal_lines: HorizontalLines::all(),
    custom_horizontal_lines: [],
    width_rules: [],
    height_rules: [],
    alignment_rules: [],
    vertical_alignment_rules: [],
    padding_rules: [],
    column_spans: [],
    row_spans: [],
    span_sources: [],
  }
}

///|
pub fn SpannedConfig::set_borders(
  self : SpannedConfig,
  borders : Borders,
) -> Unit {
  self.borders = borders
}

///|
pub fn SpannedConfig::borders(self : SpannedConfig) -> Borders {
  self.borders
}

///|
pub fn SpannedConfig::set_padding(
  self : SpannedConfig,
  left : Int,
  right : Int,
  top : Int,
  bottom : Int,
) -> Unit {
  self.padding_left = left
  self.padding_right = right
  self.padding_top = top
  self.padding_bottom = bottom
}

///|
pub fn SpannedConfig::padding_left(self : SpannedConfig) -> Int {
  self.padding_left
}

///|
pub fn SpannedConfig::padding_right(self : SpannedConfig) -> Int {
  self.padding_right
}

///|
pub fn SpannedConfig::padding_top(self : SpannedConfig) -> Int {
  self.padding_top
}

///|
pub fn SpannedConfig::padding_bottom(self : SpannedConfig) -> Int {
  self.padding_bottom
}

///|
pub fn SpannedConfig::set_alignment(
  self : SpannedConfig,
  alignment : AlignmentHorizontal,
) -> Unit {
  self.alignment = alignment
}

///|
pub fn SpannedConfig::alignment(self : SpannedConfig) -> AlignmentHorizontal {
  self.alignment
}

///|
pub fn SpannedConfig::set_vertical_alignment(
  self : SpannedConfig,
  alignment : AlignmentVertical,
) -> Unit {
  self.vertical_alignment = alignment
}

///|
pub fn SpannedConfig::vertical_alignment(
  self : SpannedConfig,
) -> AlignmentVertical {
  self.vertical_alignment
}

///|
pub fn SpannedConfig::set_width_mode(
  self : SpannedConfig,
  mode : WidthMode,
) -> Unit {
  self.width_mode = mode
}

///|
pub fn SpannedConfig::width_mode(self : SpannedConfig) -> WidthMode {
  self.width_mode
}

///|
pub fn SpannedConfig::set_width_mode_for_rows(
  self : SpannedConfig,
  start : Int,
  end : Int,
  mode : WidthMode,
) -> Unit {
  self.width_rules.push((0, start, end, mode))
}

///|
pub fn SpannedConfig::set_width_mode_for_columns(
  self : SpannedConfig,
  start : Int,
  end : Int,
  mode : WidthMode,
) -> Unit {
  self.width_rules.push((1, start, end, mode))
}

///|
pub fn SpannedConfig::set_width_mode_for_all(
  self : SpannedConfig,
  mode : WidthMode,
) -> Unit {
  self.width_rules.push((2, 0, 0, mode))
}

///|
pub fn SpannedConfig::set_width_mode_for_cell(
  self : SpannedConfig,
  row : Int,
  column : Int,
  mode : WidthMode,
) -> Unit {
  self.width_rules.push((3, row, column, mode))
}

///|
pub fn SpannedConfig::width_mode_at(
  self : SpannedConfig,
  row : Int,
  column : Int,
) -> WidthMode {
  let mut value = self.width_mode
  self.width_rules.each(rule => {
    if scope_matches(rule.0, rule.1, rule.2, row, column) {
      value = rule.3
    }
  })
  value
}

///|
pub fn SpannedConfig::set_height_mode(
  self : SpannedConfig,
  mode : HeightMode,
) -> Unit {
  self.height_mode = mode
}

///|
pub fn SpannedConfig::height_mode(self : SpannedConfig) -> HeightMode {
  self.height_mode
}

///|
pub fn SpannedConfig::set_height_mode_for_rows(
  self : SpannedConfig,
  start : Int,
  end : Int,
  mode : HeightMode,
) -> Unit {
  self.height_rules.push((0, start, end, mode))
}

///|
pub fn SpannedConfig::set_height_mode_for_columns(
  self : SpannedConfig,
  start : Int,
  end : Int,
  mode : HeightMode,
) -> Unit {
  self.height_rules.push((1, start, end, mode))
}

///|
pub fn SpannedConfig::set_height_mode_for_all(
  self : SpannedConfig,
  mode : HeightMode,
) -> Unit {
  self.height_rules.push((2, 0, 0, mode))
}

///|
pub fn SpannedConfig::set_height_mode_for_cell(
  self : SpannedConfig,
  row : Int,
  column : Int,
  mode : HeightMode,
) -> Unit {
  self.height_rules.push((3, row, column, mode))
}

///|
pub fn SpannedConfig::height_mode_at(
  self : SpannedConfig,
  row : Int,
  column : Int,
) -> HeightMode {
  let mut value = self.height_mode
  self.height_rules.each(rule => {
    if scope_matches(rule.0, rule.1, rule.2, row, column) {
      value = rule.3
    }
  })
  value
}

///|
pub fn SpannedConfig::set_horizontal_lines(
  self : SpannedConfig,
  mode : HorizontalLines,
) -> Unit {
  self.horizontal_lines = mode
}

///|
pub fn SpannedConfig::horizontal_lines(self : SpannedConfig) -> HorizontalLines {
  self.horizontal_lines
}

///|
pub fn SpannedConfig::set_custom_horizontal_lines(
  self : SpannedConfig,
  lines : Array[(Int, HorizontalLine)],
) -> Unit {
  self.custom_horizontal_lines.clear()
  lines.each(line => self.custom_horizontal_lines.push(line))
}

///|
pub fn SpannedConfig::custom_horizontal_line(
  self : SpannedConfig,
  row : Int,
) -> HorizontalLine? {
  let mut index = self.custom_horizontal_lines.length() - 1
  while index >= 0 {
    let line = self.custom_horizontal_lines[index]
    if line.0 == row {
      return Some(line.1)
    }
    index = index - 1
  }
  None
}

///|
fn scope_matches(
  kind : Int,
  start : Int,
  end : Int,
  row : Int,
  column : Int,
) -> Bool {
  if kind == 0 {
    row >= start && row < end
  } else if kind == 1 {
    column >= start && column < end
  } else if kind == 3 {
    row == start && column == end
  } else {
    true
  }
}

///|
pub fn SpannedConfig::set_alignment_for_rows(
  self : SpannedConfig,
  start : Int,
  end : Int,
  alignment : AlignmentHorizontal,
) -> Unit {
  self.alignment_rules.push((0, start, end, alignment))
}

///|
pub fn SpannedConfig::set_alignment_for_columns(
  self : SpannedConfig,
  start : Int,
  end : Int,
  alignment : AlignmentHorizontal,
) -> Unit {
  self.alignment_rules.push((1, start, end, alignment))
}

///|
pub fn SpannedConfig::set_alignment_for_all(
  self : SpannedConfig,
  alignment : AlignmentHorizontal,
) -> Unit {
  self.alignment_rules.push((2, 0, 0, alignment))
}

///|
pub fn SpannedConfig::set_alignment_for_cell(
  self : SpannedConfig,
  row : Int,
  column : Int,
  alignment : AlignmentHorizontal,
) -> Unit {
  self.alignment_rules.push((3, row, column, alignment))
}

///|
pub fn SpannedConfig::alignment_at(
  self : SpannedConfig,
  row : Int,
  column : Int,
) -> AlignmentHorizontal {
  let mut value = self.alignment
  self.alignment_rules.each(rule => {
    if scope_matches(rule.0, rule.1, rule.2, row, column) {
      value = rule.3
    }
  })
  value
}

///|
pub fn SpannedConfig::set_vertical_alignment_for_rows(
  self : SpannedConfig,
  start : Int,
  end : Int,
  alignment : AlignmentVertical,
) -> Unit {
  self.vertical_alignment_rules.push((0, start, end, alignment))
}

///|
pub fn SpannedConfig::set_vertical_alignment_for_columns(
  self : SpannedConfig,
  start : Int,
  end : Int,
  alignment : AlignmentVertical,
) -> Unit {
  self.vertical_alignment_rules.push((1, start, end, alignment))
}

///|
pub fn SpannedConfig::set_vertical_alignment_for_all(
  self : SpannedConfig,
  alignment : AlignmentVertical,
) -> Unit {
  self.vertical_alignment_rules.push((2, 0, 0, alignment))
}

///|
pub fn SpannedConfig::set_vertical_alignment_for_cell(
  self : SpannedConfig,
  row : Int,
  column : Int,
  alignment : AlignmentVertical,
) -> Unit {
  self.vertical_alignment_rules.push((3, row, column, alignment))
}

///|
pub fn SpannedConfig::vertical_alignment_at(
  self : SpannedConfig,
  row : Int,
  column : Int,
) -> AlignmentVertical {
  let mut value = self.vertical_alignment
  self.vertical_alignment_rules.each(rule => {
    if scope_matches(rule.0, rule.1, rule.2, row, column) {
      value = rule.3
    }
  })
  value
}

///|
pub fn SpannedConfig::set_padding_for_rows(
  self : SpannedConfig,
  start : Int,
  end : Int,
  left : Int,
  right : Int,
  top : Int,
  bottom : Int,
) -> Unit {
  self.padding_rules.push((0, start, end, left, right, top, bottom))
}

///|
pub fn SpannedConfig::set_padding_for_columns(
  self : SpannedConfig,
  start : Int,
  end : Int,
  left : Int,
  right : Int,
  top : Int,
  bottom : Int,
) -> Unit {
  self.padding_rules.push((1, start, end, left, right, top, bottom))
}

///|
pub fn SpannedConfig::set_padding_for_all(
  self : SpannedConfig,
  left : Int,
  right : Int,
  top : Int,
  bottom : Int,
) -> Unit {
  self.padding_rules.push((2, 0, 0, left, right, top, bottom))
}

///|
pub fn SpannedConfig::set_padding_for_cell(
  self : SpannedConfig,
  row : Int,
  column : Int,
  left : Int,
  right : Int,
  top : Int,
  bottom : Int,
) -> Unit {
  self.padding_rules.push((3, row, column, left, right, top, bottom))
}

///|
pub fn SpannedConfig::padding_at(
  self : SpannedConfig,
  row : Int,
  column : Int,
) -> (Int, Int, Int, Int) {
  let mut left = self.padding_left
  let mut right = self.padding_right
  let mut top = self.padding_top
  let mut bottom = self.padding_bottom
  self.padding_rules.each(rule => {
    if scope_matches(rule.0, rule.1, rule.2, row, column) {
      left = rule.3
      right = rule.4
      top = rule.5
      bottom = rule.6
    }
  })
  (left, right, top, bottom)
}

///|
pub fn SpannedConfig::set_column_span(
  self : SpannedConfig,
  row : Int,
  column : Int,
  span : Int,
) -> Unit {
  let next = []
  self.column_spans.each(item => {
    if item.0 != row || item.1 != column {
      next.push(item)
    }
  })
  self.column_spans.clear()
  next.each(item => self.column_spans.push(item))
  if span > 1 {
    self.column_spans.push((row, column, span))
  }
}

///|
pub fn SpannedConfig::set_row_span(
  self : SpannedConfig,
  row : Int,
  column : Int,
  span : Int,
) -> Unit {
  let next = []
  self.row_spans.each(item => {
    if item.0 != row || item.1 != column {
      next.push(item)
    }
  })
  self.row_spans.clear()
  next.each(item => self.row_spans.push(item))
  if span > 1 {
    self.row_spans.push((row, column, span))
  }
}

///|
pub fn SpannedConfig::set_span_source(
  self : SpannedConfig,
  anchor_row : Int,
  anchor_column : Int,
  source_row : Int,
  source_column : Int,
) -> Unit {
  let next = []
  self.span_sources.each(item => {
    if item.0 != anchor_row || item.1 != anchor_column {
      next.push(item)
    }
  })
  self.span_sources.clear()
  next.each(item => self.span_sources.push(item))
  if anchor_row != source_row || anchor_column != source_column {
    self.span_sources.push(
      (anchor_row, anchor_column, source_row, source_column),
    )
  }
}

///|
pub fn SpannedConfig::clear_span_source(
  self : SpannedConfig,
  anchor_row : Int,
  anchor_column : Int,
) -> Unit {
  let next = []
  self.span_sources.each(item => {
    if item.0 != anchor_row || item.1 != anchor_column {
      next.push(item)
    }
  })
  self.span_sources.clear()
  next.each(item => self.span_sources.push(item))
}

///|
pub fn SpannedConfig::clear_span_source_if_unused(
  self : SpannedConfig,
  anchor_row : Int,
  anchor_column : Int,
) -> Unit {
  if self.column_span_at(anchor_row, anchor_column) <= 1 &&
    self.row_span_at(anchor_row, anchor_column) <= 1 {
    self.clear_span_source(anchor_row, anchor_column)
  }
}

///|
pub fn SpannedConfig::span_source_at(
  self : SpannedConfig,
  anchor_row : Int,
  anchor_column : Int,
) -> (Int, Int) {
  let mut index = self.span_sources.length() - 1
  while index >= 0 {
    let item = self.span_sources[index]
    if item.0 == anchor_row && item.1 == anchor_column {
      return (item.2, item.3)
    }
    index = index - 1
  }
  (anchor_row, anchor_column)
}

///|
pub fn SpannedConfig::span_anchor_for_source(
  self : SpannedConfig,
  source_row : Int,
  source_column : Int,
) -> (Int, Int)? {
  let mut index = self.span_sources.length() - 1
  while index >= 0 {
    let item = self.span_sources[index]
    if item.2 == source_row && item.3 == source_column {
      return Some((item.0, item.1))
    }
    index = index - 1
  }
  None
}

///|
pub fn SpannedConfig::get_column_span(
  self : SpannedConfig,
  row : Int,
  column : Int,
) -> Int? {
  let mut index = self.column_spans.length() - 1
  while index >= 0 {
    let item = self.column_spans[index]
    if item.0 == row && item.1 == column {
      return Some(item.2)
    }
    index = index - 1
  }
  None
}

///|
pub fn SpannedConfig::get_row_span(
  self : SpannedConfig,
  row : Int,
  column : Int,
) -> Int? {
  let mut index = self.row_spans.length() - 1
  while index >= 0 {
    let item = self.row_spans[index]
    if item.0 == row && item.1 == column {
      return Some(item.2)
    }
    index = index - 1
  }
  None
}

///|
pub fn SpannedConfig::column_span_at(
  self : SpannedConfig,
  row : Int,
  column : Int,
) -> Int {
  match self.get_column_span(row, column) {
    Some(span) => span
    None => 1
  }
}

///|
pub fn SpannedConfig::row_span_at(
  self : SpannedConfig,
  row : Int,
  column : Int,
) -> Int {
  match self.get_row_span(row, column) {
    Some(span) => span
    None => 1
  }
}

///|
pub fn SpannedConfig::has_column_spans(self : SpannedConfig) -> Bool {
  !self.column_spans.is_empty()
}

///|
pub fn SpannedConfig::has_row_spans(self : SpannedConfig) -> Bool {
  !self.row_spans.is_empty()
}

///|
pub fn SpannedConfig::is_cell_covered_by_column_span(
  self : SpannedConfig,
  row : Int,
  column : Int,
) -> Bool {
  for index = 0; index < self.column_spans.length(); index = index + 1 {
    let item = self.column_spans[index]
    if item.0 == row && column > item.1 && column < item.1 + item.2 {
      return true
    }
  }
  false
}

///|
pub fn SpannedConfig::is_cell_covered_by_row_span(
  self : SpannedConfig,
  row : Int,
  column : Int,
) -> Bool {
  for index = 0; index < self.row_spans.length(); index = index + 1 {
    let item = self.row_spans[index]
    let colspan = self.column_span_at(item.0, item.1)
    if row > item.0 &&
      row < item.0 + item.2 &&
      column >= item.1 &&
      column < item.1 + colspan {
      return true
    }
  }
  false
}

///|
pub fn SpannedConfig::is_cell_covered_by_both_spans(
  self : SpannedConfig,
  row : Int,
  column : Int,
) -> Bool {
  self.is_cell_covered_by_column_span(row, column) &&
  self.is_cell_covered_by_row_span(row, column)
}

///|
pub fn SpannedConfig::is_cell_visible(
  self : SpannedConfig,
  row : Int,
  column : Int,
) -> Bool {
  for index = 0; index < self.column_spans.length(); index = index + 1 {
    let item = self.column_spans[index]
    let rowspan = self.row_span_at(item.0, item.1)
    if row >= item.0 &&
      row < item.0 + rowspan &&
      column > item.1 &&
      column < item.1 + item.2 {
      return false
    }
  }
  for index = 0; index < self.row_spans.length(); index = index + 1 {
    let item = self.row_spans[index]
    let colspan = self.column_span_at(item.0, item.1)
    if row > item.0 &&
      row < item.0 + item.2 &&
      column >= item.1 &&
      column < item.1 + colspan {
      return false
    }
  }
  true
}

///|
fn map_index(index_map : Array[Int], index : Int) -> Int {
  if index < 0 || index >= index_map.length() {
    -1
  } else {
    index_map[index]
  }
}

///|
fn mapped_runs(
  index_map : Array[Int],
  start : Int,
  end : Int,
) -> Array[(Int, Int)] {
  let runs = []
  let mut run_start = -1
  let mut previous = -1
  for old = start; old < end; old = old + 1 {
    let mapped = map_index(index_map, old)
    if mapped < 0 {
      continue
    }
    if run_start < 0 {
      run_start = mapped
      previous = mapped
    } else if mapped == previous + 1 {
      previous = mapped
    } else {
      runs.push((run_start, previous + 1))
      run_start = mapped
      previous = mapped
    }
  }
  if run_start >= 0 {
    runs.push((run_start, previous + 1))
  }
  runs
}

///|
pub fn SpannedConfig::remap(
  self : SpannedConfig,
  row_map : Array[Int],
  column_map : Array[Int],
) -> Unit {
  let next_alignment_rules = []
  self.alignment_rules.each(rule => {
    if rule.0 == 0 {
      mapped_runs(row_map, rule.1, rule.2).each(run => {
        next_alignment_rules.push((0, run.0, run.1, rule.3))
      })
    } else if rule.0 == 1 {
      mapped_runs(column_map, rule.1, rule.2).each(run => {
        next_alignment_rules.push((1, run.0, run.1, rule.3))
      })
    } else if rule.0 == 2 {
      next_alignment_rules.push(rule)
    } else {
      let row = map_index(row_map, rule.1)
      let column = map_index(column_map, rule.2)
      if row >= 0 && column >= 0 {
        next_alignment_rules.push((3, row, column, rule.3))
      }
    }
  })
  self.alignment_rules.clear()
  next_alignment_rules.each(rule => self.alignment_rules.push(rule))

  let next_vertical_alignment_rules = []
  self.vertical_alignment_rules.each(rule => {
    if rule.0 == 0 {
      mapped_runs(row_map, rule.1, rule.2).each(run => {
        next_vertical_alignment_rules.push((0, run.0, run.1, rule.3))
      })
    } else if rule.0 == 1 {
      mapped_runs(column_map, rule.1, rule.2).each(run => {
        next_vertical_alignment_rules.push((1, run.0, run.1, rule.3))
      })
    } else if rule.0 == 2 {
      next_vertical_alignment_rules.push(rule)
    } else {
      let row = map_index(row_map, rule.1)
      let column = map_index(column_map, rule.2)
      if row >= 0 && column >= 0 {
        next_vertical_alignment_rules.push((3, row, column, rule.3))
      }
    }
  })
  self.vertical_alignment_rules.clear()
  next_vertical_alignment_rules.each(rule => {
    self.vertical_alignment_rules.push(rule)
  })

  let next_padding_rules = []
  self.padding_rules.each(rule => {
    if rule.0 == 0 {
      mapped_runs(row_map, rule.1, rule.2).each(run => {
        next_padding_rules.push(
          (0, run.0, run.1, rule.3, rule.4, rule.5, rule.6),
        )
      })
    } else if rule.0 == 1 {
      mapped_runs(column_map, rule.1, rule.2).each(run => {
        next_padding_rules.push(
          (1, run.0, run.1, rule.3, rule.4, rule.5, rule.6),
        )
      })
    } else if rule.0 == 2 {
      next_padding_rules.push(rule)
    } else {
      let row = map_index(row_map, rule.1)
      let column = map_index(column_map, rule.2)
      if row >= 0 && column >= 0 {
        next_padding_rules.push(
          (3, row, column, rule.3, rule.4, rule.5, rule.6),
        )
      }
    }
  })
  self.padding_rules.clear()
  next_padding_rules.each(rule => self.padding_rules.push(rule))

  let next_width_rules = []
  self.width_rules.each(rule => {
    if rule.0 == 0 {
      mapped_runs(row_map, rule.1, rule.2).each(run => {
        next_width_rules.push((0, run.0, run.1, rule.3))
      })
    } else if rule.0 == 1 {
      mapped_runs(column_map, rule.1, rule.2).each(run => {
        next_width_rules.push((1, run.0, run.1, rule.3))
      })
    } else if rule.0 == 2 {
      next_width_rules.push(rule)
    } else {
      let row = map_index(row_map, rule.1)
      let column = map_index(column_map, rule.2)
      if row >= 0 && column >= 0 {
        next_width_rules.push((3, row, column, rule.3))
      }
    }
  })
  self.width_rules.clear()
  next_width_rules.each(rule => self.width_rules.push(rule))

  let next_height_rules = []
  self.height_rules.each(rule => {
    if rule.0 == 0 {
      mapped_runs(row_map, rule.1, rule.2).each(run => {
        next_height_rules.push((0, run.0, run.1, rule.3))
      })
    } else if rule.0 == 1 {
      mapped_runs(column_map, rule.1, rule.2).each(run => {
        next_height_rules.push((1, run.0, run.1, rule.3))
      })
    } else if rule.0 == 2 {
      next_height_rules.push(rule)
    } else {
      let row = map_index(row_map, rule.1)
      let column = map_index(column_map, rule.2)
      if row >= 0 && column >= 0 {
        next_height_rules.push((3, row, column, rule.3))
      }
    }
  })
  self.height_rules.clear()
  next_height_rules.each(rule => self.height_rules.push(rule))

  let next_custom_horizontal_lines = []
  self.custom_horizontal_lines.each(line => {
    let boundary = line.0
    if boundary <= 0 || boundary >= row_map.length() {
      return
    }
    let prev_row = map_index(row_map, boundary - 1)
    let next_row = map_index(row_map, boundary)
    if prev_row >= 0 && next_row >= 0 && next_row == prev_row + 1 {
      next_custom_horizontal_lines.push((next_row, line.1))
    }
  })
  self.custom_horizontal_lines.clear()
  next_custom_horizontal_lines.each(line => {
    self.custom_horizontal_lines.push(line)
  })

  let next_column_spans = []
  self.column_spans.each(item => {
    let mapped_row = map_index(row_map, item.0)
    if mapped_row < 0 {
      return
    }
    let columns = mapped_runs(column_map, item.1, item.1 + item.2)
    if columns.is_empty() {
      return
    }
    let run = columns[0]
    let span = run.1 - run.0
    if span > 1 {
      next_column_spans.push((mapped_row, run.0, span))
    }
  })
  self.column_spans.clear()
  next_column_spans.each(item => self.column_spans.push(item))

  let next_row_spans = []
  self.row_spans.each(item => {
    let rows = mapped_runs(row_map, item.0, item.0 + item.2)
    let mapped_column = map_index(column_map, item.1)
    if rows.is_empty() || mapped_column < 0 {
      return
    }
    let run = rows[0]
    let span = run.1 - run.0
    if span > 1 {
      next_row_spans.push((run.0, mapped_column, span))
    }
  })
  self.row_spans.clear()
  next_row_spans.each(item => self.row_spans.push(item))

  let next_span_sources = []
  self.span_sources.each(item => {
    let anchor_row = map_index(row_map, item.0)
    let anchor_column = map_index(column_map, item.1)
    let source_row = map_index(row_map, item.2)
    let source_column = map_index(column_map, item.3)
    if anchor_row >= 0 &&
      anchor_column >= 0 &&
      source_row >= 0 &&
      source_column >= 0 {
      next_span_sources.push(
        (anchor_row, anchor_column, source_row, source_column),
      )
    }
  })
  self.span_sources.clear()
  next_span_sources.each(item => self.span_sources.push(item))
}
