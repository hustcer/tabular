///|
enum Scope {
  RowRange(Int, Int)
  ColRange(Int, Int)
  All
  Cell(Int, Int)
}

///|
pub enum HAlign {
  Left
  Right
  Center
}

///|
pub enum VAlign {
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
pub fn HAlign::left() -> HAlign {
  Left
}

///|
pub fn HAlign::right() -> HAlign {
  Right
}

///|
pub fn HAlign::center() -> HAlign {
  Center
}

///|
pub fn VAlign::top() -> VAlign {
  Top
}

///|
pub fn VAlign::bottom() -> VAlign {
  Bottom
}

///|
pub fn VAlign::center() -> VAlign {
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
pub(all) struct CellBorder {
  top : Char?
  bottom : Char?
  left : Char?
  right : Char?
  left_top_corner : Char?
  right_top_corner : Char?
  left_bottom_corner : Char?
  right_bottom_corner : Char?
}

///|
pub fn CellBorder::empty() -> CellBorder {
  {
    top: None,
    bottom: None,
    left: None,
    right: None,
    left_top_corner: None,
    right_top_corner: None,
    left_bottom_corner: None,
    right_bottom_corner: None,
  }
}

///|
pub fn CellBorder::filled(ch : Char) -> CellBorder {
  {
    top: Some(ch),
    bottom: Some(ch),
    left: Some(ch),
    right: Some(ch),
    left_top_corner: Some(ch),
    right_top_corner: Some(ch),
    left_bottom_corner: Some(ch),
    right_bottom_corner: Some(ch),
  }
}

///|
pub struct SpannedConfig {
  mut borders : Borders
  mut padding_left : Int
  mut padding_right : Int
  mut padding_top : Int
  mut padding_bottom : Int
  mut align : HAlign
  mut valign : VAlign
  mut width_mode : WidthMode
  mut height_mode : HeightMode
  mut horizontal_lines : HorizontalLines
  custom_horizontal_lines : Array[(Int, HorizontalLine)]
  width_rules : Array[(Scope, WidthMode)]
  height_rules : Array[(Scope, HeightMode)]
  align_rules : Array[(Scope, HAlign)]
  valign_rules : Array[(Scope, VAlign)]
  padding_rules : Array[(Scope, Int, Int, Int, Int)]
  col_spans : Array[(Int, Int, Int)]
  row_spans : Array[(Int, Int, Int)]
  span_sources : Array[(Int, Int, Int, Int)]
  // Per-position border overrides for Highlight
  // (row_boundary, col, char) — horizontal fill overrides
  border_horizontal : Array[(Int, Int, Char)]
  // (row, col_boundary, char) — vertical fill overrides
  border_vertical : Array[(Int, Int, Char)]
  // (row_boundary, col_boundary, char) — intersection/corner overrides
  border_intersection : Array[(Int, Int, Char)]
  // Margin: per-side size, fill char, and offset
  mut margin_top : Int
  mut margin_bottom : Int
  mut margin_left : Int
  mut margin_right : Int
  mut margin_fill_top : Char
  mut margin_fill_bottom : Char
  mut margin_fill_left : Char
  mut margin_fill_right : Char
  mut margin_offset_top : Int
  mut margin_offset_bottom : Int
  mut margin_offset_left : Int
  mut margin_offset_right : Int
}

///|
pub fn SpannedConfig::default() -> SpannedConfig {
  {
    borders: Borders::ascii(),
    padding_left: 1,
    padding_right: 1,
    padding_top: 0,
    padding_bottom: 0,
    align: HAlign::center(),
    valign: VAlign::top(),
    width_mode: WidthMode::none(),
    height_mode: HeightMode::none(),
    horizontal_lines: HorizontalLines::all(),
    custom_horizontal_lines: [],
    width_rules: [],
    height_rules: [],
    align_rules: [],
    valign_rules: [],
    padding_rules: [],
    col_spans: [],
    row_spans: [],
    span_sources: [],
    border_horizontal: [],
    border_vertical: [],
    border_intersection: [],
    margin_top: 0,
    margin_bottom: 0,
    margin_left: 0,
    margin_right: 0,
    margin_fill_top: ' ',
    margin_fill_bottom: ' ',
    margin_fill_left: ' ',
    margin_fill_right: ' ',
    margin_offset_top: 0,
    margin_offset_bottom: 0,
    margin_offset_left: 0,
    margin_offset_right: 0,
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
pub fn SpannedConfig::set_align(self : SpannedConfig, align : HAlign) -> Unit {
  self.align = align
}

///|
pub fn SpannedConfig::align(self : SpannedConfig) -> HAlign {
  self.align
}

///|
pub fn SpannedConfig::set_valign(self : SpannedConfig, align : VAlign) -> Unit {
  self.valign = align
}

///|
pub fn SpannedConfig::valign(self : SpannedConfig) -> VAlign {
  self.valign
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
  self.width_rules.push((RowRange(start, end), mode))
}

///|
pub fn SpannedConfig::set_width_mode_for_cols(
  self : SpannedConfig,
  start : Int,
  end : Int,
  mode : WidthMode,
) -> Unit {
  self.width_rules.push((ColRange(start, end), mode))
}

///|
pub fn SpannedConfig::set_width_mode_for_all(
  self : SpannedConfig,
  mode : WidthMode,
) -> Unit {
  self.width_rules.push((All, mode))
}

///|
pub fn SpannedConfig::set_width_mode_for_cell(
  self : SpannedConfig,
  row : Int,
  col : Int,
  mode : WidthMode,
) -> Unit {
  self.width_rules.push((Cell(row, col), mode))
}

///|
pub fn SpannedConfig::width_mode_at(
  self : SpannedConfig,
  row : Int,
  col : Int,
) -> WidthMode {
  let mut value = self.width_mode
  self.width_rules.each(rule => {
    if scope_matches(rule.0, row, col) {
      value = rule.1
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
  self.height_rules.push((RowRange(start, end), mode))
}

///|
pub fn SpannedConfig::set_height_mode_for_cols(
  self : SpannedConfig,
  start : Int,
  end : Int,
  mode : HeightMode,
) -> Unit {
  self.height_rules.push((ColRange(start, end), mode))
}

///|
pub fn SpannedConfig::set_height_mode_for_all(
  self : SpannedConfig,
  mode : HeightMode,
) -> Unit {
  self.height_rules.push((All, mode))
}

///|
pub fn SpannedConfig::set_height_mode_for_cell(
  self : SpannedConfig,
  row : Int,
  col : Int,
  mode : HeightMode,
) -> Unit {
  self.height_rules.push((Cell(row, col), mode))
}

///|
pub fn SpannedConfig::height_mode_at(
  self : SpannedConfig,
  row : Int,
  col : Int,
) -> HeightMode {
  let mut value = self.height_mode
  self.height_rules.each(rule => {
    if scope_matches(rule.0, row, col) {
      value = rule.1
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
fn scope_matches(scope : Scope, row : Int, col : Int) -> Bool {
  match scope {
    RowRange(start, end) => row >= start && row < end
    ColRange(start, end) => col >= start && col < end
    Cell(r, c) => row == r && col == c
    All => true
  }
}

///|
pub fn SpannedConfig::set_align_for_rows(
  self : SpannedConfig,
  start : Int,
  end : Int,
  align : HAlign,
) -> Unit {
  self.align_rules.push((RowRange(start, end), align))
}

///|
pub fn SpannedConfig::set_align_for_cols(
  self : SpannedConfig,
  start : Int,
  end : Int,
  align : HAlign,
) -> Unit {
  self.align_rules.push((ColRange(start, end), align))
}

///|
pub fn SpannedConfig::set_align_for_all(
  self : SpannedConfig,
  align : HAlign,
) -> Unit {
  self.align_rules.push((All, align))
}

///|
pub fn SpannedConfig::set_align_for_cell(
  self : SpannedConfig,
  row : Int,
  col : Int,
  align : HAlign,
) -> Unit {
  self.align_rules.push((Cell(row, col), align))
}

///|
pub fn SpannedConfig::align_at(
  self : SpannedConfig,
  row : Int,
  col : Int,
) -> HAlign {
  let mut value = self.align
  self.align_rules.each(rule => {
    if scope_matches(rule.0, row, col) {
      value = rule.1
    }
  })
  value
}

///|
pub fn SpannedConfig::set_valign_for_rows(
  self : SpannedConfig,
  start : Int,
  end : Int,
  align : VAlign,
) -> Unit {
  self.valign_rules.push((RowRange(start, end), align))
}

///|
pub fn SpannedConfig::set_valign_for_cols(
  self : SpannedConfig,
  start : Int,
  end : Int,
  align : VAlign,
) -> Unit {
  self.valign_rules.push((ColRange(start, end), align))
}

///|
pub fn SpannedConfig::set_valign_for_all(
  self : SpannedConfig,
  align : VAlign,
) -> Unit {
  self.valign_rules.push((All, align))
}

///|
pub fn SpannedConfig::set_valign_for_cell(
  self : SpannedConfig,
  row : Int,
  col : Int,
  align : VAlign,
) -> Unit {
  self.valign_rules.push((Cell(row, col), align))
}

///|
pub fn SpannedConfig::valign_at(
  self : SpannedConfig,
  row : Int,
  col : Int,
) -> VAlign {
  let mut value = self.valign
  self.valign_rules.each(rule => {
    if scope_matches(rule.0, row, col) {
      value = rule.1
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
  self.padding_rules.push((RowRange(start, end), left, right, top, bottom))
}

///|
pub fn SpannedConfig::set_padding_for_cols(
  self : SpannedConfig,
  start : Int,
  end : Int,
  left : Int,
  right : Int,
  top : Int,
  bottom : Int,
) -> Unit {
  self.padding_rules.push((ColRange(start, end), left, right, top, bottom))
}

///|
pub fn SpannedConfig::set_padding_for_all(
  self : SpannedConfig,
  left : Int,
  right : Int,
  top : Int,
  bottom : Int,
) -> Unit {
  self.padding_rules.push((All, left, right, top, bottom))
}

///|
pub fn SpannedConfig::set_padding_for_cell(
  self : SpannedConfig,
  row : Int,
  col : Int,
  left : Int,
  right : Int,
  top : Int,
  bottom : Int,
) -> Unit {
  self.padding_rules.push((Cell(row, col), left, right, top, bottom))
}

///|
pub fn SpannedConfig::padding_at(
  self : SpannedConfig,
  row : Int,
  col : Int,
) -> (Int, Int, Int, Int) {
  let mut left = self.padding_left
  let mut right = self.padding_right
  let mut top = self.padding_top
  let mut bottom = self.padding_bottom
  self.padding_rules.each(rule => {
    if scope_matches(rule.0, row, col) {
      left = rule.1
      right = rule.2
      top = rule.3
      bottom = rule.4
    }
  })
  (left, right, top, bottom)
}

///|
pub fn SpannedConfig::set_col_span(
  self : SpannedConfig,
  row : Int,
  col : Int,
  span : Int,
) -> Unit {
  let next = []
  self.col_spans.each(item => {
    if item.0 != row || item.1 != col {
      next.push(item)
    }
  })
  self.col_spans.clear()
  next.each(item => self.col_spans.push(item))
  if span > 1 {
    self.col_spans.push((row, col, span))
  }
}

///|
pub fn SpannedConfig::set_row_span(
  self : SpannedConfig,
  row : Int,
  col : Int,
  span : Int,
) -> Unit {
  let next = []
  self.row_spans.each(item => {
    if item.0 != row || item.1 != col {
      next.push(item)
    }
  })
  self.row_spans.clear()
  next.each(item => self.row_spans.push(item))
  if span > 1 {
    self.row_spans.push((row, col, span))
  }
}

///|
pub fn SpannedConfig::set_span_source(
  self : SpannedConfig,
  anchor_row : Int,
  anchor_col : Int,
  source_row : Int,
  source_col : Int,
) -> Unit {
  let next = []
  self.span_sources.each(item => {
    if item.0 != anchor_row || item.1 != anchor_col {
      next.push(item)
    }
  })
  self.span_sources.clear()
  next.each(item => self.span_sources.push(item))
  if anchor_row != source_row || anchor_col != source_col {
    self.span_sources.push((anchor_row, anchor_col, source_row, source_col))
  }
}

///|
pub fn SpannedConfig::clear_span_source(
  self : SpannedConfig,
  anchor_row : Int,
  anchor_col : Int,
) -> Unit {
  let next = []
  self.span_sources.each(item => {
    if item.0 != anchor_row || item.1 != anchor_col {
      next.push(item)
    }
  })
  self.span_sources.clear()
  next.each(item => self.span_sources.push(item))
}

///|
/// Clear all spans and border override arrays.
/// Used after operations like Split that completely reshape the table.
pub fn SpannedConfig::clear_spans_and_overrides(self : SpannedConfig) -> Unit {
  self.col_spans.clear()
  self.row_spans.clear()
  self.span_sources.clear()
  self.border_horizontal.clear()
  self.border_vertical.clear()
  self.border_intersection.clear()
}

///|
pub fn SpannedConfig::clear_unused_span_source(
  self : SpannedConfig,
  anchor_row : Int,
  anchor_col : Int,
) -> Unit {
  if self.col_span_at(anchor_row, anchor_col) <= 1 &&
    self.row_span_at(anchor_row, anchor_col) <= 1 {
    self.clear_span_source(anchor_row, anchor_col)
  }
}

///|
pub fn SpannedConfig::span_source_at(
  self : SpannedConfig,
  anchor_row : Int,
  anchor_col : Int,
) -> (Int, Int) {
  let mut index = self.span_sources.length() - 1
  while index >= 0 {
    let item = self.span_sources[index]
    if item.0 == anchor_row && item.1 == anchor_col {
      return (item.2, item.3)
    }
    index = index - 1
  }
  (anchor_row, anchor_col)
}

///|
pub fn SpannedConfig::span_anchor_for_source(
  self : SpannedConfig,
  source_row : Int,
  source_col : Int,
) -> (Int, Int)? {
  let mut index = self.span_sources.length() - 1
  while index >= 0 {
    let item = self.span_sources[index]
    if item.2 == source_row && item.3 == source_col {
      return Some((item.0, item.1))
    }
    index = index - 1
  }
  None
}

///|
pub fn SpannedConfig::get_col_span(
  self : SpannedConfig,
  row : Int,
  col : Int,
) -> Int? {
  let mut index = self.col_spans.length() - 1
  while index >= 0 {
    let item = self.col_spans[index]
    if item.0 == row && item.1 == col {
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
  col : Int,
) -> Int? {
  let mut index = self.row_spans.length() - 1
  while index >= 0 {
    let item = self.row_spans[index]
    if item.0 == row && item.1 == col {
      return Some(item.2)
    }
    index = index - 1
  }
  None
}

///|
pub fn SpannedConfig::col_span_at(
  self : SpannedConfig,
  row : Int,
  col : Int,
) -> Int {
  match self.get_col_span(row, col) {
    Some(span) => span
    None => 1
  }
}

///|
pub fn SpannedConfig::row_span_at(
  self : SpannedConfig,
  row : Int,
  col : Int,
) -> Int {
  match self.get_row_span(row, col) {
    Some(span) => span
    None => 1
  }
}

///|
pub fn SpannedConfig::has_col_spans(self : SpannedConfig) -> Bool {
  !self.col_spans.is_empty()
}

///|
pub fn SpannedConfig::has_row_spans(self : SpannedConfig) -> Bool {
  !self.row_spans.is_empty()
}

///|
pub fn SpannedConfig::is_cell_covered_by_col_span(
  self : SpannedConfig,
  row : Int,
  col : Int,
) -> Bool {
  for index in 0..<self.col_spans.length() {
    let item = self.col_spans[index]
    if item.0 == row && col > item.1 && col < item.1 + item.2 {
      return true
    }
  }
  false
}

///|
pub fn SpannedConfig::is_cell_covered_by_row_span(
  self : SpannedConfig,
  row : Int,
  col : Int,
) -> Bool {
  for index in 0..<self.row_spans.length() {
    let item = self.row_spans[index]
    let colspan = self.col_span_at(item.0, item.1)
    if row > item.0 &&
      row < item.0 + item.2 &&
      col >= item.1 &&
      col < item.1 + colspan {
      return true
    }
  }
  false
}

///|
pub fn SpannedConfig::is_cell_covered_by_both_spans(
  self : SpannedConfig,
  row : Int,
  col : Int,
) -> Bool {
  // Find anchor cells that have BOTH row and col spans,
  // then check if (row, col) is strictly inside both ranges.
  for i in 0..<self.row_spans.length() {
    let rs = self.row_spans[i]
    let anchor_row = rs.0
    let anchor_col = rs.1
    let row_span = rs.2
    if row > anchor_row && row < anchor_row + row_span {
      // This anchor's row span covers our row. Check if it also has a col span.
      for j in 0..<self.col_spans.length() {
        let cs = self.col_spans[j]
        if cs.0 == anchor_row && cs.1 == anchor_col {
          let col_span = cs.2
          if col > anchor_col && col < anchor_col + col_span {
            return true
          }
        }
      }
    }
  }
  false
}

///|
pub fn SpannedConfig::is_cell_visible(
  self : SpannedConfig,
  row : Int,
  col : Int,
) -> Bool {
  for index in 0..<self.col_spans.length() {
    let item = self.col_spans[index]
    let rowspan = self.row_span_at(item.0, item.1)
    if row >= item.0 &&
      row < item.0 + rowspan &&
      col > item.1 &&
      col < item.1 + item.2 {
      return false
    }
  }
  for index in 0..<self.row_spans.length() {
    let item = self.row_spans[index]
    let colspan = self.col_span_at(item.0, item.1)
    if row > item.0 &&
      row < item.0 + item.2 &&
      col >= item.1 &&
      col < item.1 + colspan {
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
fn set_or_overwrite_3(
  arr : Array[(Int, Int, Char)],
  a : Int,
  b : Int,
  ch : Char,
) -> Unit {
  for i in 0..<arr.length() {
    if arr[i].0 == a && arr[i].1 == b {
      arr[i] = (a, b, ch)
      return
    }
  }
  arr.push((a, b, ch))
}

///|
fn lookup_3(arr : Array[(Int, Int, Char)], a : Int, b : Int) -> Char? {
  let mut result : Char? = None
  arr.each(item => if item.0 == a && item.1 == b { result = Some(item.2) })
  result
}

///|
/// Set per-cell border overrides at the grid-position level.
/// Each border component is stored at the actual grid position it affects.
pub fn SpannedConfig::set_cell_border(
  self : SpannedConfig,
  row : Int,
  col : Int,
  border : CellBorder,
) -> Unit {
  match border.top {
    Some(ch) => set_or_overwrite_3(self.border_horizontal, row, col, ch)
    None => ()
  }
  match border.bottom {
    Some(ch) => set_or_overwrite_3(self.border_horizontal, row + 1, col, ch)
    None => ()
  }
  match border.left {
    Some(ch) => set_or_overwrite_3(self.border_vertical, row, col, ch)
    None => ()
  }
  match border.right {
    Some(ch) => set_or_overwrite_3(self.border_vertical, row, col + 1, ch)
    None => ()
  }
  match border.left_top_corner {
    Some(ch) => set_or_overwrite_3(self.border_intersection, row, col, ch)
    None => ()
  }
  match border.right_top_corner {
    Some(ch) => set_or_overwrite_3(self.border_intersection, row, col + 1, ch)
    None => ()
  }
  match border.left_bottom_corner {
    Some(ch) => set_or_overwrite_3(self.border_intersection, row + 1, col, ch)
    None => ()
  }
  match border.right_bottom_corner {
    Some(ch) =>
      set_or_overwrite_3(self.border_intersection, row + 1, col + 1, ch)
    None => ()
  }
}

///|
pub fn SpannedConfig::horizontal_override_at(
  self : SpannedConfig,
  row_boundary : Int,
  col : Int,
) -> Char? {
  lookup_3(self.border_horizontal, row_boundary, col)
}

///|
pub fn SpannedConfig::vertical_override_at(
  self : SpannedConfig,
  row : Int,
  col_boundary : Int,
) -> Char? {
  lookup_3(self.border_vertical, row, col_boundary)
}

///|
pub fn SpannedConfig::intersection_override_at(
  self : SpannedConfig,
  row_boundary : Int,
  col_boundary : Int,
) -> Char? {
  lookup_3(self.border_intersection, row_boundary, col_boundary)
}

///|
pub fn SpannedConfig::has_cell_borders(self : SpannedConfig) -> Bool {
  not(self.border_horizontal.is_empty()) ||
  not(self.border_vertical.is_empty()) ||
  not(self.border_intersection.is_empty())
}

///|
/// Get the effective cell border for a cell at (row, col) given table shape (count_rows, count_cols).
/// Returns a CellBorder with the resolved border characters including overrides.
pub fn SpannedConfig::get_cell_border(
  self : SpannedConfig,
  row : Int,
  col : Int,
  count_rows : Int,
  count_cols : Int,
) -> CellBorder {
  let borders = self.borders()
  // Top border
  let top = if row == 0 {
    match self.horizontal_override_at(0, col) {
      Some(ch) => Some(ch)
      None => borders.top
    }
  } else {
    match self.horizontal_override_at(row, col) {
      Some(ch) => Some(ch)
      None => borders.horizontal
    }
  }
  // Bottom border
  let bottom = if row + 1 == count_rows {
    match self.horizontal_override_at(count_rows, col) {
      Some(ch) => Some(ch)
      None => borders.bottom
    }
  } else {
    match self.horizontal_override_at(row + 1, col) {
      Some(ch) => Some(ch)
      None => borders.horizontal
    }
  }
  // Left border
  let left = if col == 0 {
    match self.vertical_override_at(row, 0) {
      Some(ch) => Some(ch)
      None => borders.left
    }
  } else {
    match self.vertical_override_at(row, col) {
      Some(ch) => Some(ch)
      None => borders.vertical
    }
  }
  // Right border
  let right = if col + 1 == count_cols {
    match self.vertical_override_at(row, count_cols) {
      Some(ch) => Some(ch)
      None => borders.right
    }
  } else {
    match self.vertical_override_at(row, col + 1) {
      Some(ch) => Some(ch)
      None => borders.vertical
    }
  }
  // Corners
  let left_top = match self.intersection_override_at(row, col) {
    Some(ch) => Some(ch)
    None =>
      if row == 0 && col == 0 {
        borders.top_left
      } else if row == 0 {
        borders.top_intersection
      } else if col == 0 {
        borders.left_intersection
      } else {
        borders.intersection
      }
  }
  let right_top = match self.intersection_override_at(row, col + 1) {
    Some(ch) => Some(ch)
    None =>
      if row == 0 && col + 1 == count_cols {
        borders.top_right
      } else if row == 0 {
        borders.top_intersection
      } else if col + 1 == count_cols {
        borders.right_intersection
      } else {
        borders.intersection
      }
  }
  let left_bottom = match self.intersection_override_at(row + 1, col) {
    Some(ch) => Some(ch)
    None =>
      if row + 1 == count_rows && col == 0 {
        borders.bottom_left
      } else if row + 1 == count_rows {
        borders.bottom_intersection
      } else if col == 0 {
        borders.left_intersection
      } else {
        borders.intersection
      }
  }
  let right_bottom = match self.intersection_override_at(row + 1, col + 1) {
    Some(ch) => Some(ch)
    None =>
      if row + 1 == count_rows && col + 1 == count_cols {
        borders.bottom_right
      } else if row + 1 == count_rows {
        borders.bottom_intersection
      } else if col + 1 == count_cols {
        borders.right_intersection
      } else {
        borders.intersection
      }
  }
  {
    top,
    bottom,
    left,
    right,
    left_top_corner: left_top,
    right_top_corner: right_top,
    left_bottom_corner: left_bottom,
    right_bottom_corner: right_bottom,
  }
}

///|
/// Check if a cell has a "left" border (for border correction).
/// Returns false if the cell is covered by a col span or both spans.
pub fn SpannedConfig::has_left_border(
  self : SpannedConfig,
  row : Int,
  col : Int,
  count_rows : Int,
  count_cols : Int,
) -> Bool {
  if self.is_cell_covered_by_both_spans(row, col) ||
    self.is_cell_covered_by_col_span(row, col) {
    return false
  }
  let border = self.get_cell_border(row, col, count_rows, count_cols)
  not(border.left is None) ||
  not(border.left_top_corner is None) ||
  not(border.left_bottom_corner is None)
}

///|
/// Check if a cell has a "top" border (for border correction).
/// Returns false if the cell is covered by a row span or both spans.
pub fn SpannedConfig::has_top_border(
  self : SpannedConfig,
  row : Int,
  col : Int,
  count_rows : Int,
  count_cols : Int,
) -> Bool {
  if self.is_cell_covered_by_both_spans(row, col) ||
    self.is_cell_covered_by_row_span(row, col) {
    return false
  }
  let border = self.get_cell_border(row, col, count_rows, count_cols)
  not(border.top is None) ||
  not(border.left_top_corner is None) ||
  not(border.right_top_corner is None)
}

///|
pub fn SpannedConfig::set_margin(
  self : SpannedConfig,
  top : Int,
  bottom : Int,
  left : Int,
  right : Int,
  fill_top : Char,
  fill_bottom : Char,
  fill_left : Char,
  fill_right : Char,
) -> Unit {
  self.margin_top = top
  self.margin_bottom = bottom
  self.margin_left = left
  self.margin_right = right
  self.margin_fill_top = fill_top
  self.margin_fill_bottom = fill_bottom
  self.margin_fill_left = fill_left
  self.margin_fill_right = fill_right
}

///|
pub fn SpannedConfig::set_margin_offset(
  self : SpannedConfig,
  top : Int,
  bottom : Int,
  left : Int,
  right : Int,
) -> Unit {
  self.margin_offset_top = top
  self.margin_offset_bottom = bottom
  self.margin_offset_left = left
  self.margin_offset_right = right
}

///|
pub fn SpannedConfig::has_margin(self : SpannedConfig) -> Bool {
  self.margin_top > 0 ||
  self.margin_bottom > 0 ||
  self.margin_left > 0 ||
  self.margin_right > 0
}

///|
pub fn SpannedConfig::remap(
  self : SpannedConfig,
  row_map : Array[Int],
  col_map : Array[Int],
) -> Unit {
  let previous_col_spans = self.col_spans.copy()
  let previous_row_spans = self.row_spans.copy()

  let next_align_rules = []
  self.align_rules.each(rule => {
    match rule.0 {
      RowRange(start, end) =>
        mapped_runs(row_map, start, end).each(run => {
          next_align_rules.push((RowRange(run.0, run.1), rule.1))
        })
      ColRange(start, end) =>
        mapped_runs(col_map, start, end).each(run => {
          next_align_rules.push((ColRange(run.0, run.1), rule.1))
        })
      All => next_align_rules.push(rule)
      Cell(r, c) => {
        let row = map_index(row_map, r)
        let col = map_index(col_map, c)
        if row >= 0 && col >= 0 {
          next_align_rules.push((Cell(row, col), rule.1))
        }
      }
    }
  })
  self.align_rules.clear()
  next_align_rules.each(rule => self.align_rules.push(rule))

  let next_valign_rules = []
  self.valign_rules.each(rule => {
    match rule.0 {
      RowRange(start, end) =>
        mapped_runs(row_map, start, end).each(run => {
          next_valign_rules.push((RowRange(run.0, run.1), rule.1))
        })
      ColRange(start, end) =>
        mapped_runs(col_map, start, end).each(run => {
          next_valign_rules.push((ColRange(run.0, run.1), rule.1))
        })
      All => next_valign_rules.push(rule)
      Cell(r, c) => {
        let row = map_index(row_map, r)
        let col = map_index(col_map, c)
        if row >= 0 && col >= 0 {
          next_valign_rules.push((Cell(row, col), rule.1))
        }
      }
    }
  })
  self.valign_rules.clear()
  next_valign_rules.each(rule => self.valign_rules.push(rule))

  let next_padding_rules = []
  self.padding_rules.each(rule => {
    match rule.0 {
      RowRange(start, end) =>
        mapped_runs(row_map, start, end).each(run => {
          next_padding_rules.push(
            (RowRange(run.0, run.1), rule.1, rule.2, rule.3, rule.4),
          )
        })
      ColRange(start, end) =>
        mapped_runs(col_map, start, end).each(run => {
          next_padding_rules.push(
            (ColRange(run.0, run.1), rule.1, rule.2, rule.3, rule.4),
          )
        })
      All => next_padding_rules.push(rule)
      Cell(r, c) => {
        let row = map_index(row_map, r)
        let col = map_index(col_map, c)
        if row >= 0 && col >= 0 {
          next_padding_rules.push(
            (Cell(row, col), rule.1, rule.2, rule.3, rule.4),
          )
        }
      }
    }
  })
  self.padding_rules.clear()
  next_padding_rules.each(rule => self.padding_rules.push(rule))

  let next_width_rules = []
  self.width_rules.each(rule => {
    match rule.0 {
      RowRange(start, end) =>
        mapped_runs(row_map, start, end).each(run => {
          next_width_rules.push((RowRange(run.0, run.1), rule.1))
        })
      ColRange(start, end) =>
        mapped_runs(col_map, start, end).each(run => {
          next_width_rules.push((ColRange(run.0, run.1), rule.1))
        })
      All => next_width_rules.push(rule)
      Cell(r, c) => {
        let row = map_index(row_map, r)
        let col = map_index(col_map, c)
        if row >= 0 && col >= 0 {
          next_width_rules.push((Cell(row, col), rule.1))
        }
      }
    }
  })
  self.width_rules.clear()
  next_width_rules.each(rule => self.width_rules.push(rule))

  let next_height_rules = []
  self.height_rules.each(rule => {
    match rule.0 {
      RowRange(start, end) =>
        mapped_runs(row_map, start, end).each(run => {
          next_height_rules.push((RowRange(run.0, run.1), rule.1))
        })
      ColRange(start, end) =>
        mapped_runs(col_map, start, end).each(run => {
          next_height_rules.push((ColRange(run.0, run.1), rule.1))
        })
      All => next_height_rules.push(rule)
      Cell(r, c) => {
        let row = map_index(row_map, r)
        let col = map_index(col_map, c)
        if row >= 0 && col >= 0 {
          next_height_rules.push((Cell(row, col), rule.1))
        }
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

  let next_col_spans = []
  self.col_spans.each(item => {
    let mapped_row = map_index(row_map, item.0)
    if mapped_row < 0 {
      return
    }
    let cols = mapped_runs(col_map, item.1, item.1 + item.2)
    if cols.is_empty() {
      return
    }
    let run = cols[0]
    let span = run.1 - run.0
    if span > 1 {
      next_col_spans.push((mapped_row, run.0, span))
    }
  })
  self.col_spans.clear()
  next_col_spans.each(item => self.col_spans.push(item))

  let next_row_spans = []
  self.row_spans.each(item => {
    let rows = mapped_runs(row_map, item.0, item.0 + item.2)
    let mapped_col = map_index(col_map, item.1)
    if rows.is_empty() || mapped_col < 0 {
      return
    }
    let run = rows[0]
    let span = run.1 - run.0
    if span > 1 {
      next_row_spans.push((run.0, mapped_col, span))
    }
  })
  self.row_spans.clear()
  next_row_spans.each(item => self.row_spans.push(item))

  let next_span_sources = []
  self.span_sources.each(item => {
    let mut row_span = 1
    previous_row_spans.each(span => {
      if span.0 == item.0 && span.1 == item.1 {
        row_span = span.2
      }
    })
    let mut col_span = 1
    previous_col_spans.each(span => {
      if span.0 == item.0 && span.1 == item.1 {
        col_span = span.2
      }
    })
    let row_runs = mapped_runs(row_map, item.0, item.0 + row_span)
    let col_runs = mapped_runs(col_map, item.1, item.1 + col_span)
    let source_row = map_index(row_map, item.2)
    let source_col = map_index(col_map, item.3)
    if !row_runs.is_empty() &&
      !col_runs.is_empty() &&
      source_row >= 0 &&
      source_col >= 0 {
      let anchor_row = row_runs[0].0
      let anchor_col = col_runs[0].0
      next_span_sources.push((anchor_row, anchor_col, source_row, source_col))
    }
  })
  self.span_sources.clear()
  next_span_sources.each(item => self.span_sources.push(item))
}

///|
/// Shift all spans whose row >= target_row downward by 1.
/// Used when inserting a horizontal panel row.
pub fn SpannedConfig::shift_row_spans_down(
  self : SpannedConfig,
  target_row : Int,
) -> Unit {
  // Collect current spans, then rewrite them shifted
  let col_spans : Array[(Int, Int, Int)] = []
  self.col_spans.each(item => col_spans.push(item))
  let row_spans : Array[(Int, Int, Int)] = []
  self.row_spans.each(item => row_spans.push(item))
  // Process col_spans: shift rows >= target_row
  col_spans.each(item => {
    if item.0 >= target_row {
      self.set_col_span(item.0, item.1, 1) // remove old
      self.set_col_span(item.0 + 1, item.1, item.2) // add shifted
    }
  })
  // Process row_spans: shift rows >= target_row
  row_spans.each(item => {
    if item.0 >= target_row {
      self.set_row_span(item.0, item.1, 1) // remove old
      self.set_row_span(item.0 + 1, item.1, item.2) // add shifted
    }
  })
  // Shift span sources
  let sources : Array[(Int, Int, Int, Int)] = []
  self.span_sources.each(item => sources.push(item))
  self.span_sources.clear()
  sources.each(item => {
    let anchor_row = if item.0 >= target_row { item.0 + 1 } else { item.0 }
    let source_row = if item.2 >= target_row { item.2 + 1 } else { item.2 }
    self.span_sources.push((anchor_row, item.1, source_row, item.3))
  })
  // Shift border overrides
  let h = self.border_horizontal.copy()
  self.border_horizontal.clear()
  h.each(item => {
    let rb = if item.0 >= target_row { item.0 + 1 } else { item.0 }
    self.border_horizontal.push((rb, item.1, item.2))
  })
  let v = self.border_vertical.copy()
  self.border_vertical.clear()
  v.each(item => {
    let r = if item.0 >= target_row { item.0 + 1 } else { item.0 }
    self.border_vertical.push((r, item.1, item.2))
  })
  let ix = self.border_intersection.copy()
  self.border_intersection.clear()
  ix.each(item => {
    let rb = if item.0 >= target_row { item.0 + 1 } else { item.0 }
    self.border_intersection.push((rb, item.1, item.2))
  })
}

///|
/// Shift all spans whose col >= target_col rightward by 1.
/// Used when inserting a vertical panel col.
pub fn SpannedConfig::shift_col_spans_right(
  self : SpannedConfig,
  target_col : Int,
) -> Unit {
  let col_spans : Array[(Int, Int, Int)] = []
  self.col_spans.each(item => col_spans.push(item))
  let row_spans : Array[(Int, Int, Int)] = []
  self.row_spans.each(item => row_spans.push(item))
  // Process col_spans: shift cols >= target_col
  col_spans.each(item => {
    if item.1 >= target_col {
      self.set_col_span(item.0, item.1, 1) // remove old
      self.set_col_span(item.0, item.1 + 1, item.2) // add shifted
    }
  })
  // Process row_spans: shift cols >= target_col
  row_spans.each(item => {
    if item.1 >= target_col {
      self.set_row_span(item.0, item.1, 1) // remove old
      self.set_row_span(item.0, item.1 + 1, item.2) // add shifted
    }
  })
  // Shift span sources
  let sources : Array[(Int, Int, Int, Int)] = []
  self.span_sources.each(item => sources.push(item))
  self.span_sources.clear()
  sources.each(item => {
    let anchor_col = if item.1 >= target_col { item.1 + 1 } else { item.1 }
    let source_col = if item.3 >= target_col { item.3 + 1 } else { item.3 }
    self.span_sources.push((item.0, anchor_col, item.2, source_col))
  })
  // Shift border overrides
  let h = self.border_horizontal.copy()
  self.border_horizontal.clear()
  h.each(item => {
    let c = if item.1 >= target_col { item.1 + 1 } else { item.1 }
    self.border_horizontal.push((item.0, c, item.2))
  })
  let v = self.border_vertical.copy()
  self.border_vertical.clear()
  v.each(item => {
    let cb = if item.1 >= target_col { item.1 + 1 } else { item.1 }
    self.border_vertical.push((item.0, cb, item.2))
  })
  let ix = self.border_intersection.copy()
  self.border_intersection.clear()
  ix.each(item => {
    let cb = if item.1 >= target_col { item.1 + 1 } else { item.1 }
    self.border_intersection.push((item.0, cb, item.2))
  })
}
