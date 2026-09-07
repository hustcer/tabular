///|
/// Select ordered groups of cells. Each group is a destination entity for Dup.
pub(open) trait Object {
  fn cells(Self, Int, Int) -> Array[Array[(Int, Int)]]
}

///|
pub impl Object for Rows with fn cells(self, row_count, col_count) {
  resolve_rows(self, row_count).map(row => {
    Array::makei(col_count, col => (row, col))
  })
}

///|
pub impl Object for Cols with fn cells(self, row_count, col_count) {
  resolve_cols(self, col_count).map(col => {
    Array::makei(row_count, row => (row, col))
  })
}

///|
pub impl Object for Cell with fn cells(self, row_count, col_count) {
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
pub impl Object for Segment with fn cells(self, row_count, col_count) {
  match (self.kind, self.skip_n, self.step_n) {
    (All, 0, 1) => [resolve_segment_cells(self, row_count, col_count)]
    (RowsOnly(rows), 0, 1) => Object::cells(rows, row_count, col_count)
    (ColsOnly(cols), 0, 1) => Object::cells(cols, row_count, col_count)
    _ => resolve_segment_cells(self, row_count, col_count).map(cell => [cell])
  }
}
