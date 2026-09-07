///|
/// Horizontal or vertical alignment, matching tabled's unified Alignment API.
pub enum Alignment {
  Horizontal(Align)
  Vertical(VAlign)
}

///|
pub fn Alignment::left() -> Alignment {
  Horizontal(Align::left())
}

///|
pub fn Alignment::right() -> Alignment {
  Horizontal(Align::right())
}

///|
pub fn Alignment::center() -> Alignment {
  Horizontal(Align::center())
}

///|
pub fn Alignment::top() -> Alignment {
  Vertical(VAlign::top())
}

///|
pub fn Alignment::bottom() -> Alignment {
  Vertical(VAlign::bottom())
}

///|
pub fn Alignment::center_vertical() -> Alignment {
  Vertical(VAlign::center())
}

///|
pub fn Alignment::from_horizontal(align : Align) -> Alignment {
  Horizontal(align)
}

///|
pub fn Alignment::from_vertical(align : VAlign) -> Alignment {
  Vertical(align)
}

///|
pub fn Alignment::as_horizontal(self : Alignment) -> Align? {
  match self {
    Horizontal(align) => Some(align)
    _ => None
  }
}

///|
pub fn Alignment::as_vertical(self : Alignment) -> VAlign? {
  match self {
    Vertical(align) => Some(align)
    _ => None
  }
}

///|
pub impl CellOption for Alignment with fn change(self, table, entity) {
  match self {
    Horizontal(align) =>
      CellOption::change(Setting::align(align), table, entity)
    Vertical(align) => CellOption::change(Setting::valign(align), table, entity)
  }
}

///|
pub impl TableOption for Alignment with fn change(self, table) {
  CellOption::change(self, table, Entity::Global)
}

///|
pub impl TableOption for Alignment with fn hint_change(_self) {
  None
}
