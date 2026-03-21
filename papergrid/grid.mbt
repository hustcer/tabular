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
  row : Array[String],
  count_columns : Int,
  padding_left : Int,
  padding_right : Int,
  alignment : AlignmentHorizontal,
  blank : Bool,
) -> String {
  let mut out = match borders.left {
    Some(value) => value.to_string()
    None => ""
  }

  for column = 0; column < count_columns; column = column + 1 {
    let content = if blank {
      ""
    } else if column < row.length() {
      row[column]
    } else {
      ""
    }
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
  count_columns : Int,
  padding_left : Int,
  padding_right : Int,
  padding_top : Int,
  padding_bottom : Int,
  alignment : AlignmentHorizontal,
) -> Array[String] {
  let lines = []
  for i = 0; i < padding_top; i = i + 1 {
    ignore(i)
    lines.push(
      render_row_line(
        borders, widths, row, count_columns, padding_left, padding_right, alignment,
        true,
      ),
    )
  }
  lines.push(
    render_row_line(
      borders, widths, row, count_columns, padding_left, padding_right, alignment,
      false,
    ),
  )
  for i = 0; i < padding_bottom; i = i + 1 {
    ignore(i)
    lines.push(
      render_row_line(
        borders, widths, row, count_columns, padding_left, padding_right, alignment,
        true,
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
  let padding_left = self.config.padding_left()
  let padding_right = self.config.padding_right()
  let padding_top = self.config.padding_top()
  let padding_bottom = self.config.padding_bottom()
  let alignment = self.config.alignment()
  for row_index = 0; row_index < rows.length(); row_index = row_index + 1 {
    render_row(
      borders,
      widths,
      rows[row_index],
      self.records.count_columns(),
      padding_left,
      padding_right,
      padding_top,
      padding_bottom,
      alignment,
    ).each(line => lines.push(line))
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
