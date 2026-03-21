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

  for column = 0; column < count_columns; column = column + 1 {
    let content = if column < values.length() { values[column] } else { "" }
    let (padding_left, padding_right, _, _) = config.padding_at(
      row_index, column,
    )
    let alignment = config.alignment_at(row_index, column)
    out = out +
      render_cell(
        content,
        widths[column],
        padding_left,
        padding_right,
        alignment,
      )
    if column + 1 < count_columns {
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
  width_mode : WidthMode,
  height_mode : HeightMode,
) -> Array[String] {
  let cell_lines = []
  let mut row_height = 0
  let mut row_padding_top = 0
  let mut row_padding_bottom = 0
  for column = 0; column < count_columns; column = column + 1 {
    let content = if column < row.length() { row[column] } else { "" }
    let lines = processed_lines(content, width_mode, height_mode)
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
    let blank_values = []
    for column = 0; column < count_columns; column = column + 1 {
      blank_values.push("")
    }
    lines.push(
      render_row_line(
        borders, widths, blank_values, row_index, count_columns, config,
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
    let blank_values = []
    for column = 0; column < count_columns; column = column + 1 {
      blank_values.push("")
    }
    lines.push(
      render_row_line(
        borders, widths, blank_values, row_index, count_columns, config,
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
  let top = borders.build_line(
    borders.top_left,
    borders.top,
    borders.top_intersection,
    borders.top_right,
    widths,
  )
  if top != "" {
    lines.push(top)
  }

  let rows = self.records.rows()
  let width_mode = self.config.width_mode()
  let height_mode = self.config.height_mode()
  let horizontal_lines = self.config.horizontal_lines()
  for row_index = 0; row_index < rows.length(); row_index = row_index + 1 {
    render_row(
      borders,
      widths,
      rows[row_index],
      row_index,
      self.records.count_columns(),
      self.config,
      width_mode,
      height_mode,
    ).each(line => lines.push(line))
    let show_middle = match horizontal_lines {
      All => row_index + 1 < rows.length()
      HeaderOnly => row_index == 0 && row_index + 1 < rows.length()
      None => false
    }
    if show_middle {
      let middle = borders.build_line(
        borders.left_intersection,
        borders.horizontal,
        borders.intersection,
        borders.right_intersection,
        widths,
      )
      if middle != "" {
        lines.push(middle)
      }
    }
  }

  let bottom = borders.build_line(
    borders.bottom_left,
    borders.bottom,
    borders.bottom_intersection,
    borders.bottom_right,
    widths,
  )
  if bottom != "" {
    lines.push(bottom)
  }

  lines.join("\n")
}
