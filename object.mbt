///|
/// Select ordered groups of cells from a table.
/// Each group is an entity: a row, a column, a cell, or the whole table.
/// Operations such as `Duplicate` restart the source sequence for each group.
pub(open) trait Object {
  fn cells(Self, Table) -> Array[Array[(Int, Int)]]
  fn entities(Self, Table) -> Array[Entity] = _
}

///|
/// Custom objects may provide groups alone; each selected position then has
/// cell scope for configuration. Override `entities` to expose wider scopes.
impl Object with fn entities(self, table) {
  Object::cells(self, table).flatten().map(cell => Entity::Cell(cell.0, cell.1))
}

///|
pub impl Object for Rows with fn entities(self, table) {
  resolve_rows(self, table.count_rows()).map(row => Entity::Row(row))
}

///|
pub impl Object for Cols with fn entities(self, table) {
  resolve_cols(self, table.count_cols()).map(col => Entity::Col(col))
}

///|
pub impl Object for Cell with fn entities(self, table) {
  Object::cells(self, table).flatten().map(cell => Entity::Cell(cell.0, cell.1))
}

///|
pub impl Object for Segment with fn entities(self, table) {
  match (self.kind, self.skip_n, self.step_n) {
    (All, 0, 1) => [Entity::Global]
    (RowsOnly(rows), 0, 1) => Object::entities(rows, table)
    (ColsOnly(cols), 0, 1) => Object::entities(cols, table)
    _ =>
      resolve_segment_cells(self, table.count_rows(), table.count_cols()).map(cell => {
        Entity::Cell(cell.0, cell.1)
      })
  }
}

///|
pub impl Object for Rows with fn cells(self, table) {
  let col_count = table.count_cols()
  resolve_rows(self, table.count_rows()).map(row => {
    Array::makei(col_count, col => (row, col))
  })
}

///|
pub impl Object for Cols with fn cells(self, table) {
  let row_count = table.count_rows()
  resolve_cols(self, table.count_cols()).map(col => {
    Array::makei(row_count, row => (row, col))
  })
}

///|
pub impl Object for Cell with fn cells(self, table) {
  let (row_count, col_count) = table.shape()
  if self.row >= 0 &&
    self.row < row_count &&
    self.col >= 0 &&
    self.col < col_count {
    [[(self.row, self.col)]]
  } else {
    []
  }
}

///|
pub impl Object for (Int, Int) with fn cells(self, table) {
  Object::cells(Cell::new(self.0, self.1), table)
}

///|
pub impl Object for (Int, Int) with fn entities(self, table) {
  Object::entities(Cell::new(self.0, self.1), table)
}

///|
pub impl Object for Segment with fn cells(self, table) {
  let (row_count, col_count) = table.shape()
  match (self.kind, self.skip_n, self.step_n) {
    (All, 0, 1) => [resolve_segment_cells(self, row_count, col_count)]
    (RowsOnly(rows), 0, 1) => Object::cells(rows, table)
    (ColsOnly(cols), 0, 1) => Object::cells(cols, table)
    _ => resolve_segment_cells(self, row_count, col_count).map(cell => [cell])
  }
}

///|
pub impl Object for ByColName with fn entities(self, table) {
  resolve_cols_by_name(table.rows, self).map(col => Entity::Col(col))
}

///|
pub impl Object for ByColName with fn cells(self, table) {
  Object::entities(self, table).map(entity => {
    entity.iter(table.count_rows(), table.count_cols()).to_array()
  })
}
