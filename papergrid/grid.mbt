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
fn render_cell(content : String, width : Int) -> String {
  let padding = width - content.length()
  let mut out = content
  for i = 0; i < padding; i = i + 1 {
    ignore(i)
    out = out + " "
  }
  out
}

///|
fn render_row(
  borders : Borders,
  widths : Array[Int],
  row : Array[String],
  count_columns : Int,
) -> String {
  let mut out = match borders.left {
    Some(value) => value.to_string()
    None => ""
  }

  for column = 0; column < count_columns; column = column + 1 {
    let content = if column < row.length() { row[column] } else { "" }
    out = out + render_cell(content, widths[column])
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
  for row_index = 0; row_index < rows.length(); row_index = row_index + 1 {
    lines.push(
      render_row(borders, widths, rows[row_index], self.records.count_columns()),
    )
    if row_index + 1 < rows.length() {
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
