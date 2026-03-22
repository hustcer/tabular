///|
pub struct Style {
  borders : @papergrid.Borders
  horizontal_lines : @papergrid.HorizontalLines
  custom_horizontal_lines : Array[(Int, @papergrid.HorizontalLine)]
}

///|
pub enum Align {
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
pub enum Width {
  Wrap(Int)
  Truncate(Int, String)
}

///|
pub enum Height {
  Increase(Int)
  Limit(Int)
}

///|
pub enum Format {
  Surround(String, String, Bool)
  Value(String, Bool)
  Content((String) -> String, Bool)
  Positioned((String, Int, Int) -> String, Bool)
}

///|
pub struct Rows {
  start : Int
  end_ : Int
  skip_n : Int
  step_n : Int
  exclude_start : Int
  exclude_end : Int
  predicate : ((Entity) -> Bool)?
}

///|
pub struct Cols {
  start : Int
  end_ : Int
  skip_n : Int
  step_n : Int
  exclude_start : Int
  exclude_end : Int
  predicate : ((Entity) -> Bool)?
}

///|
pub struct Cell {
  row : Int
  col : Int
}

///|
pub struct ByColName {
  name : String
}

///|
pub enum Entity {
  Row(Int)
  Col(Int)
}

///|
pub enum Segment {
  All(Int, Int)
  Range(Int, Int, Int, Int, Int, Int)
  RowsOnly(Rows, Int, Int)
  ColsOnly(Cols, Int, Int)
  CellOnly(Cell, Int, Int)
  Cross(Rows, Cols, Int, Int)
  InverseRows(Rows, Int, Int)
  InverseCols(Cols, Int, Int)
  InverseCell(Cell, Int, Int)
  Union2(Segment, Segment, Int, Int)
  Diff2(Segment, Segment, Int, Int)
}

///|
pub enum Setting {
  Align(Align)
  VAlign(VAlign)
  Pad(Padding)
  W(Width)
  H(Height)
  Fmt(Format)
  SpanCol(Int)
  SpanRow(Int)
}

///|
pub struct Padding {
  left : Int
  right : Int
  top : Int
  bottom : Int
}

///|
pub struct HorizontalLine {
  line : @papergrid.HorizontalLine
}

///|
pub enum Span {}

///|
pub enum Panel {}

///|
/// Insert a horizontal panel at the given row index.
/// The panel text spans all cols.
pub fn Panel::horizontal(row : Int, text : String) -> (Int, String, Bool) {
  (row, text, true)
}

///|
/// Insert a header panel at row 0.
pub fn Panel::header(text : String) -> (Int, String, Bool) {
  (0, text, true)
}

///|
/// Insert a footer panel after the last row.
pub fn Panel::footer(text : String) -> (Int, String, Bool) {
  (-1, text, true)
}

///|
/// Insert a vertical panel at the given col index.
/// The panel text spans all rows.
pub fn Panel::vertical(col : Int, text : String) -> (Int, String, Bool) {
  (col, text, false)
}

///|
/// Apply a horizontal or vertical panel to the table.
pub fn Table::panel(self : Table, panel : (Int, String, Bool)) -> Table {
  let (index, text, is_horizontal) = panel
  if is_horizontal {
    self.apply_horizontal_panel(index, text)
  } else {
    self.apply_vertical_panel(index, text)
  }
  self
}

///|
fn Table::apply_horizontal_panel(
  self : Table,
  row : Int,
  text : String,
) -> Unit {
  let count_rows = self.rows.length()
  let count_cols = if count_rows > 0 { self.rows[0].length() } else { 1 }
  // Resolve special row values
  let target_row = if row < 0 { count_rows } else { row }
  // Bounds check
  if target_row > count_rows {
    return
  }
  // Check if any cell at target_row is covered by a row span
  for col = 0; col < count_cols; col = col + 1 {
    if self.config.is_cell_covered_by_row_span(target_row, col) {
      return
    }
  }
  // Insert an empty row at target_row, shifting existing rows down
  let new_row = Array::make(count_cols, "")
  self.rows.insert(target_row, new_row)
  // Shift span metadata
  self.config.shift_row_spans_down(target_row)
  // Set the panel text in the first col
  self.rows[target_row][0] = text
  // Set col span to cover all cols
  if count_cols > 1 {
    self.config.set_col_span(target_row, 0, count_cols)
  }
}

///|
fn Table::apply_vertical_panel(self : Table, col : Int, text : String) -> Unit {
  let count_rows = self.rows.length()
  let count_cols = if count_rows > 0 { self.rows[0].length() } else { 0 }
  // Bounds check
  if col > count_cols {
    return
  }
  // Check if any cell at target_col is covered by a col span
  for row = 0; row <= count_rows; row = row + 1 {
    if row < count_rows && self.config.is_cell_covered_by_col_span(row, col) {
      return
    }
  }
  // Insert an empty col at target_col in each row
  self.rows.each(row => row.insert(col, ""))
  // Shift span metadata
  self.config.shift_col_spans_right(col)
  // Set the panel text in the first row
  if count_rows > 0 {
    self.rows[0][col] = text
  }
  // Set row span to cover all rows
  if count_rows > 1 {
    self.config.set_row_span(0, col, count_rows)
  }
}

///|
/// Split a string by character width, inserting newlines.
fn split_string_by_width(s : String, width : Int) -> String {
  if width <= 0 {
    return ""
  }
  let buf = StringBuilder::new()
  let mut count = 0
  let mut first_chunk = true
  for ch in s {
    if count >= width {
      buf.write_char('\n')
      count = 0
      first_chunk = false
    }
    ignore(first_chunk)
    buf.write_char(ch)
    count = count + 1
  }
  buf.to_string()
}

///|
/// Insert a vertical panel with text split to fit a certain width.
pub fn Panel::vertical_with_width(
  col : Int,
  text : String,
  width : Int,
) -> (Int, String, Bool) {
  let split_text = split_string_by_width(text, width)
  (col, split_text, false)
}

///|
pub enum Merge {
  Horizontal
  Vertical
}

///|
pub fn Merge::horizontal() -> Merge {
  Horizontal
}

///|
pub fn Merge::vertical() -> Merge {
  Vertical
}

///|
/// Apply merge to the table, combining adjacent duplicate cells using spans.
pub fn Table::merge(self : Table, merge : Merge) -> Table {
  let count_rows = self.rows.length()
  if count_rows == 0 {
    return self
  }
  let count_cols = self.rows[0].length()
  if count_cols == 0 {
    return self
  }
  match merge {
    Horizontal =>
      merge_horizontal(self.rows, self.config, count_rows, count_cols)
    Vertical => merge_vertical(self.rows, self.config, count_rows, count_cols)
  }
  self
}

///|
fn merge_horizontal(
  rows : Array[Array[String]],
  config : @papergrid.SpannedConfig,
  count_rows : Int,
  count_cols : Int,
) -> Unit {
  for row = 0; row < count_rows; row = row + 1 {
    let mut repeat_length = 0
    let mut repeat_value = ""
    let mut repeat_is_set = false
    let mut last_is_col_span = false
    for col = count_cols - 1; col >= 0; col = col - 1 {
      if last_is_col_span {
        last_is_col_span = false
        continue
      }
      let is_cell_visible = config.is_cell_visible(row, col)
      let is_col_span_cell = config.get_row_span(row, col) is Some(_)
      if not(repeat_is_set) {
        if not(is_cell_visible) {
          continue
        }
        if is_col_span_cell {
          continue
        }
        repeat_length = 1
        repeat_value = rows[row][col]
        repeat_is_set = true
        continue
      }
      if is_col_span_cell {
        repeat_is_set = false
        last_is_col_span = true
        continue
      }
      if not(is_cell_visible) {
        repeat_is_set = false
        continue
      }
      let text = rows[row][col]
      if text == repeat_value {
        repeat_length = repeat_length + 1
        continue
      }
      if repeat_length > 1 {
        config.set_col_span(row, col + 1, repeat_length)
      }
      repeat_length = 1
      repeat_value = rows[row][col]
    }
    if repeat_length > 1 {
      config.set_col_span(row, 0, repeat_length)
    }
  }
}

///|
fn merge_vertical(
  rows : Array[Array[String]],
  config : @papergrid.SpannedConfig,
  count_rows : Int,
  count_cols : Int,
) -> Unit {
  for col = 0; col < count_cols; col = col + 1 {
    let mut repeat_length = 0
    let mut repeat_value = ""
    let mut repeat_is_set = false
    let mut last_is_row_span = false
    for row = count_rows - 1; row >= 0; row = row - 1 {
      if last_is_row_span {
        last_is_row_span = false
        continue
      }
      let is_cell_visible = config.is_cell_visible(row, col)
      let is_row_span_cell = config.get_col_span(row, col) is Some(_)
      if not(repeat_is_set) {
        if not(is_cell_visible) {
          continue
        }
        if is_row_span_cell {
          continue
        }
        repeat_length = 1
        repeat_value = rows[row][col]
        repeat_is_set = true
        continue
      }
      if is_row_span_cell {
        repeat_is_set = false
        last_is_row_span = true
        continue
      }
      if not(is_cell_visible) {
        repeat_is_set = false
        continue
      }
      let text = rows[row][col]
      if text == repeat_value {
        repeat_length = repeat_length + 1
        continue
      }
      if repeat_length > 1 {
        config.set_row_span(row + 1, col, repeat_length)
      }
      repeat_length = 1
      repeat_value = rows[row][col]
    }
    if repeat_length > 1 {
      config.set_row_span(0, col, repeat_length)
    }
  }
}

///|
/// Correct border junctions at span boundaries so merged cells display proper corners.
pub fn Table::correct_borders(self : Table) -> Table {
  let count_rows = self.rows.length()
  if count_rows == 0 {
    return self
  }
  let count_cols = self.rows[0].length()
  if count_cols == 0 {
    return self
  }
  let cfg = self.config
  let borders = cfg.borders()
  // Phase 1: Fix col span junctions
  for row = 0; row < count_rows; row = row + 1 {
    for col = 0; col < count_cols; col = col + 1 {
      let span = match cfg.get_col_span(row, col) {
        Some(s) => s
        None => continue
      }
      if span <= 1 {
        continue
      }
      for c = col; c < col + span && c < count_cols; c = c + 1 {
        if c == 0 {
          continue
        }
        let is_first = c == col
        let has_up = row > 0 &&
          cfg.has_left_border(row - 1, c, count_rows, count_cols)
        let has_down = row + 1 < count_rows &&
          cfg.has_left_border(row + 1, c, count_rows, count_cols)
        let border = cfg.get_cell_border(row, c, count_rows, count_cols)
        // Fix top-left corner
        let has_top_border = not(border.left_top_corner is None) &&
          not(border.top is None)
        let new_ltc = if has_top_border {
          if has_up && is_first {
            borders.intersection
          } else if has_up {
            borders.bottom_intersection
          } else if is_first {
            borders.top_intersection
          } else {
            border.top
          }
        } else {
          None
        }
        // Fix bottom-left corner
        let has_bottom_border = not(border.left_bottom_corner is None) &&
          not(border.bottom is None)
        let new_lbc = if has_bottom_border {
          if has_down && is_first {
            borders.intersection
          } else if has_down {
            borders.top_intersection
          } else if is_first {
            borders.bottom_intersection
          } else {
            border.bottom
          }
        } else {
          None
        }
        let cb : @papergrid.CellBorder = {
          top: None,
          bottom: None,
          left: None,
          right: None,
          left_top_corner: new_ltc,
          right_top_corner: None,
          left_bottom_corner: new_lbc,
          right_bottom_corner: None,
        }
        cfg.set_cell_border(row, c, cb)
      }
    }
  }
  // Phase 2: Fix row span junctions
  for row = 0; row < count_rows; row = row + 1 {
    for col = 0; col < count_cols; col = col + 1 {
      let span = match cfg.get_row_span(row, col) {
        Some(s) => s
        None => continue
      }
      if span <= 1 {
        continue
      }
      for r = row + 1; r < row + span && r < count_rows; r = r + 1 {
        let border = cfg.get_cell_border(r, col, count_rows, count_cols)
        // Fix left-top corner (left junction)
        let new_ltc = if not(border.left_top_corner is None) {
          let has_left = col > 0 &&
            cfg.has_top_border(r, col - 1, count_rows, count_cols)
          if has_left {
            borders.right_intersection
          } else {
            borders.vertical
          }
        } else {
          None
        }
        // Fix right-top corner (right junction)
        let new_rtc = if not(border.right_top_corner is None) {
          let has_right = col + 1 < count_cols &&
            cfg.has_top_border(r, col + 1, count_rows, count_cols)
          if has_right {
            borders.left_intersection
          } else {
            borders.vertical
          }
        } else {
          None
        }
        let cb : @papergrid.CellBorder = {
          top: None,
          bottom: None,
          left: None,
          right: None,
          left_top_corner: new_ltc,
          right_top_corner: new_rtc,
          left_bottom_corner: None,
          right_bottom_corner: None,
        }
        cfg.set_cell_border(r, col, cb)
      }
    }
  }
  // Phase 3: Fix cells covered by both row and col spans
  for row = 0; row < count_rows; row = row + 1 {
    for col = 0; col < count_cols; col = col + 1 {
      if not(cfg.is_cell_covered_by_both_spans(row, col)) {
        continue
      }
      if row == 0 {
        continue
      }
      let border = cfg.get_cell_border(row, col, count_rows, count_cols)
      let has_right = col + 1 < count_cols &&
        cfg.has_top_border(row, col + 1, count_rows, count_cols)
      let has_up = cfg.has_left_border(row - 1, col, count_rows, count_cols)
      let has_down = row + 1 < count_rows &&
        cfg.has_left_border(row + 1, col, count_rows, count_cols)
      let mut new_rtc : Char? = None
      let mut new_lbc : Char? = None
      if has_up && not(has_right) {
        new_rtc = borders.right_intersection
      }
      if not(has_up) && has_right {
        new_rtc = borders.left_intersection
      }
      if has_down {
        new_lbc = borders.top_intersection
      }
      if not(has_down) && not(has_up) && not(has_right) {
        new_rtc = borders.vertical
        new_lbc = border.bottom
      }
      let cb : @papergrid.CellBorder = {
        top: None,
        bottom: None,
        left: None,
        right: None,
        left_top_corner: None,
        right_top_corner: new_rtc,
        left_bottom_corner: new_lbc,
        right_bottom_corner: None,
      }
      cfg.set_cell_border(row, col, cb)
    }
  }
  self
}

///|
pub enum HighlightTarget {
  HCell(Cell)
  HRows(Rows)
  HCols(Cols)
  HSegment(Segment)
}

///|
pub struct Highlight {
  target : HighlightTarget
  border : @papergrid.CellBorder
}

///|
pub fn Highlight::outline_cell(cell : Cell, ch : Char) -> Highlight {
  { target: HCell(cell), border: @papergrid.CellBorder::filled(ch) }
}

///|
pub fn Highlight::outline_rows(rows : Rows, ch : Char) -> Highlight {
  { target: HRows(rows), border: @papergrid.CellBorder::filled(ch) }
}

///|
pub fn Highlight::outline_cols(cols : Cols, ch : Char) -> Highlight {
  { target: HCols(cols), border: @papergrid.CellBorder::filled(ch) }
}

///|
pub fn Highlight::outline_segment(segment : Segment, ch : Char) -> Highlight {
  { target: HSegment(segment), border: @papergrid.CellBorder::filled(ch) }
}

///|
pub fn Highlight::new_cell(cell : Cell) -> Highlight {
  { target: HCell(cell), border: @papergrid.CellBorder::empty() }
}

///|
pub fn Highlight::new_rows(rows : Rows) -> Highlight {
  { target: HRows(rows), border: @papergrid.CellBorder::empty() }
}

///|
pub fn Highlight::new_cols(cols : Cols) -> Highlight {
  { target: HCols(cols), border: @papergrid.CellBorder::empty() }
}

///|
pub fn Highlight::new_segment(segment : Segment) -> Highlight {
  { target: HSegment(segment), border: @papergrid.CellBorder::empty() }
}

///|
pub fn Highlight::with_border(
  self : Highlight,
  border : @papergrid.CellBorder,
) -> Highlight {
  { ..self, border, }
}

///|
fn resolve_target_to_cells(
  target : HighlightTarget,
  count_rows : Int,
  count_cols : Int,
) -> Array[(Int, Int)] {
  match target {
    HCell(cell) =>
      if cell.row >= 0 &&
        cell.row < count_rows &&
        cell.col >= 0 &&
        cell.col < count_cols {
        [(cell.row, cell.col)]
      } else {
        []
      }
    HRows(rows) => {
      let row_indexes = resolve_rows(rows, count_rows)
      let cells = []
      row_indexes.each(row => {
        for col = 0; col < count_cols; col = col + 1 {
          cells.push((row, col))
        }
      })
      cells
    }
    HCols(cols) => {
      let col_indexes = resolve_cols(cols, count_cols)
      let cells = []
      for row = 0; row < count_rows; row = row + 1 {
        col_indexes.each(col => cells.push((row, col)))
      }
      cells
    }
    HSegment(segment) => resolve_segment_cells(segment, count_rows, count_cols)
  }
}

///|
fn is_cell_connected(p1 : (Int, Int), p2 : (Int, Int)) -> Bool {
  if p1.0 == p2.0 {
    // same row: check left/right adjacency
    if p1.1 + 1 == p2.1 || p2.1 + 1 == p1.1 {
      return true
    }
  }
  if p1.1 == p2.1 {
    // same col: check up/down adjacency
    if p1.0 + 1 == p2.0 || p2.0 + 1 == p1.0 {
      return true
    }
  }
  false
}

///|
fn split_segments(cells : Array[(Int, Int)]) -> Array[Array[(Int, Int)]] {
  let segments : Array[Array[(Int, Int)]] = []
  cells.each(cell => {
    let mut found_index = -1
    for i = 0; i < segments.length(); i = i + 1 {
      let seg = segments[i]
      for j = 0; j < seg.length(); j = j + 1 {
        if is_cell_connected(cell, seg[j]) {
          found_index = i
          break
        }
      }
      if found_index >= 0 {
        break
      }
    }
    if found_index >= 0 {
      segments[found_index].push(cell)
    } else {
      segments.push([cell])
    }
  })
  // Merge segments that are connected to each other
  let result : Array[Array[(Int, Int)]] = []
  while not(segments.is_empty()) {
    let segment = segments.remove(0)
    let mut i = 0
    while i < segments.length() {
      let mut connected = false
      for j = 0; j < segment.length(); j = j + 1 {
        for k = 0; k < segments[i].length(); k = k + 1 {
          if is_cell_connected(segment[j], segments[i][k]) {
            connected = true
            break
          }
        }
        if connected {
          break
        }
      }
      if connected {
        segments[i].each(c => segment.push(c))
        ignore(segments.remove(i))
      } else {
        i = i + 1
      }
    }
    result.push(segment)
  }
  result
}

///|
fn sector_contains(sector : Array[(Int, Int)], p : (Int, Int)) -> Bool {
  sector.contains(p)
}

///|
fn build_highlight_cell_border(
  sector : Array[(Int, Int)],
  p : (Int, Int),
  border : @papergrid.CellBorder,
) -> @papergrid.CellBorder {
  let has_top = p.0 > 0 && sector_contains(sector, (p.0 - 1, p.1))
  let has_bottom = sector_contains(sector, (p.0 + 1, p.1))
  let has_left = p.1 > 0 && sector_contains(sector, (p.0, p.1 - 1))
  let has_right = sector_contains(sector, (p.0, p.1 + 1))
  let has_lt = p.0 > 0 && p.1 > 0 && sector_contains(sector, (p.0 - 1, p.1 - 1))
  let has_rt = p.0 > 0 && sector_contains(sector, (p.0 - 1, p.1 + 1))
  let has_lb = p.1 > 0 && sector_contains(sector, (p.0 + 1, p.1 - 1))
  let has_rb = sector_contains(sector, (p.0 + 1, p.1 + 1))
  let mut b = @papergrid.CellBorder::empty()
  // Top side
  if not(has_top) {
    b = { ..b, top: border.top }
    if has_right && not(has_rt) {
      b = { ..b, right_top_corner: border.top }
    }
  }
  // Bottom side
  if not(has_bottom) {
    b = { ..b, bottom: border.bottom }
    if has_right && not(has_rb) {
      b = { ..b, right_bottom_corner: border.bottom }
    }
  }
  // Left side
  if not(has_left) {
    b = { ..b, left: border.left }
    if has_bottom && not(has_lb) {
      b = { ..b, left_bottom_corner: border.left }
    }
  }
  // Right side
  if not(has_right) {
    b = { ..b, right: border.right }
    if has_bottom && not(has_rb) {
      b = { ..b, right_bottom_corner: border.right }
    }
  }
  // Corners (only when no neighbor in both directions)
  if not(has_left) && not(has_top) {
    b = { ..b, left_top_corner: border.left_top_corner }
  }
  if not(has_left) && not(has_bottom) {
    b = { ..b, left_bottom_corner: border.left_bottom_corner }
  }
  if not(has_right) && not(has_top) {
    b = { ..b, right_top_corner: border.right_top_corner }
  }
  if not(has_right) && not(has_bottom) {
    b = { ..b, right_bottom_corner: border.right_bottom_corner }
  }
  // Diagonal rules for L-shaped segments
  if not(has_bottom) {
    if not(has_left) && has_lt {
      b = { ..b, left_top_corner: border.right_top_corner }
    }
    if has_left && has_lb {
      b = { ..b, left_bottom_corner: border.left_top_corner }
    }
    if not(has_right) && has_rt {
      b = { ..b, right_top_corner: border.left_top_corner }
    }
    if has_right && has_rb {
      b = { ..b, right_bottom_corner: border.right_top_corner }
    }
  }
  if not(has_top) {
    if not(has_left) && has_lb {
      b = { ..b, left_bottom_corner: border.right_bottom_corner }
    }
    if has_left && has_lt {
      b = { ..b, left_top_corner: border.left_bottom_corner }
    }
    if not(has_right) && has_rb {
      b = { ..b, right_bottom_corner: border.left_bottom_corner }
    }
    if has_right && has_rt {
      b = { ..b, right_top_corner: border.right_bottom_corner }
    }
  }
  b
}

///|
pub fn Table::highlight(self : Table, highlight : Highlight) -> Table {
  let count_rows = self.rows.length()
  if count_rows == 0 {
    return self
  }
  let count_cols = self.rows[0].length()
  if count_cols == 0 {
    return self
  }
  let cells = resolve_target_to_cells(highlight.target, count_rows, count_cols)
  if cells.is_empty() {
    return self
  }
  let segments = split_segments(cells)
  segments.each(segment => {
    segment.each(p => {
      let cell_border = build_highlight_cell_border(
        segment,
        p,
        highlight.border,
      )
      self.config.set_cell_border(p.0, p.1, cell_border)
    })
  })
  self
}

///|
pub struct Shadow {
  size : Int
  offset : Int
  fill : Char
  top : Bool
  bottom : Bool
  left : Bool
  right : Bool
}

///|
/// Create a shadow with default direction (bottom-right) and default fill '▒'.
pub fn Shadow::new(size : Int) -> Shadow {
  {
    size,
    offset: 1,
    fill: '▒',
    top: false,
    bottom: true,
    left: false,
    right: true,
  }
}

///|
pub fn Shadow::set_fill(self : Shadow, c : Char) -> Shadow {
  { ..self, fill: c }
}

///|
pub fn Shadow::set_offset(self : Shadow, offset : Int) -> Shadow {
  { ..self, offset, }
}

///|
pub fn Shadow::set_top(self : Shadow) -> Shadow {
  { ..self, top: true, bottom: false }
}

///|
pub fn Shadow::set_bottom(self : Shadow) -> Shadow {
  { ..self, top: false, bottom: true }
}

///|
pub fn Shadow::set_left(self : Shadow) -> Shadow {
  { ..self, left: true, right: false }
}

///|
pub fn Shadow::set_right(self : Shadow) -> Shadow {
  { ..self, left: false, right: true }
}

///|
pub fn Table::shadow(self : Table, shadow : Shadow) -> Table {
  let fill = shadow.fill
  let top_size = if shadow.top { shadow.size } else { 0 }
  let bottom_size = if shadow.bottom { shadow.size } else { 0 }
  let left_size = if shadow.left { shadow.size } else { 0 }
  let right_size = if shadow.right { shadow.size } else { 0 }
  self.config.set_margin(
    top_size, bottom_size, left_size, right_size, fill, fill, fill, fill,
  )
  // Set offsets: the offset determines where fill starts on perpendicular sides
  let h_offset = shadow.offset
  let v_offset = shadow.offset
  // For right+bottom (default): start offset on both
  // For left: end offset on vertical, start offset on horizontal
  // For top: end offset on horizontal, start offset on vertical
  let top_offset = if shadow.top {
    if shadow.left {
      h_offset
    } else {
      h_offset
    }
  } else {
    0
  }
  let bottom_offset = if shadow.bottom {
    if shadow.left {
      h_offset
    } else {
      h_offset
    }
  } else {
    0
  }
  let left_offset = if shadow.left { v_offset } else { 0 }
  let right_offset = if shadow.right { v_offset } else { 0 }
  self.config.set_margin_offset(
    top_offset, bottom_offset, left_offset, right_offset,
  )
  self
}

///|
pub fn Style::ascii() -> Style {
  {
    borders: @papergrid.Borders::ascii(),
    horizontal_lines: @papergrid.HorizontalLines::all(),
    custom_horizontal_lines: [],
  }
}

///|
pub fn Style::modern() -> Style {
  {
    borders: @papergrid.Borders::modern(),
    horizontal_lines: @papergrid.HorizontalLines::all(),
    custom_horizontal_lines: [],
  }
}

///|
pub fn Style::rounded() -> Style {
  {
    borders: @papergrid.Borders::rounded(),
    horizontal_lines: @papergrid.HorizontalLines::all(),
    custom_horizontal_lines: [],
  }
}

///|
pub fn Style::empty() -> Style {
  {
    borders: @papergrid.Borders::empty(),
    horizontal_lines: @papergrid.HorizontalLines::none(),
    custom_horizontal_lines: [],
  }
}

///|
pub fn Style::blank() -> Style {
  Style::empty()
}

///|
pub fn Style::extended() -> Style {
  {
    borders: @papergrid.Borders::extended(),
    horizontal_lines: @papergrid.HorizontalLines::all(),
    custom_horizontal_lines: [],
  }
}

///|
pub fn Style::dots() -> Style {
  {
    borders: @papergrid.Borders::dots(),
    horizontal_lines: @papergrid.HorizontalLines::all(),
    custom_horizontal_lines: [],
  }
}

///|
pub fn Style::re_structured_text() -> Style {
  {
    borders: @papergrid.Borders::re_structured_text(),
    horizontal_lines: @papergrid.HorizontalLines::none(),
    custom_horizontal_lines: [
      (1, @papergrid.HorizontalLine::new('=').with_intersection(' ')),
    ],
  }
}

///|
pub fn Style::ascii_rounded() -> Style {
  {
    borders: @papergrid.Borders::ascii_rounded(),
    horizontal_lines: @papergrid.HorizontalLines::none(),
    custom_horizontal_lines: [],
  }
}

///|
pub fn Style::markdown() -> Style {
  {
    borders: @papergrid.Borders::markdown(),
    horizontal_lines: @papergrid.HorizontalLines::header_only(),
    custom_horizontal_lines: [],
  }
}

///|
pub fn Style::psql() -> Style {
  {
    borders: @papergrid.Borders::psql(),
    horizontal_lines: @papergrid.HorizontalLines::header_only(),
    custom_horizontal_lines: [],
  }
}

///|
pub fn Style::borders(self : Style) -> @papergrid.Borders {
  self.borders
}

///|
pub fn Style::horizontal_lines(self : Style) -> @papergrid.HorizontalLines {
  self.horizontal_lines
}

///|
pub fn Style::custom_horizontal_lines(
  self : Style,
) -> Array[(Int, @papergrid.HorizontalLine)] {
  self.custom_horizontal_lines
}

///|
pub fn HorizontalLine::new(ch : Char) -> HorizontalLine {
  { line: @papergrid.HorizontalLine::new(ch) }
}

///|
pub fn HorizontalLine::filled(ch : Char) -> HorizontalLine {
  HorizontalLine::new(ch)
}

///|
pub fn HorizontalLine::full(
  main : Char,
  left? : Char = main,
  intersection? : Char = main,
  right? : Char = main,
) -> HorizontalLine {
  { line: @papergrid.HorizontalLine::full(main, left, intersection, right) }
}

///|
pub fn HorizontalLine::left(self : HorizontalLine, ch : Char) -> HorizontalLine {
  { line: self.line.with_left(ch) }
}

///|
pub fn HorizontalLine::intersection(
  self : HorizontalLine,
  ch : Char,
) -> HorizontalLine {
  { line: self.line.with_intersection(ch) }
}

///|
pub fn HorizontalLine::right(
  self : HorizontalLine,
  ch : Char,
) -> HorizontalLine {
  { line: self.line.with_right(ch) }
}

///|
pub fn HorizontalLine::from_style(style : Style) -> HorizontalLine {
  {
    line: @papergrid.HorizontalLine::from_chars(
      style.borders.horizontal,
      style.borders.left_intersection,
      style.borders.intersection,
      style.borders.right_intersection,
    ),
  }
}

///|
pub fn Style::top(self : Style, ch : Char) -> Style {
  { ..self, borders: self.borders.with_top(ch) }
}

///|
pub fn Style::bottom(self : Style, ch : Char) -> Style {
  { ..self, borders: self.borders.with_bottom(ch) }
}

///|
pub fn Style::left(self : Style, ch : Char) -> Style {
  { ..self, borders: self.borders.with_left(ch) }
}

///|
pub fn Style::right(self : Style, ch : Char) -> Style {
  { ..self, borders: self.borders.with_right(ch) }
}

///|
pub fn Style::horizontal(self : Style, ch : Char) -> Style {
  {
    ..self,
    borders: self.borders.with_horizontal(ch),
    horizontal_lines: @papergrid.HorizontalLines::all(),
  }
}

///|
pub fn Style::vertical(self : Style, ch : Char) -> Style {
  { ..self, borders: self.borders.with_vertical(ch) }
}

///|
pub fn Style::corner_top_left(self : Style, ch : Char) -> Style {
  { ..self, borders: self.borders.with_top_left(ch) }
}

///|
pub fn Style::corner_top_right(self : Style, ch : Char) -> Style {
  { ..self, borders: self.borders.with_top_right(ch) }
}

///|
pub fn Style::corner_bottom_left(self : Style, ch : Char) -> Style {
  { ..self, borders: self.borders.with_bottom_left(ch) }
}

///|
pub fn Style::corner_bottom_right(self : Style, ch : Char) -> Style {
  { ..self, borders: self.borders.with_bottom_right(ch) }
}

///|
pub fn Style::intersection_top(self : Style, ch : Char) -> Style {
  { ..self, borders: self.borders.with_top_intersection(ch) }
}

///|
pub fn Style::intersection_bottom(self : Style, ch : Char) -> Style {
  { ..self, borders: self.borders.with_bottom_intersection(ch) }
}

///|
pub fn Style::intersection_left(self : Style, ch : Char) -> Style {
  { ..self, borders: self.borders.with_left_intersection(ch) }
}

///|
pub fn Style::intersection_right(self : Style, ch : Char) -> Style {
  { ..self, borders: self.borders.with_right_intersection(ch) }
}

///|
pub fn Style::intersection(self : Style, ch : Char) -> Style {
  { ..self, borders: self.borders.with_intersection(ch) }
}

///|
pub fn Style::remove_top(self : Style) -> Style {
  { ..self, borders: self.borders.remove_top() }
}

///|
pub fn Style::remove_bottom(self : Style) -> Style {
  { ..self, borders: self.borders.remove_bottom() }
}

///|
pub fn Style::remove_left(self : Style) -> Style {
  { ..self, borders: self.borders.remove_left() }
}

///|
pub fn Style::remove_right(self : Style) -> Style {
  { ..self, borders: self.borders.remove_right() }
}

///|
pub fn Style::remove_horizontal(self : Style) -> Style {
  { ..self, horizontal_lines: @papergrid.HorizontalLines::none() }
}

///|
pub fn Style::remove_horizontals(self : Style) -> Style {
  {
    ..self,
    horizontal_lines: @papergrid.HorizontalLines::none(),
    custom_horizontal_lines: [],
  }
}

///|
pub fn Style::remove_vertical(self : Style) -> Style {
  { ..self, borders: self.borders.remove_vertical() }
}

///|
pub fn Style::horizontals(
  self : Style,
  lines : Array[(Int, HorizontalLine)],
) -> Style {
  { ..self, custom_horizontal_lines: lines.map(line => (line.0, line.1.line)) }
}

///|
pub fn Align::left() -> Align {
  Left
}

///|
pub fn Align::right() -> Align {
  Right
}

///|
pub fn Align::center() -> Align {
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
pub fn Width::wrap(width : Int) -> Width {
  Wrap(width)
}

///|
pub fn Width::truncate(width : Int, suffix? : String = "") -> Width {
  Truncate(width, suffix)
}

///|
pub fn Height::increase(size : Int) -> Height {
  Increase(size)
}

///|
pub fn Height::limit(size : Int) -> Height {
  Limit(size)
}

///|
pub fn Format::surround(prefix : String, suffix : String) -> Format {
  Surround(prefix, suffix, false)
}

///|
pub fn Format::value(text : String) -> Format {
  Value(text, false)
}

///|
pub fn Format::content(transform : (String) -> String) -> Format {
  Content(transform, false)
}

///|
pub fn Format::positioned(transform : (String, Int, Int) -> String) -> Format {
  Positioned(transform, false)
}

///|
pub fn Format::multiline(self : Format) -> Format {
  match self {
    Surround(prefix, suffix, _) => Surround(prefix, suffix, true)
    Value(text, _) => Value(text, true)
    Content(transform, _) => Content(transform, true)
    Positioned(transform, _) => Positioned(transform, true)
  }
}

///|
pub fn Rows::new(start : Int, end_ : Int) -> Rows {
  {
    start,
    end_,
    skip_n: 0,
    step_n: 1,
    exclude_start: 0,
    exclude_end: 0,
    predicate: None,
  }
}

///|
pub fn Rows::first() -> Rows {
  Rows::new(0, 1)
}

///|
pub fn Rows::one(index : Int) -> Rows {
  Rows::new(index, index + 1)
}

///|
pub fn Rows::first_offset(offset : Int) -> Rows {
  Rows::one(offset)
}

///|
pub fn Rows::last() -> Rows {
  Rows::new(-2, 0)
}

///|
pub fn Rows::last_offset(offset : Int) -> Rows {
  Rows::new(-2 - offset, 0)
}

///|
pub fn Rows::all() -> Rows {
  Rows::new(0, -1)
}

///|
pub fn Rows::intersect(self : Rows, cols : Cols) -> Segment {
  Cross(self, cols, 0, 1)
}

///|
pub fn Rows::and_(self : Rows, other : Rows) -> Segment {
  self.as_segment().and_(other.as_segment())
}

///|
pub fn Rows::and_cols(self : Rows, cols : Cols) -> Segment {
  self.as_segment().and_(cols.as_segment())
}

///|
pub fn Rows::and_cell(self : Rows, cell : Cell) -> Segment {
  self.as_segment().and_(cell.as_segment())
}

///|
pub fn Rows::as_segment(self : Rows) -> Segment {
  RowsOnly(self, 0, 1)
}

///|
pub fn Rows::inverse(self : Rows) -> Segment {
  InverseRows(self, 0, 1)
}

///|
pub fn Rows::not(self : Rows, other : Rows) -> Rows {
  {
    start: self.start,
    end_: self.end_,
    skip_n: self.skip_n,
    step_n: self.step_n,
    exclude_start: other.start,
    exclude_end: other.end_,
    predicate: self.predicate,
  }
}

///|
pub fn Rows::not_cols(self : Rows, cols : Cols) -> Segment {
  self.as_segment().not(cols.as_segment())
}

///|
pub fn Rows::not_cell(self : Rows, cell : Cell) -> Segment {
  self.as_segment().not(cell.as_segment())
}

///|
pub fn Rows::skip(self : Rows, count : Int) -> Rows {
  {
    start: self.start,
    end_: self.end_,
    skip_n: count,
    step_n: self.step_n,
    exclude_start: self.exclude_start,
    exclude_end: self.exclude_end,
    predicate: self.predicate,
  }
}

///|
pub fn Rows::step_by(self : Rows, step : Int) -> Rows {
  {
    start: self.start,
    end_: self.end_,
    skip_n: self.skip_n,
    step_n: if step <= 0 {
      1
    } else {
      step
    },
    exclude_start: self.exclude_start,
    exclude_end: self.exclude_end,
    predicate: self.predicate,
  }
}

///|
pub fn Rows::filter(self : Rows, predicate : (Entity) -> Bool) -> Rows {
  {
    start: self.start,
    end_: self.end_,
    skip_n: self.skip_n,
    step_n: self.step_n,
    exclude_start: self.exclude_start,
    exclude_end: self.exclude_end,
    predicate: Some(predicate),
  }
}

///|
pub fn Cols::new(start : Int, end_ : Int) -> Cols {
  {
    start,
    end_,
    skip_n: 0,
    step_n: 1,
    exclude_start: 0,
    exclude_end: 0,
    predicate: None,
  }
}

///|
pub fn Cols::first() -> Cols {
  Cols::new(0, 1)
}

///|
pub fn Cols::one(index : Int) -> Cols {
  Cols::new(index, index + 1)
}

///|
pub fn Cols::first_offset(offset : Int) -> Cols {
  Cols::one(offset)
}

///|
pub fn Cols::last() -> Cols {
  Cols::new(-2, 0)
}

///|
pub fn Cols::last_offset(offset : Int) -> Cols {
  Cols::new(-2 - offset, 0)
}

///|
pub fn Cols::all() -> Cols {
  Cols::new(0, -1)
}

///|
pub fn Cols::intersect(self : Cols, rows : Rows) -> Segment {
  Cross(rows, self, 0, 1)
}

///|
pub fn Cols::and_(self : Cols, other : Cols) -> Segment {
  self.as_segment().and_(other.as_segment())
}

///|
pub fn Cols::and_rows(self : Cols, rows : Rows) -> Segment {
  self.as_segment().and_(rows.as_segment())
}

///|
pub fn Cols::and_cell(self : Cols, cell : Cell) -> Segment {
  self.as_segment().and_(cell.as_segment())
}

///|
pub fn Cols::as_segment(self : Cols) -> Segment {
  ColsOnly(self, 0, 1)
}

///|
pub fn Cols::inverse(self : Cols) -> Segment {
  InverseCols(self, 0, 1)
}

///|
pub fn Cols::not(self : Cols, other : Cols) -> Cols {
  {
    start: self.start,
    end_: self.end_,
    skip_n: self.skip_n,
    step_n: self.step_n,
    exclude_start: other.start,
    exclude_end: other.end_,
    predicate: self.predicate,
  }
}

///|
pub fn Cols::not_rows(self : Cols, rows : Rows) -> Segment {
  self.as_segment().not(rows.as_segment())
}

///|
pub fn Cols::not_cell(self : Cols, cell : Cell) -> Segment {
  self.as_segment().not(cell.as_segment())
}

///|
pub fn Cols::skip(self : Cols, count : Int) -> Cols {
  {
    start: self.start,
    end_: self.end_,
    skip_n: count,
    step_n: self.step_n,
    exclude_start: self.exclude_start,
    exclude_end: self.exclude_end,
    predicate: self.predicate,
  }
}

///|
pub fn Cols::step_by(self : Cols, step : Int) -> Cols {
  {
    start: self.start,
    end_: self.end_,
    skip_n: self.skip_n,
    step_n: if step <= 0 {
      1
    } else {
      step
    },
    exclude_start: self.exclude_start,
    exclude_end: self.exclude_end,
    predicate: self.predicate,
  }
}

///|
pub fn Cols::filter(self : Cols, predicate : (Entity) -> Bool) -> Cols {
  {
    start: self.start,
    end_: self.end_,
    skip_n: self.skip_n,
    step_n: self.step_n,
    exclude_start: self.exclude_start,
    exclude_end: self.exclude_end,
    predicate: Some(predicate),
  }
}

///|
pub fn Segment::all() -> Segment {
  All(0, 1)
}

///|
pub fn Cell::new(row : Int, col : Int) -> Cell {
  { row, col }
}

///|
pub fn ByColName::new(name : String) -> ByColName {
  { name, }
}

///|
pub fn Cell::as_segment(self : Cell) -> Segment {
  CellOnly(self, 0, 1)
}

///|
pub fn Cell::and_(self : Cell, other : Cell) -> Segment {
  self.as_segment().and_(other.as_segment())
}

///|
pub fn Cell::not(self : Cell, other : Cell) -> Segment {
  self.as_segment().not(other.as_segment())
}

///|
pub fn Cell::inverse(self : Cell) -> Segment {
  InverseCell(self, 0, 1)
}

///|
pub fn Segment::new(
  row_start : Int,
  row_end : Int,
  col_start : Int,
  col_end : Int,
) -> Segment {
  Range(row_start, row_end, col_start, col_end, 0, 1)
}

///|
pub fn Segment::and_(self : Segment, other : Segment) -> Segment {
  Union2(self, other, 0, 1)
}

///|
pub fn Segment::and_rows(self : Segment, rows : Rows) -> Segment {
  self.and_(rows.as_segment())
}

///|
pub fn Segment::and_cols(self : Segment, cols : Cols) -> Segment {
  self.and_(cols.as_segment())
}

///|
pub fn Segment::and_cell(self : Segment, cell : Cell) -> Segment {
  self.and_(cell.as_segment())
}

///|
pub fn Segment::not_(self : Segment, other : Segment) -> Segment {
  Diff2(self, other, 0, 1)
}

///|
pub fn Segment::not(self : Segment, other : Segment) -> Segment {
  self.not_(other)
}

///|
pub fn Segment::not_cell(self : Segment, cell : Cell) -> Segment {
  self.not(cell.as_segment())
}

///|
pub fn Segment::skip(self : Segment, count : Int) -> Segment {
  match self {
    All(_, step) => All(count, step)
    Range(row_start, row_end, col_start, col_end, _, step) =>
      Range(row_start, row_end, col_start, col_end, count, step)
    RowsOnly(rows, _, step) => RowsOnly(rows, count, step)
    ColsOnly(cols, _, step) => ColsOnly(cols, count, step)
    CellOnly(cell, _, step) => CellOnly(cell, count, step)
    Cross(rows, cols, _, step) => Cross(rows, cols, count, step)
    InverseRows(rows, _, step) => InverseRows(rows, count, step)
    InverseCols(cols, _, step) => InverseCols(cols, count, step)
    InverseCell(cell, _, step) => InverseCell(cell, count, step)
    Union2(lhs, rhs, _, step) => Union2(lhs, rhs, count, step)
    Diff2(lhs, rhs, _, step) => Diff2(lhs, rhs, count, step)
  }
}

///|
pub fn Segment::step_by(self : Segment, step : Int) -> Segment {
  let next_step = if step <= 0 { 1 } else { step }
  match self {
    All(skip_n, _) => All(skip_n, next_step)
    Range(row_start, row_end, col_start, col_end, skip_n, _) =>
      Range(row_start, row_end, col_start, col_end, skip_n, next_step)
    RowsOnly(rows, skip_n, _) => RowsOnly(rows, skip_n, next_step)
    ColsOnly(cols, skip_n, _) => ColsOnly(cols, skip_n, next_step)
    CellOnly(cell, skip_n, _) => CellOnly(cell, skip_n, next_step)
    Cross(rows, cols, skip_n, _) => Cross(rows, cols, skip_n, next_step)
    InverseRows(rows, skip_n, _) => InverseRows(rows, skip_n, next_step)
    InverseCols(cols, skip_n, _) => InverseCols(cols, skip_n, next_step)
    InverseCell(cell, skip_n, _) => InverseCell(cell, skip_n, next_step)
    Union2(lhs, rhs, skip_n, _) => Union2(lhs, rhs, skip_n, next_step)
    Diff2(lhs, rhs, skip_n, _) => Diff2(lhs, rhs, skip_n, next_step)
  }
}

///|
pub fn Setting::align(align : Align) -> Setting {
  Align(align)
}

///|
pub fn Setting::valign(align : VAlign) -> Setting {
  VAlign(align)
}

///|
pub fn Setting::padding(padding : Padding) -> Setting {
  Pad(padding)
}

///|
pub fn Setting::format(format : Format) -> Setting {
  Fmt(format)
}

///|
pub fn Setting::width(width : Width) -> Setting {
  W(width)
}

///|
pub fn Setting::height(height : Height) -> Setting {
  H(height)
}

///|
pub fn Span::col(size : Int) -> Setting {
  SpanCol(size)
}

///|
pub fn Span::row(size : Int) -> Setting {
  SpanRow(size)
}

///|
pub fn Padding::new(
  left : Int,
  right : Int,
  top : Int,
  bottom : Int,
) -> Padding {
  { left, right, top, bottom }
}

///|
fn convert_align(align : Align) -> @papergrid.HAlign {
  match align {
    Left => @papergrid.HAlign::left()
    Right => @papergrid.HAlign::right()
    Center => @papergrid.HAlign::center()
  }
}

///|
fn convert_valign(align : VAlign) -> @papergrid.VAlign {
  match align {
    Top => @papergrid.VAlign::top()
    Bottom => @papergrid.VAlign::bottom()
    Center => @papergrid.VAlign::center()
  }
}

///|
fn convert_width(width : Width) -> @papergrid.WidthMode {
  match width {
    Wrap(size) => @papergrid.WidthMode::wrap(size)
    Truncate(size, suffix) => @papergrid.WidthMode::truncate(size, suffix)
  }
}

///|
fn convert_height(height : Height) -> @papergrid.HeightMode {
  match height {
    Increase(size) => @papergrid.HeightMode::increase(size)
    Limit(size) => @papergrid.HeightMode::limit(size)
  }
}

///|
fn join_lines(lines : Array[String]) -> String {
  let mut result = ""
  for index = 0; index < lines.length(); index = index + 1 {
    if index > 0 {
      result += "\n"
    }
    result += lines[index]
  }
  result
}

///|
fn format_content_once(
  value : String,
  format : Format,
  row : Int,
  col : Int,
) -> String {
  match format {
    Surround(prefix, suffix, _) => prefix + value + suffix
    Value(text, _) => text
    Content(transform, _) => transform(value)
    Positioned(transform, _) => transform(value, row, col)
  }
}

///|
fn format_content(
  value : String,
  format : Format,
  row : Int,
  col : Int,
) -> String {
  let multiline = match format {
    Surround(_, _, multiline) => multiline
    Value(_, multiline) => multiline
    Content(_, multiline) => multiline
    Positioned(_, multiline) => multiline
  }
  if !multiline {
    return format_content_once(value, format, row, col)
  }

  let lines = @papergrid.split_lines(value)
  let formatted = []
  lines.each(line => formatted.push(format_content_once(line, format, row, col)))
  join_lines(formatted)
}

///|
fn clamp_start(value : Int) -> Int {
  if value < 0 {
    0
  } else {
    value
  }
}

///|
fn clamp_end(value : Int, limit : Int) -> Int {
  if value < 0 || value > limit {
    limit
  } else {
    value
  }
}

///|
fn resolve_indexes(
  start : Int,
  end_ : Int,
  count : Int,
  exclude_start : Int,
  exclude_end : Int,
  skip_n : Int,
  step_n : Int,
) -> Array[Int] {
  let result = []
  if start <= -2 && end_ == 0 {
    let offset = -start - 2
    let index = count - offset - 1
    if index >= 0 && index < count {
      result.push(index)
    }
    return result
  }
  let start_index = clamp_start(start)
  let end_index = clamp_end(end_, count)
  let mut seen = 0
  for index = start_index; index < end_index; index = index + 1 {
    if index >= exclude_start && index < exclude_end {
      continue
    }
    if seen < skip_n {
      seen = seen + 1
      continue
    }
    if step_n <= 1 || (seen - skip_n) % step_n == 0 {
      result.push(index)
    }
    seen = seen + 1
  }
  result
}

///|
fn resolve_rows(rows : Rows, count : Int) -> Array[Int] {
  let indexes = resolve_indexes(
    rows.start,
    rows.end_,
    count,
    rows.exclude_start,
    rows.exclude_end,
    rows.skip_n,
    rows.step_n,
  )
  match rows.predicate {
    Some(predicate) => {
      let filtered = []
      indexes.each(index => if predicate(Row(index)) { filtered.push(index) })
      filtered
    }
    None => indexes
  }
}

///|
fn resolve_cols(cols : Cols, count : Int) -> Array[Int] {
  let indexes = resolve_indexes(
    cols.start,
    cols.end_,
    count,
    cols.exclude_start,
    cols.exclude_end,
    cols.skip_n,
    cols.step_n,
  )
  match cols.predicate {
    Some(predicate) => {
      let filtered = []
      indexes.each(index => if predicate(Col(index)) { filtered.push(index) })
      filtered
    }
    None => indexes
  }
}

///|
fn resolve_cols_by_name(
  rows : Array[Array[String]],
  by_name : ByColName,
) -> Array[Int] {
  if rows.is_empty() {
    return []
  }
  let result = []
  rows[0].eachi((index, value) => {
    if value == by_name.name {
      result.push(index)
    }
  })
  result
}

///|
fn apply_skip_step_to_cells(
  cells : Array[(Int, Int)],
  skip_n : Int,
  step_n : Int,
) -> Array[(Int, Int)] {
  let result = []
  let mut seen = 0
  cells.each(cell => {
    if seen < skip_n {
      seen = seen + 1
    } else {
      if step_n <= 1 || (seen - skip_n) % step_n == 0 {
        result.push(cell)
      }
      seen = seen + 1
    }
  })
  result
}

///|
fn unique_cells(cells : Array[(Int, Int)]) -> Array[(Int, Int)] {
  let result = []
  cells.each(cell => if !result.contains(cell) { result.push(cell) })
  result
}

///|
fn unique_indexes(indexes : Array[Int]) -> Array[Int] {
  let result = []
  indexes.each(index => if !result.contains(index) { result.push(index) })
  result
}

///|
fn sort_indexes_desc(indexes : Array[Int]) -> Array[Int] {
  let result = indexes.copy()
  for i = 0; i < result.length(); i = i + 1 {
    for j = i + 1; j < result.length(); j = j + 1 {
      if result[j] > result[i] {
        let current = result[i]
        result[i] = result[j]
        result[j] = current
      }
    }
  }
  result
}

///|
fn build_identity_map(count : Int) -> Array[Int] {
  let result = Array::make(count, -1)
  for index = 0; index < count; index = index + 1 {
    result[index] = index
  }
  result
}

///|
fn build_extract_map(count : Int, indexes : Array[Int]) -> Array[Int] {
  let result = Array::make(count, -1)
  let mut next = 0
  indexes.each(index => {
    if index >= 0 && index < count && result[index] < 0 {
      result[index] = next
      next = next + 1
    }
  })
  result
}

///|
fn build_remove_map(count : Int, indexes : Array[Int]) -> Array[Int] {
  let removed = unique_indexes(indexes)
  let result = Array::make(count, -1)
  let mut next = 0
  for index = 0; index < count; index = index + 1 {
    if removed.contains(index) {
      continue
    }
    result[index] = next
    next = next + 1
  }
  result
}

///|
fn remove_rows_at(rows : Array[Array[String]], indexes : Array[Int]) -> Unit {
  let unique = unique_indexes(indexes)
  let sorted = sort_indexes_desc(unique)
  sorted.each(index => {
    if index >= 0 && index < rows.length() {
      rows.remove(index) |> ignore
    }
  })
}

///|
fn remove_cols_at(rows : Array[Array[String]], indexes : Array[Int]) -> Unit {
  let unique = unique_indexes(indexes)
  let sorted = sort_indexes_desc(unique)
  rows.each(row => {
    sorted.each(index => {
      if index >= 0 && index < row.length() {
        row.remove(index) |> ignore
      }
    })
  })
}

///|
fn extract_rows_at(
  rows : Array[Array[String]],
  indexes : Array[Int],
) -> Array[Array[String]] {
  let result = []
  indexes.each(index => {
    if index >= 0 && index < rows.length() {
      result.push(rows[index].copy())
    }
  })
  result
}

///|
fn extract_cols_at(
  rows : Array[Array[String]],
  indexes : Array[Int],
) -> Array[Array[String]] {
  let result = []
  rows.each(row => {
    let next = []
    indexes.each(index => {
      if index >= 0 && index < row.length() {
        next.push(row[index])
      }
    })
    result.push(next)
  })
  result
}

///|
fn resolve_segment_cells(
  segment : Segment,
  row_count : Int,
  col_count : Int,
) -> Array[(Int, Int)] {
  let result = []
  let (row_start, row_end, col_start, col_end, skip_n, step_n) = match segment {
    All(skip_n, step_n) => (0, row_count, 0, col_count, skip_n, step_n)
    Range(row_start, row_end, col_start, col_end, skip_n, step_n) =>
      (
        clamp_start(row_start),
        clamp_end(row_end, row_count),
        clamp_start(col_start),
        clamp_end(col_end, col_count),
        skip_n,
        step_n,
      )
    RowsOnly(rows, skip_n, step_n) => {
      let row_indexes = resolve_rows(rows, row_count)
      let cells = []
      row_indexes.each(row => {
        for col = 0; col < col_count; col = col + 1 {
          cells.push((row, col))
        }
      })
      return apply_skip_step_to_cells(cells, skip_n, step_n)
    }
    ColsOnly(cols, skip_n, step_n) => {
      let col_indexes = resolve_cols(cols, col_count)
      let cells = []
      for row = 0; row < row_count; row = row + 1 {
        col_indexes.each(col => cells.push((row, col)))
      }
      return apply_skip_step_to_cells(cells, skip_n, step_n)
    }
    CellOnly(cell, skip_n, step_n) => {
      let cells = if cell.row >= 0 &&
        cell.row < row_count &&
        cell.col >= 0 &&
        cell.col < col_count {
        [(cell.row, cell.col)]
      } else {
        []
      }
      return apply_skip_step_to_cells(cells, skip_n, step_n)
    }
    Cross(rows, cols, skip_n, step_n) => {
      let row_indexes = resolve_rows(rows, row_count)
      let col_indexes = resolve_cols(cols, col_count)
      let cells = []
      row_indexes.each(row => col_indexes.each(col => cells.push((row, col))))
      return apply_skip_step_to_cells(cells, skip_n, step_n)
    }
    InverseRows(rows, skip_n, step_n) => {
      let excluded = resolve_rows(rows, row_count)
      let cells = []
      for row = 0; row < row_count; row = row + 1 {
        if excluded.contains(row) {
          continue
        }
        for col = 0; col < col_count; col = col + 1 {
          cells.push((row, col))
        }
      }
      return apply_skip_step_to_cells(cells, skip_n, step_n)
    }
    InverseCols(cols, skip_n, step_n) => {
      let excluded = resolve_cols(cols, col_count)
      let cells = []
      for row = 0; row < row_count; row = row + 1 {
        for col = 0; col < col_count; col = col + 1 {
          if excluded.contains(col) {
            continue
          }
          cells.push((row, col))
        }
      }
      return apply_skip_step_to_cells(cells, skip_n, step_n)
    }
    InverseCell(cell, skip_n, step_n) => {
      let cells = []
      for row = 0; row < row_count; row = row + 1 {
        for col = 0; col < col_count; col = col + 1 {
          if row == cell.row && col == cell.col {
            continue
          }
          cells.push((row, col))
        }
      }
      return apply_skip_step_to_cells(cells, skip_n, step_n)
    }
    Union2(lhs, rhs, skip_n, step_n) => {
      let lhs_cells = resolve_segment_cells(lhs, row_count, col_count)
      let rhs_cells = resolve_segment_cells(rhs, row_count, col_count)
      return apply_skip_step_to_cells(
        unique_cells(lhs_cells + rhs_cells),
        skip_n,
        step_n,
      )
    }
    Diff2(lhs, rhs, skip_n, step_n) => {
      let lhs_cells = resolve_segment_cells(lhs, row_count, col_count)
      let rhs_cells = resolve_segment_cells(rhs, row_count, col_count)
      let cells = []
      lhs_cells.each(cell => if !rhs_cells.contains(cell) { cells.push(cell) })
      return apply_skip_step_to_cells(unique_cells(cells), skip_n, step_n)
    }
  }
  let mut seen = 0
  for row = row_start; row < row_end; row = row + 1 {
    for col = col_start; col < col_end; col = col + 1 {
      if seen < skip_n {
        seen = seen + 1
        continue
      }
      if step_n <= 1 || (seen - skip_n) % step_n == 0 {
        result.push((row, col))
      }
      seen = seen + 1
    }
  }
  result
}

///|
fn apply_setting_to_row(
  config : @papergrid.SpannedConfig,
  row : Int,
  setting : Setting,
) -> Unit {
  match setting {
    Align(align) =>
      config.set_align_for_rows(row, row + 1, convert_align(align))
    VAlign(align) =>
      config.set_valign_for_rows(row, row + 1, convert_valign(align))
    Pad(padding) =>
      config.set_padding_for_rows(
        row,
        row + 1,
        padding.left,
        padding.right,
        padding.top,
        padding.bottom,
      )
    W(width) =>
      config.set_width_mode_for_rows(row, row + 1, convert_width(width))
    H(height) =>
      config.set_height_mode_for_rows(row, row + 1, convert_height(height))
    Fmt(_) => ()
    SpanCol(_) => ()
    SpanRow(_) => ()
  }
}

///|
fn apply_setting_to_col(
  config : @papergrid.SpannedConfig,
  col : Int,
  setting : Setting,
) -> Unit {
  match setting {
    Align(align) =>
      config.set_align_for_cols(col, col + 1, convert_align(align))
    VAlign(align) =>
      config.set_valign_for_cols(col, col + 1, convert_valign(align))
    Pad(padding) =>
      config.set_padding_for_cols(
        col,
        col + 1,
        padding.left,
        padding.right,
        padding.top,
        padding.bottom,
      )
    W(width) =>
      config.set_width_mode_for_cols(col, col + 1, convert_width(width))
    H(height) =>
      config.set_height_mode_for_cols(col, col + 1, convert_height(height))
    Fmt(_) => ()
    SpanCol(_) => ()
    SpanRow(_) => ()
  }
}

///|
fn apply_setting_to_cell(
  config : @papergrid.SpannedConfig,
  row : Int,
  col : Int,
  setting : Setting,
) -> Unit {
  match setting {
    Align(align) => config.set_align_for_cell(row, col, convert_align(align))
    VAlign(align) => config.set_valign_for_cell(row, col, convert_valign(align))
    Pad(padding) =>
      config.set_padding_for_cell(
        row,
        col,
        padding.left,
        padding.right,
        padding.top,
        padding.bottom,
      )
    W(width) => config.set_width_mode_for_cell(row, col, convert_width(width))
    H(height) =>
      config.set_height_mode_for_cell(row, col, convert_height(height))
    Fmt(_) => ()
    SpanCol(_) => ()
    SpanRow(_) => ()
  }
}

///|
fn span_intersects_col(
  config : @papergrid.SpannedConfig,
  row : Int,
  col : Int,
  span : Int,
) -> Bool {
  let end_ = col + span
  for current = col; current < end_; current = current + 1 {
    if !config.is_cell_visible(row, current) {
      return true
    }
  }
  false
}

///|
fn span_intersects_row(
  config : @papergrid.SpannedConfig,
  row : Int,
  col : Int,
  span : Int,
) -> Bool {
  let end_ = row + span
  for current = row; current < end_; current = current + 1 {
    if !config.is_cell_visible(current, col) {
      return true
    }
  }
  false
}

///|
fn resolved_span_anchor(
  config : @papergrid.SpannedConfig,
  row : Int,
  col : Int,
) -> (Int, Int) {
  match config.span_anchor_for_source(row, col) {
    Some(anchor) => anchor
    None => (row, col)
  }
}

///|
fn apply_col_span(
  rows : Array[Array[String]],
  config : @papergrid.SpannedConfig,
  row : Int,
  col : Int,
  size : Int,
) -> Unit {
  if row < 0 || row >= rows.length() {
    return
  }
  let col_count = @papergrid.IterRecords::new(rows).count_cols()
  if col < 0 || col >= col_count {
    return
  }
  let current_anchor = resolved_span_anchor(config, row, col)
  if (current_anchor.0 == row && current_anchor.1 == col) &&
    !config.is_cell_visible(row, col) {
    return
  }
  if size == 1 {
    config.set_col_span(current_anchor.0, current_anchor.1, 1)
    config.clear_unused_span_source(current_anchor.0, current_anchor.1)
    return
  }
  config.set_col_span(current_anchor.0, current_anchor.1, 1)
  config.clear_unused_span_source(current_anchor.0, current_anchor.1)

  let start = if size > 1 {
    col
  } else if size == 0 {
    0
  } else {
    let normalized = col + size
    if normalized < 0 {
      0
    } else {
      normalized
    }
  }
  let span = if size > 1 {
    if start + size > col_count {
      col_count - start
    } else {
      size
    }
  } else if size == 0 {
    col_count - start
  } else {
    col - start + 1
  }
  if span <= 1 || span_intersects_col(config, row, start, span) {
    return
  }
  config.set_col_span(row, start, span)
  config.set_span_source(row, start, row, col)
}

///|
fn apply_row_span(
  rows : Array[Array[String]],
  config : @papergrid.SpannedConfig,
  row : Int,
  col : Int,
  size : Int,
) -> Unit {
  if rows.is_empty() || row < 0 || row >= rows.length() {
    return
  }
  let col_count = @papergrid.IterRecords::new(rows).count_cols()
  if col < 0 || col >= col_count {
    return
  }
  let current_anchor = resolved_span_anchor(config, row, col)
  if (current_anchor.0 == row && current_anchor.1 == col) &&
    !config.is_cell_visible(row, col) {
    return
  }
  if size == 1 {
    config.set_row_span(current_anchor.0, current_anchor.1, 1)
    config.clear_unused_span_source(current_anchor.0, current_anchor.1)
    return
  }
  config.set_row_span(current_anchor.0, current_anchor.1, 1)
  config.clear_unused_span_source(current_anchor.0, current_anchor.1)

  let start = if size > 1 {
    row
  } else if size == 0 {
    0
  } else {
    let normalized = row + size
    if normalized < 0 {
      0
    } else {
      normalized
    }
  }
  let span = if size > 1 {
    if row + size > rows.length() {
      rows.length() - start
    } else {
      size
    }
  } else if size == 0 {
    rows.length() - start
  } else {
    row - start + 1
  }
  if span <= 1 || span_intersects_row(config, start, col, span) {
    return
  }
  config.set_row_span(start, col, span)
  config.set_span_source(start, col, row, col)
}

///|
fn apply_format_to_cell(
  rows : Array[Array[String]],
  row : Int,
  col : Int,
  format : Format,
) -> Unit {
  if row < 0 || row >= rows.length() {
    return
  }
  let row_values = rows[row]
  if col < 0 || col >= row_values.length() {
    return
  }
  row_values[col] = format_content(row_values[col], format, row, col)
}

///|
fn apply_setting_to_row_values(
  rows : Array[Array[String]],
  row : Int,
  setting : Setting,
) -> Unit {
  match setting {
    Fmt(format) =>
      if row >= 0 && row < rows.length() {
        let row_values = rows[row]
        for col = 0; col < row_values.length(); col = col + 1 {
          apply_format_to_cell(rows, row, col, format)
        }
      }
    W(_) => ()
    H(_) => ()
    _ => ()
  }
}

///|
fn apply_setting_to_col_values(
  rows : Array[Array[String]],
  col : Int,
  setting : Setting,
) -> Unit {
  match setting {
    Fmt(format) =>
      for row = 0; row < rows.length(); row = row + 1 {
        apply_format_to_cell(rows, row, col, format)
      }
    W(_) => ()
    H(_) => ()
    _ => ()
  }
}

///|
fn apply_setting_to_cell_value(
  rows : Array[Array[String]],
  config : @papergrid.SpannedConfig,
  row : Int,
  col : Int,
  setting : Setting,
) -> Unit {
  match setting {
    Fmt(format) => apply_format_to_cell(rows, row, col, format)
    W(_) => ()
    H(_) => ()
    SpanCol(size) => apply_col_span(rows, config, row, col, size)
    SpanRow(size) => apply_row_span(rows, config, row, col, size)
    _ => ()
  }
}

///|
pub struct Builder {
  rows : Array[Array[String]]
  mut empty_cell : String
}

///|
pub fn Builder::default() -> Builder {
  { rows: [], empty_cell: "" }
}

///|
pub fn Builder::from_rows(rows : Array[Array[String]]) -> Builder {
  { rows, empty_cell: "" }
}

///|
pub fn Builder::push_record(self : Builder, row : Array[String]) -> Unit {
  self.rows.push(row)
}

///|
pub fn Builder::extend(self : Builder, row : Array[String]) -> Unit {
  self.push_record(row)
}

///|
pub fn Builder::insert_record(
  self : Builder,
  index : Int,
  row : Array[String],
) -> Unit {
  self.rows.insert(index, row)
}

///|
pub fn Builder::remove_record(self : Builder, index : Int) -> Unit {
  if index < self.rows.length() {
    self.rows.remove(index) |> ignore
  }
}

///|
pub fn Builder::insert_col(
  self : Builder,
  index : Int,
  col : Array[String],
) -> Unit {
  let row_count = if self.rows.length() > col.length() {
    self.rows.length()
  } else {
    col.length()
  }

  while self.rows.length() < row_count {
    self.rows.push([])
  }

  for row_index = 0; row_index < row_count; row_index = row_index + 1 {
    let row = self.rows[row_index]
    while row.length() < index {
      row.push("")
    }
    row.insert(
      index,
      if row_index < col.length() {
        col[row_index]
      } else {
        ""
      },
    )
  }
}

///|
pub fn Builder::push_col(self : Builder, col : Array[String]) -> Unit {
  let mut index = 0
  self.rows.each(row => if row.length() > index { index = row.length() })
  self.insert_col(index, col)
}

///|
pub fn Builder::remove_col(self : Builder, index : Int) -> Unit {
  self.rows.each(row => if index < row.length() { row.remove(index) |> ignore })
}

///|
pub fn Builder::set_empty(self : Builder, value : String) -> Unit {
  self.empty_cell = value
}

///|
pub fn Builder::clear(self : Builder) -> Unit {
  self.rows.clear()
}

///|
pub fn Builder::clean(self : Builder) -> Unit {
  let mut max_cols = 0
  self.rows.each(row => if row.length() > max_cols { max_cols = row.length() })
  if max_cols == 0 {
    return
  }
  // Determine which cols to keep (at least one non-empty cell)
  let keep_col = Array::make(max_cols, false)
  self.rows.each(row => {
    for col = 0; col < max_cols; col = col + 1 {
      if col < row.length() && row[col] != "" {
        keep_col[col] = true
      }
    }
  })
  // Filter cols in-place
  self.rows.each(row => {
    let next = []
    for col = 0; col < max_cols; col = col + 1 {
      if keep_col[col] {
        next.push(if col < row.length() { row[col] } else { "" })
      }
    }
    row.clear()
    next.each(value => row.push(value))
  })
  // Remove empty rows (all cells empty or no cells)
  let kept_rows : Array[Array[String]] = []
  self.rows.each(row => {
    let mut has_content = false
    row.each(cell => if cell != "" { has_content = true })
    if has_content || row.length() == 0 {
      // Keep rows with content; drop all-empty rows
      if has_content {
        kept_rows.push(row)
      }
    }
  })
  self.rows.clear()
  kept_rows.each(row => self.rows.push(row))
}

///|
fn normalize_rows(
  rows : Array[Array[String]],
  empty_cell : String,
) -> Array[Array[String]] {
  let mut max_cols = 0
  rows.each(row => if row.length() > max_cols { max_cols = row.length() })

  rows.map(row => {
    let normalized = []
    for col = 0; col < max_cols; col = col + 1 {
      if col < row.length() {
        normalized.push(row[col])
      } else {
        normalized.push(empty_cell)
      }
    }
    normalized
  })
}

///|
pub fn Builder::build(self : Builder) -> Table {
  Table::from_rows(normalize_rows(self.rows, self.empty_cell))
}

///|
pub fn Builder::count_records(self : Builder) -> Int {
  self.rows.length()
}

///|
pub fn Builder::count_cols(self : Builder) -> Int {
  let mut max = 0
  self.rows.each(row => if row.length() > max { max = row.length() })
  max
}

///|
/// Create an IndexBuilder from this Builder for index/transpose operations.
pub fn Builder::index(self : Builder) -> IndexBuilder {
  {
    rows: self.rows,
    empty_cell: self.empty_cell,
    index_col: None,
    index_name: Some(""),
    show_index: true,
  }
}

///|
pub struct IndexBuilder {
  rows : Array[Array[String]]
  empty_cell : String
  mut index_col : Int?
  mut index_name : String?
  mut show_index : Bool
}

///|
/// Use the specified col as the index col (0-based).
pub fn IndexBuilder::col(self : IndexBuilder, col : Int) -> IndexBuilder {
  self.index_col = Some(col)
  self
}

///|
/// Set the name for the index col. None removes the name row.
pub fn IndexBuilder::name(self : IndexBuilder, name : String?) -> IndexBuilder {
  self.index_name = name
  self
}

///|
/// Hide the index col.
pub fn IndexBuilder::hide(self : IndexBuilder) -> IndexBuilder {
  self.show_index = false
  self
}

///|
/// Transpose the table (swap rows and cols).
pub fn IndexBuilder::transpose(self : IndexBuilder) -> IndexBuilder {
  let norm = normalize_rows(self.rows, self.empty_cell)
  let row_count = norm.length()
  let col_count = if row_count > 0 { norm[0].length() } else { 0 }
  if row_count == 0 || col_count == 0 {
    return self
  }
  // After transpose, first col = original headers (row 0 values),
  // remaining cols = original data rows, new header = row indices
  let result : Array[Array[String]] = []
  // Header row: empty + original row indices
  let header : Array[String] = [""]
  for r = 1; r < row_count; r = r + 1 {
    header.push((r - 1).to_string())
  }
  result.push(header)
  // Each original col becomes a data row
  for c = 0; c < col_count; c = c + 1 {
    let new_row : Array[String] = []
    for r = 0; r < row_count; r = r + 1 {
      new_row.push(norm[r][c])
    }
    result.push(new_row)
  }
  self.rows.clear()
  result.each(row => self.rows.push(row))
  // After transpose, index is already baked in; disable further index processing
  self.show_index = false
  self
}

///|
/// Build the final Table from the IndexBuilder.
pub fn IndexBuilder::build(self : IndexBuilder) -> Table {
  let norm = normalize_rows(self.rows, self.empty_cell)
  let row_count = norm.length()
  let col_count = if row_count > 0 { norm[0].length() } else { 0 }
  if row_count == 0 || col_count == 0 {
    return Table::from_rows(norm)
  }
  match self.index_col {
    None => {
      // Default: add a numeric index col at position 0
      if not(self.show_index) {
        return Table::from_rows(norm)
      }
      let result : Array[Array[String]] = []
      for i = 0; i < row_count; i = i + 1 {
        let row : Array[String] = []
        if i == 0 {
          // Header row: index name or empty
          row.push(self.index_name.unwrap_or(""))
        } else {
          row.push((i - 1).to_string())
        }
        norm[i].each(cell => row.push(cell))
        result.push(row)
      }
      Table::from_rows(result)
    }
    Some(col_idx) => {
      // Use specified col as index, move it to position 0
      if col_idx >= col_count {
        return Table::from_rows(norm)
      }
      let result : Array[Array[String]] = []
      // First row: header with index name
      let header_row : Array[String] = []
      header_row.push("")
      for c = 0; c < col_count; c = c + 1 {
        if c != col_idx {
          header_row.push(if row_count > 0 { norm[0][c] } else { "" })
        }
      }
      result.push(header_row)
      // Index name row (if set)
      match self.index_name {
        Some(name) => {
          let name_row : Array[String] = Array::make(col_count, "")
          name_row[0] = if name == "" { norm[0][col_idx] } else { name }
          result.push(name_row)
        }
        None => ()
      }
      // Data rows: use col value as index
      for r = 1; r < row_count; r = r + 1 {
        let data_row : Array[String] = []
        data_row.push(norm[r][col_idx])
        for c = 0; c < col_count; c = c + 1 {
          if c != col_idx {
            data_row.push(norm[r][c])
          }
        }
        result.push(data_row)
      }
      Table::from_rows(result)
    }
  }
}

///|
pub struct Table {
  mut rows : Array[Array[String]]
  config : @papergrid.SpannedConfig
}

///|
pub fn Table::from_rows(rows : Array[Array[String]]) -> Table {
  { rows, config: @papergrid.SpannedConfig::default() }
}

///|
pub fn Table::apply(self : Table, style : Style) -> Table {
  self.config.set_borders(style.borders())
  self.config.set_horizontal_lines(style.horizontal_lines())
  self.config.set_custom_horizontal_lines(style.custom_horizontal_lines())
  self
}

///|
pub fn Table::set_align(self : Table, align : Align) -> Table {
  self.config.set_align(convert_align(align))
  self
}

///|
pub fn Table::set_valign(self : Table, align : VAlign) -> Table {
  self.config.set_valign(convert_valign(align))
  self
}

///|
pub fn Table::set_padding(self : Table, padding : Padding) -> Table {
  self.config.set_padding(
    padding.left,
    padding.right,
    padding.top,
    padding.bottom,
  )
  self
}

///|
pub fn Table::set_width(self : Table, width : Width) -> Table {
  self.config.set_width_mode(convert_width(width))
  self
}

///|
pub fn Table::set_height(self : Table, height : Height) -> Table {
  self.config.set_height_mode(convert_height(height))
  self
}

///|
pub fn Table::to_string(self : Table) -> String {
  let records = @papergrid.IterRecords::new(self.rows)
  let dims = @papergrid.IterGridDimension::default()
  dims.estimate(records, self.config)
  let grid = @papergrid.IterGrid::new(records, self.config, dims)
  grid.to_string()
}

///|
pub fn Table::modify_rows(
  self : Table,
  rows : Rows,
  setting : Setting,
) -> Table {
  let row_indexes = resolve_rows(rows, self.rows.length())
  if setting is SpanCol(_) || setting is SpanRow(_) {
    let col_count = @papergrid.IterRecords::new(self.rows).count_cols()
    row_indexes.each(row => {
      for col = 0; col < col_count; col = col + 1 {
        apply_setting_to_cell_value(self.rows, self.config, row, col, setting)
      }
    })
  } else {
    row_indexes.each(row => {
      apply_setting_to_row_values(self.rows, row, setting)
      apply_setting_to_row(self.config, row, setting)
    })
  }
  self
}

///|
pub fn Table::modify_cols(
  self : Table,
  cols : Cols,
  setting : Setting,
) -> Table {
  let col_count = @papergrid.IterRecords::new(self.rows).count_cols()
  let col_indexes = resolve_cols(cols, col_count)
  if setting is SpanCol(_) || setting is SpanRow(_) {
    for row = 0; row < self.rows.length(); row = row + 1 {
      col_indexes.each(col => {
        apply_setting_to_cell_value(self.rows, self.config, row, col, setting)
      })
    }
  } else {
    col_indexes.each(col => {
      apply_setting_to_col_values(self.rows, col, setting)
      apply_setting_to_col(self.config, col, setting)
    })
  }
  self
}

///|
pub fn Table::modify_segment(
  self : Table,
  segment : Segment,
  setting : Setting,
) -> Table {
  match segment {
    All(0, 1) =>
      match setting {
        Align(align) => self.config.set_align_for_all(convert_align(align))
        VAlign(align) => self.config.set_valign_for_all(convert_valign(align))
        Pad(padding) =>
          self.config.set_padding_for_all(
            padding.left,
            padding.right,
            padding.top,
            padding.bottom,
          )
        W(width) => self.config.set_width_mode_for_all(convert_width(width))
        H(height) => self.config.set_height_mode_for_all(convert_height(height))
        Fmt(format) =>
          for row = 0; row < self.rows.length(); row = row + 1 {
            let row_values = self.rows[row]
            for col = 0; col < row_values.length(); col = col + 1 {
              apply_format_to_cell(self.rows, row, col, format)
            }
          }
        SpanCol(_) => {
          let col_count = @papergrid.IterRecords::new(self.rows).count_cols()
          for row = 0; row < self.rows.length(); row = row + 1 {
            for col = 0; col < col_count; col = col + 1 {
              apply_setting_to_cell_value(
                self.rows,
                self.config,
                row,
                col,
                setting,
              )
            }
          }
        }
        SpanRow(_) => {
          let col_count = @papergrid.IterRecords::new(self.rows).count_cols()
          for row = 0; row < self.rows.length(); row = row + 1 {
            for col = 0; col < col_count; col = col + 1 {
              apply_setting_to_cell_value(
                self.rows,
                self.config,
                row,
                col,
                setting,
              )
            }
          }
        }
      }
    _ => {
      let col_count = @papergrid.IterRecords::new(self.rows).count_cols()
      resolve_segment_cells(segment, self.rows.length(), col_count).each(cell => {
        apply_setting_to_cell_value(
          self.rows,
          self.config,
          cell.0,
          cell.1,
          setting,
        )
        apply_setting_to_cell(self.config, cell.0, cell.1, setting)
      })
    }
  }
  self
}

///|
pub fn Table::modify_cell(
  self : Table,
  cell : Cell,
  setting : Setting,
) -> Table {
  apply_setting_to_cell_value(
    self.rows,
    self.config,
    cell.row,
    cell.col,
    setting,
  )
  apply_setting_to_cell(self.config, cell.row, cell.col, setting)
  self
}

///|
pub fn Table::modify_by_col_name(
  self : Table,
  by_name : ByColName,
  setting : Setting,
) -> Table {
  resolve_cols_by_name(self.rows, by_name).each(col => {
    self.modify_cols(Cols::one(col), setting) |> ignore
  })
  self
}

///|
pub fn Table::remove_rows(self : Table, rows : Rows) -> Table {
  let indexes = resolve_rows(rows, self.rows.length())
  let row_map = build_remove_map(self.rows.length(), indexes)
  let col_count = @papergrid.IterRecords::new(self.rows).count_cols()
  remove_rows_at(self.rows, indexes)
  self.config.remap(row_map, build_identity_map(col_count))
  self
}

///|
pub fn Table::remove_cols(self : Table, cols : Cols) -> Table {
  let col_count = @papergrid.IterRecords::new(self.rows).count_cols()
  let indexes = resolve_cols(cols, col_count)
  let col_map = build_remove_map(col_count, indexes)
  remove_cols_at(self.rows, indexes)
  self.config.remap(build_identity_map(self.rows.length()), col_map)
  self
}

///|
pub fn Table::remove_by_col_name(self : Table, by_name : ByColName) -> Table {
  let col_count = @papergrid.IterRecords::new(self.rows).count_cols()
  let indexes = resolve_cols_by_name(self.rows, by_name)
  let col_map = build_remove_map(col_count, indexes)
  remove_cols_at(self.rows, indexes)
  self.config.remap(build_identity_map(self.rows.length()), col_map)
  self
}

///|
pub fn Table::extract_rows(self : Table, rows : Rows) -> Table {
  let indexes = resolve_rows(rows, self.rows.length())
  let row_map = build_extract_map(self.rows.length(), indexes)
  let col_count = @papergrid.IterRecords::new(self.rows).count_cols()
  self.rows = extract_rows_at(self.rows, indexes)
  self.config.remap(row_map, build_identity_map(col_count))
  self
}

///|
pub fn Table::extract_cols(self : Table, cols : Cols) -> Table {
  let col_count = @papergrid.IterRecords::new(self.rows).count_cols()
  let indexes = resolve_cols(cols, col_count)
  let col_map = build_extract_map(col_count, indexes)
  self.rows = extract_cols_at(self.rows, indexes)
  self.config.remap(build_identity_map(self.rows.length()), col_map)
  self
}

///|
pub fn Table::extract_segment(self : Table, rows : Rows, cols : Cols) -> Table {
  let row_indexes = resolve_rows(rows, self.rows.length())
  let row_map = build_extract_map(self.rows.length(), row_indexes)
  let extracted_rows = extract_rows_at(self.rows, row_indexes)
  let original_col_count = @papergrid.IterRecords::new(self.rows).count_cols()
  let col_indexes = resolve_cols(cols, original_col_count)
  let col_map = build_extract_map(original_col_count, col_indexes)
  self.rows = extract_cols_at(extracted_rows, col_indexes)
  self.config.remap(row_map, col_map)
  self
}

///|
priv enum SplitDirection {
  SplitCol
  SplitRow
}

///|
priv enum SplitBehavior {
  SplitConcat
  SplitZip
}

///|
priv enum SplitDisplay {
  SplitClean
  SplitRetain
} derive(Eq)

///|
pub struct Split {
  priv direction : SplitDirection
  priv mut behavior : SplitBehavior
  priv mut display : SplitDisplay
  priv index : Int
}

///|
pub fn Split::col(index : Int) -> Split {
  { direction: SplitCol, behavior: SplitZip, display: SplitClean, index }
}

///|
pub fn Split::row(index : Int) -> Split {
  { direction: SplitRow, behavior: SplitZip, display: SplitClean, index }
}

///|
pub fn Split::concat(self : Split) -> Split {
  self.behavior = SplitConcat
  self
}

///|
pub fn Split::zip(self : Split) -> Split {
  self.behavior = SplitZip
  self
}

///|
pub fn Split::clean(self : Split) -> Split {
  self.display = SplitClean
  self
}

///|
pub fn Split::retain(self : Split) -> Split {
  self.display = SplitRetain
  self
}

///|
fn split_ceil_div(x : Int, y : Int) -> Int {
  1 + (x - 1) / y
}

///|
/// Apply a Split setting to reshape the table.
/// This resets config (spans, borders) since Split fundamentally changes the table shape.
pub fn Table::split(self : Table, split : Split) -> Table {
  let section_length = split.index
  let count_rows = self.rows.length()
  let count_cols = if count_rows > 0 { self.rows[0].length() } else { 0 }
  // Early return for empty table or zero index
  if count_cols == 0 || count_rows == 0 || section_length == 0 {
    return self
  }
  let (primary_length, secondary_length) = match split.direction {
    SplitCol => (count_cols, count_rows)
    SplitRow => (count_rows, count_cols)
  }
  let sections_per_direction = split_ceil_div(primary_length, section_length)
  let (outer_start, outer_end, inner_start, inner_end) = match split.behavior {
    SplitConcat => (1, sections_per_direction, 0, secondary_length)
    SplitZip => (0, secondary_length, 1, sections_per_direction)
  }
  let mut filtered_sections = 0
  for outer_index = outer_start
      outer_index < outer_end
      outer_index = outer_index + 1 {
    let from_secondary_index = outer_index * sections_per_direction -
      filtered_sections
    for inner_index = inner_start
        inner_index < inner_end
        inner_index = inner_index + 1 {
      let (section_index, from_sec, to_sec) = match split.behavior {
        SplitConcat => {
          let si = outer_index
          let fs = inner_index
          let ts = inner_index +
            outer_index * secondary_length -
            filtered_sections
          (si, fs, ts)
        }
        SplitZip => {
          let si = inner_index
          let fs = from_secondary_index
          let ts = outer_index * sections_per_direction +
            inner_index -
            filtered_sections
          (si, fs, ts)
        }
      }
      // Insert new row/col
      match (split.direction, split.behavior) {
        (SplitCol, SplitConcat) => split_push_row(self.rows)
        (SplitCol, SplitZip) => split_insert_row(self.rows, to_sec)
        (SplitRow, SplitConcat) => split_push_col(self.rows)
        (SplitRow, SplitZip) => split_insert_col(self.rows, to_sec)
      }
      // Copy cells from overflow position to new position
      let section_is_empty = split_copy_section(
        self.rows,
        section_length,
        section_index,
        primary_length,
        from_sec,
        to_sec,
        split.direction,
      )
      // If section is empty and display is Clean, delete the inserted row/col
      if section_is_empty && split.display == SplitClean {
        match split.direction {
          SplitCol => split_remove_row(self.rows, to_sec)
          SplitRow => split_remove_col(self.rows, to_sec)
        }
        filtered_sections = filtered_sections + 1
      }
    }
  }
  // Cleanup: remove extra cols/rows beyond section_length
  for segment = primary_length - 1
      segment >= section_length
      segment = segment - 1 {
    match split.direction {
      SplitCol => split_remove_col_all(self.rows, segment)
      SplitRow => split_remove_row(self.rows, segment)
    }
  }
  // Clear spans and border overrides since the table shape changed completely
  self.config.clear_spans_and_overrides()
  self
}

///|
fn split_push_row(rows : Array[Array[String]]) -> Unit {
  let col_count = if rows.length() > 0 { rows[0].length() } else { 0 }
  rows.push(Array::make(col_count, ""))
}

///|
fn split_insert_row(rows : Array[Array[String]], index : Int) -> Unit {
  let col_count = if rows.length() > 0 { rows[0].length() } else { 0 }
  rows.insert(index, Array::make(col_count, ""))
}

///|
fn split_push_col(rows : Array[Array[String]]) -> Unit {
  for i = 0; i < rows.length(); i = i + 1 {
    rows[i].push("")
  }
}

///|
fn split_insert_col(rows : Array[Array[String]], col : Int) -> Unit {
  for i = 0; i < rows.length(); i = i + 1 {
    rows[i].insert(col, "")
  }
}

///|
fn split_remove_row(rows : Array[Array[String]], index : Int) -> Unit {
  rows.remove(index) |> ignore
}

///|
fn split_remove_col_all(rows : Array[Array[String]], col : Int) -> Unit {
  for i = 0; i < rows.length(); i = i + 1 {
    if col < rows[i].length() {
      rows[i].remove(col) |> ignore
    }
  }
}

///|
fn split_remove_col(rows : Array[Array[String]], col : Int) -> Unit {
  for i = 0; i < rows.length(); i = i + 1 {
    if col < rows[i].length() {
      rows[i].remove(col) |> ignore
    }
  }
}

///|
fn split_format_position(
  direction : SplitDirection,
  primary_index : Int,
  secondary_index : Int,
) -> (Int, Int) {
  match direction {
    SplitCol => (secondary_index, primary_index)
    SplitRow => (primary_index, secondary_index)
  }
}

///|
fn split_copy_section(
  rows : Array[Array[String]],
  section_length : Int,
  section_index : Int,
  primary_length : Int,
  from_secondary_index : Int,
  to_secondary_index : Int,
  direction : SplitDirection,
) -> Bool {
  let mut section_is_empty = true
  for to_primary_index = 0
      to_primary_index < section_length
      to_primary_index = to_primary_index + 1 {
    let from_primary_index = to_primary_index + section_index * section_length
    if from_primary_index < primary_length {
      let (from_row, from_col) = split_format_position(
        direction, from_primary_index, from_secondary_index,
      )
      if from_row < rows.length() && from_col < rows[from_row].length() {
        if rows[from_row][from_col] != "" {
          section_is_empty = false
        }
        let (to_row, to_col) = split_format_position(
          direction, to_primary_index, to_secondary_index,
        )
        if to_row < rows.length() && to_col < rows[to_row].length() {
          // Swap the cells
          let tmp = rows[from_row][from_col]
          rows[from_row][from_col] = rows[to_row][to_col]
          rows[to_row][to_col] = tmp
        }
      }
    }
  }
  section_is_empty
}
