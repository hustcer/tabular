///|
/// Append another table's records, using the first table's configuration.
pub struct Concat {
  priv table : Table
  priv horizontal : Bool
  priv empty_cell : String
}

///|
/// Append columns from another table.
pub fn Concat::horizontal(table : Table) -> Concat {
  { table, horizontal: true, empty_cell: "", }
}

///|
/// Append rows from another table.
pub fn Concat::vertical(table : Table) -> Concat {
  { table, horizontal: false, empty_cell: "", }
}

///|
/// Fill the first table's newly introduced rows (horizontal concatenation)
/// or columns (vertical concatenation). Other missing cells remain empty.
pub fn Concat::default_cell(self : Concat, text : String) -> Concat {
  { ..self, empty_cell: text, }
}

///|
/// Concatenate records, keeping the receiving table's style and cell settings.
///
/// ```mbt check
/// test {
///   let table = Table::from_rows([["a"]])
///   let other = Table::from_rows([["b"], ["c"]])
///   table.concat(Concat::horizontal(other).default_cell("?")) |> ignore
///   assert_eq(table.rows, [["a", "b"], ["?", "c"]])
/// }
/// ```
pub fn Table::concat(self : Table, concat : Concat) -> Table {
  let lhs = @papergrid.IterRecords::new(self.rows)
  let rhs = @papergrid.IterRecords::new(concat.table.rows)
  let left_rows = lhs.count_rows()
  let left_cols = lhs.count_cols()
  let right_rows = rhs.count_rows()
  let right_cols = rhs.count_cols()
  self.rows = if concat.horizontal {
    Array::makei(Int::max(left_rows, right_rows), row => {
      Array::makei(left_cols + right_cols, col => {
        if col >= left_cols && row < right_rows {
          rhs.get_cell(row, col - left_cols)
        } else if row >= left_rows {
          concat.empty_cell
        } else if col < left_cols {
          lhs.get_cell(row, col)
        } else {
          ""
        }
      })
    })
  } else {
    Array::makei(left_rows + right_rows, row => {
      Array::makei(Int::max(left_cols, right_cols), col => {
        if row >= left_rows && col < right_cols {
          rhs.get_cell(row - left_rows, col)
        } else if col >= left_cols {
          concat.empty_cell
        } else if row < left_rows {
          lhs.get_cell(row, col)
        } else {
          ""
        }
      })
    })
  }
  self
}
