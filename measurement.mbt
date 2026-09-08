///|
/// The dimension being measured. This replaces Rust's trait type parameter.
pub(all) enum Attribute {
  Width
  Height
} derive(Eq, Debug)

///|
/// Compute a width or height from the table's records and configuration.
/// MoonBit traits do not accept type parameters, so Attribute selects the axis.
///
/// ```mbt check
/// test {
///   let table = Table::from_rows([["abcd", "x"]])
///   assert_eq(Measurement::measure(Percent::new(50), table, Attribute::Width), 6)
///   assert_eq(Measurement::measure(Max::new(), table, Attribute::Width), 4)
/// }
/// ```
pub(open) trait Measurement {
  fn measure(Self, Table, Attribute) -> Int
}

///|
pub impl Measurement for Int with fn measure(self, _table, _attribute) {
  Int::max(0, self)
}

///|
pub(all) struct Max {} derive(Eq, Debug)

///|
pub fn Max::new() -> Max {
  Max::{ }
}

///|
pub fn Max::default() -> Max {
  Max::new()
}

///|
pub(all) struct Min {} derive(Eq, Debug)

///|
pub fn Min::new() -> Min {
  Min::{ }
}

///|
pub fn Min::default() -> Min {
  Min::new()
}

///|
pub(all) struct Percent(Int) derive(Eq, Debug)

///|
pub fn Percent::new(value : Int) -> Percent {
  Percent(Int::max(0, value))
}

///|
fn measure_max_width(table : Table) -> Int {
  let mut width = 0
  for row in table.rows {
    for cell in row {
      width = Int::max(width, @papergrid.get_text_width(cell))
    }
  }
  width
}

///|
fn measure_min_width(table : Table) -> Int {
  let columns = table.count_cols()
  let mut width = 0
  for row in table.rows {
    let mut smallest = if columns == 0 { 0 } else { 0x7fffffff }
    for col in 0..<columns {
      smallest = Int::min(
        smallest,
        @papergrid.get_text_width(row.get(col).unwrap_or("")),
      )
    }
    width = Int::max(width, smallest)
  }
  width
}

///|
fn row_height(row : Array[String], columns : Int) -> Int {
  let mut height = 0
  for col in 0..<columns {
    height = Int::max(
      height,
      @papergrid.count_lines(row.get(col).unwrap_or("")),
    )
  }
  height
}

///|
pub impl Measurement for Max with fn measure(_self, table, attribute) {
  let columns = table.count_cols()
  match attribute {
    Width => measure_max_width(table)
    Height =>
      table.rows.fold(init=0, (height, row) => {
        Int::max(height, row_height(row, columns))
      })
  }
}

///|
pub impl Measurement for Min with fn measure(_self, table, attribute) {
  let columns = table.count_cols()
  match attribute {
    Width => measure_min_width(table)
    Height =>
      if table.rows.is_empty() {
        0
      } else {
        table.rows.fold(init=0x7fffffff, (height, row) => {
          Int::min(height, row_height(row, columns))
        })
      }
  }
}

///|
fn percent_of(total : Int, percent : Int) -> Int {
  let result = total.to_int64() * Int::max(0, percent).to_int64() / 100L
  if result > 0x7fffffffL {
    0x7fffffff
  } else {
    result.to_int()
  }
}

///|
pub impl Measurement for Percent with fn measure(self, table, attribute) {
  let records = @papergrid.IterRecords::new(table.rows)
  let total = match attribute {
    Width => @papergrid.IterGridDimension::total_width(records, table.config)
    Height => @papergrid.IterGridDimension::total_height(records, table.config)
  }
  percent_of(total, self.0)
}
