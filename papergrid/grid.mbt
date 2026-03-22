///|
pub struct IterGrid {
  records : IterRecords
  config : SpannedConfig
  dimension : IterGridDimension
}

///|
pub fn IterGrid::new(
  records : IterRecords,
  config : SpannedConfig,
  dimension : IterGridDimension,
) -> IterGrid {
  { records, config, dimension }
}

///|
fn render_padding(size : Int) -> String {
  let mut out = ""
  for i in 0..<size {
    ignore(i)
    out += " "
  }
  out
}

///|
fn render_cell(
  content : String,
  width : Int,
  padding_left : Int,
  padding_right : Int,
  align : HAlign,
) -> String {
  let available = width - padding_left - padding_right
  let gap = available - string_display_width(content)
  let (left_fill, right_fill) = match align {
    Left => (0, gap)
    Right => (gap, 0)
    Center => (gap / 2, gap - gap / 2)
  }
  render_padding(padding_left) +
  render_padding(left_fill) +
  content +
  render_padding(right_fill) +
  render_padding(padding_right)
}

///|
fn span_width(
  widths : Array[Int],
  borders : Borders,
  start : Int,
  span : Int,
) -> Int {
  let end_ = if start + span < widths.length() {
    start + span
  } else {
    widths.length()
  }
  let mut total = 0
  for col = start; col < end_; col = col + 1 {
    total = total + widths[col]
  }
  if borders.vertical is Some(_) && end_ - start > 1 {
    total = total + (end_ - start - 1)
  }
  total
}

///|
fn blank_values(count_cols : Int) -> Array[String] {
  let values = []
  for _ in 0..<count_cols {
    values.push("")
  }
  values
}

///|
fn sum_range(values : Array[Int], start : Int, end_ : Int) -> Int {
  let mut total = 0
  for index = start; index < end_; index = index + 1 {
    total = total + values[index]
  }
  total
}

///|
fn boundary_has_line(
  config : SpannedConfig,
  boundary_row : Int,
  count_rows : Int,
) -> Bool {
  if boundary_row <= 0 || boundary_row >= count_rows {
    return false
  }
  let standard = match config.horizontal_lines() {
    All => true
    HeaderOnly => boundary_row == 1
    None => false
  }
  standard || config.custom_horizontal_line(boundary_row) is Some(_)
}

///|
fn count_range_boundaries(
  config : SpannedConfig,
  count_rows : Int,
  start : Int,
  end_ : Int,
) -> Int {
  let mut total = 0
  for boundary_row = start + 1
      boundary_row < end_
      boundary_row = boundary_row + 1 {
    if boundary_has_line(config, boundary_row, count_rows) {
      total += 1
    }
  }
  total
}

///|
fn inc_range(values : Array[Int], size : Int, start : Int, end_ : Int) -> Unit {
  let span = end_ - start
  if span <= 0 || size <= 0 {
    return
  }
  let one = size / span
  let rest = size - span * one
  for index = start; index < end_; index = index + 1 {
    if index == start {
      values[index] = values[index] + one + rest
    } else {
      values[index] = values[index] + one
    }
  }
}

///|
fn row_span_anchor(config : SpannedConfig, row : Int, col : Int) -> (Int, Int)? {
  let mut index = config.row_spans.length() - 1
  while index >= 0 {
    let item = config.row_spans[index]
    let colspan = config.col_span_at(item.0, item.1)
    if row > item.0 &&
      row < item.0 + item.2 &&
      col >= item.1 &&
      col < item.1 + colspan {
      return Some((item.0, item.1))
    }
    index = index - 1
  }
  None
}

///|
fn row_span_crosses_boundary(
  config : SpannedConfig,
  boundary_row : Int,
  col : Int,
) -> Bool {
  for index in 0..<config.row_spans.length() {
    let item = config.row_spans[index]
    let colspan = config.col_span_at(item.0, item.1)
    if boundary_row > item.0 &&
      boundary_row < item.0 + item.2 &&
      col >= item.1 &&
      col < item.1 + colspan {
      return true
    }
  }
  false
}

///|
fn row_span_boundary_anchor(
  config : SpannedConfig,
  boundary_row : Int,
  col : Int,
) -> (Int, Int)? {
  match row_span_anchor(config, boundary_row, col) {
    Some(anchor) =>
      if boundary_row > anchor.0 &&
        boundary_row < anchor.0 + config.row_span_at(anchor.0, anchor.1) {
        Some(anchor)
      } else {
        None
      }
    None => None
  }
}

///|
fn display_anchor_for(
  config : SpannedConfig,
  row : Int,
  col : Int,
) -> (Int, Int)? {
  match row_span_anchor(config, row, col) {
    Some(anchor) => if anchor.1 == col { Some(anchor) } else { None }
    None =>
      if config.is_cell_visible(row, col) {
        Some((row, col))
      } else {
        None
      }
  }
}

///|
fn span_source_for_anchor(
  config : SpannedConfig,
  anchor_row : Int,
  anchor_col : Int,
) -> (Int, Int) {
  config.span_source_at(anchor_row, anchor_col)
}

///|
fn row_metrics(
  records : IterRecords,
  count_cols : Int,
  config : SpannedConfig,
) -> (Array[Int], Array[Int], Array[Int]) {
  let count_rows = records.count_rows()
  let content_heights = Array::make(count_rows, 0)
  let top_paddings = Array::make(count_rows, 0)
  let bottom_paddings = Array::make(count_rows, 0)
  for row in 0..<count_rows {
    for col in 0..<count_cols {
      if !config.is_cell_visible(row, col) {
        continue
      }
      let source = span_source_for_anchor(config, row, col)
      let lines = processed_lines(
        records.get_cell(source.0, source.1),
        config.width_mode_at(source.0, source.1),
        config.height_mode_at(source.0, source.1),
      )
      let rowspan = config.row_span_at(row, col)
      let (_, _, top, bottom) = config.padding_at(source.0, source.1)
      if rowspan > 1 {
        if top > top_paddings[row] {
          top_paddings[row] = top
        }
        let last_row = if row + rowspan < count_rows {
          row + rowspan - 1
        } else {
          count_rows - 1
        }
        if bottom > bottom_paddings[last_row] {
          bottom_paddings[last_row] = bottom
        }
      } else {
        if lines.length() > content_heights[row] {
          content_heights[row] = lines.length()
        }
        if top > top_paddings[row] {
          top_paddings[row] = top
        }
        if bottom > bottom_paddings[row] {
          bottom_paddings[row] = bottom
        }
      }
    }
  }

  let mut changed = true
  while changed {
    changed = false
    for row in 0..<count_rows {
      for col in 0..<count_cols {
        let rowspan = config.row_span_at(row, col)
        if rowspan <= 1 || !config.is_cell_visible(row, col) {
          continue
        }
        let source = span_source_for_anchor(config, row, col)
        let end_ = if row + rowspan < count_rows {
          row + rowspan
        } else {
          count_rows
        }
        let needed = processed_lines(
          records.get_cell(source.0, source.1),
          config.width_mode_at(source.0, source.1),
          config.height_mode_at(source.0, source.1),
        ).length()
        let current = sum_range(content_heights, row, end_) +
          count_range_boundaries(config, count_rows, row, end_)
        if needed > current {
          inc_range(content_heights, needed - current, row, end_)
          changed = true
        }
      }
    }
  }
  (content_heights, top_paddings, bottom_paddings)
}

///|
fn cell_content_for_row(
  records : IterRecords,
  config : SpannedConfig,
  row_heights : Array[Int],
  row : Int,
  col : Int,
  line_index : Int,
) -> String {
  let anchor = match display_anchor_for(config, row, col) {
    Some(anchor) => anchor
    None => return ""
  }
  let source = span_source_for_anchor(config, anchor.0, anchor.1)
  if anchor.0 == row && config.row_span_at(anchor.0, anchor.1) <= 1 {
    let lines = processed_lines(
      records.get_cell(source.0, source.1),
      config.width_mode_at(source.0, source.1),
      config.height_mode_at(source.0, source.1),
    )
    let missing = row_heights[row] - lines.length()
    let valign = config.valign_at(source.0, source.1)
    let top_fill = match valign {
      Top => 0
      Bottom => missing
      Center => missing / 2
    }
    if line_index < top_fill || line_index >= top_fill + lines.length() {
      return ""
    }
    return lines[line_index - top_fill]
  }

  let rowspan = config.row_span_at(anchor.0, anchor.1)
  let end_ = if anchor.0 + rowspan < row_heights.length() {
    anchor.0 + rowspan
  } else {
    row_heights.length()
  }
  let total_height = sum_range(row_heights, anchor.0, end_) +
    count_range_boundaries(config, row_heights.length(), anchor.0, end_)
  let lines = processed_lines(
    records.get_cell(source.0, source.1),
    config.width_mode_at(source.0, source.1),
    config.height_mode_at(source.0, source.1),
  )
  let missing = total_height - lines.length()
  let valign = config.valign_at(source.0, source.1)
  let top_fill = match valign {
    Top => 0
    Bottom => missing
    Center => missing / 2
  }
  let mut offset = 0
  for index = anchor.0; index < row; index = index + 1 {
    offset = offset + row_heights[index]
    if boundary_has_line(config, index + 1, row_heights.length()) {
      offset += 1
    }
  }
  let absolute = offset + line_index
  if absolute < top_fill || absolute >= top_fill + lines.length() {
    ""
  } else {
    lines[absolute - top_fill]
  }
}

///|
fn cell_content_for_boundary(
  records : IterRecords,
  config : SpannedConfig,
  row_heights : Array[Int],
  boundary_row : Int,
  col : Int,
) -> String {
  let anchor = match row_span_boundary_anchor(config, boundary_row, col) {
    Some(anchor) => anchor
    None => return ""
  }
  let source = span_source_for_anchor(config, anchor.0, anchor.1)
  let rowspan = config.row_span_at(anchor.0, anchor.1)
  let end_ = if anchor.0 + rowspan < row_heights.length() {
    anchor.0 + rowspan
  } else {
    row_heights.length()
  }
  let total_height = sum_range(row_heights, anchor.0, end_) +
    count_range_boundaries(config, row_heights.length(), anchor.0, end_)
  let lines = processed_lines(
    records.get_cell(source.0, source.1),
    config.width_mode_at(source.0, source.1),
    config.height_mode_at(source.0, source.1),
  )
  let missing = total_height - lines.length()
  let valign = config.valign_at(source.0, source.1)
  let top_fill = match valign {
    Top => 0
    Bottom => missing
    Center => missing / 2
  }
  let mut absolute = 0
  for row = anchor.0; row < boundary_row; row = row + 1 {
    absolute = absolute + row_heights[row]
    if row + 1 < boundary_row &&
      boundary_has_line(config, row + 1, row_heights.length()) {
      absolute += 1
    }
  }
  if absolute < top_fill || absolute >= top_fill + lines.length() {
    ""
  } else {
    lines[absolute - top_fill]
  }
}

///|
fn render_split_line(
  records : IterRecords,
  borders : Borders,
  widths : Array[Int],
  boundary_row : Int,
  count_cols : Int,
  config : SpannedConfig,
  row_heights : Array[Int],
) -> String {
  let mut has_uncovered = false
  let mut has_content = false
  for col in 0..<count_cols {
    if !row_span_crosses_boundary(config, boundary_row, col) {
      has_uncovered = true
    }
    if !has_content &&
      cell_content_for_boundary(records, config, row_heights, boundary_row, col) !=
      "" {
      has_content = true
    }
  }
  if !has_uncovered && !has_content {
    return ""
  }

  let mut out = match config.intersection_override_at(boundary_row, 0) {
    Some(ch) => ch.to_string()
    None =>
      match first_char([borders.left_intersection, borders.left]) {
        Some(value) => value.to_string()
        None => ""
      }
  }
  let mut col = 0
  while col < count_cols {
    let covered = row_span_crosses_boundary(config, boundary_row, col)
    let fill = match row_span_boundary_anchor(config, boundary_row, col) {
      Some(anchor) =>
        if anchor.1 == col {
          let source = span_source_for_anchor(config, anchor.0, anchor.1)
          let (padding_left, padding_right, _, _) = config.padding_at(
            source.0,
            source.1,
          )
          let align = config.align_at(source.0, source.1)
          let colspan = config.col_span_at(anchor.0, anchor.1)
          col = col + colspan
          render_cell(
            cell_content_for_boundary(
              records,
              config,
              row_heights,
              boundary_row,
              col - colspan,
            ),
            span_width(widths, borders, anchor.1, colspan),
            padding_left,
            padding_right,
            align,
          )
        } else {
          col = col + 1
          continue
        }
      None => {
        col = col + 1
        if covered {
          " ".repeat(widths[col - 1])
        } else {
          match borders.horizontal {
            Some(value) => value.to_string().repeat(widths[col - 1])
            None => " ".repeat(widths[col - 1])
          }
        }
      }
    }
    out = out + fill
    if col < count_cols {
      let current_anchor = row_span_boundary_anchor(
        config,
        boundary_row,
        col - 1,
      )
      let next_anchor = row_span_boundary_anchor(config, boundary_row, col)
      let join = match config.intersection_override_at(boundary_row, col) {
        Some(ch) =>
          if current_anchor == next_anchor && current_anchor is Some(_) {
            ""
          } else {
            ch.to_string()
          }
        None =>
          match current_anchor {
            Some(_) =>
              if current_anchor == next_anchor {
                ""
              } else {
                match
                  first_char([
                    borders.intersection,
                    borders.vertical,
                    borders.horizontal,
                  ]) {
                  Some(value) => value.to_string()
                  None => ""
                }
              }
            None =>
              match
                first_char([
                  borders.intersection,
                  borders.vertical,
                  borders.horizontal,
                ]) {
                Some(value) => value.to_string()
                None => ""
              }
          }
      }
      out = out + join
    }
  }
  out +
  (match config.intersection_override_at(boundary_row, count_cols) {
    Some(ch) => ch.to_string()
    None =>
      match first_char([borders.right_intersection, borders.right]) {
        Some(value) => value.to_string()
        None => ""
      }
  })
}

///|
fn render_row_line(
  borders : Borders,
  widths : Array[Int],
  values : Array[String],
  row_index : Int,
  count_cols : Int,
  config : SpannedConfig,
) -> String {
  let has_overrides = config.has_cell_borders()
  let left_ch = if has_overrides {
    match config.vertical_override_at(row_index, 0) {
      Some(ch) => Some(ch)
      None => borders.left
    }
  } else {
    borders.left
  }
  let mut out = match left_ch {
    Some(value) => value.to_string()
    None => ""
  }

  let mut col = 0
  while col < count_cols {
    let anchor = match display_anchor_for(config, row_index, col) {
      Some(anchor) => anchor
      None => {
        col = col + 1
        continue
      }
    }
    if anchor.1 != col {
      col = col + 1
      continue
    }
    let content = if col < values.length() { values[col] } else { "" }
    let (padding_left, padding_right, _, _) = config.padding_at(
      anchor.0,
      anchor.1,
    )
    let align = config.align_at(anchor.0, anchor.1)
    let colspan = config.col_span_at(anchor.0, anchor.1)
    out = out +
      render_cell(
        content,
        span_width(widths, borders, anchor.1, colspan),
        padding_left,
        padding_right,
        align,
      )
    col = col + colspan
    if col < count_cols {
      let sep_ch = if has_overrides {
        match config.vertical_override_at(row_index, col) {
          Some(ch) => Some(ch)
          None => borders.vertical
        }
      } else {
        borders.vertical
      }
      out = out +
        (match sep_ch {
          Some(value) => value.to_string()
          None => ""
        })
    }
  }

  let right_ch = if has_overrides {
    match config.vertical_override_at(row_index, count_cols) {
      Some(ch) => Some(ch)
      None => borders.right
    }
  } else {
    borders.right
  }
  out +
  (match right_ch {
    Some(value) => value.to_string()
    None => ""
  })
}

///|
fn render_row(
  records : IterRecords,
  borders : Borders,
  widths : Array[Int],
  row_index : Int,
  count_cols : Int,
  config : SpannedConfig,
  row_heights : Array[Int],
  row_top_paddings : Array[Int],
  row_bottom_paddings : Array[Int],
) -> Array[String] {
  let lines = []
  for i in 0..<row_top_paddings[row_index] {
    ignore(i)
    lines.push(
      render_row_line(
        borders,
        widths,
        blank_values(count_cols),
        row_index,
        count_cols,
        config,
      ),
    )
  }
  for line_index = 0
      line_index < row_heights[row_index]
      line_index = line_index + 1 {
    let values = []
    for col in 0..<count_cols {
      values.push(
        cell_content_for_row(
          records, config, row_heights, row_index, col, line_index,
        ),
      )
    }
    lines.push(
      render_row_line(borders, widths, values, row_index, count_cols, config),
    )
  }
  for i in 0..<row_bottom_paddings[row_index] {
    ignore(i)
    lines.push(
      render_row_line(
        borders,
        widths,
        blank_values(count_cols),
        row_index,
        count_cols,
        config,
      ),
    )
  }
  lines
}

///|
/// Build a horizontal line with per-cell border overrides.
/// row_boundary: 0 = above row 0, count_rows = below last row
fn build_line_with_overrides(
  config : SpannedConfig,
  widths : Array[Int],
  default_left : Char?,
  default_fill : Char?,
  default_intersection : Char?,
  default_right : Char?,
  row_boundary : Int,
  count_cols : Int,
) -> String {
  let left = match config.intersection_override_at(row_boundary, 0) {
    Some(ch) => Some(ch)
    None => default_left
  }
  let mut out = match left {
    Some(value) => value.to_string()
    None => ""
  }
  for col in 0..<count_cols {
    let fill = match config.horizontal_override_at(row_boundary, col) {
      Some(ch) => Some(ch)
      None => default_fill
    }
    let w = widths[col]
    out = out +
      (match fill {
        Some(value) => value.to_string().repeat(w)
        None => "".repeat(w)
      })
    if col + 1 < count_cols {
      let ix = match config.intersection_override_at(row_boundary, col + 1) {
        Some(ch) => Some(ch)
        None => default_intersection
      }
      out = out +
        (match ix {
          Some(value) => value.to_string()
          None => ""
        })
    }
  }
  let right = match config.intersection_override_at(row_boundary, count_cols) {
    Some(ch) => Some(ch)
    None => default_right
  }
  out +
  (match right {
    Some(value) => value.to_string()
    None => ""
  })
}

///|
pub fn IterGrid::to_string(self : IterGrid) -> String {
  let widths = self.dimension.widths()
  let borders = self.config.borders()
  if widths.is_empty() {
    return ""
  }

  let lines : Array[String] = []
  let has_overrides = self.config.has_cell_borders()
  let count_cols = self.records.count_cols()
  let top_left = match borders.top {
    Some(_) => first_char([borders.top_left, borders.left])
    None => None
  }
  let top_intersection = match borders.top {
    Some(_) => first_char([borders.top_intersection, borders.top])
    None => None
  }
  let top_right = match borders.top {
    Some(_) => first_char([borders.top_right, borders.right])
    None => None
  }
  let top = if has_overrides {
    build_line_with_overrides(
      self.config,
      widths,
      top_left,
      borders.top,
      top_intersection,
      top_right,
      0,
      count_cols,
    )
  } else {
    borders.build_line(
      top_left,
      borders.top,
      top_intersection,
      top_right,
      widths,
    )
  }
  if top != "" {
    lines.push(top)
  }

  let rows = self.records.rows()
  let (row_heights, row_top_paddings, row_bottom_paddings) = row_metrics(
    self.records,
    count_cols,
    self.config,
  )
  let horizontal_lines = self.config.horizontal_lines()
  for row_index in 0..<rows.length() {
    render_row(
      self.records,
      borders,
      widths,
      row_index,
      count_cols,
      self.config,
      row_heights,
      row_top_paddings,
      row_bottom_paddings,
    ).each(line => lines.push(line))
    let show_middle = match horizontal_lines {
      All => row_index + 1 < rows.length()
      HeaderOnly => row_index == 0 && row_index + 1 < rows.length()
      None => false
    }
    let custom_middle = self.config.custom_horizontal_line(row_index + 1)
    if show_middle || custom_middle is Some(_) {
      let boundary = row_index + 1
      let middle = match custom_middle {
        Some(line) =>
          if self.config.has_row_spans() {
            render_split_line(
              self.records,
              {
                ..borders,
                horizontal: line.main,
                left_intersection: first_char([
                  line.left,
                  borders.left_intersection,
                  borders.left,
                ]),
                intersection: first_char([
                  line.intersection,
                  borders.intersection,
                  borders.vertical,
                  line.main,
                ]),
                right_intersection: first_char([
                  line.right,
                  borders.right_intersection,
                  borders.right,
                ]),
              },
              widths,
              boundary,
              count_cols,
              self.config,
              row_heights,
            )
          } else if has_overrides {
            build_line_with_overrides(
              self.config,
              widths,
              first_char([line.left, borders.left_intersection, borders.left]),
              line.main,
              first_char([
                line.intersection,
                borders.intersection,
                borders.vertical,
                line.main,
              ]),
              first_char([line.right, borders.right_intersection, borders.right]),
              boundary,
              count_cols,
            )
          } else {
            borders.build_line(
              first_char([line.left, borders.left_intersection, borders.left]),
              line.main,
              first_char([
                line.intersection,
                borders.intersection,
                borders.vertical,
                line.main,
              ]),
              first_char([line.right, borders.right_intersection, borders.right]),
              widths,
            )
          }
        None =>
          if self.config.has_row_spans() {
            render_split_line(
              self.records,
              borders,
              widths,
              boundary,
              count_cols,
              self.config,
              row_heights,
            )
          } else if has_overrides {
            build_line_with_overrides(
              self.config,
              widths,
              first_char([borders.left_intersection, borders.left]),
              borders.horizontal,
              first_char([
                borders.intersection,
                borders.vertical,
                borders.horizontal,
              ]),
              first_char([borders.right_intersection, borders.right]),
              boundary,
              count_cols,
            )
          } else {
            borders.build_line(
              first_char([borders.left_intersection, borders.left]),
              borders.horizontal,
              first_char([
                borders.intersection,
                borders.vertical,
                borders.horizontal,
              ]),
              first_char([borders.right_intersection, borders.right]),
              widths,
            )
          }
      }
      if middle != "" {
        lines.push(middle)
      }
    }
  }

  let bottom_left = match borders.bottom {
    Some(_) => first_char([borders.bottom_left, borders.left])
    None => None
  }
  let bottom_intersection = match borders.bottom {
    Some(_) => first_char([borders.bottom_intersection, borders.bottom])
    None => None
  }
  let bottom_right = match borders.bottom {
    Some(_) => first_char([borders.bottom_right, borders.right])
    None => None
  }
  let bottom = if has_overrides {
    build_line_with_overrides(
      self.config,
      widths,
      bottom_left,
      borders.bottom,
      bottom_intersection,
      bottom_right,
      rows.length(),
      count_cols,
    )
  } else {
    borders.build_line(
      bottom_left,
      borders.bottom,
      bottom_intersection,
      bottom_right,
      widths,
    )
  }
  if bottom != "" {
    lines.push(bottom)
  }

  // Apply margin if configured
  if self.config.has_margin() {
    let total_width = if lines.is_empty() { 0 } else { lines[0].length() }
    let full_width = total_width +
      self.config.margin_left +
      self.config.margin_right
    let table_height = lines.length()
    // Add left/right margins to each line
    if self.config.margin_left > 0 || self.config.margin_right > 0 {
      for i in 0..<lines.length() {
        let left = margin_vertical_str(
          self.config.margin_fill_left,
          self.config.margin_left,
          self.config.margin_offset_left,
          i,
          table_height,
        )
        let right = margin_vertical_str(
          self.config.margin_fill_right,
          self.config.margin_right,
          self.config.margin_offset_right,
          i,
          table_height,
        )
        lines[i] = left + lines[i] + right
      }
    }
    // Prepend top margin lines
    if self.config.margin_top > 0 {
      let top_lines = margin_horizontal_lines(
        self.config.margin_fill_top,
        self.config.margin_top,
        self.config.margin_offset_top,
        full_width,
      )
      for i = top_lines.length() - 1; i >= 0; i = i - 1 {
        lines.insert(0, top_lines[i])
      }
    }
    // Append bottom margin lines
    if self.config.margin_bottom > 0 {
      let bottom_lines = margin_horizontal_lines(
        self.config.margin_fill_bottom,
        self.config.margin_bottom,
        self.config.margin_offset_bottom,
        full_width,
      )
      for i in 0..<bottom_lines.length() {
        lines.push(bottom_lines[i])
      }
    }
  }

  lines.join("\n")
}

///|
/// Build a vertical margin string for left/right margins.
/// `offset` uses Start semantics: lines before offset get spaces, lines at/after get fill.
fn margin_vertical_str(
  fill : Char,
  size : Int,
  offset : Int,
  line : Int,
  height : Int,
) -> String {
  if size == 0 {
    return ""
  }
  let offset = if offset > height { height } else { offset }
  if offset >= 0 {
    // Start offset: line < offset → spaces, line >= offset → fill
    if line >= offset {
      fill.to_string().repeat(size)
    } else {
      " ".repeat(size)
    }
  } else {
    // End offset: from end
    let abs_off = -offset
    let abs_off = if abs_off > height { height } else { abs_off }
    let pos = height - abs_off
    if line >= pos {
      " ".repeat(size)
    } else {
      fill.to_string().repeat(size)
    }
  }
}

///|
/// Build horizontal margin lines (top or bottom).
/// `offset` uses Start semantics: cols before offset get spaces, rest get fill.
fn margin_horizontal_lines(
  fill : Char,
  size : Int,
  offset : Int,
  width : Int,
) -> Array[String] {
  if size == 0 {
    return []
  }
  let start_offset = if offset >= 0 {
    if offset > width {
      width
    } else {
      offset
    }
  } else {
    0
  }
  let end_offset = if offset < 0 {
    let abs_off = -offset
    if abs_off > width {
      width
    } else {
      abs_off
    }
  } else {
    0
  }
  let indent_size = width - start_offset - end_offset
  let result = []
  for _ in 0..<size {
    let line = " ".repeat(start_offset) +
      fill.to_string().repeat(indent_size) +
      " ".repeat(end_offset)
    result.push(line)
  }
  result
}
