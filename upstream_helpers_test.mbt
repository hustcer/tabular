///|
// Equivalent to tabled/tests/util/matrix.rs::Matrix::new/to_table.
fn upstream_matrix(row_count : Int, col_count : Int) -> @tabular.Table {
  let rows = Array::makei(row_count + 1, row => {
    Array::makei(col_count + 1, col => {
      if row == 0 {
        if col == 0 {
          "N"
        } else {
          "column \{col - 1}"
        }
      } else if col == 0 {
        (row - 1).to_string()
      } else {
        "\{row - 1}-\{col - 1}"
      }
    })
  })
  @tabular.Table::from_rows(rows).set_align(@tabular.Align::center())
}

///|
// Equivalent to Matrix::iter for tuples of i32, including Tabled headers.
fn upstream_int_table(values : Array[Array[Int]]) -> @tabular.Table {
  let rows = [Array::make(values[0].length(), "i32")]
  for row in values {
    rows.push(row.map(value => value.to_string()))
  }
  @tabular.Table::from_rows(rows).set_align(@tabular.Align::center())
}

///|
fn upstream_top_border() -> @tabular.Highlight {
  @tabular.Highlight::new_rows(@tabular.Rows::one(0)).with_border({
    ..@papergrid.CellBorder::empty(),
    top: Some('*'),
  })
}

///|
fn upstream_bottom_border() -> @tabular.Highlight {
  @tabular.Highlight::new_cell(@tabular.Cell::new(0, 2)).with_border({
    ..@papergrid.CellBorder::empty(),
    bottom: Some('*'),
  })
}
