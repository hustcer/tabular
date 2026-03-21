///|
pub struct Style {
  borders : @papergrid.Borders
}

///|
pub enum Alignment {
  Left
  Right
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
pub struct Padding {
  left : Int
  right : Int
  top : Int
  bottom : Int
}

///|
pub fn Style::ascii() -> Style {
  { borders: @papergrid.Borders::ascii() }
}

///|
pub fn Style::modern() -> Style {
  { borders: @papergrid.Borders::modern() }
}

///|
pub fn Style::rounded() -> Style {
  { borders: @papergrid.Borders::rounded() }
}

///|
pub fn Style::borders(self : Style) -> @papergrid.Borders {
  self.borders
}

///|
pub fn Alignment::left() -> Alignment {
  Left
}

///|
pub fn Alignment::right() -> Alignment {
  Right
}

///|
pub fn Alignment::center() -> Alignment {
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
pub fn Padding::new(
  left : Int,
  right : Int,
  top : Int,
  bottom : Int,
) -> Padding {
  { left, right, top, bottom }
}

///|
fn convert_alignment(alignment : Alignment) -> @papergrid.AlignmentHorizontal {
  match alignment {
    Left => @papergrid.AlignmentHorizontal::left()
    Right => @papergrid.AlignmentHorizontal::right()
    Center => @papergrid.AlignmentHorizontal::center()
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
pub fn Builder::insert_column(
  self : Builder,
  index : Int,
  column : Array[String],
) -> Unit {
  let row_count = if self.rows.length() > column.length() {
    self.rows.length()
  } else {
    column.length()
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
      if row_index < column.length() {
        column[row_index]
      } else {
        ""
      },
    )
  }
}

///|
pub fn Builder::push_column(self : Builder, column : Array[String]) -> Unit {
  let mut index = 0
  self.rows.each(row => if row.length() > index { index = row.length() })
  self.insert_column(index, column)
}

///|
pub fn Builder::remove_column(self : Builder, index : Int) -> Unit {
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
  let mut max_columns = 0
  self.rows.each(row => {
    if row.length() > max_columns {
      max_columns = row.length()
    }
  })
  if max_columns == 0 {
    return
  }

  let keep = Array::make(max_columns, false)
  self.rows.each(row => {
    for column = 0; column < max_columns; column = column + 1 {
      if column < row.length() && row[column] != "" {
        keep[column] = true
      }
    }
  })

  self.rows.each(row => {
    let next = []
    for column = 0; column < max_columns; column = column + 1 {
      if keep[column] {
        next.push(if column < row.length() { row[column] } else { "" })
      }
    }
    row.clear()
    next.each(value => row.push(value))
  })
}

///|
fn normalize_rows(
  rows : Array[Array[String]],
  empty_cell : String,
) -> Array[Array[String]] {
  let mut max_columns = 0
  rows.each(row => if row.length() > max_columns { max_columns = row.length() })

  rows.map(row => {
    let normalized = []
    for column = 0; column < max_columns; column = column + 1 {
      if column < row.length() {
        normalized.push(row[column])
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
pub struct Table {
  rows : Array[Array[String]]
  config : @papergrid.SpannedConfig
}

///|
pub fn Table::from_rows(rows : Array[Array[String]]) -> Table {
  { rows, config: @papergrid.SpannedConfig::default() }
}

///|
pub fn Table::apply(self : Table, style : Style) -> Table {
  self.config.set_borders(style.borders())
  self
}

///|
pub fn Table::set_alignment(self : Table, alignment : Alignment) -> Table {
  self.config.set_alignment(convert_alignment(alignment))
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
