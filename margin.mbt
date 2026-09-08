///|
/// Outer table spacing. Fill characters are configurable for each side.
pub struct Margin {
  left : Int
  right : Int
  top : Int
  bottom : Int
  fill_left : Char
  fill_right : Char
  fill_top : Char
  fill_bottom : Char
}

///|
pub fn Margin::new(left : Int, right : Int, top : Int, bottom : Int) -> Margin {
  {
    left: Int::max(0, left),
    right: Int::max(0, right),
    top: Int::max(0, top),
    bottom: Int::max(0, bottom),
    fill_left: ' ',
    fill_right: ' ',
    fill_top: ' ',
    fill_bottom: ' ',
  }
}

///|
pub fn Margin::fill(
  self : Margin,
  left : Char,
  right : Char,
  top : Char,
  bottom : Char,
) -> Margin {
  {
    ..self,
    fill_left: left,
    fill_right: right,
    fill_top: top,
    fill_bottom: bottom,
  }
}

///|
pub impl TableOption for Margin with fn change(self, table) {
  table.config.set_margin(
    self.top,
    self.bottom,
    self.left,
    self.right,
    self.fill_top,
    self.fill_bottom,
    self.fill_left,
    self.fill_right,
  )
}
