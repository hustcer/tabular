///|
/// Rotate the records while keeping formatting attached to table coordinates.
/// `Top` and `Bottom` both reverse the row order, as in tabled.
pub(all) enum Rotate {
  Left
  Right
  Top
  Bottom
} derive(Eq, Debug)

///|
/// Rotate table contents by a quarter turn or reverse the row order.
///
/// ```mbt check
/// test {
///   let table = Table::from_rows([["a", "b"], ["c", "d"]])
///   table.rotate(Rotate::Left) |> ignore
///   assert_eq(table.rows, [["b", "d"], ["a", "c"]])
/// }
/// ```
pub fn Table::rotate(self : Table, rotation : Rotate) -> Table {
  let records = @papergrid.IterRecords::new(self.rows)
  let row_count = records.count_rows()
  let col_count = records.count_cols()
  self.rows = match rotation {
    Left =>
      Array::makei(col_count, row => {
        Array::makei(row_count, col => {
          records.get_cell(col, col_count - row - 1)
        })
      })
    Right =>
      Array::makei(col_count, row => {
        Array::makei(row_count, col => {
          records.get_cell(row_count - col - 1, row)
        })
      })
    Top | Bottom =>
      Array::makei(row_count, row => {
        Array::makei(col_count, col => {
          records.get_cell(row_count - row - 1, col)
        })
      })
  }
  self.finish_legacy_change()
}
