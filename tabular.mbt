///|
pub struct Style {
  borders : @papergrid.Borders
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
pub struct Builder {
  rows : Array[Array[String]]
}

///|
pub fn Builder::default() -> Builder {
  { rows: [] }
}

///|
pub fn Builder::push_record(self : Builder, row : Array[String]) -> Unit {
  self.rows.push(row)
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
pub fn Builder::build(self : Builder) -> Table {
  Table::from_rows(self.rows)
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
pub fn Table::to_string(self : Table) -> String {
  let records = @papergrid.IterRecords::new(self.rows)
  let dims = @papergrid.IterGridDimension::default()
  dims.estimate(records, self.config)
  let grid = @papergrid.IterGrid::new(records, self.config, dims)
  grid.to_string()
}
