///|
pub struct IterRecords {
  rows : Array[Array[String]]
  count_cols : Int
}

///|
pub fn IterRecords::new(rows : Array[Array[String]]) -> IterRecords {
  let mut count_cols = 0
  rows.each(row => if row.length() > count_cols { count_cols = row.length() })
  { rows, count_cols }
}

///|
pub fn IterRecords::count_rows(self : IterRecords) -> Int {
  self.rows.length()
}

///|
pub fn IterRecords::count_cols(self : IterRecords) -> Int {
  self.count_cols
}

///|
pub fn IterRecords::get_cell(
  self : IterRecords,
  row : Int,
  col : Int,
) -> String {
  if row < self.rows.length() && col < self.rows[row].length() {
    self.rows[row][col]
  } else {
    ""
  }
}

///|
pub fn IterRecords::rows(self : IterRecords) -> Array[Array[String]] {
  self.rows
}
