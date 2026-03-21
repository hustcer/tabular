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
  for i = 0; i < size; i = i + 1 {
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
  alignment : AlignmentHorizontal,
) -> String {
  let available = width - padding_left - padding_right
  let gap = available - content.length()
  let (left_fill, right_fill) = match alignment {
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
  for column = start; column < end_; column = column + 1 {
    total = total + widths[column]
  }
  if borders.vertical is Some(_) && end_ - start > 1 {
    total = total + (end_ - start - 1)
  }
  total
}

///|
fn blank_values(count_columns : Int) -> Array[String] {
  let values = []
  for column = 0; column < count_columns; column = column + 1 {
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
fn row_span_anchor(
  config : SpannedConfig,
  row : Int,
  column : Int,
) -> (Int, Int)? {
  let mut index = config.row_spans.length() - 1
  while index >= 0 {
    let item = config.row_spans[index]
    let colspan = config.column_span_at(item.0, item.1)
    if row > item.0 &&
      row < item.0 + item.2 &&
      column >= item.1 &&
      column < item.1 + colspan {
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
  column : Int,
) -> Bool {
  for index = 0; index < config.row_spans.length(); index = index + 1 {
    let item = config.row_spans[index]
    let colspan = config.column_span_at(item.0, item.1)
    if boundary_row > item.0 &&
      boundary_row < item.0 + item.2 &&
      column >= item.1 &&
      column < item.1 + colspan {
      return true
    }
  }
  false
}

///|
fn row_span_boundary_anchor(
  config : SpannedConfig,
  boundary_row : Int,
  column : Int,
) -> (Int, Int)? {
  match row_span_anchor(config, boundary_row, column) {
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
  column : Int,
) -> (Int, Int)? {
  match row_span_anchor(config, row, column) {
    Some(anchor) => if anchor.1 == column { Some(anchor) } else { None }
    None =>
      if config.is_cell_visible(row, column) {
        Some((row, column))
      } else {
        None
      }
  }
}

///|
fn span_source_for_anchor(
  config : SpannedConfig,
  anchor_row : Int,
  anchor_column : Int,
) -> (Int, Int) {
  config.span_source_at(anchor_row, anchor_column)
}

///|
fn row_metrics(
  records : IterRecords,
  count_columns : Int,
  config : SpannedConfig,
) -> (Array[Int], Array[Int], Array[Int]) {
  let count_rows = records.count_rows()
  let content_heights = Array::make(count_rows, 0)
  let top_paddings = Array::make(count_rows, 0)
  let bottom_paddings = Array::make(count_rows, 0)
  for row = 0; row < count_rows; row = row + 1 {
    for column = 0; column < count_columns; column = column + 1 {
      if !config.is_cell_visible(row, column) {
        continue
      }
      let source = span_source_for_anchor(config, row, column)
      let lines = processed_lines(
        records.get_cell(source.0, source.1),
        config.width_mode_at(source.0, source.1),
        config.height_mode_at(source.0, source.1),
      )
      let rowspan = config.row_span_at(row, column)
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
    for row = 0; row < count_rows; row = row + 1 {
      for column = 0; column < count_columns; column = column + 1 {
        let rowspan = config.row_span_at(row, column)
        if rowspan <= 1 || !config.is_cell_visible(row, column) {
          continue
        }
        let source = span_source_for_anchor(config, row, column)
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
  column : Int,
  line_index : Int,
) -> String {
  let anchor = match display_anchor_for(config, row, column) {
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
    let vertical_alignment = config.vertical_alignment_at(source.0, source.1)
    let top_fill = match vertical_alignment {
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
  let vertical_alignment = config.vertical_alignment_at(source.0, source.1)
  let top_fill = match vertical_alignment {
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
  column : Int,
) -> String {
  let anchor = match row_span_boundary_anchor(config, boundary_row, column) {
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
  let vertical_alignment = config.vertical_alignment_at(source.0, source.1)
  let top_fill = match vertical_alignment {
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
  count_columns : Int,
  config : SpannedConfig,
  row_heights : Array[Int],
) -> String {
  let mut has_uncovered = false
  let mut has_content = false
  for column = 0; column < count_columns; column = column + 1 {
    if !row_span_crosses_boundary(config, boundary_row, column) {
      has_uncovered = true
    }
    if !has_content &&
      cell_content_for_boundary(
        records, config, row_heights, boundary_row, column,
      ) !=
      "" {
      has_content = true
    }
  }
  if !has_uncovered && !has_content {
    return ""
  }

  let mut out = match first_char([borders.left_intersection, borders.left]) {
    Some(value) => value.to_string()
    None => ""
  }
  let mut column = 0
  while column < count_columns {
    let covered = row_span_crosses_boundary(config, boundary_row, column)
    let fill = match row_span_boundary_anchor(config, boundary_row, column) {
      Some(anchor) =>
        if anchor.1 == column {
          let source = span_source_for_anchor(config, anchor.0, anchor.1)
          let (padding_left, padding_right, _, _) = config.padding_at(
            source.0,
            source.1,
          )
          let alignment = config.alignment_at(source.0, source.1)
          let colspan = config.column_span_at(anchor.0, anchor.1)
          column = column + colspan
          render_cell(
            cell_content_for_boundary(
              records,
              config,
              row_heights,
              boundary_row,
              column - colspan,
            ),
            span_width(widths, borders, anchor.1, colspan),
            padding_left,
            padding_right,
            alignment,
          )
        } else {
          column = column + 1
          continue
        }
      None => {
        column = column + 1
        if covered {
          " ".repeat(widths[column - 1])
        } else {
          match borders.horizontal {
            Some(value) => value.to_string().repeat(widths[column - 1])
            None => " ".repeat(widths[column - 1])
          }
        }
      }
    }
    out = out + fill
    if column < count_columns {
      let current_anchor = row_span_boundary_anchor(
        config,
        boundary_row,
        column - 1,
      )
      let next_anchor = row_span_boundary_anchor(config, boundary_row, column)
      let join = match current_anchor {
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
      out = out + join
    }
  }
  out +
  (match first_char([borders.right_intersection, borders.right]) {
    Some(value) => value.to_string()
    None => ""
  })
}

///|
fn render_row_line(
  borders : Borders,
  widths : Array[Int],
  values : Array[String],
  row_index : Int,
  count_columns : Int,
  config : SpannedConfig,
) -> String {
  let mut out = match borders.left {
    Some(value) => value.to_string()
    None => ""
  }

  let mut column = 0
  while column < count_columns {
    let anchor = match display_anchor_for(config, row_index, column) {
      Some(anchor) => anchor
      None => {
        column = column + 1
        continue
      }
    }
    if anchor.1 != column {
      column = column + 1
      continue
    }
    let content = if column < values.length() { values[column] } else { "" }
    let (padding_left, padding_right, _, _) = config.padding_at(
      anchor.0,
      anchor.1,
    )
    let alignment = config.alignment_at(anchor.0, anchor.1)
    let colspan = config.column_span_at(anchor.0, anchor.1)
    out = out +
      render_cell(
        content,
        span_width(widths, borders, anchor.1, colspan),
        padding_left,
        padding_right,
        alignment,
      )
    column = column + colspan
    if column < count_columns {
      out = out +
        (match borders.vertical {
          Some(value) => value.to_string()
          None => ""
        })
    }
  }

  out +
  (match borders.right {
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
  count_columns : Int,
  config : SpannedConfig,
  row_heights : Array[Int],
  row_top_paddings : Array[Int],
  row_bottom_paddings : Array[Int],
) -> Array[String] {
  let lines = []
  for i = 0; i < row_top_paddings[row_index]; i = i + 1 {
    ignore(i)
    lines.push(
      render_row_line(
        borders,
        widths,
        blank_values(count_columns),
        row_index,
        count_columns,
        config,
      ),
    )
  }
  for line_index = 0
      line_index < row_heights[row_index]
      line_index = line_index + 1 {
    let values = []
    for column = 0; column < count_columns; column = column + 1 {
      values.push(
        cell_content_for_row(
          records, config, row_heights, row_index, column, line_index,
        ),
      )
    }
    lines.push(
      render_row_line(borders, widths, values, row_index, count_columns, config),
    )
  }
  for i = 0; i < row_bottom_paddings[row_index]; i = i + 1 {
    ignore(i)
    lines.push(
      render_row_line(
        borders,
        widths,
        blank_values(count_columns),
        row_index,
        count_columns,
        config,
      ),
    )
  }
  lines
}

///|
pub fn IterGrid::to_string(self : IterGrid) -> String {
  let widths = self.dimension.widths()
  let borders = self.config.borders()
  if widths.is_empty() {
    return ""
  }

  let lines : Array[String] = []
  let top_left = match borders.top {
    Some(_) => first_char([borders.top_left, borders.left, borders.top])
    None => None
  }
  let top_intersection = match borders.top {
    Some(_) => first_char([borders.top_intersection, borders.top])
    None => None
  }
  let top_right = match borders.top {
    Some(_) => first_char([borders.top_right, borders.right, borders.top])
    None => None
  }
  let top = borders.build_line(
    top_left,
    borders.top,
    top_intersection,
    top_right,
    widths,
  )
  if top != "" {
    lines.push(top)
  }

  let rows = self.records.rows()
  let (row_heights, row_top_paddings, row_bottom_paddings) = row_metrics(
    self.records,
    self.records.count_columns(),
    self.config,
  )
  let horizontal_lines = self.config.horizontal_lines()
  for row_index = 0; row_index < rows.length(); row_index = row_index + 1 {
    render_row(
      self.records,
      borders,
      widths,
      row_index,
      self.records.count_columns(),
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
              row_index + 1,
              self.records.count_columns(),
              self.config,
              row_heights,
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
              row_index + 1,
              self.records.count_columns(),
              self.config,
              row_heights,
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
    Some(_) => first_char([borders.bottom_left, borders.left, borders.bottom])
    None => None
  }
  let bottom_intersection = match borders.bottom {
    Some(_) => first_char([borders.bottom_intersection, borders.bottom])
    None => None
  }
  let bottom_right = match borders.bottom {
    Some(_) => first_char([borders.bottom_right, borders.right, borders.bottom])
    None => None
  }
  let bottom = borders.build_line(
    bottom_left,
    borders.bottom,
    bottom_intersection,
    bottom_right,
    widths,
  )
  if bottom != "" {
    lines.push(bottom)
  }

  lines.join("\n")
}
