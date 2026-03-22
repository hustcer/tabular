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
  for row in 0..<count_rows {
    for col in 0..<count_cols {
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
  for row in 0..<count_rows {
    for col in 0..<count_cols {
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
  for row in 0..<count_rows {
    for col in 0..<count_cols {
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
        for col in 0..<count_cols {
          cells.push((row, col))
        }
      })
      cells
    }
    HCols(cols) => {
      let col_indexes = resolve_cols(cols, count_cols)
      let cells = []
      for row in 0..<count_rows {
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
    for i in 0..<segments.length() {
      let seg = segments[i]
      for j in 0..<seg.length() {
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
      for j in 0..<segment.length() {
        for k in 0..<segments[i].length() {
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
  let top_offset = if shadow.top { h_offset } else { 0 }
  let bottom_offset = if shadow.bottom { h_offset } else { 0 }
  let left_offset = if shadow.left { v_offset } else { 0 }
  let right_offset = if shadow.right { v_offset } else { 0 }
  self.config.set_margin_offset(
    top_offset, bottom_offset, left_offset, right_offset,
  )
  self
}
