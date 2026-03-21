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
    if !config.is_cell_visible(row_index, column) {
      column = column + 1
      continue
    }
    let content = if column < values.length() { values[column] } else { "" }
    let (padding_left, padding_right, _, _) = config.padding_at(
      row_index, column,
    )
    let alignment = config.alignment_at(row_index, column)
    let colspan = config.column_span_at(row_index, column)
    out = out +
      render_cell(
        content,
        span_width(widths, borders, column, colspan),
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
  borders : Borders,
  widths : Array[Int],
  row : Array[String],
  row_index : Int,
  count_columns : Int,
  config : SpannedConfig,
) -> Array[String] {
  let cell_lines = []
  let mut row_height = 0
  let mut row_padding_top = 0
  let mut row_padding_bottom = 0
  for column = 0; column < count_columns; column = column + 1 {
    if !config.is_cell_visible(row_index, column) {
      cell_lines.push([""])
      continue
    }
    let content = if column < row.length() { row[column] } else { "" }
    let lines = processed_lines(
      content,
      config.width_mode_at(row_index, column),
      config.height_mode_at(row_index, column),
    )
    if lines.length() > row_height {
      row_height = lines.length()
    }
    let (_, _, top, bottom) = config.padding_at(row_index, column)
    if top > row_padding_top {
      row_padding_top = top
    }
    if bottom > row_padding_bottom {
      row_padding_bottom = bottom
    }
    cell_lines.push(lines)
  }

  let aligned_cells = []
  for column = 0; column < count_columns; column = column + 1 {
    let lines_for_cell = cell_lines[column]
    let missing = row_height - lines_for_cell.length()
    let vertical_alignment = config.vertical_alignment_at(row_index, column)
    let top_fill = match vertical_alignment {
      Top => 0
      Bottom => missing
      Center => missing / 2
    }
    let bottom_fill = missing - top_fill
    let aligned = []
    for i = 0; i < top_fill; i = i + 1 {
      ignore(i)
      aligned.push("")
    }
    lines_for_cell.each(line => aligned.push(line))
    for i = 0; i < bottom_fill; i = i + 1 {
      ignore(i)
      aligned.push("")
    }
    aligned_cells.push(aligned)
  }

  let lines = []
  for i = 0; i < row_padding_top; i = i + 1 {
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
  for line_index = 0; line_index < row_height; line_index = line_index + 1 {
    let values = []
    for column = 0; column < count_columns; column = column + 1 {
      let lines_for_cell = aligned_cells[column]
      values.push(
        if line_index < lines_for_cell.length() {
          lines_for_cell[line_index]
        } else {
          ""
        },
      )
    }
    lines.push(
      render_row_line(borders, widths, values, row_index, count_columns, config),
    )
  }
  for i = 0; i < row_padding_bottom; i = i + 1 {
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
  let horizontal_lines = self.config.horizontal_lines()
  for row_index = 0; row_index < rows.length(); row_index = row_index + 1 {
    render_row(
      borders,
      widths,
      rows[row_index],
      row_index,
      self.records.count_columns(),
      self.config,
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
          borders.build_line(
            first_char([
              line.left,
              borders.left_intersection,
              borders.left,
              line.main,
            ]),
            line.main,
            first_char([
              line.intersection,
              borders.intersection,
              borders.vertical,
              line.main,
            ]),
            first_char([
              line.right,
              borders.right_intersection,
              borders.right,
              line.main,
            ]),
            widths,
          )
        None =>
          borders.build_line(
            first_char([
              borders.left_intersection,
              borders.left,
              borders.horizontal,
            ]),
            borders.horizontal,
            first_char([
              borders.intersection,
              borders.vertical,
              borders.horizontal,
            ]),
            first_char([
              borders.right_intersection,
              borders.right,
              borders.horizontal,
            ]),
            widths,
          )
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
