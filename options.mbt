///|
/// A reusable option that changes table records, layout, or configuration.
pub(open) trait TableOption {
  fn change(Self, Table) -> Unit
  fn hint_change(Self) -> Entity? = _
}

///|
impl TableOption with fn hint_change(_self) {
  Some(Entity::Global)
}

///|
/// A reusable option applied to a cell, row, column, or the entire table.
pub(open) trait CellOption {
  fn change(Self, Table, Entity) -> Unit
  fn hint_change(Self) -> Entity? = _
}

///|
impl CellOption with fn hint_change(_self) {
  Some(Entity::Global)
}

///|
/// Apply any table option. The suffix avoids MoonBit's `with` keyword.
///
/// ```mbt check
/// test {
///   let table = Table::from_rows([["a", "b"]])
///   table.with_(Rotate::Left) |> ignore
///   assert_eq(table.rows, [["b"], ["a"]])
/// }
/// ```
pub fn[T : TableOption] Table::with_(self : Table, option : T) -> Table {
  TableOption::change(option, self)
  self
}

///|
/// Apply a cell option to each entity selected by an object.
pub fn[O : Object, M : CellOption] Table::modify(
  self : Table,
  object : O,
  option : M,
) -> Table {
  for entity in Object::entities(object, self) {
    CellOption::change(option, self, entity)
  }
  self
}

///|
pub impl CellOption for Setting with fn change(self, table, entity) {
  match entity {
    Global => table.modify_segment(Segment::all(), self) |> ignore
    Row(row) => table.modify_rows(Rows::one(row), self) |> ignore
    Col(col) | Column(col) => table.modify_cols(Cols::one(col), self) |> ignore
    Cell(row, col) => table.modify_cell(Cell::new(row, col), self) |> ignore
  }
}

///|
pub impl TableOption for Setting with fn change(self, table) {
  CellOption::change(self, table, Entity::Global)
}

///|
pub impl CellOption for String with fn change(self, table, entity) {
  CellOption::change(Setting::format(Format::value(self)), table, entity)
}

///|
pub impl[T : TableOption] TableOption for Array[T] with fn change(self, table) {
  for option in self {
    TableOption::change(option, table)
  }
}

///|
pub impl[T : CellOption] CellOption for Array[T] with fn change(
  self,
  table,
  entity,
) {
  for option in self {
    CellOption::change(option, table, entity)
  }
}

///|
fn combine_hints(hints : Array[Entity?]) -> Entity? {
  hints.fold(init=None, (result, next) => {
    match (result, next) {
      (None, hint) | (hint, None) => hint
      (Some(first), Some(second)) => Some(combine_entity(first, second))
    }
  })
}

///|
fn combine_entity(first : Entity, second : Entity) -> Entity {
  match (first, second) {
    (Col(a) | Column(a), Col(b) | Column(b)) if a == b => Column(a)
    (Col(a) | Column(a), Cell(_, b)) if a == b => Column(a)
    (Cell(_, a), Col(b) | Column(b)) if a == b => Column(a)
    (Row(a), Row(b)) if a == b => Row(a)
    (Row(a), Cell(b, _)) if a == b => Row(a)
    (Cell(a, _), Row(b)) if a == b => Row(a)
    (Cell(a, b), Cell(c, d)) if a == c && b == d => Cell(a, b)
    _ => Global
  }
}
