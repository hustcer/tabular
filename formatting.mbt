///|
/// Trim whitespace when rendering, without changing records or dimensions.
pub(all) enum TrimStrategy {
  Vertical
  Horizontal
  Both
  None
} derive(Eq, Debug)

///|
pub impl CellOption for TrimStrategy with fn change(self, table, entity) {
  match self {
    Vertical => table.config.set_trim_vertical(entity, true)
    Horizontal => table.config.set_trim_horizontal(entity, true)
    Both => {
      table.config.set_trim_horizontal(entity, true)
      table.config.set_trim_vertical(entity, true)
    }
    None => {
      table.config.set_trim_horizontal(entity, false)
      table.config.set_trim_vertical(entity, false)
    }
  }
}

///|
pub impl TableOption for TrimStrategy with fn change(self, table) {
  CellOption::change(self, table, Entity::Global)
}

///|
pub impl TableOption for TrimStrategy with fn hint_change(_self) {
  None
}

///|
/// Align each cell as one block (the default), or align its lines separately.
pub(all) enum AlignmentStrategy {
  PerCell
  PerLine
} derive(Eq, Debug)

///|
pub impl CellOption for AlignmentStrategy with fn change(self, table, entity) {
  table.config.set_line_alignment(entity, self == PerLine)
}

///|
pub impl TableOption for AlignmentStrategy with fn change(self, table) {
  CellOption::change(self, table, Entity::Global)
}

///|
pub impl TableOption for AlignmentStrategy with fn hint_change(_self) {
  None
}

///|
/// Fill the space used to align text, independently from cell padding.
pub struct Justification {
  priv fill : Char
  priv ansi : Color?
}

///|
pub fn Justification::default() -> Justification {
  Justification::new(' ')
}

///|
pub fn Justification::new(fill : Char) -> Justification {
  { fill, ansi: None, }
}

///|
pub fn Justification::colored(fill : Char, color : Color) -> Justification {
  { fill, ansi: Some(color), }
}

///|
pub fn Justification::color(
  self : Justification,
  color : Color,
) -> Justification {
  { ..self, ansi: Some(color), }
}

///|
pub impl CellOption for Justification with fn change(self, table, entity) {
  match self.ansi {
    Some(color) =>
      table.config.set_justification(
        entity,
        self.fill,
        color=color.to_ansi_buf(),
      )
    None => table.config.set_justification(entity, self.fill)
  }
}

///|
pub impl TableOption for Justification with fn change(self, table) {
  CellOption::change(self, table, Entity::Global)
}

///|
pub impl CellOption for Justification with fn hint_change(_self) {
  None
}

///|
pub impl TableOption for Justification with fn hint_change(_self) {
  None
}
