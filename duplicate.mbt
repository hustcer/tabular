///|
/// Duplicate an ordered source selection into a destination selection.
pub struct Dup {
  priv dst : &Object
  priv src : &Object
}

///|
/// Source values are collected before any destination is changed.
/// The source cycles independently for each destination entity.
pub fn Dup::new(dst : &Object, src : &Object) -> Dup {
  { dst, src, }
}

///|
/// Copy source contents to selected cells without changing formatting.
///
/// ```mbt check
/// test {
///   let table = Table::from_rows([["a", "b"], ["c", "d"]])
///   table.duplicate(Dup::new(Rows::one(1), Rows::one(0))) |> ignore
///   assert_eq(table.rows, [["a", "b"], ["a", "b"]])
/// }
/// ```
pub fn Table::duplicate(self : Table, dup : Dup) -> Table {
  let records = @papergrid.IterRecords::new(self.rows)
  let row_count = records.count_rows()
  let col_count = records.count_cols()
  let valid = (cell : (Int, Int)) => {
    cell.0 >= 0 && cell.0 < row_count && cell.1 >= 0 && cell.1 < col_count
  }
  let source : Array[String] = []
  for group in dup.src.cells(self) {
    for cell in group {
      if valid(cell) {
        source.push(records.get_cell(cell.0, cell.1))
      }
    }
  }
  guard !source.is_empty() else { return self }
  for group in dup.dst.cells(self) {
    let mut index = 0
    for cell in group {
      if valid(cell) {
        let row = self.rows[cell.0]
        while row.length() <= cell.1 {
          row.push("")
        }
        row[cell.1] = source[index % source.length()]
        index += 1
      }
    }
  }
  self
}
