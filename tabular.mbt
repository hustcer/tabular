///|
pub struct Style {
  borders : @papergrid.Borders
  horizontal_lines : @papergrid.HorizontalLines
}

///|
pub enum Alignment {
  Left
  Right
  Center
}

///|
pub enum VerticalAlignment {
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
pub struct Rows {
  start : Int
  end_ : Int
  skip_n : Int
  step_n : Int
  exclude_start : Int
  exclude_end : Int
}

///|
pub struct Columns {
  start : Int
  end_ : Int
  skip_n : Int
  step_n : Int
  exclude_start : Int
  exclude_end : Int
}

///|
pub struct Cell {
  row : Int
  column : Int
}

///|
pub enum Segment {
  All(Int, Int)
  Range(Int, Int, Int, Int, Int, Int)
  RowsOnly(Rows, Int, Int)
  ColumnsOnly(Columns, Int, Int)
  CellOnly(Cell, Int, Int)
  Cross(Rows, Columns, Int, Int)
  InverseRows(Rows, Int, Int)
  InverseColumns(Columns, Int, Int)
  InverseCell(Cell, Int, Int)
  Union2(Segment, Segment, Int, Int)
  Diff2(Segment, Segment, Int, Int)
}

///|
pub enum Setting {
  Align(Alignment)
  VAlign(VerticalAlignment)
  Pad(Padding)
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
  {
    borders: @papergrid.Borders::ascii(),
    horizontal_lines: @papergrid.HorizontalLines::all(),
  }
}

///|
pub fn Style::modern() -> Style {
  {
    borders: @papergrid.Borders::modern(),
    horizontal_lines: @papergrid.HorizontalLines::all(),
  }
}

///|
pub fn Style::rounded() -> Style {
  {
    borders: @papergrid.Borders::rounded(),
    horizontal_lines: @papergrid.HorizontalLines::all(),
  }
}

///|
pub fn Style::markdown() -> Style {
  {
    borders: @papergrid.Borders::markdown(),
    horizontal_lines: @papergrid.HorizontalLines::header_only(),
  }
}

///|
pub fn Style::psql() -> Style {
  {
    borders: @papergrid.Borders::psql(),
    horizontal_lines: @papergrid.HorizontalLines::header_only(),
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
pub fn VerticalAlignment::top() -> VerticalAlignment {
  Top
}

///|
pub fn VerticalAlignment::bottom() -> VerticalAlignment {
  Bottom
}

///|
pub fn VerticalAlignment::center() -> VerticalAlignment {
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
pub fn Rows::new(start : Int, end_ : Int) -> Rows {
  { start, end_, skip_n: 0, step_n: 1, exclude_start: 0, exclude_end: 0 }
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
pub fn Rows::intersect(self : Rows, columns : Columns) -> Segment {
  Cross(self, columns, 0, 1)
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
  }
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
  }
}

///|
pub fn Columns::new(start : Int, end_ : Int) -> Columns {
  { start, end_, skip_n: 0, step_n: 1, exclude_start: 0, exclude_end: 0 }
}

///|
pub fn Columns::first() -> Columns {
  Columns::new(0, 1)
}

///|
pub fn Columns::one(index : Int) -> Columns {
  Columns::new(index, index + 1)
}

///|
pub fn Columns::last() -> Columns {
  Columns::new(-2, 0)
}

///|
pub fn Columns::last_offset(offset : Int) -> Columns {
  Columns::new(-2 - offset, 0)
}

///|
pub fn Columns::all() -> Columns {
  Columns::new(0, -1)
}

///|
pub fn Columns::intersect(self : Columns, rows : Rows) -> Segment {
  Cross(rows, self, 0, 1)
}

///|
pub fn Columns::as_segment(self : Columns) -> Segment {
  ColumnsOnly(self, 0, 1)
}

///|
pub fn Columns::inverse(self : Columns) -> Segment {
  InverseColumns(self, 0, 1)
}

///|
pub fn Columns::not(self : Columns, other : Columns) -> Columns {
  {
    start: self.start,
    end_: self.end_,
    skip_n: self.skip_n,
    step_n: self.step_n,
    exclude_start: other.start,
    exclude_end: other.end_,
  }
}

///|
pub fn Columns::skip(self : Columns, count : Int) -> Columns {
  {
    start: self.start,
    end_: self.end_,
    skip_n: count,
    step_n: self.step_n,
    exclude_start: self.exclude_start,
    exclude_end: self.exclude_end,
  }
}

///|
pub fn Columns::step_by(self : Columns, step : Int) -> Columns {
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
  }
}

///|
pub fn Segment::all() -> Segment {
  All(0, 1)
}

///|
pub fn Cell::new(row : Int, column : Int) -> Cell {
  { row, column }
}

///|
pub fn Cell::as_segment(self : Cell) -> Segment {
  CellOnly(self, 0, 1)
}

///|
pub fn Cell::inverse(self : Cell) -> Segment {
  InverseCell(self, 0, 1)
}

///|
pub fn Segment::new(
  row_start : Int,
  row_end : Int,
  column_start : Int,
  column_end : Int,
) -> Segment {
  Range(row_start, row_end, column_start, column_end, 0, 1)
}

///|
pub fn Segment::and_(self : Segment, other : Segment) -> Segment {
  Union2(self, other, 0, 1)
}

///|
pub fn Segment::not_(self : Segment, other : Segment) -> Segment {
  Diff2(self, other, 0, 1)
}

///|
pub fn Segment::skip(self : Segment, count : Int) -> Segment {
  match self {
    All(_, step) => All(count, step)
    Range(row_start, row_end, column_start, column_end, _, step) =>
      Range(row_start, row_end, column_start, column_end, count, step)
    RowsOnly(rows, _, step) => RowsOnly(rows, count, step)
    ColumnsOnly(columns, _, step) => ColumnsOnly(columns, count, step)
    CellOnly(cell, _, step) => CellOnly(cell, count, step)
    Cross(rows, columns, _, step) => Cross(rows, columns, count, step)
    InverseRows(rows, _, step) => InverseRows(rows, count, step)
    InverseColumns(columns, _, step) => InverseColumns(columns, count, step)
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
    Range(row_start, row_end, column_start, column_end, skip_n, _) =>
      Range(row_start, row_end, column_start, column_end, skip_n, next_step)
    RowsOnly(rows, skip_n, _) => RowsOnly(rows, skip_n, next_step)
    ColumnsOnly(columns, skip_n, _) => ColumnsOnly(columns, skip_n, next_step)
    CellOnly(cell, skip_n, _) => CellOnly(cell, skip_n, next_step)
    Cross(rows, columns, skip_n, _) => Cross(rows, columns, skip_n, next_step)
    InverseRows(rows, skip_n, _) => InverseRows(rows, skip_n, next_step)
    InverseColumns(columns, skip_n, _) =>
      InverseColumns(columns, skip_n, next_step)
    InverseCell(cell, skip_n, _) => InverseCell(cell, skip_n, next_step)
    Union2(lhs, rhs, skip_n, _) => Union2(lhs, rhs, skip_n, next_step)
    Diff2(lhs, rhs, skip_n, _) => Diff2(lhs, rhs, skip_n, next_step)
  }
}

///|
pub fn Setting::alignment(alignment : Alignment) -> Setting {
  Align(alignment)
}

///|
pub fn Setting::vertical_alignment(alignment : VerticalAlignment) -> Setting {
  VAlign(alignment)
}

///|
pub fn Setting::padding(padding : Padding) -> Setting {
  Pad(padding)
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
fn convert_vertical_alignment(
  alignment : VerticalAlignment,
) -> @papergrid.AlignmentVertical {
  match alignment {
    Top => @papergrid.AlignmentVertical::top()
    Bottom => @papergrid.AlignmentVertical::bottom()
    Center => @papergrid.AlignmentVertical::center()
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
  resolve_indexes(
    rows.start,
    rows.end_,
    count,
    rows.exclude_start,
    rows.exclude_end,
    rows.skip_n,
    rows.step_n,
  )
}

///|
fn resolve_columns(columns : Columns, count : Int) -> Array[Int] {
  resolve_indexes(
    columns.start,
    columns.end_,
    count,
    columns.exclude_start,
    columns.exclude_end,
    columns.skip_n,
    columns.step_n,
  )
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
fn resolve_segment_cells(
  segment : Segment,
  row_count : Int,
  column_count : Int,
) -> Array[(Int, Int)] {
  let result = []
  let (row_start, row_end, column_start, column_end, skip_n, step_n) = match
    segment {
    All(skip_n, step_n) => (0, row_count, 0, column_count, skip_n, step_n)
    Range(row_start, row_end, column_start, column_end, skip_n, step_n) =>
      (
        clamp_start(row_start),
        clamp_end(row_end, row_count),
        clamp_start(column_start),
        clamp_end(column_end, column_count),
        skip_n,
        step_n,
      )
    RowsOnly(rows, skip_n, step_n) => {
      let row_indexes = resolve_rows(rows, row_count)
      let cells = []
      row_indexes.each(row => {
        for column = 0; column < column_count; column = column + 1 {
          cells.push((row, column))
        }
      })
      return apply_skip_step_to_cells(cells, skip_n, step_n)
    }
    ColumnsOnly(columns, skip_n, step_n) => {
      let column_indexes = resolve_columns(columns, column_count)
      let cells = []
      for row = 0; row < row_count; row = row + 1 {
        column_indexes.each(column => cells.push((row, column)))
      }
      return apply_skip_step_to_cells(cells, skip_n, step_n)
    }
    CellOnly(cell, skip_n, step_n) => {
      let cells = if cell.row >= 0 &&
        cell.row < row_count &&
        cell.column >= 0 &&
        cell.column < column_count {
        [(cell.row, cell.column)]
      } else {
        []
      }
      return apply_skip_step_to_cells(cells, skip_n, step_n)
    }
    Cross(rows, columns, skip_n, step_n) => {
      let row_indexes = resolve_rows(rows, row_count)
      let column_indexes = resolve_columns(columns, column_count)
      let cells = []
      row_indexes.each(row => {
        column_indexes.each(column => cells.push((row, column)))
      })
      return apply_skip_step_to_cells(cells, skip_n, step_n)
    }
    InverseRows(rows, skip_n, step_n) => {
      let excluded = resolve_rows(rows, row_count)
      let cells = []
      for row = 0; row < row_count; row = row + 1 {
        if excluded.contains(row) {
          continue
        }
        for column = 0; column < column_count; column = column + 1 {
          cells.push((row, column))
        }
      }
      return apply_skip_step_to_cells(cells, skip_n, step_n)
    }
    InverseColumns(columns, skip_n, step_n) => {
      let excluded = resolve_columns(columns, column_count)
      let cells = []
      for row = 0; row < row_count; row = row + 1 {
        for column = 0; column < column_count; column = column + 1 {
          if excluded.contains(column) {
            continue
          }
          cells.push((row, column))
        }
      }
      return apply_skip_step_to_cells(cells, skip_n, step_n)
    }
    InverseCell(cell, skip_n, step_n) => {
      let cells = []
      for row = 0; row < row_count; row = row + 1 {
        for column = 0; column < column_count; column = column + 1 {
          if row == cell.row && column == cell.column {
            continue
          }
          cells.push((row, column))
        }
      }
      return apply_skip_step_to_cells(cells, skip_n, step_n)
    }
    Union2(lhs, rhs, skip_n, step_n) => {
      let lhs_cells = resolve_segment_cells(lhs, row_count, column_count)
      let rhs_cells = resolve_segment_cells(rhs, row_count, column_count)
      return apply_skip_step_to_cells(
        unique_cells(lhs_cells + rhs_cells),
        skip_n,
        step_n,
      )
    }
    Diff2(lhs, rhs, skip_n, step_n) => {
      let lhs_cells = resolve_segment_cells(lhs, row_count, column_count)
      let rhs_cells = resolve_segment_cells(rhs, row_count, column_count)
      let cells = []
      lhs_cells.each(cell => if !rhs_cells.contains(cell) { cells.push(cell) })
      return apply_skip_step_to_cells(unique_cells(cells), skip_n, step_n)
    }
  }
  let mut seen = 0
  for row = row_start; row < row_end; row = row + 1 {
    for column = column_start; column < column_end; column = column + 1 {
      if seen < skip_n {
        seen = seen + 1
        continue
      }
      if step_n <= 1 || (seen - skip_n) % step_n == 0 {
        result.push((row, column))
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
    Align(alignment) =>
      config.set_alignment_for_rows(row, row + 1, convert_alignment(alignment))
    VAlign(alignment) =>
      config.set_vertical_alignment_for_rows(
        row,
        row + 1,
        convert_vertical_alignment(alignment),
      )
    Pad(padding) =>
      config.set_padding_for_rows(
        row,
        row + 1,
        padding.left,
        padding.right,
        padding.top,
        padding.bottom,
      )
  }
}

///|
fn apply_setting_to_column(
  config : @papergrid.SpannedConfig,
  column : Int,
  setting : Setting,
) -> Unit {
  match setting {
    Align(alignment) =>
      config.set_alignment_for_columns(
        column,
        column + 1,
        convert_alignment(alignment),
      )
    VAlign(alignment) =>
      config.set_vertical_alignment_for_columns(
        column,
        column + 1,
        convert_vertical_alignment(alignment),
      )
    Pad(padding) =>
      config.set_padding_for_columns(
        column,
        column + 1,
        padding.left,
        padding.right,
        padding.top,
        padding.bottom,
      )
  }
}

///|
fn apply_setting_to_cell(
  config : @papergrid.SpannedConfig,
  row : Int,
  column : Int,
  setting : Setting,
) -> Unit {
  match setting {
    Align(alignment) =>
      config.set_alignment_for_cell(row, column, convert_alignment(alignment))
    VAlign(alignment) =>
      config.set_vertical_alignment_for_cell(
        row,
        column,
        convert_vertical_alignment(alignment),
      )
    Pad(padding) =>
      config.set_padding_for_cell(
        row,
        column,
        padding.left,
        padding.right,
        padding.top,
        padding.bottom,
      )
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
  self.config.set_horizontal_lines(style.horizontal_lines())
  self
}

///|
pub fn Table::set_alignment(self : Table, alignment : Alignment) -> Table {
  self.config.set_alignment(convert_alignment(alignment))
  self
}

///|
pub fn Table::set_vertical_alignment(
  self : Table,
  alignment : VerticalAlignment,
) -> Table {
  self.config.set_vertical_alignment(convert_vertical_alignment(alignment))
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
  resolve_rows(rows, self.rows.length()).each(row => {
    apply_setting_to_row(self.config, row, setting)
  })
  self
}

///|
pub fn Table::modify_columns(
  self : Table,
  columns : Columns,
  setting : Setting,
) -> Table {
  let column_count = @papergrid.IterRecords::new(self.rows).count_columns()
  resolve_columns(columns, column_count).each(column => {
    apply_setting_to_column(self.config, column, setting)
  })
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
        Align(alignment) =>
          self.config.set_alignment_for_all(convert_alignment(alignment))
        VAlign(alignment) =>
          self.config.set_vertical_alignment_for_all(
            convert_vertical_alignment(alignment),
          )
        Pad(padding) =>
          self.config.set_padding_for_all(
            padding.left,
            padding.right,
            padding.top,
            padding.bottom,
          )
      }
    _ => {
      let column_count = @papergrid.IterRecords::new(self.rows).count_columns()
      resolve_segment_cells(segment, self.rows.length(), column_count).each(cell => {
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
  apply_setting_to_cell(self.config, cell.row, cell.column, setting)
  self
}
