///|
pub fn Borders::has_left(self : Borders) -> Bool {
  self.left is Some(_) ||
  self.left_intersection is Some(_) ||
  self.top_left is Some(_) ||
  self.bottom_left is Some(_)
}

///|
pub fn Borders::has_right(self : Borders) -> Bool {
  self.right is Some(_) ||
  self.right_intersection is Some(_) ||
  self.top_right is Some(_) ||
  self.bottom_right is Some(_)
}

///|
pub fn Borders::has_top(self : Borders) -> Bool {
  self.top is Some(_) ||
  self.top_intersection is Some(_) ||
  self.top_left is Some(_) ||
  self.top_right is Some(_)
}

///|
pub fn Borders::has_bottom(self : Borders) -> Bool {
  self.bottom is Some(_) ||
  self.bottom_intersection is Some(_) ||
  self.bottom_left is Some(_) ||
  self.bottom_right is Some(_)
}

///|
pub fn Borders::has_horizontal(self : Borders) -> Bool {
  self.horizontal is Some(_) ||
  self.left_intersection is Some(_) ||
  self.right_intersection is Some(_) ||
  self.intersection is Some(_)
}

///|
pub fn Borders::has_vertical(self : Borders) -> Bool {
  self.vertical is Some(_) ||
  self.top_intersection is Some(_) ||
  self.bottom_intersection is Some(_) ||
  self.intersection is Some(_)
}

///|
pub fn SpannedConfig::has_vertical(
  self : SpannedConfig,
  col : Int,
  columns : Int,
) -> Bool {
  if col < 0 || col > columns {
    return false
  }
  let standard = (col == 0 && self.borders.has_left()) ||
    (col == columns && self.borders.has_right()) ||
    (col > 0 && col < columns && self.borders.has_vertical())
  standard ||
  self.border_vertical.any(entry => entry.1 == col) ||
  self.border_intersection.any(entry => entry.1 == col) ||
  self.custom_horizontal_lines.any(entry => {
    let line = entry.1
    (col == 0 && line.left is Some(_)) ||
    (col == columns && line.right is Some(_)) ||
    (col > 0 && col < columns && line.intersection is Some(_))
  })
}

///|
pub fn SpannedConfig::has_horizontal(
  self : SpannedConfig,
  row : Int,
  rows : Int,
) -> Bool {
  if row < 0 || row > rows {
    return false
  }
  let middle = match self.horizontal_lines {
    All => true
    HeaderOnly => row == 1
    None => false
  }
  let standard = (row == 0 && self.borders.has_top()) ||
    (row == rows && self.borders.has_bottom()) ||
    (row > 0 && row < rows && middle && self.borders.has_horizontal())
  standard ||
  self.border_horizontal.any(entry => entry.0 == row) ||
  self.border_intersection.any(entry => entry.0 == row) ||
  self.custom_horizontal_lines.any(entry => {
    entry.0 == row &&
    (
      entry.1.main is Some(_) ||
      entry.1.left is Some(_) ||
      entry.1.right is Some(_) ||
      entry.1.intersection is Some(_)
    )
  })
}

///|
pub fn SpannedConfig::count_vertical(
  self : SpannedConfig,
  columns : Int,
) -> Int {
  let mut count = 0
  for col in 0..<=columns {
    if self.has_vertical(col, columns) {
      count += 1
    }
  }
  count
}

///|
pub fn SpannedConfig::count_horizontal(self : SpannedConfig, rows : Int) -> Int {
  let mut count = 0
  for row in 0..<=rows {
    if self.has_horizontal(row, rows) {
      count += 1
    }
  }
  count
}
