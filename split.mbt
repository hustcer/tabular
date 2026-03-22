///|
priv enum SplitDirection {
  SplitCol
  SplitRow
}

///|
priv enum SplitBehavior {
  SplitConcat
  SplitZip
}

///|
priv enum SplitDisplay {
  SplitClean
  SplitRetain
} derive(Eq)

///|
pub struct Split {
  priv direction : SplitDirection
  priv mut behavior : SplitBehavior
  priv mut display : SplitDisplay
  priv index : Int
}

///|
pub fn Split::col(index : Int) -> Split {
  { direction: SplitCol, behavior: SplitZip, display: SplitClean, index }
}

///|
pub fn Split::row(index : Int) -> Split {
  { direction: SplitRow, behavior: SplitZip, display: SplitClean, index }
}

///|
pub fn Split::concat(self : Split) -> Split {
  self.behavior = SplitConcat
  self
}

///|
pub fn Split::zip(self : Split) -> Split {
  self.behavior = SplitZip
  self
}

///|
pub fn Split::clean(self : Split) -> Split {
  self.display = SplitClean
  self
}

///|
pub fn Split::retain(self : Split) -> Split {
  self.display = SplitRetain
  self
}

///|
fn split_ceil_div(x : Int, y : Int) -> Int {
  1 + (x - 1) / y
}

///|
fn split_push_row(rows : Array[Array[String]]) -> Unit {
  let col_count = if rows.length() > 0 { rows[0].length() } else { 0 }
  rows.push(Array::make(col_count, ""))
}

///|
fn split_insert_row(rows : Array[Array[String]], index : Int) -> Unit {
  let col_count = if rows.length() > 0 { rows[0].length() } else { 0 }
  rows.insert(index, Array::make(col_count, ""))
}

///|
fn split_push_col(rows : Array[Array[String]]) -> Unit {
  for i in 0..<rows.length() {
    rows[i].push("")
  }
}

///|
fn split_insert_col(rows : Array[Array[String]], col : Int) -> Unit {
  for i in 0..<rows.length() {
    rows[i].insert(col, "")
  }
}

///|
fn split_remove_row(rows : Array[Array[String]], index : Int) -> Unit {
  rows.remove(index) |> ignore
}

///|
fn split_remove_col(rows : Array[Array[String]], col : Int) -> Unit {
  for i in 0..<rows.length() {
    if col < rows[i].length() {
      rows[i].remove(col) |> ignore
    }
  }
}

///|
fn split_format_position(
  direction : SplitDirection,
  primary_index : Int,
  secondary_index : Int,
) -> (Int, Int) {
  match direction {
    SplitCol => (secondary_index, primary_index)
    SplitRow => (primary_index, secondary_index)
  }
}

///|
fn split_copy_section(
  rows : Array[Array[String]],
  section_length : Int,
  section_index : Int,
  primary_length : Int,
  from_secondary_index : Int,
  to_secondary_index : Int,
  direction : SplitDirection,
) -> Bool {
  let mut section_is_empty = true
  for to_primary_index = 0
      to_primary_index < section_length
      to_primary_index = to_primary_index + 1 {
    let from_primary_index = to_primary_index + section_index * section_length
    if from_primary_index < primary_length {
      let (from_row, from_col) = split_format_position(
        direction, from_primary_index, from_secondary_index,
      )
      if from_row < rows.length() && from_col < rows[from_row].length() {
        if rows[from_row][from_col] != "" {
          section_is_empty = false
        }
        let (to_row, to_col) = split_format_position(
          direction, to_primary_index, to_secondary_index,
        )
        if to_row < rows.length() && to_col < rows[to_row].length() {
          // Swap the cells
          let tmp = rows[from_row][from_col]
          rows[from_row][from_col] = rows[to_row][to_col]
          rows[to_row][to_col] = tmp
        }
      }
    }
  }
  section_is_empty
}
