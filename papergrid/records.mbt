///|
pub struct IterRecords {
  rows : Array[Array[String]]
  count_columns : Int
}

///|
pub fn IterRecords::new(rows : Array[Array[String]]) -> IterRecords {
  let mut count_columns = 0
  rows.each(row => {
    if row.length() > count_columns {
      count_columns = row.length()
    }
  })
  { rows, count_columns }
}

///|
pub fn IterRecords::count_rows(self : IterRecords) -> Int {
  self.rows.length()
}

///|
pub fn IterRecords::count_columns(self : IterRecords) -> Int {
  self.count_columns
}

///|
pub fn IterRecords::get_cell(
  self : IterRecords,
  row : Int,
  column : Int,
) -> String {
  if row < self.rows.length() && column < self.rows[row].length() {
    self.rows[row][column]
  } else {
    ""
  }
}

///|
pub fn IterRecords::rows(self : IterRecords) -> Array[Array[String]] {
  self.rows
}
