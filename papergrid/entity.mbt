///|
/// A table region used by configuration and selection APIs.
pub(all) enum Entity {
  Global
  Row(Int)
  Col(Int)
  Cell(Int, Int)
} derive(Eq, Debug)

///|
/// Enumerate valid positions in row-major order within an entity.
pub fn Entity::iter(
  self : Entity,
  row_count : Int,
  col_count : Int,
) -> Iter[(Int, Int)] {
  let row_count = Int::max(0, row_count)
  let col_count = Int::max(0, col_count)
  let (row_start, row_end, col_start, col_end) = match self {
    Global => (0, row_count, 0, col_count)
    Row(row) => {
      guard row >= 0 && row < row_count else { return Iter::empty() }
      (row, row + 1, 0, col_count)
    }
    Col(col) => {
      guard col >= 0 && col < col_count else { return Iter::empty() }
      (0, row_count, col, col + 1)
    }
    Cell(row, col) => {
      guard row >= 0 && row < row_count && col >= 0 && col < col_count else {
        return Iter::empty()
      }
      (row, row + 1, col, col + 1)
    }
  }
  let mut row = row_start
  let mut col = col_start
  Iter::new(() => {
    guard row < row_end && col < col_end else { return None }
    let position = (row, col)
    col += 1
    if col == col_end {
      col = col_start
      row += 1
    }
    Some(position)
  })
}
