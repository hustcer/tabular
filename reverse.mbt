///|
pub using @papergrid {type Offset}

///|
/// Reverse a contiguous range of rows or columns.
pub struct Reverse {
  priv columns : Bool
  priv start : Int
  priv end_ : Offset
}

///|
/// Reverse all rows from `start`, including `start`.
pub fn Reverse::rows(start : Int) -> Reverse {
  { columns: false, start, end_: End(0), }
}

///|
/// Reverse all columns from `start`, including `start`.
pub fn Reverse::columns(start : Int) -> Reverse {
  { columns: true, start, end_: End(0), }
}

///|
/// Set the exclusive end using a length (`Start`) or trailing exclusion (`End`).
pub fn Reverse::limit(self : Reverse, limit : Offset) -> Reverse {
  { ..self, end_: limit, }
}

///|
/// Reverse records without moving coordinate-based formatting.
/// Invalid ranges leave the table unchanged.
///
/// ```mbt check
/// test {
///   let table = Table::from_rows([["a"], ["b"], ["c"], ["d"]])
///   table.reverse(Reverse::rows(1).limit(Offset::Start(2))) |> ignore
///   assert_eq(table.rows, [["a"], ["c"], ["b"], ["d"]])
/// }
/// ```
pub fn Table::reverse(self : Table, reverse : Reverse) -> Table {
  let records = @papergrid.IterRecords::new(self.rows)
  let count = if reverse.columns {
    records.count_cols()
  } else {
    records.count_rows()
  }
  let start = reverse.start
  guard start >= 0 && start < count else { return self }
  let end_ = match reverse.end_ {
    Start(length) => {
      guard length >= 0 && length <= count - start else { return self }
      start + length
    }
    End(excluded) => {
      guard excluded >= 0 && excluded <= count else { return self }
      count - excluded
    }
  }
  guard end_ > start else { return self }
  if reverse.columns {
    self.rows = Array::makei(records.count_rows(), row => {
      Array::makei(count, col => {
        let source = if col >= start && col < end_ {
          end_ - 1 - (col - start)
        } else {
          col
        }
        records.get_cell(row, source)
      })
    })
  } else {
    for i in 0..<((end_ - start) / 2) {
      self.rows.swap(start + i, end_ - 1 - i)
    }
  }
  self.finish_legacy_change()
}
